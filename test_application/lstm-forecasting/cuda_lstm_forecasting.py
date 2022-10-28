# %% [markdown]
# # How to use PyTorch LSTMs for time series regression
import torch as torch
device = torch.device("cuda:0" if torch.cuda.is_available() else "cpu")
print(device)
import time 
start_time = time.time()

# %% [markdown]
# # Data

# %% [markdown]
# 1. Download the data from the URLs listed in the docstring in `preprocess_data.py`.
# 2. Run the `preprocess_data.py` script to compile the individual sensors PM2.5 data into
#    a single DataFrame.

# %%
import pandas as pd

df = pd.read_csv("processed_pm25.csv", index_col="created_at")
df

def get_default_device():
    """Pick GPU if available, else CPU"""
    if torch.cuda.is_available():
        return torch.device('cuda')
    else:
        return torch.device('cpu')

def to_device(data, device):
    """Move tensor(s) to chosen device"""
    if isinstance(data, (list,tuple)):
        return [to_device(x, device) for x in data]
    return data.to(device, non_blocking=True)

device = get_default_device()
device


# %%
# import plotly.express as px
# import plotly.graph_objects as go
# import plotly.io as pio
# pio.templates.default = "plotly_white"

# plot_template = dict(
#     layout=go.Layout({
#         "font_size": 18,
#         "xaxis_title_font_size": 24,
#         "yaxis_title_font_size": 24})
# )

# fig = px.line(df, labels=dict(
#     created_at="Date", value="PM2.5 (ug/m3)", variable="Sensor"
# ))
# fig.update_layout(
#   template=plot_template, legend=dict(orientation='h', y=1.02, title_text="")
# )
# fig.show()
# fig.write_image("pm25_data.png", width=1200, height=600)

# # %%
# fig.update_yaxes(range = [0, 60])
# fig.show()
# fig.write_image("pm25_data_zoomed.png", width=1200, height=600)

# %% [markdown]
# ## Create the target variable

# %%
target_sensor = "Austin"
features = list(df.columns.difference([target_sensor]))
#features = features.to(device)
#exit()
forecast_lead = 15
target = f"{target_sensor}_lead{forecast_lead}"

df[target] = df[target_sensor].shift(-forecast_lead)
df = df.iloc[:-forecast_lead]

# %% [markdown]
# ## Create a hold-out test set and preprocess the data

# %%
test_start = "2021-10-10"

df_train = df.loc[:test_start].copy()
df_test = df.loc[test_start:].copy()

print("Test set fraction:", len(df_test) / len(df))

# %% [markdown]
# ## Standardize the features and target, based on the training set

# %%
target_mean = df_train[target].mean()
target_stdev = df_train[target].std()

for c in df_train.columns:
    mean = df_train[c].mean()
    stdev = df_train[c].std()

    df_train[c] = (df_train[c] - mean) / stdev
    df_test[c] = (df_test[c] - mean) / stdev



class DeviceDataLoader():
    """Wrap a dataloader to move data to a device"""
    def __init__(self, dl, device):
        self.dl = dl
        self.device = device
        
    def __iter__(self):
        """Yield a batch of data after moving it to device"""
        for b in self.dl: 
            yield to_device(b, self.device)

    def __len__(self):
        """Number of batches"""
        return len(self.dl)

# %% [markdown]
# ## Create datasets that PyTorch `DataLoader` can work with

# %%
import torch
from torch.utils.data import Dataset

class SequenceDataset(Dataset):
    def __init__(self, dataframe, target, features, sequence_length=5):
        self.features = features
        self.target = target
        self.sequence_length = sequence_length
        self.device = get_default_device()
        print("*"*10)
        print(self.device)
        print("*"*10)
        self.y = to_device(torch.tensor(dataframe[self.target].values).float(),self.device)
        self.X = to_device(torch.tensor(dataframe[self.features].values).float(),self.device)
        # for b in self.y:
        #     yield to_device(b,self.device)
        # for b in self.X:
        #     yield to_device(b,self.device)

    def __len__(self):
        return self.X.shape[0]

    def __getitem__(self, i): 
        if i >= self.sequence_length - 1:
            i_start = i - self.sequence_length + 1
            x = self.X[i_start:(i + 1), :]
        else:
            padding = self.X[0].repeat(self.sequence_length - i - 1, 1)
            x = self.X[0:(i + 1), :]
            x = torch.cat((padding, x), 0)

        return x, self.y[i]

# %%
i = 27
sequence_length = 4

train_dataset = SequenceDataset(
    df_train,
    target=target,
    features=features,
    sequence_length=sequence_length
)

X, y = train_dataset[i]
print(X)

# %%
X, y = train_dataset[i + 1]
print(X)

# %%
print(df_train[features].iloc[(i - sequence_length + 1): (i + 1)])

# %%
from torch.utils.data import DataLoader
torch.manual_seed(99)

train_loader = DeviceDataLoader(DataLoader(train_dataset, batch_size=3, shuffle=True),device)

X, y = next(iter(train_loader))
print(X.shape)
print(X)

# %% [markdown]
# ## Create the datasets and data loaders for real

