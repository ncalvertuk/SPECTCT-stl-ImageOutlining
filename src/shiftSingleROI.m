function New_ROIs = shiftSingleROI(ROIs,shift,dim)
New_ROIs = ROIs;
for i =1:length(ROIs)
    New_ROIs{i}(dim,:) = New_ROIs{i}(dim,:)+shift;
end