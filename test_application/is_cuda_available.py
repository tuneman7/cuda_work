import torch

use_cuda = torch.cuda.is_available()
returner = 0
if use_cuda == True:
   print("********************")
   print(" CUDA IS AVAILABLE  ")
   print("********************")
else:
   print("*******************")
   print(" NO CUDA AVAILABLE ")
   print("*******************")
   returner = 1
print(use_cuda)

