function commonNote = commonNote( file1,file2,time_tolerance,loadmode )
%COMMON function of finding notes those are exist in file1 and file2
%   此处显示详细说明
if loadmode %从文件导入
    note1 = load(file1);
    note2 = load(file2);
    commonNote = [];
else
    note1 = file1;
    note2 = file2;
    commonNote = [];
end
if ~isempty(note2)
    for i = 1:size(note1,1)
        %common notes have same pitch and nearly start time
        res = note2(find(abs(note2(:,1)-note1(i,1))<=time_tolerance & note2(:,3)==note1(i,3)),:);
        if ~isempty(res)
            commonNote=[commonNote;res];
        end
    end
end


commonNote = unique(commonNote,'rows');

end