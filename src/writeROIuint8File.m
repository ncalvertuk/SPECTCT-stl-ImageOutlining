function [] = writeROIuint8File(Filename,VoxROI)


    indfilename = [Filename '.roi'];
    f=fopen(indfilename,'w');
    fwrite(f,VoxROI,'uint8');
    fclose(f);
