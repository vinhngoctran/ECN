#Created by: Vinh Ngoc Tran (vinhtn@umich.edu)

#==================================================================================================================
## Import dependent libraries#################################################################################

import numpy as np
import numpy, scipy.io
import pywt
import copy
import pandas as pd


### Wavelet transform: function = db5, level = 3 ==========================================================
def Wavelet_Transform(Data, wavefunc='db5', lv=3, m=1, n=3, plot=False):
    # Decomposing
    coeff = pywt.wavedec(Data, wavefunc, mode='sym',
                         level=lv)  # Decomposing by levels，cD is the details coefficient
    sgn = lambda x: 1 if x > 0 else -1 if x < 0 else 0  # sgn function

    # Denoising
    for i in range(m, n + 1):
        cD = coeff[i]
        Tr = np.sqrt(2 * np.log2(len(cD)))
        for j in range(len(cD)):
            if cD[j] >= Tr:
                coeff[i][j] = sgn(cD[j]) * (np.abs(cD[j]) - Tr)
            else:
                coeff[i][j] = 0
    # Reconstructing
    coeffs = {}
    for i in range(len(coeff)):
        coeffs[i] = copy.deepcopy(coeff)
        for j in range(len(coeff)):
            if j != i:
                coeffs[i][j] = np.zeros_like(coeff[j])

    for i in range(len(coeff)):
        coeff[i] = pywt.waverec(coeffs[i], wavefunc)
        if len(coeff[i]) > len(Data):
            coeff[i] = coeff[i][:-1]

    wavelet_variable = np.asarray(coeff)
    wavelet_variable = np.vstack((wavelet_variable))
    wavelet_variable = np.transpose(wavelet_variable)
    return wavelet_variable




#==================================================================================================================
## Transforming dataset #################################################################################
Filename = 'InDat.txt'
df = pd.read_csv(Filename, header=None, delimiter=r"\s+")
DAT = df.values
X_inputs = DAT
X1 = []
input_dim = X_inputs.shape[1]
for n_in in range(input_dim):
    wavelet_variable = Wavelet_Transform(X_inputs[:, n_in])
    if n_in == 0:
        #X1 = X_inputs[:, n_in]
        #X1 = np.column_stack((X1, wavelet_variable))
        X1 = wavelet_variable
    else:
        #X1 = np.column_stack((X1, X_inputs[:, n_in]))
        X1 = np.column_stack((X1, wavelet_variable))
        
# Save results
Filename = 'TransformData.mat'
scipy.io.savemat(Filename, mdict={'X1': X1})  
    