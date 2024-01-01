% function NSout = Nash(obsData, simData)
% 
% E = obsData(:,1) - simData(:,1);
% SSE = sum(E.^2);
% u = mean(obsData(:,1));
% SSU = sum((obsData(:,1) - u).^2);
% NSout = 1 - SSE/SSU;
% end
% 
% 
% 
% 
% 
function NS = Nash(Qobs,Qtt)
%Nash-Sutcliffe coefficient calculation
A = 0.;
B = 0.;
C = 0.;
N = numel(Qtt);
for i = 1:N
    A = A+(Qtt(i)-Qobs(i))^2;
    B = B+Qobs(i);
end
X = B/N;
AA = A;
for i = 1:N
    C = C+(Qobs(i)-X)^2;
end
NS = 1-A/C;
end