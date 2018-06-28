function [meancounts,stdcounts,vol,ROI] = STLCountsUncert(CTPixSize,SPECTPixCent1,SPECTPixCent2,SPECTPixCent3,SPECT_Image,Surface,nIts,flipnorms)
if (nargin<8)
    flipnorms = false;
end
if (iscell(SPECT_Image))
    n_imgs = length(SPECT_Image);
else
    n_imgs = 1;
end
sigma_x = 1.*CTPixSize(1);
sigma_y = 1.*CTPixSize(2);
sigma_z = 1.*CTPixSize(3);
ROI = CreateROIVox(Surface,SPECTPixCent1,SPECTPixCent2,SPECTPixCent3,flipnorms);
noshift_counts = zeros(1,n_imgs);
if (n_imgs >1)
    for k = 1:n_imgs
            SP = SPECT_Image{k};
            noshift_counts(1,k) = sum(SP(ROI==1));
    end
else
    noshift_counts = sum(SPECT_Image(ROI==1));
end
shiftx = randn(nIts,1).*sigma_x;
shifty = randn(nIts,1).*sigma_y;
shiftz = randn(nIts,1).*sigma_z;
SPECTPixSize(1,1) = abs(SPECTPixCent1(2) - SPECTPixCent1(1));
SPECTPixSize(2,1) = abs(SPECTPixCent2(2) - SPECTPixCent2(1));
SPECTPixSize(3,1) = abs(SPECTPixCent3(2) - SPECTPixCent3(1));
shift_counts = zeros(nIts,n_imgs);
vols = zeros(nIts,n_imgs);
if (n_imgs >1)
    for it = 1:nIts
        TempSurf = Surface;
        centshift = [shiftx(it) shifty(it) shiftz(it)];
        TempSurf.vertices = TempSurf.vertices + centshift;
        ROI_shift = CreateROIVox(TempSurf,SPECTPixCent1,SPECTPixCent2,SPECTPixCent3,flipnorms);
        for k = 1:n_imgs
            SP = SPECT_Image{k};
            shift_counts(it,k) = sum(SP(ROI_shift==1));
            vols(it,k) = sum(ROI_shift(:)==1).*prod(SPECTPixSize)./1000;
        end
    end
else
    for it = 1:nIts
        TempSurf = Surface;
        centshift = [shiftx(it) shifty(it) shiftz(it)];
        TempSurf.vertices = TempSurf.vertices + centshift;
        ROI_shift = CreateROIVox(TempSurf,SPECTPixCent1,SPECTPixCent2,SPECTPixCent3,flipnorms);
        shift_counts(it,1) = sum(SPECT_Image(ROI_shift==1));
        vols(it,1) = sum(ROI_shift(:)==1).*prod(SPECTPixSize)./1000;
    end
end
meancounts = mean([noshift_counts;shift_counts]);
stdcounts = std([noshift_counts;shift_counts]);
vol = mean(vols);