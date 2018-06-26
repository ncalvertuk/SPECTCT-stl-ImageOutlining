function [Surface,AllCompNormalVecs] = ShortReadSTLFile(Filename)
tic
fid = fopen(Filename);

PelvisString = textscan(fid,'%s');
PelvisString = PelvisString{1,1};
normalind =false(length(PelvisString),1);
for i = 1:length(PelvisString)
    normalind(i) = strcmp(PelvisString{i},'normal');
end
normalfind = find(normalind);
A = PelvisString(normalfind);
AllCompNormalVecs = [str2double(PelvisString(normalfind+1)) str2double(PelvisString(normalfind+2)) str2double(PelvisString(normalfind+3))];
vertind =false(length(PelvisString),1);
for i = 1:length(PelvisString)
    vertind(i) = strcmp(PelvisString{i},'vertex');
end
vertfind = find(vertind);
AllCompVertices = [str2double(PelvisString(vertfind+1)) str2double(PelvisString(vertfind+2)) str2double(PelvisString(vertfind+3))];
AllCompFaceInd = [];
for i = 1:length(AllCompNormalVecs)
    AllCompFaceInd = [AllCompFaceInd;i*ones(3,1)];
end
Surface.vertices = AllCompVertices;
Surface.faces = reshape(1:size(AllCompVertices,1),3,[]).';
fclose(fid);
if(isempty(Surface.vertices))
    fid = fopen(Filename);
    Header = fread(fid,80,'uint8');
    while(~feof(fid))
        nTris = fread(fid,1,'uint32');
        TempVerts = zeros(nTris.*3,3);
        AllCompNormalVecs = zeros(nTris,3);
        TempFaces = AllCompNormalVecs;
        for iTri = 1:nTris
            AllCompNormalVecs(iTri,:) = fread(fid,3,'float');
            TempVerts((iTri-1)*3+1,:) = fread(fid,3,'float');
            TempVerts((iTri-1)*3+2,:) = fread(fid,3,'float');
            TempVerts((iTri-1)*3+3,:) = fread(fid,3,'float');
            TempFaces(iTri,:) = [(iTri-1)*3+1 (iTri-1)*3+2 (iTri-1)*3+3] + size(Surface.vertices,1);
            AttCount = fread(fid,1,'uint16');
        end
        Surface.vertices = [Surface.vertices;TempVerts];
        Surface.faces = [Surface.faces;TempFaces];
    end
    fclose(fid);
end

% Surface = ReduceVerts(Surface);
t = toc;
disp(['Opened ' Filename ' STL File, timetaken = ' num2str(t) ' seconds']);