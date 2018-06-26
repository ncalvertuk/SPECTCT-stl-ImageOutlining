function ax = ViewSingleSliceOverlay_SPECTMat(ax,CT_img,slice,dim,ROIs_Mat,PixCent1,PixCent2,Pixx,PixxSize,minvoxval,maxvoxval,SPECT_img,SPECTPixCent1,SPECTPixCent2,spslice,flipydir,changelims)
if (nargin < 16)
    flipydir = 0;
    changelims = 0;
end
if (nargin > 15 && nargin <17)
    changelims = 0;
end
if(~changelims)
    x = get(ax,'XLim');
    y = get(ax,'YLim');
end
% minvoxval = min(CT_img(:));
% if (minvoxval < -1024)
%     minvoxval = -1024;
% end
% maxvoxval = max(CT_img(:));
cla(ax,'reset')

if (dim==1)
    ImSlice = CT_img(slice,:,:);
elseif(dim==2)
    ImSlice = CT_img(:,slice,:);
else
%     ImSlice = CT_img(:,:,size(CT_img,3) - slice+1);
    ImSlice = CT_img(:,:,slice);
end
ImSlice =squeeze(ImSlice).';
minval = min([minvoxval 0.7*maxvoxval]);
maxval = max([minvoxval 0.7*maxvoxval]);
RCT = (ImSlice - minval)./(maxval - minval);
GCT = (ImSlice - minval)./(maxval - minval);
BCT = (ImSlice - minval)./(maxval - minval);
RCT(RCT> 1) = 1;
RCT(RCT< 0) = 0;
BCT(BCT> 1) = 1;
BCT(BCT< 0) = 0;
GCT(GCT> 1) = 1;
GCT(GCT< 0) = 0;
CTGrey = zeros([size(RCT),3]);
CTGrey(:,:,1) = RCT;
CTGrey(:,:,2) = GCT;
CTGrey(:,:,3) = BCT;

if(dim>2)    
    imagesc(ax,PixCent1,PixCent2,CTGrey);        
else
    imagesc(ax,PixCent1,(PixCent2),CTGrey);
end
% colormap('gray')


if (dim==1)
    NMSlice = SPECT_img(spslice,:,:);
elseif(dim==2)
    NMSlice = SPECT_img(:,spslice,:);
else
    NMSlice = SPECT_img(:,:,spslice);
end
A = squeeze(NMSlice).'./max(SPECT_img(:));

hold(ax,'on')
axis(ax, 'image')
% imagesc(ax,SPECTPixCent1,SPECTPixCent2,squeeze(NMslice),'AlphaData',(A+1)/2)
if(dim>2)    
    imagesc(ax,SPECTPixCent1,SPECTPixCent2,squeeze(NMSlice).','AlphaData',(A+1)/4);        
else
    imagesc(ax,SPECTPixCent1,(SPECTPixCent2),squeeze(NMSlice).','AlphaData',(A+1)/4);
end
ColourPal = [0 114 189;217 83 25; 237 177 32;126 47 142;119 172 48;77 190 238;162 20 47;255.*rand(1,3)]./255;
while(length(ROIs_Mat) > size(ColourPal,1))
    ColourPal = [ColourPal;rand(1,3)];
end

for i = 1:length(ROIs_Mat)
    if(dim==1)
        pixdistx = abs(ROIs_Mat{i}(1,:) - Pixx);
    elseif(dim==2)
        pixdistx = abs(ROIs_Mat{i}(2,:) - Pixx);
    else
        pixdistx = abs(ROIs_Mat{i}(3,:) - Pixx);
    end
    l = pixdistx < PixxSize;
    ROIx = ROIs_Mat{i}(:,l);
    if(~isempty(ROIx))
        if(dim==1)
            scatter(ax,[ROIx(2,:) ROIx(2,1)],[ROIx(3,:) ROIx(3,1)],2,ColourPal(i,:));
        elseif(dim==2)
            scatter(ax,[ROIx(1,:) ROIx(1,1)],[ROIx(3,:) ROIx(3,1)],2,ColourPal(i,:));
        else
            scatter(ax,[ROIx(1,:) ROIx(1,1)],[ROIx(2,:) ROIx(2,1)],2,ColourPal(i,:));
        end
    end
end
if(flipydir)
    set(ax,'YDir','normal');
end
if(~changelims)
    set(ax,'XLim',x);
    set(ax,'YLim',y);
end
% caxis(ax,sort([minvoxval 0.7.*maxvoxval]));