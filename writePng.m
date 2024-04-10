function writePng(strucMatrix, filename)

    strucMatrix(strucMatrix==99)=4;
    
%     map = [0.2539 0.4102 0.8789;
%     0.4805 0.3438 0.0156;
%     0 1 0;
%     1 1 1;
%     1 1 0];

map = [0/255 114/255 178/255;
    133/255 87/255 35/255;
    0/255 255/255 50/255;
    1 1 1;
    230/255 159/255 0/255];
    
    strucMatrix = strucMatrix + 1;
%     strucMatrix = strucMatrix(50:90,50:90);
%     
%    strucMatrix = repelem(strucMatrix,10,10);
   strucMatrix = repelem(strucMatrix,5,5);

    
    imwrite(strucMatrix, map, filename)
    
end