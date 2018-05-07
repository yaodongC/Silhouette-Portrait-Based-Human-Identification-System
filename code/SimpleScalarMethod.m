%% yaodong cui
% 2018-05-06
% initialize program
clear all
close all
load rect2.mat
label=[48,47,50,49,52,51,54,53,56,55,58,57,60,59,62,61,64,63,66,65,87,88];
bingo=0;
%% Read training and testing folder
%% put training image in training folder
%% put testing image in test folder
%store training folder's labels and file path
%store testing folder's file path only
Trset = imageDatastore('../training','IncludeSubfolders',true,...
'FileExtensions','.jpg','LabelSource','foldernames') ;
Tsset = imageDatastore('../test','IncludeSubfolders',true,'FileExtensions','.jpg') ;
%% Read testing file names
file_path =  '../test/';
img_path_list = dir(strcat(file_path,'*.jpg'));
name = {img_path_list.name}';
%read all file pathes and labels
Trainfiles = Trset.Files;
Testfiles = Tsset.Files;
%% read and process image, generate feature vector
[TrainData,areaTr,neckTr,perimeterTr,compactTr,irregularTr]=readAndLabelImage(Trainfiles,rect2);
[TestData,areaTes,neckTes,perimeterTes,compactTes,irregularTes]=readAndLabelImage(Testfiles,rect2);
%% neck only
Trr=neckTr';
Tee=neckTes';
%% use knn to classifiy 
[Idx Dis]= knnsearch(Trr,Tee,'K',88,'Distance','minkowski','P',2);
%% calculate Top N correct rate 
for jj=1:22
[~, rank(jj)]=find(Idx(jj,:)==label(jj));
end
cumRank(1)=0;
for jj=1:88
 cumRank(jj)= length(find(rank==jj));
 if jj>1
 cumRank(jj)=cumRank(jj)+cumRank(jj-1);
 end
end
CorrectRate=100.*cumRank./22;
%% use perimeter length
Trr2=perimeterTr';
Tee2=perimeterTes';
%% use knn to classifiy
[Idx2 Dis2]= knnsearch(Trr2,Tee2,'K',88,'Distance','minkowski','P',2);
%% calculate Top N correct rate
for jj=1:22
[~, rank2(jj)]=find(Idx2(jj,:)==label(jj));
end
cumRank2(1)=0;
for jj=1:88
 cumRank2(jj)= length(find(rank2==jj));
 if jj>1
 cumRank2(jj)=cumRank2(jj)+cumRank2(jj-1);
 end
end
CorrectRate2=100.*cumRank2./22;
%% use area
Trr3=areaTr';
Tee3=areaTes';
%% use knn to classifiy
[Idx3 Dis3]= knnsearch(Trr3,Tee3,'K',88,'Distance','minkowski','P',2);
%% calculate Top N correct rate
for jj=1:22
[~, rank3(jj)]=find(Idx3(jj,:)==label(jj));
end
cumRank3(1)=0;
for jj=1:88
 cumRank3(jj)= length(find(rank3==jj));
 if jj>1
 cumRank3(jj)=cumRank3(jj)+cumRank3(jj-1);
 end
end
CorrectRate3=100.*cumRank3./22;
%% use compactness
Trr4=compactTr';
Tee4=compactTes';
%% use knn to classifiy
[Idx4 Dis4]= knnsearch(Trr4,Tee4,'K',88,'Distance','minkowski','P',2);
%% calculate Top N correct rate
for jj=1:22
[~, rank4(jj)]=find(Idx4(jj,:)==label(jj));
end
cumRank4(1)=0;
for jj=1:88
 cumRank4(jj)= length(find(rank4==jj));
 if jj>1
 cumRank4(jj)=cumRank4(jj)+cumRank4(jj-1);
 end
end
CorrectRate4=100.*cumRank4./22;
%% use irregularity
Trr5=irregularTr';
Tee5=irregularTes';
%% use knn to classifiy
[Idx5 Dis5]= knnsearch(Trr5,Tee5,'K',88,'Distance','minkowski','P',2);
%% calculate Top N correct rate
for jj=1:22
[~, rank5(jj)]=find(Idx5(jj,:)==label(jj));
end
cumRank5(1)=0;
for jj=1:88
 cumRank5(jj)= length(find(rank5==jj));
 if jj>1
 cumRank5(jj)=cumRank5(jj)+cumRank5(jj-1);
 end
end
CorrectRate5=100.*cumRank5./22;
%% plot correction rates
h1=plot(CorrectRate)
set(h1,'LineWidth',1.5);       %| 设置图形线宽
hold on
grid on
x = 27;
y = 0:0.05:100;
h2=plot(CorrectRate2)
set(h2,'LineWidth',1.5); 
h3=plot(CorrectRate3)
set(h3,'LineWidth',1.5); 
h4=plot(CorrectRate4)
set(h4,'LineWidth',1.5); 
h5=plot(CorrectRate5)
set(h5,'LineWidth',1.5); 
plot(x,y)
hold off
set(gca,'fontsize',14,'fontweight','normal','fontangle','italic')
%| 设置x轴labal字体为斜体,黑体，字号12
set(get(gca,'xlabel'),'fontangle','italic','fontweight','bold','fontsize',14)
%| 设置y轴labal字体为斜体，非黑体，字号12
set(get(gca,'ylabel'),'fontangle','italic','fontweight','bold','fontsize',14)
title('Correct Classification Rates','FontSize',14)
xlabel('Top N Guess','FontSize',14)
ylabel('Correct Rate(%)','FontSize',14)
%text(CorrectRate(27),'o','color','g')
legend('Neck length','Perimeter','Area','Compactness','Irregularity')
