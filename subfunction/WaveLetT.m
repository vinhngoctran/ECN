function FinalDatTrans = WaveLetT(DAT)
save('InDat.txt','DAT','-ascii');
!python DWT.py
load TransformData.mat;
DatTrans = [DAT X1];
delete InDat.txt TransformData.mat;
FinalDatTrans = [];
for i=1:size(DatTrans,2)
    if abs(sum(DatTrans(:,i),'omitnan'))>0 && max(DatTrans(:,i)) > min(DatTrans(:,i))
        FinalDatTrans = [FinalDatTrans DatTrans(:,i)];
    end
end
end