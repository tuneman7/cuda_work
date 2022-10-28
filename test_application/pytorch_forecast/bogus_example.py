import torch
import time

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





def main():
    my_device = get_default_device()
    import torch as torch
    my_device = torch.device("cuda:0" if torch.cuda.is_available() else "cpu")
    has_cuda = False
    if torch.cuda.is_available():
        has_cuda = True
        if torch.cuda.device_count() > 1:
            my_device = torch.device("cuda:1" if torch.cuda.is_available() else "cpu")
        else:
            my_device = torch.device("cuda:0" if torch.cuda.is_available() else "cpu")
    print(my_device)
    import time 
    start_time = time.time()




    import os
    import warnings

    warnings.filterwarnings("ignore")  # avoid printing out absolute paths

    import copy
    from pathlib import Path
    import warnings

    import numpy as np
    import pandas as pd
    import pytorch_lightning as pl
    from pytorch_lightning.callbacks import EarlyStopping, LearningRateMonitor
    from pytorch_lightning.loggers import TensorBoardLogger
    import torch

    from pytorch_forecasting import Baseline, TemporalFusionTransformer, TimeSeriesDataSet
    from pytorch_forecasting.data import GroupNormalizer
    from pytorch_forecasting.metrics import SMAPE, PoissonLoss, QuantileLoss
    from pytorch_forecasting.models.temporal_fusion_transformer.tuning import optimize_hyperparameters

    from pytorch_forecasting.data.examples import get_stallion_data

    data = get_stallion_data()

    # add time index
    data["time_idx"] = data["date"].dt.year * 12 + data["date"].dt.month
    data["time_idx"] -= data["time_idx"].min()

    # add additional features
    data["month"] = data.date.dt.month.astype(str).astype("category")  # categories have be strings
    data["log_volume"] = np.log(data.volume + 1e-8)
    data["avg_volume_by_sku"] = data.groupby(["time_idx", "sku"], observed=True).volume.transform("mean")
    data["avg_volume_by_agency"] = data.groupby(["time_idx", "agency"], observed=True).volume.transform("mean")

    # we want to encode special days as one variable and thus need to first reverse one-hot encoding
    special_days = [
        "easter_day",
        "good_friday",
        "new_year",
        "christmas",
        "labor_day",
        "independence_day",
        "revolution_day_memorial",
        "regional_games",
        "fifa_u_17_world_cup",
        "football_gold_cup",
        "beer_capital",
        "music_fest",
    ]
    data[special_days] = data[special_days].apply(lambda x: x.map({0: "-", 1: x.name})).astype("category")

    #print(data.sample(10, random_state=521))


    max_prediction_length = 6
    max_encoder_length = 24
    training_cutoff = data["time_idx"].max() - max_prediction_length

    training = TimeSeriesDataSet(
        data[lambda x: x.time_idx <= training_cutoff],
        time_idx="time_idx",
        target="volume",
        group_ids=["agency", "sku"],
        min_encoder_length=max_encoder_length // 2,  # keep encoder length long (as it is in the validation set)
        max_encoder_length=max_encoder_length,
        min_prediction_length=1,
        max_prediction_length=max_prediction_length,
        static_categoricals=["agency", "sku"],
        static_reals=["avg_population_2017", "avg_yearly_household_income_2017"],
        time_varying_known_categoricals=["special_days", "month"],
        variable_groups={"special_days": special_days},  # group of categorical variables can be treated as one variable
        time_varying_known_reals=["time_idx", "price_regular", "discount_in_percent"],
        time_varying_unknown_categoricals=[],
        time_varying_unknown_reals=[
            "volume",
            "log_volume",
            "industry_volume",
            "soda_volume",
            "avg_max_temp",
            "avg_volume_by_agency",
            "avg_volume_by_sku",
        ],
        target_normalizer=GroupNormalizer(
            groups=["agency", "sku"], transformation="softplus"
        ),  # use softplus and normalize by group
        add_relative_time_idx=True,
        add_target_scales=True,
        add_encoder_length=True,
    )


    # create validation set (predict=True) which means to predict the last max_prediction_length points in time
    # for each series
    validation = TimeSeriesDataSet.from_dataset(training, data, predict=True, stop_randomization=True)

    # create dataloaders for model
    batch_size = 128  # set this between 32 to 128
    train_dataloader =  training.to_dataloader(train=True, batch_size=batch_size, num_workers=0)
    val_dataloader = validation.to_dataloader(train=False, batch_size=batch_size * 10, num_workers=0)


    # calculate baseline mean absolute error, i.e. predict next value as the last available value from the history
    if has_cuda:
        actuals = torch.cat([y for x, (y, weight) in iter(val_dataloader)]).cuda(my_device)
        baseline_predictions = Baseline().predict(val_dataloader).cuda(my_device)
    else:
        actuals = torch.cat([y for x, (y, weight) in iter(val_dataloader)])
        baseline_predictions = Baseline().predict(val_dataloader)

    blm = (actuals - baseline_predictions).abs().mean().item()

    print(blm)

    #Trainer(accelerator='gpu', devices=device(type='cuda', index=1)
    gpus = torch.device(1 if has_cuda else 0)
    # configure network and trainer
    pl.seed_everything(42)



    #find optimal learning rate
    #this no longer works
    # res = trainer.tuner.lr_find(
    #     tft,
    #     train_dataloaders=train_dataloader,
    #     val_dataloaders=val_dataloader,
    #     max_lr=10.0,
    #     min_lr=1e-6,
    # )

    # print(f"suggested learning rate: {res.suggestion()}")
    # fig = res.plot(show=True, suggest=True)
    # fig.show()


    # configure network and trainer
    early_stop_callback = EarlyStopping(monitor="val_loss", min_delta=1e-4, patience=10, verbose=False, mode="min")
    lr_logger = LearningRateMonitor()  # log the learning rate
    logger = TensorBoardLogger("lightning_logs")  # logging results to a tensorboard


    if not has_cuda:
        trainer = pl.Trainer(
            max_epochs=30,
            gpus="auto",
            enable_model_summary=True,
            gradient_clip_val=0.1,
            limit_train_batches=30,  # coment in for training, running valiation every 30 batches
            # fast_dev_run=True,  # comment in to check that networkor dataset has no serious bugs
            callbacks=[lr_logger, early_stop_callback],
            logger=logger,
        )
    else:
        trainer = pl.Trainer(
            max_epochs=30,
            gpus="auto",
            enable_model_summary=True,
            gradient_clip_val=0.1,
            limit_train_batches=30,  # coment in for training, running valiation every 30 batches
            # fast_dev_run=True,  # comment in to check that networkor dataset has no serious bugs
            callbacks=[lr_logger, early_stop_callback],
            logger=logger,
        )    

    tft = TemporalFusionTransformer.from_dataset(
        training,
        learning_rate=0.03,
        hidden_size=16,
        attention_head_size=1,
        dropout=0.1,
        hidden_continuous_size=8,
        output_size=7,  # 7 quantiles by default
        loss=QuantileLoss(),
        log_interval=10,  # uncomment for learning rate finder and otherwise, e.g. to 10 for logging every 10 batches
        reduce_on_plateau_patience=4,
    )

    if has_cuda:
        tft.cuda(my_device)
    print(f"Number of parameters in network: {tft.size()/1e3:.1f}k")

    trainer.fit(
        tft,
        train_dataloaders=train_dataloader,
        val_dataloaders=val_dataloader,
    )

    print("--- %s seconds ---" % (float(time.time()) - float(start_time)))

def run():
    torch.multiprocessing.freeze_support()
    print('loop')

if __name__ == '__main__':
    run()
    main()

