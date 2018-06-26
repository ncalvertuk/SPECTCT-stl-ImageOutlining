function [ROIs_mat] =ROICell2Mats(ROIs)
ROIs_mat = cell(size(ROIs));
for i = 1:length(ROIs)    
    tempROI = [];
    for j = 1:length(ROIs{i})
        tempROI = [tempROI ROIs{i}{j}];
    end
    ROIs_mat{i} = tempROI;
end