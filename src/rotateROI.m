function NewROI = rotateROI(ROIs,Cent,theta,dim1,dim2,iROI)

NewROI = ROIs;
if (iROI < 1)
    for i = 1:length(ROIs)
        x = ROIs{i}(dim1,:) - Cent(dim1);
        y = ROIs{i}(dim2,:) - Cent(dim2);
        xRotate = cosd(theta).*x - sind(theta).*y + Cent(dim1);
        yRotate = cosd(theta).*y + sind(theta).*x + Cent(dim2);
        NewROI{i}(dim1,:) = xRotate;
        NewROI{i}(dim2,:) = yRotate;
    end
else
    x = ROIs{iROI}(dim1,:) - Cent(dim1);
    y = ROIs{iROI}(dim2,:) - Cent(dim2);
    xRotate = cosd(theta).*x - sind(theta).*y + Cent(dim1);
    yRotate = cosd(theta).*y + sind(theta).*x + Cent(dim2);
    NewROI{iROI}(dim1,:) = xRotate;
    NewROI{iROI}(dim2,:) = yRotate;
end