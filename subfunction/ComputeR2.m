function R2 = ComputeR2(x,y)
%%%%%%% Compute R^2: Input=x,y; Output=R^2
% th1 = 0; th2 = 1;  % y=x
% TSS = sum( (y-mean(y)).^2 );
% RSS = sum( (y-th1-th2*x).^2 );
% ESS = TSS-RSS;
% R2  = ESS/TSS;     % The coefficient of determination
mdl = fitlm(x,y);
R2 = mdl.Rsquared.Ordinary;
end