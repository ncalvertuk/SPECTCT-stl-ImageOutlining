function [] = writeMIDASROIFile(Filename,VoxROI)

indmax = max(VoxROI(:));
for i = 1:indmax
    indfilename = [Filename '_' num2str(i) '.roi'];
    f=fopen(indfilename,'w');
    V = zeros(size(VoxROI));
    V(VoxROI ==i) = 255;
    fwrite(f,V,'uint8');
    fclose(f);
end