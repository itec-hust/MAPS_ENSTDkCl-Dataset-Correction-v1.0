% histall=[];
% histcommon = [];
% percent=[];
% for i =0:0.01:5
%     histall(end+1) = size(find(noteall(:,4)<i+0.01 & noteall(:,4)>=i),1);
%     histcommon(end+1) = size(find(commonplot(:,4)<i+0.01 & commonplot(:,4)>=i),1);
%     
%     percent(end+1) = histcommon(end)/histall(end);
%     if length(percent)>13
%         i;
%     end
% end

path = '.\data_corr\slow';
b = cell(0,0);
c=[];
for i = 1:30
    pathtmp=fullfile(path,songList{i});
    a = songList{i};
    b{i,1} = a(10:end-9);
    load(pathtmp)
    c(i,1) = size(slow,1);
end