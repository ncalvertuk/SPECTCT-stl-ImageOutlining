function [meancounts,stdcounts,vol,ROI] = STLCountsUncert(CTPixSize,SPECTPixCent1,SPECTPixCent2,SPECTPixCent3,SPECT_Image,Surface,nIts,flipnorms)
if (nargin<8)
    flipnorms = false;
end
sigma_x = 1.*CTPixSize(1);
sigma_y = 1.*CTPixSize(2);
sigma_z = 1.*CTPixSize(3);
ROI = CreateROIVox(Surface,SPECTPixCent1,SPECTPixCent2,SPECTPixCent3,flipnorms);
noshift_counts = sum(SPECT_Image(ROI==1));
shiftx = randn(nIts,1).*sigma_x;
shifty = randn(nIts,1).*sigma_y;
shiftz = randn(nIts,1).*sigma_z;
SPECTPixSize(1,1) = abs(SPECTPixCent1(2) - SPECTPixCent1(1));
SPECTPixSize(2,1) = abs(SPECTPixCent2(2) - SPECTPixCent2(1));
SPECTPixSize(3,1) = abs(SPECTPixCent3(2) - SPECTPixCent3(1));
shift_counts = zeros(nIts,1);
vols = zeros(nIts,1);
for it = 1:nIts
    TempSurf = Surface;
    centshift = [shiftx(it) shifty(it) shiftz(it)];
    TempSurf.vertices = TempSurf.vertices + centshift;
    ROI_shift = CreateROIVox(TempSurf,SPECTPixCent1,SPECTPixCent2,SPECTPixCent3,flipnorms);
    shift_counts(it) = sum(SPECT_Image(ROI_shift==1));
    vols(it) = sum(ROI_shift(:)==1).*prod(SPECTPixSize)./1000;
end
meancounts = mean([noshift_counts;shift_counts]);
stdcounts = std([noshift_counts;shift_counts]);
vol = mean(vols);