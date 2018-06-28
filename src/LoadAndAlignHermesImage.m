function recon_image = LoadAndAlignHermesImage(filename,align_header)

recon_image_raw=  flip(squeeze(double(dicm_img(filename))),3);
recon_image_hdr = dicm_hdr(filename);
recon_image_Slope = recon_image_hdr.RealWorldValueMappingSequence.Item_1.RealWorldValueSlope;
recon_image = zeros(128,128,128);
ID = round((align_header.Unknown_0054_0022.Item_1.ImagePositionPatient(3) - recon_image_hdr.Unknown_0054_0022.Item_1.ImagePositionPatient(3))/4.4196);
recon_image(:,:,(ID+2 - size(recon_image_raw,3)):(ID+1)) = recon_image_raw.*recon_image_Slope;