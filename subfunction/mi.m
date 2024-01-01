function I=mi(A,B,varargin) 
%MI Determines the mutual information of two signals
if nargin>=3
    L=varargin{1};
else
    L=256;
end
A=double(A); 
B=double(B);     
na = hist(A(:),L); 
na = na/sum(na);
nb = hist(B(:),L); 
nb = nb/sum(nb);
n2 = hist2(A,B,L); 
n2 = n2/sum(n2(:));
I=sum(minf(n2,na'*nb)); 

function y=minf(pab,papb)

I=find(papb(:)>1e-12 & pab(:)>1e-12); % function support 
y=pab(I).*log2(pab(I)./papb(I));

function n=hist2(A,B,L) 
ma=min(A(:)); 
MA=max(A(:)); 
mb=min(B(:)); 
MB=max(B(:));
% Scale and round to fit in {0,...,L-1} 
A=round((A-ma)*(L-1)/(MA-ma+eps)); 
B=round((B-mb)*(L-1)/(MB-mb+eps)); 
n=zeros(L); 
x=0:L-1; 
for i=0:L-1 
    n(i+1,:) = histc(B(A==i),x,1); 
end

