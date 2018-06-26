function [ROIs_x, ROIs_y,ROIs_z] = ResampROIs(ROIs)
ROIs_x = cell(size(ROIs));
ROIs_y = ROIs_x;
ROIs_z = ROIs_x;
for i = 1:length(ROIs)    
    roi = [];
    iROI = ROIs{i};
    for j = 1:length(iROI)
        roi = [roi iROI{j}];
    end
    x = unique(roi(1,:));
    y = unique(roi(2,:));
    z = unique(roi(3,:));
    for ix = 1:length(x)
        l = abs(roi(1,:) -x(ix))<1e-8;
        ROIs_x{i}{ix,1} = roi(:,l);
    end
    for iy = 1:length(y)
        l = abs(roi(2,:) - y(iy))<1e-8;
        ROIs_y{i}{iy,1} = roi(:,l);
    end
    for iz = 1:length(z)
        l = abs(roi(3,:) - z(iz))<1e-8;
        ROIs_z{i}{iz,1} = roi(:,l);
    end
end