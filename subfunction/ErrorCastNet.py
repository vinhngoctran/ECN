# In[1]: Import Library
import GPy, GPyOpt
import numpy as np
import warnings
warnings.filterwarnings('ignore')
import pandas as pd
from tqdm import tqdm
import tensorflow
from tensorflow import keras
from tensorflow.keras.models import Sequential
from tensorflow.keras.models import Model
from tensorflow.keras.layers import concatenate
from tensorflow.keras.layers import Input
from tensorflow.keras.layers import Dense
from tensorflow.keras.layers import Dropout
from tensorflow.keras.layers import LSTM
from tensorflow.keras.layers import Lambda, Dot, Concatenate, Layer, RepeatVector, Add
from tensorflow.keras.layers import Conv1D, MaxPooling1D
import scipy.io
from keras.layers import Activation,BatchNormalization, Reshape
import keras.backend as K
from keras.layers.core import *
from keras.models import *
#from attention import Attention
from datetime import datetime
import sys	
import os.path
import os
# In[2]: Load Data
idx = "3"
#idx = sys.argv[1]
# In[3]: Functions
# Attention mechanism
debug_flag = int(os.environ.get('KERAS_ATTENTION_DEBUG', 0))
class Attention(object if debug_flag else Layer):
    SCORE_LUONG = 'luong'
    SCORE_BAHDANAU = 'bahdanau'

    def __init__(self, units: int = 128, score: str = 'luong', **kwargs):
        super(Attention, self).__init__(**kwargs)
        if score not in {self.SCORE_LUONG, self.SCORE_BAHDANAU}:
            raise ValueError(f'Possible values for score are: [{self.SCORE_LUONG}] and [{self.SCORE_BAHDANAU}].')
        self.units = units
        self.score = score

    # noinspection PyAttributeOutsideInit
    def build(self, input_shape):
        input_dim = int(input_shape[-1])
        with K.name_scope(self.name if not debug_flag else 'attention'):
            # W in W*h_S.
            if self.score == self.SCORE_LUONG:
                self.luong_w = Dense(input_dim, use_bias=False, name='luong_w')
                # dot : last hidden state H_t and every hidden state H_s.
                self.luong_dot = Dot(axes=[1, 2], name='attention_score')
            else:
                # Dense implements the operation: output = activation(dot(input, kernel) + bias)
                self.bahdanau_v = Dense(1, use_bias=False, name='bahdanau_v')
                self.bahdanau_w1 = Dense(input_dim, use_bias=False, name='bahdanau_w1')
                self.bahdanau_w2 = Dense(input_dim, use_bias=False, name='bahdanau_w2')
                self.bahdanau_repeat = RepeatVector(input_shape[1])
                self.bahdanau_tanh = Activation('tanh', name='bahdanau_tanh')
                self.bahdanau_add = Add()

            self.h_t = Lambda(lambda x: x[:, -1, :], output_shape=(input_dim,), name='last_hidden_state')

            # exp / sum(exp) -> softmax.
            self.softmax_normalizer = Activation('softmax', name='attention_weight')

            # dot : score * every hidden state H_s.
            # dot product. SUM(v1*v2). H_s = every source hidden state.
            self.dot_context = Dot(axes=[1, 1], name='context_vector')

            # [Ct; ht]
            self.concat_c_h = Concatenate(name='attention_output')

            # x -> tanh(w_c(x))
            self.w_c = Dense(self.units, use_bias=False, activation='tanh', name='attention_vector')
        if not debug_flag:
            # debug: the call to build() is done in call().
            super(Attention, self).build(input_shape)

    def compute_output_shape(self, input_shape):
        return input_shape[0], self.units

    def __call__(self, inputs, training=None, **kwargs):
        if debug_flag:
            return self.call(inputs, training, **kwargs)
        else:
            return super(Attention, self).__call__(inputs, training, **kwargs)

    # noinspection PyUnusedLocal
    def call(self, inputs, training=None, **kwargs):
        """
        Many-to-one attention mechanism for Keras. Supports:
            - Luong's multiplicative style.
            - Bahdanau's additive style.
        @param inputs: 3D tensor with shape (batch_size, time_steps, input_dim).
        @param training: not used in this layer.
        @return: 2D tensor with shape (batch_size, units)
        @author: philipperemy, felixhao28.
        """
        h_s = inputs
        if debug_flag:
            self.build(h_s.shape)
        h_t = self.h_t(h_s)
        if self.score == self.SCORE_LUONG:
            # Luong's multiplicative style.
            score = self.luong_dot([h_t, self.luong_w(h_s)])
        else:
            # Bahdanau's additive style.
            self.bahdanau_w1(h_s)
            a1 = self.bahdanau_w1(h_t)
            a2 = self.bahdanau_w2(h_s)
            a1 = self.bahdanau_repeat(a1)
            score = self.bahdanau_tanh(self.bahdanau_add([a1, a2]))
            score = self.bahdanau_v(score)
            score = K.squeeze(score, axis=-1)

        alpha_s = self.softmax_normalizer(score)
        context_vector = self.dot_context([h_s, alpha_s])
        a_t = self.w_c(self.concat_c_h([context_vector, h_t]))
        return a_t

    def get_config(self):
        config = super(Attention, self).get_config()
        config.update({'units': self.units, 'score': self.score})
        return config


