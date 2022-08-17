import torch

use_cuda = torch.cuda.is_available()

if use_cuda == True:
   print("********************")
   print(" CUDA IS AVAILABLE  ")
   print("********************")
else:
   print("*******************")
   print(" NO CUDA AVAILABLE ")
   PRINT("*******************")
print(use_cuda)
