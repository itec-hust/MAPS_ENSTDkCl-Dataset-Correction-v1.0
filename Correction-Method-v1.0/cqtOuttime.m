function [ outputTimeVec,absCQT ] = cqtOuttime( Xcqt )
%CQTOUTTIME 此处显示有关此函数的摘要
%   此处显示详细说明
    fcomp=0.6;
    fs=44100;
    % 获取时间信息
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

