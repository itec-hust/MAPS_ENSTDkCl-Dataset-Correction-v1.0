function [ midiout ] = cqtmax( absCQT,outputTimeVec,midi )
%CQTMAX 此处显示有关此函数的摘要
%   此处显示详细说明
load('note_range.mat')
load('y_axis.mat')

timeRange=0.05;
hop=0.002312925;
step=floor(timeRange/hop);

for i = 1:size(midi,1)
    time = midi(i,1);
    time_index=find(outputTimeVec>time,1);
    
    pitch = midi(i,3);
    freq_min=note_range(find(note_range(:,1)==pitch),3);
    freq_min=find(y_axis>freq_min,1);
    
    freq_max=note_range(find(note_range(:,1)==pitch),4);
    freq_max=find(y_axis>freq_max,1)-1;
    
    if freq_max-freq_min>2
        freq_min = freq_min+1;
        freq_max = freq_max-1;
    end
    
    basicCQT = absCQT(freq_min:freq_max,time_index-step:time_index+step);
    
    if pitch<96
        pitch = pitch+12;
        freq_min=note_range(find(note_range(:,1)==pitch),3);
        freq_min=find(y_axis>freq_min,1);
        
        freq_max=note_range(find(note_range(:,1)==pitch),4);
        freq_max=find(y_axis>freq_max,1)-1;
        
        if freq_max-freq_min>2
            freq_min = freq_min+1;
            freq_max = freq_max-1;
        end
        
        octaveCQT = absCQT(freq_min:freq_max,time_index-step:time_index+step);
    else
        octaveCQT = zeros(size(basicCQT,1),size(basicCQT,2));
    end
    
    basicMax = max(max(basicCQT));
    octaveMax = max(max(octaveCQT));
    midiout(i,:)=[midi(i,:),max(basicMax,octaveMax)];
    
end


end

