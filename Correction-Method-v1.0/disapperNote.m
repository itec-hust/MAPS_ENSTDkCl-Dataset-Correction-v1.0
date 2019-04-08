function disapperNote  = disapperNote( file1,file2,time_tolerance,loadmode )
%disapperNote function of finding notes those are exist in file1 and disapper in file2 
%   此处显示详细说明

if loadmode %从文件导入
    note1 = load(file1);
    note2 = load(file2);
    disapperNote = [];
else
    note1 = file1;
    note2 = file2;
    disapperNote = [];
end

for i = 1:size(note1,1)
    res = note1(find(abs(note2(:,1)-note1(i,1))<=time_tolerance & note2(:,3)==note1(i,3)),:);
    if isempty(res)
        disapperNote = [disapperNote;note1(i,:)];
    end
end

disapperNote = unique(disapperNote,'rows');
end

