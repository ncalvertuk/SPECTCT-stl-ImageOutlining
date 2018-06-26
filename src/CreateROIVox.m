function ROIVox = CreateROIVox(Surface,PixCentX,PixCentY,PixCentZ,flipnormals)
if(nargin < 5)
    flipnormals = false;
end
[PixListX,PixListY,PixListZ] = meshgrid(PixCentX,PixCentY,PixCentZ);
PixListX = permute(PixListX,[2 1 3]);
PixListY = permute(PixListY,[2 1 3]);
PixListZ = permute(PixListZ,[2 1 3]);
ROIVox = zeros(size(PixListX));
verts = Surface.vertices;
xmin = min(verts(:,1))-1;
xmax = max(verts(:,1))+1;
ymin = min(verts(:,2))-1;
ymax = max(verts(:,2))+1;
zmin = min(verts(:,3))-1;
zmax = max(verts(:,3))+1;
l = PixListX >= xmin & PixListX <= xmax & PixListY >= ymin & PixListY <= ymax & PixListZ >= zmin & PixListZ <= zmax;
% pts = [PixListX(l) PixListY(l) PixListZ(l)];
%     Surface2.vertices = verts';
% IN = reshape(inpolyhedron(Surface,pts),size(PixListX,1),size(PixListX,2),size(PixListX,3));
x = PixCentX(PixCentX >= xmin & PixCentX <= xmax);
y = PixCentY(PixCentY >= ymin & PixCentY <= ymax);
z = PixCentZ(PixCentZ >= zmin & PixCentZ <= zmax);
IN = inpolyhedron(Surface,x,y,z,'FLIPNORMALS',flipnormals);
IN = permute(IN,[2 1 3]);
ROIVox(l) = IN;