# Hyper-parameter optimization
class BayesML():
    def __init__(self, hu0=64,hu1=64, 
                 hu2=64, 
                 DropoutRate=0.1,  
                 batch_size=8):
        self.hu0 = hu0
        self.hu1 = hu1
        self.hu2 = hu2
        self.DropoutRate = DropoutRate
        self.batch_size = batch_size
        self.__x_train = trainX
        self.__x_test = validX
        self.__y_train = trainY
        self.__y_test = validY
        self.__model = self.bayes_model()
        
    
    def bayes_model(self): 
        tensorflow.keras.backend.clear_session()
        inp = Input(shape=(self.__x_train.shape[1],self.__x_train.shape[2]))
        x=Conv1D(filters = self.hu0, kernel_size = 1, activation = 'relu')(inp)
        x=MaxPooling1D(pool_size = self.__x_train.shape[1])(x)
        x=Dropout(self.DropoutRate)(x)
        x = LSTM(self.hu1, return_sequences=True)(inp)
        x = LSTM(self.hu2, input_shape=(self.__x_train.shape[1],self.__x_train.shape[2]),dropout=self.DropoutRate, recurrent_dropout = self.DropoutRate,return_sequences=True)(x)
        x = Attention(units=32)(x)
        mean = Dropout(rate=self.DropoutRate)(x,training=True)
        mean = Dense(1)(mean)
        logVar = Dropout(rate=self.DropoutRate)(x, training=True)
        logVar = Dense(1)(logVar)
        out = concatenate([mean, logVar])
        model = Model(inp,out)
        @tensorflow.autograph.experimental.do_not_convert
        def heteroscedastic_loss(true,pred):
            # Customized loss function for aleatoric uncertainty
            mean_ = pred[:,0]
            logVar = pred[:,1]
            precision = tensorflow.keras.backend.exp(-logVar)
            return (0.5*precision * (true-mean)**2 + 0.5*logVar)
    
        model.compile(optimizer=keras.optimizers.Adam(lr=0.0001), loss=heteroscedastic_loss)
        return model


    # fit model
    def bayes_fit(self):
        #early_stopping = EarlyStopping(patience=0, verbose=1)
        early_stopping_cb = keras.callbacks.EarlyStopping(patience=15, restore_best_weights=True)
        from tensorflow.python.framework.ops import disable_eager_execution
        disable_eager_execution()
        
        self.__model.fit(self.__x_train, self.__y_train,
                       batch_size=self.batch_size,
                       epochs=200,
                       verbose=0,
                       validation_data=(self.__x_test, self.__y_test),
                       callbacks=[early_stopping_cb])
    #hist = model.fit(X,y,epochs = numEpoch, batch_size=batchSize, verbose=0, validation_data=(valX, valy), callbacks=callBack)
    
    # evaluate model
    def bayes_evaluate(self):
        self.bayes_fit()
        
        evaluation = self.__model.evaluate(self.__x_test, self.__y_test, batch_size=self.batch_size, verbose=0)
        return evaluation

# function to run BayesML class
def run_bayesml(hu0=64, hu1=64, hu2=64, 
              DropoutRate=0.1, 
              batch_size=8): 
    _ML = BayesML(hu0=hu0,hu1=hu1, hu2=hu2, 
                   DropoutRate=DropoutRate, 
                   batch_size=batch_size)
    ML_evaluation = _ML.bayes_evaluate()
    return ML_evaluation

# bounds for hyper-parameters in BayesML model
# the bounds dict should be in order of continuous type and then discrete type
bounds = [{'name': 'hu0',           'type': 'discrete',    'domain': range(64, 512)},
          {'name': 'hu1',           'type': 'discrete',    'domain': range(64, 512)},
          {'name': 'hu2',           'type': 'discrete',    'domain': range(64, 512)},
          {'name': 'DropoutRate',   'type': 'continuous',  'domain': (0.1, 0.6)},
          {'name': 'batch_size',    'type': 'discrete',    'domain': range(8, 64)}]


#  Bayesian Optimization
def f(x):
    print(x)
    evaluation = run_bayesml(
        hu0 = int(x[:,0]),
        hu1 = int(x[:,1]),
        hu2 = int(x[:,2]), 
        DropoutRate = float(x[:,3]), 
        batch_size = int(x[:,4]))
    #print(evaluation)
    return evaluation

