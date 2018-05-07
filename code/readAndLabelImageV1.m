%% read and process images
% yaodong cui 
% 2018-05-01
function [Iout,pixels] = readAndLabelImageV1(imset,crop)  
     % crop settings
      rects=crop;  
     % crop settings   
      [row,~] = size(imset); %read the size of images
     %
      pixels=zeros(1,row);
     % neck length
      neck=zeros(1,row);
     % centroid
      centraPos=0;
% read every image in the folder  
for loop = 1:row
    I = imread(char(imset(loop))); %read the corresponding image
    imshow(I)
    he = imcrop(I,rects);
   %  imshow(he)
   % Iout(k,:,:,:)=im2double(img);
   %% color-based segmentation
cform = makecform('srgb2lab');
lab_he = applycform(he,cform);
ab = double(lab_he(:,:,2:3));
nrows = size(ab,1);
ncols = size(ab,2);
ab = reshape(ab,nrows*ncols,2);
% seperate background and forground
nColors = 2;
% repeat the clustering 3 times to avoid local minima
[cluster_idx, cluster_center] = kmeans(ab,nColors,'distance','sqEuclidean', ...
                                      'Replicates',3);
pixel_labels = reshape(cluster_idx,nrows,ncols);
%imshow(pixel_labels,[]), title('image labeled by cluster index');
%imshow(pixel_labels)
segmented_images = cell(1,3);
rgb_label = repmat(pixel_labels,[1 1 3]);
for k = 1:nColors
    color = he;
    % different class set to black
    color(rgb_label ~= k) = 0;
    % this class set to white
    color(rgb_label == k) = 255;   
    % or this class set to orignal color
    % segmented_images{k} = color;
    % create seperate pictures
    if rgb_label(3,3,1)==k
     index=1;
    else
     index=2;  
    end
   segmented_images{index} = rgb2gray(color); 
  % segmented_images{index} = color;  
end
Temp=segmented_images{1};
imshow(Temp), title('head');
%outLine=imcontour(Temp);
%% generate contour
[row,colum]=find(Temp~=255);
rowMin=min(min(row));
%rowMax=max(max(row))
columMin=min(min(colum));
columMax=max(max(colum));
cropp=imcrop(Temp,[columMin-20,0,columMax-columMin+40,498]);
%imshow(cropp), title('head cropp');
[sizeR,sizeC]=size(cropp);
kk=0;
% padding holes
for ii=rowMin:sizeR
    aTemp=cropp(ii,:);
    [rowR,columR]=find(aTemp~=255);
    columRMin=min(columR);
    columRMax=max(columR);
    cropp(ii,columRMin:columRMax)=0;
    if ii-rowMin>100
     kk=kk+1;    
    lengthR(kk)=columRMax-columRMin;
    end
end
neck(loop)=min(lengthR);
centraPos = lengthR(kk)/2+columRMin;
%cropp(sizeR-2:sizeR,:)=255;
[row2,~]=find(cropp==0);
pixels(loop)=length(row2)/488511;
%imshow(cropp), title('head');
%% Fourier Description
outLine=imcontour(cropp)';
%force the number of boundary points to be even
if mod(size(outLine,1), 2) ~= 0
    outLine = [outLine; outLine(end, :)];
end
%define the number of significative descriptors I want to extract (it must be even)
numdescr = 40;
%Now, you can extract all fourier descriptors...
f = fourierdescriptor(outLine);
%...and get only the most significative:
Iout(loop,:) = getsignificativedescriptors(f, numdescr);
% clear memory
clear lengthR
clear row
clear colum
clear row2
end
end 