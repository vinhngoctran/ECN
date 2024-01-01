function [Xtrain, Xapply,Xtest, Ytrain, Yapply,Ytest, CY,SY] = formdatacamel6(Data,LT)
%%
Delay = 30;
RawData = [];
k=0;
for i=1:size(Data.Q  ,3)
    for j=1+LT:size(Data.Q  ,1)
        k=k+1;
        ErrorNWM(k,1) = Data.Q(j,1,i)-Data.Q(j,2,i);
        RawData(k,:) = [Data.Q(j-LT,1,i), Data.Q(j,2,i), Data.W(j,:,i)];
    end
end
Xtot_trans = WaveLetT(RawData);
[Xtrain_norm, CX, SX]= normalize(Xtot_trans);  % Normalization; to Denormalize: Results = Results*S+C;
[Ytrain_norm, CY, SY]= normalize(ErrorNWM);

SelectedLagMI = inputselection(Xtot_trans,ErrorNWM,Delay);
Lookback = 0 + max(SelectedLagMI(:)); % Set minimum lookback period = 7-day
if Lookback>30
    Lookback = 30;
end

Xtot = [];
Ytot = [];
kk=0;
for i=1:size(Data.Q,3)
    for j=41-LT:size(Data.Q,1)-LT 
        kk=kk+1;
        Ytot(kk,1) = Ytrain_norm((i-1)*(size(Data.Q,1)-LT)+j,1);
        for k=1:size(Xtrain_norm,2)
            FinalData = Xtrain_norm((i-1)*(size(Data.Q,1)-LT)+j-Lookback:(i-1)*(size(Data.Q,1)-LT)+j,k);
            Xtot(kk,:,k) = FinalData(:)';
        end
    end
end

Nsize = round(0.1*size(Data.Q,3));
Xtrain = Xtot(1:(size(Data.Q,3)-Nsize*2)*30,:,:);
Xapply = Xtot((size(Data.Q,3)-Nsize*2)*30+1:(size(Data.Q,3)-Nsize)*30,:,:);
Xtest = Xtot((size(Data.Q,3)-Nsize)*30+1:end,:,:);

Ytrain = Ytot(1:(size(Data.Q,3)-Nsize*2)*30,:);
Yapply = Ytot((size(Data.Q,3)-Nsize*2)*30+1:(size(Data.Q,3)-Nsize)*30,:);
Ytest = Ytot((size(Data.Q,3)-Nsize)*30+1:end,:);
end