# %% [markdown]
# Using just 4 time periods to forecast 15 time periods ahead seems challenging, so let's
# use sequences of length 30 (60 minutes) instead.
# 
# The PyTorch `DataLoader` is a very convenient way to iterate through these datasets. For
# the training set we'll shuffle (the rows *within* each training sequence are not
# shuffled, only the order in which we draw those blocks). For the test set, shuffling
# isn't necessary.

# %%
torch.manual_seed(101)

batch_size = 4
sequence_length = 30

train_dataset = SequenceDataset(
    df_train,
    target=target,
    features=features,
    sequence_length=sequence_length
)
test_dataset = SequenceDataset(
    df_test,
    target=target,
    features=features,
    sequence_length=sequence_length
)

train_loader = DeviceDataLoader(DataLoader(train_dataset, batch_size=batch_size, shuffle=True),device)
test_loader = DeviceDataLoader(DataLoader(test_dataset, batch_size=batch_size, shuffle=False),device)

X, y = next(iter(train_loader))

print("Features shape:", X.shape)
print("Target shape:", y.shape)

# %% [markdown]
# # The model and learning algorithm

# %%



from torch import nn



class ShallowRegressionLSTM(nn.Module):
    def __init__(self, num_sensors, hidden_units):
        super().__init__()
        self.num_sensors = num_sensors  # this is the number of features
        self.device = get_default_device()
        self.hidden_units = hidden_units
        self.num_layers = 1

        self.lstm = nn.LSTM(
            input_size=num_sensors,
            hidden_size=hidden_units,
            batch_first=True,
            num_layers=self.num_layers
        )

        self.linear = nn.Linear(in_features=self.hidden_units, out_features=1)

    def forward(self, x):
        batch_size = x.shape[0]
        h0 = to_device(torch.zeros(self.num_layers, batch_size, self.hidden_units).requires_grad_(),device)
        c0 = to_device(torch.zeros(self.num_layers, batch_size, self.hidden_units).requires_grad_(),device)
        
        _, (hn, _) = self.lstm(x, (h0, c0))
        out = self.linear(hn[0]).flatten()  # First dim of Hn is num_layers, which is set to 1 above.

        return out


# %%
learning_rate = 5e-5
num_hidden_units = 16

model = ShallowRegressionLSTM(num_sensors=len(features), hidden_units=num_hidden_units)
to_device(model,device)
loss_function = nn.MSELoss()
to_device(loss_function,device)

optimizer = torch.optim.Adam(model.parameters(), lr=learning_rate)
#to_device(optimizer,device)




# %% [markdown]
# # Train

# %%
def train_model(data_loader, model, loss_function, optimizer):
    num_batches = len(data_loader)
    total_loss = 0
    if torch.cuda.is_available():
        model.cuda()
    model.train()
    
    for X, y in data_loader:
        output = model(X)
        loss = loss_function(output, y)

        optimizer.zero_grad()
        loss.backward()
        optimizer.step()

        total_loss += loss.item()

    avg_loss = total_loss / num_batches
    print(f"Train loss: {avg_loss}")

def test_model(data_loader, model, loss_function):
    
    num_batches = len(data_loader)
    total_loss = 0

    model.eval()
    with torch.no_grad():
        for X, y in data_loader:
            output = to_device(model(X),device)
            total_loss += loss_function(output, y).item()

    avg_loss = total_loss / num_batches
    print(f"Test loss: {avg_loss}")



# %%
print("Untrained test\n--------")
if torch.cuda.is_available():
   model.to(device)
   loss_function.to(device)
test_model(test_loader, model, loss_function)
print()



for ix_epoch in range(2):
    print(f"Epoch {ix_epoch}\n---------")
    train_model(train_loader, model, loss_function, optimizer=optimizer)
    test_model(test_loader, model, loss_function)
    print()

print("--- %s seconds ---" % (float(time.time()) - float(start_time)))
exit()

# %% [markdown]
# # Evaluation

# %%
def predict(data_loader, model):
    """Just like `test_loop` function but keep track of the outputs instead of the loss
    function.
    """
    output = torch.tensor([])
    model.eval()
    with torch.no_grad():
        for X, _ in data_loader:
            y_star = model(X)
            output = torch.cat((output, y_star), 0)
    
    return output

# %%
train_eval_loader = DataLoader(train_dataset, batch_size=batch_size, shuffle=False)

ystar_col = "Model forecast"
df_train[ystar_col] = predict(train_eval_loader, model).numpy()
df_test[ystar_col] = predict(test_loader, model).numpy()

df_out = pd.concat((df_train, df_test))[[target, ystar_col]]

for c in df_out.columns:
    df_out[c] = df_out[c] * target_stdev + target_mean

print(df_out)

# %%
# fig = px.line(df_out, labels={'value': "PM2.5 (ug/m3)", 'created_at': 'Date'})
# fig.add_vline(x=test_start, line_width=4, line_dash="dash")
# fig.add_annotation(xref="paper", x=0.75, yref="paper", y=0.8, text="Test set start", showarrow=False)
# fig.update_layout(
#   template=plot_template, legend=dict(orientation='h', y=1.02, title_text="")
# )
# fig.show()
# fig.write_image("pm25_forecast.png", width=1200, height=600)

