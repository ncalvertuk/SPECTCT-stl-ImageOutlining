function Volume = MeshVolCalc(Polygon,pbar)
if(nargin<2)
    pbar = 0;
end
Volume = 0;
if(pbar >0)
    progressbar('Calculating Volume')
end
for iFace = 1:size(Polygon.faces,1)
    vert1 = Polygon.vertices(Polygon.faces(iFace,1),:);
    vert2 = Polygon.vertices(Polygon.faces(iFace,2),:);
    vert3 = Polygon.vertices(Polygon.faces(iFace,3),:);
    signedVol = SignedTetraVolume(vert1,vert2,vert3);
    Volume = Volume + signedVol;
    if(pbar>0)
        progressbar(iFace./size(Polygon.faces,1))
    end
end
Volume = abs(Volume);


function signedVol = SignedTetraVolume(vert1,vert2,vert3)
signedVol = dot(vert1,cross(vert2,vert3))/6.0;