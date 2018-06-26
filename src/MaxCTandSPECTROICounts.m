function [ShiftSurface,ROI,shiftam,rotam,shift_counts,shift_counts_ct,nvox,nvox_ct,tv_am] = MaxCTandSPECTROICounts(Surface,CTPixSize,SPECTPixCent1,SPECTPixCent2,SPECTPixCent3,SPECT_Image,CTPixCent1,CTPixCent2,CTPixCent3,CTimg,nIts,flipnormals)
if (iscell(Surface))
    nSurfs = length(Surface);
else
    nSurfs = 1;
    Surface = {Surface};
end
% CTimg(CTimg <1075) = 1075;
sigma_x = 1.*CTPixSize(1);
sigma_y = 1.*CTPixSize(2);
sigma_z = 1.*CTPixSize(3);
sigma_thetax = 1;% 1 degree
sigma_thetay = 1;
sigma_thetaz = 1;
shiftx = [0;randn(nIts,1).*sigma_x];
shifty = [0;randn(nIts,1).*sigma_y];
shiftz = [0;randn(nIts,1).*sigma_z];
shiftthetax = [0;randn(nIts,1).*sigma_thetax];
shiftthetay = [0;randn(nIts,1).*sigma_thetay];
shiftthetaz = [0;randn(nIts,1).*sigma_thetaz];
shift_counts = zeros(nIts,nSurfs);
shift_counts_ct = zeros(nIts,nSurfs);
nvox = shift_counts;
nvox_ct = shift_counts_ct;
tv_am = shift_counts_ct;
CTshif1 = zeros(size(CTimg));
CTshif1(1:(end-1),:,:) = CTimg(2:end,:,:);
CTshif2 = zeros(size(CTimg));
CTshif3 = zeros(size(CTimg));
CTshif2(:,1:(end-1),:) = CTimg(:,2:end,:);
CTshif3(:,:,1:(end-1)) = CTimg(:,:,2:end);
CTTV = sqrt(abs(CTshif1-CTimg).^2 + abs(CTshif2-CTimg).^2 + abs(CTshif3-CTimg).^2);
Cent = zeros(3,nSurfs);

for k = 1:nSurfs
    for j = 1:3
        Cent(j) = (max(Surface{k}.vertices(:,j))-min(Surface{k}.vertices(:,j)))./2 + min(Surface{k}.vertices(:,j));
    end
end
progressbar('Iterating')
for it = 1:nIts
    for k = 1:nSurfs
        TROI = {Surface{k}.vertices'};
        TROI = rotateROI(TROI,Cent,shiftthetax(it),2,3,1);
        TROI = rotateROI(TROI,Cent,shiftthetay(it),1,3,1);
        TROI = rotateROI(TROI,Cent,shiftthetaz(it),1,2,1);
        TempSurf = Surface{k};
        centshift = [shiftx(it) shifty(it) shiftz(it)];
        TempSurf.vertices = TROI{1}' + centshift;
        ROI_shift = CreateROIVox(TempSurf,SPECTPixCent1,SPECTPixCent2,SPECTPixCent3,flipnormals);
        ROI_shift_CT = CreateROIVox(TempSurf,CTPixCent1,CTPixCent2,CTPixCent3,flipnormals);
        shift_counts(it,k) = sum(SPECT_Image(ROI_shift==1));
        shift_counts_ct(it,k) = sum(CTimg(ROI_shift_CT==1));
        nvox(it,k) = sum(ROI_shift(:) ==1);
        nvox_ct(it,k) = sum(ROI_shift_CT(:) ==1);
        tv_am(it,k) = sum(CTTV(ROI_shift_CT(:) ==1));
    end
    progressbar(it./nIts);
end
ShiftSurface = Surface;
ROI = zeros(size(ROI_shift));
shiftam = zeros(nSurfs,3);
rotam = zeros(nSurfs,3);
for k = 1:nSurfs
    [~,I1] = sort(shift_counts(:,k)./nvox(:,k),'descend');
    [~,I2] = sort(shift_counts_ct(:,k)./nvox_ct(:,k),'ascend');
    [~,I3] = sort(tv_am(:,k)./nvox_ct(:,k),'ascend');
    shiftrank = zeros(nIts,1);
    for i = 1:nIts;shiftrank(i) = 1*find(I1 ==i) + find(I2 ==i)+find(I3 ==i);end
    
    
    % [~,imax] = max(shift_counts);
    [~,imax] = min(shiftrank);
    shiftam(k,:) = [shiftx(imax) shifty(imax) shiftz(imax)];
    rotam(k,:) = [shiftthetax(imax) shiftthetay(imax) shiftthetaz(imax)];
    TROI = {Surface{k}.vertices'};
    TROI = rotateROI(TROI,Cent,rotam(k,1),2,3,1);
    TROI = rotateROI(TROI,Cent,rotam(k,2),1,3,1);
    TROI = rotateROI(TROI,Cent,rotam(k,3),1,2,1);
%     ShiftSurface = Surface;
    
    ShiftSurface{k}.vertices = TROI{1}' + shiftam(k,:);
    R = CreateROIVox(TempSurf,SPECTPixCent1,SPECTPixCent2,SPECTPixCent3,flipnormals);
    ROI = ROI + R*k;
end
