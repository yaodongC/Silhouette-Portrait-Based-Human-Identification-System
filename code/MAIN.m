%% yaodong cui
% 2018-05-06
% initialize program
clear all
close all
load rect2.mat
label=[48,47,50,49,52,51,54,53,56,55,58,57,60,59,62,61,64,63,66,65,87,88];
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
[TrainData,areaTr]=readAndLabelImageV1(Trainfiles,rect2);
[TestData,areaTes]=readAndLabelImageV1(Testfiles,rect2);
%% mixture model
Trr=[abs(TrainData(:,1)),abs(TrainData(:,6)),abs(TrainData(:,11)),abs(TrainData(:,26)),abs(TrainData(:,31))]./10000;
Tee=[abs(TestData(:,1)),abs(TestData(:,6)),abs(TestData(:,11)),abs(TestData(:,26)),abs(TestData(:,31))]./10000;
Trr=[400.*areaTr',Trr];
Tee=[400.*areaTes',Tee];
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
%% FD only model
Trr2=[abs(TrainData(:,1)),abs(TrainData(:,6)),abs(TrainData(:,11)),abs(TrainData(:,26)),abs(TrainData(:,31))]./10000;
Tee2=[abs(TestData(:,1)),abs(TestData(:,6)),abs(TestData(:,11)),abs(TestData(:,26)),abs(TestData(:,31))]./10000;
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
%% plot correct rate 
h1=plot(CorrectRate)
set(h1,'LineWidth',1.5);       %| 设置图形线宽
hold on
grid on
h2=plot(CorrectRate2)
set(h2,'LineWidth',1.5);       %| 设置图形线宽
x = 27;
y = 0:0.05:100;
plot(x,y)
hold off
set(gca,'fontsize',14,'fontweight','normal','fontangle','italic')
%| 设置x轴labal字体为斜体,黑体，字号12
title('Correct Classification Rates','FontSize',14)
xlabel('Top N Guess','FontSize',14)
ylabel('Correct Rate(%)','FontSize',14)
legend('Combined Method','FD only Method')
%% plot distance
figure,bar(Dis(1,:),'b')
hold on
bar(Dis(1,1),'r')
hold off
set(gca,'fontsize',14,'fontweight','normal','fontangle','italic')
%| 设置x轴labal字体为斜体,黑体，字号12
set(get(gca,'xlabel'),'fontangle','italic','fontweight','bold','fontsize',14)
%| 设置y轴labal字体为斜体，非黑体，字号12
set(get(gca,'ylabel'),'fontangle','italic','fontweight','bold','fontsize',14)
title('Minkowski Distance','FontSize',14)
xlabel('Guesses','FontSize',14)
ylabel('Minkowski Distance','FontSize',14)
legend('Between-Class Distance','Within-Class Distance')
%% this section is to calculate and plot FAR FRR and EER
%% false accept rates
for threshold=1:1:50
 FalseAccp(threshold)=0;   
for jj=1:22
  if Dis2(1,jj)<=threshold & Idx(jj,1)~=label(jj)
    FalseAccp(threshold)=FalseAccp(threshold)+1;
   end
end
end
%% false reject rates
for threshold=1:1:50
 FalseReject(threshold)=0;   
for jj=1:22
  if Dis2(1,jj)>=threshold & Idx(jj,1)==label(jj)
    FalseReject(threshold)=FalseReject(threshold)+1;
  end
end
end
len1=max(FalseAccp);
len2=max(FalseReject);
figure,h=plot(FalseAccp(1:8)./len1)
set(h,'LineWidth',3);       %| 设置图形线宽
hold on
h2=plot(FalseReject(1:8)./len2)
set(h2,'LineWidth',3);       %| 设置图形线宽
hold off
set(gca,'fontsize',14,'fontweight','normal','fontangle','italic')
%| 设置x轴labal字体为斜体,黑体，字号12
title('Equal Error Rates ','FontSize',14)
xlabel('Threshold','FontSize',14)
ylabel('Correct Rate(%)','FontSize',14)
legend('False Accept Rate','False Reject Rates')