# In[M4]: CNN-LSTM Attention
def fitModel_CNN_LSTM_Attention(hu0,hu1,hu2,DropoutRate,batchSize,X,y,valX,valy,callBack):
    tensorflow.keras.backend.clear_session()
    inp = Input(shape=(X.shape[1],X.shape[2]))
    x=Conv1D(filters = hu0, kernel_size = 1, activation = 'sigmoid')(inp)
    x=MaxPooling1D(pool_size = X.shape[1])(x)
    x=Dropout(DropoutRate)(x)
    x = LSTM(hu1, return_sequences=True)(inp)
    x = LSTM(hu2, input_shape=(X.shape[1],X.shape[2]),dropout=DropoutRate, recurrent_dropout = DropoutRate,return_sequences=True)(x)
    x = Attention(units=32)(x)
    mean = Dropout(rate=DropoutRate)(x,training=True)
    mean = Dense(1)(mean)
    logVar = Dropout(rate=DropoutRate)(x, training=True)
    logVar = Dense(1)(logVar)
    out = concatenate([mean, logVar])
    model = Model(inp,out)
    def heteroscedastic_loss(true,pred):
        mean_ = pred[:,0]
        logVar = pred[:,1]
        precision = tensorflow.keras.backend.exp(-logVar)
        return (0.5*precision * (true-mean)**2 + 0.5*logVar)
    model.compile(optimizer=keras.optimizers.Adam(lr=0.0001), loss=heteroscedastic_loss)
    hist = model.fit(X,y,epochs = 200, batch_size=batchSize, verbose=10, validation_data=(valX, valy), callbacks=callBack)
    loss = hist.history['loss'][-1]
    return model,loss


# Early stop callback function.
early_stopping_cb = keras.callbacks.EarlyStopping(patience=15, restore_best_weights=True)
from tensorflow.python.framework.ops import disable_eager_execution
disable_eager_execution()
# In[4]: Run model
for iiii in range(10):
    idy = str(iiii+1)
    Filename = "Results6/W_"+idx+"_"+idy+".mat"
    if os.path.isfile(Filename)==False:
        Filename = "Data/Input8/W_"+idx+"_"+idy+".mat"

        #Filename = "W_1.mat"
        Data = scipy.io.loadmat(Filename)
        trainX = Data['Xtrain'].astype('float32')
        trainY = Data['Ytrain'].astype('float32')
        validX =  Data['Xapply'].astype('float32')
        validY =  Data['Yapply'].astype('float32')
        testX =  Data['Xtest'].astype('float32')
        testY =  Data['Ytest'].astype('float32')
        
        # In[3]: Functions 
        try:
            opt_ML = GPyOpt.methods.BayesianOptimization(f=f, domain=bounds)
            opt_ML.run_optimization(max_iter=30)
        except:
            opt_ML = GPyOpt.methods.BayesianOptimization(f=f, domain=bounds)
            opt_ML.run_optimization(max_iter=30)
        print("""
        Optimized Parameters:
        \t{0}:\t{1}
        \t{2}:\t{3}
        \t{4}:\t{5}
        \t{6}:\t{7}
        \t{8}:\t{9}
        """.format(bounds[0]["name"],opt_ML.x_opt[0],
                   bounds[1]["name"],opt_ML.x_opt[1],
                   bounds[2]["name"],opt_ML.x_opt[2],
                   bounds[3]["name"],opt_ML.x_opt[3],
                   bounds[4]["name"],opt_ML.x_opt[4]))
        print("optimized loss: {0}".format(opt_ML.fx_opt))
        hyper = opt_ML.x_opt
        
        
        # In[4]: Train Model with optimized hyperparameters
        hu0 = int(hyper[0])
        hu1 = int(hyper[1])
        hu2 = int(hyper[2])
        DropoutRate = hyper[3]
        batchSize = int(hyper[4])
        FittedModel, LossV = fitModel_CNN_LSTM_Attention(hu0,hu1,hu2,DropoutRate,batchSize,trainX,trainY,validX,validY,[early_stopping_cb])
        startTime = datetime.now()
        predicted = [FittedModel.predict(testX) for _ in tqdm(range(1000))]
        eps = np.zeros((predicted[0].shape[0],1000))
        ale = np.zeros((predicted[0].shape[0],1000))
        for i in range(1000):
            eps[:,i] = predicted[i][:,0]
            ale[:,i] = predicted[i][:,1]
        eps = np.array(eps)
        ale = np.array(ale)
        m = np.mean(eps, axis=0).flatten() # predictive mean
        v = np.var(eps, axis=0).flatten() # epistemic uncertainty
        a_u = np.exp(ale) # aleatoric uncertainty
        a_u = a_u.squeeze()
        
        Filename = "Results6/W_"+idx+"_"+idy+".mat"
        #Filename = "TestRRRR.mat"
        endTime = datetime.now()
        RR = endTime - startTime
        RunTime = RR.total_seconds()
        scipy.io.savemat(Filename, mdict={'eps': eps, 'a_u': a_u,'hyper':hyper,'RunTime':RunTime}) 
