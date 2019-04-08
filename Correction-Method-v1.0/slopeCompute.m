function [slopedata,absCQT,outputTimeVec]  = slopeCompute(wavpath,midi)
load('note_range.mat')
load('y_axis.mat');

[~,Xcqt]=cqtCompute(wavpath);
[ outputTimeVec,absCQT ] = cqtOuttime( Xcqt );
timeRange=0.15;
hop=0.002312925;
step=floor(timeRange/hop);

for j=1:size(midi,1)
    time = midi(j,1);
    time_index=find(outputTimeVec>time,1);
    
    pitch = midi(j,3);
    freq_min=note_range(find(note_range(:,1)==pitch),3);
    freq_min=find(y_axis>freq_min,1);
    
    freq_max=note_range(find(note_range(:,1)==pitch),4);
    freq_max=find(y_axis>freq_max,1)-1;
    
    Sloperow1 = slopeCQT( absCQT(freq_min:freq_max,time_index-step:time_index+step));
    slopedata{j,1} = Sloperow1;
    if pitch<96
        pitch=pitch+12;
        freq_min=note_range(find(note_range(:,1)==pitch),3);
        freq_min=find(y_axis>freq_min,1);
        freq_max=note_range(find(note_range(:,1)==pitch),4);
        freq_max=find(y_axis>freq_max,1)-1;
        Sloperow2 = slopeCQT( absCQT(freq_min:freq_max,time_index-step:time_index+step));
    else
        Sloperow2=zeros(size(Sloperow1,1),size(Sloperow1,2));
    end
    slopedata{j,2} = Sloperow2;
end

end

function Sloperow = slopeCQT(cqtdata)
global imid
imid=15;
cols = size(cqtdata,1);
if cols>3
    delIndex=[1,4];
    cqtdata(delIndex,:)=[];
end
cqtdataD=cqtdata;
rows = size(cqtdata,1);
Sloperow=[];

for i = 1:rows
    for j=1:31
        Sloperow(i,j) = slopefind(cqtdataD(i,(j-1)*4+1:(j-1)*4+9));
    end
end

end

function slope = slopefind(cqtblock)
[iMin,minIndex]=min(cqtblock);

if minIndex<9
    [iMinmax,~]=max(cqtblock(minIndex:end));
    minSlope=iMinmax-iMin;
else
    minSlope=0;
end

[iMax,maxIndex]=max(cqtblock);
if maxIndex>1
    [iMaxmin,~]=min(cqtblock(1:maxIndex));
    maxSlope=iMaxmin-iMax;
else
    maxSlope=0;
end

slope=max(minSlope,maxSlope);
end

function [ outputTimeVec,absCQT ] = cqtOuttime( Xcqt )
if Xcqt.intParams.rast == 0
    absCQT = getCQT(Xcqt,'all','all','linear');
else
    absCQT = abs(Xcqt.spCQT);
end

emptyHops = Xcqt.intParams.firstcenter/Xcqt.intParams.atomHOP;
maxDrop = emptyHops*2^(Xcqt.octaveNr-1)-emptyHops;
droppedSamples = (maxDrop-1)*Xcqt.intParams.atomHOP + Xcqt.intParams.firstcenter;
outputTimeVec = (1:size(absCQT,2))*Xcqt.intParams.atomHOP-Xcqt.intParams.preZeros+droppedSamples;
outputTimeVec=outputTimeVec/44100;

end
