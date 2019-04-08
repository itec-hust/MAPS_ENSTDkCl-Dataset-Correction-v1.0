function [hmix,allerrs,specmix]=mix_trans(wavpath,datpath,template)
[~,Xcqt]=DEMO(wavpath);
% load('F:\ScoreInformedPianoTranscription\gxcqt\constant-q-toolbox-2b03ca77abcc\template4CQT.mat')
%   'C:\Users\zxy\Downloads\回放文件_优雅的大象_2018-03-26_21_59_56_0_2\play.mp3';
load('F:\ScoreInformedPianoTranscription\gxcqt\constant-q-toolbox-2b03ca77abcc\template4CQTws.mat')
load(template)

beta=0.6;
niter=15;
global NPITCH   %多音调检测音符个数
NPITCH=88;
allerrs=zeros(0,0);
%% 获取时间信息
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
%% 转录 
[ allspec,~,~,~,~,allframe ] = gx_voicespectest(wavpath,datpath,1);
% nFrame=ceil(max(outputTimeVec)*44100/512);
nFrame=length(allframe);
% nFrame=length(absCQT(1,:));
h0=ones(89,nFrame);
h0=h0;
hmix = zeros(NPITCH,nFrame);


if length(templatemix)==589
    for iFrame = 1:nFrame
        nframetime=iFrame*512/44100;
        cqtframenum=find(outputTimeVec>nframetime,1);
        xFrame(1:105)=absCQT(1:105,cqtframenum)*5;
        xFrame(106:589)=allspec(30:513,iFrame);
        [hmix(:,iFrame),~] = transcriptionOfMIX(xFrame',templatemix,[],h0(:,iFrame),beta,niter);
        %     allerrs(:,iFrame)=errs;
        specmix(:,iFrame)=xFrame;
    end
end

if length(templatemix)==618
    for iFrame = 1:nFrame
        nframetime=iFrame*512/44100;
        cqtframenum=find(outputTimeVec>nframetime,1);
        xFrame(1:105)=absCQT(1:105,cqtframenum)*5;
%         templatemix(106:618,:)=temp11025(1:513,:);
        xFrame(106:618)=allspec(1:513,iFrame);
        [hmix(:,iFrame),~] = transcriptionOfMIX(xFrame',templatemix,[],h0(:,iFrame),beta,niter);
        %     allerrs(:,iFrame)=errs;
        specmix(:,iFrame)=xFrame;
    end
end

if length(templatemix)==753
    for iFrame = 1:nFrame
        nframetime=iFrame*512/44100;
        cqtframenum=find(outputTimeVec>nframetime,1);
        xFrame(1:240)=absCQT(1:240,cqtframenum)*5;
%         templatemix(106:618,:)=temp11025(1:513,:);
        xFrame(241:753)=allspec(1:513,iFrame);
        [hmix(:,iFrame),~] = transcriptionOfMIX(xFrame',templatemix,[],h0(:,iFrame),beta,niter);
        %     allerrs(:,iFrame)=errs;
        specmix(:,iFrame)=xFrame;
    end
end
if length(templatemix)==581
    for iFrame = 1:nFrame
        nframetime=iFrame*512/44100;
        cqtframenum=find(outputTimeVec>nframetime,1);
        xFrame(1:83)=absCQT(1:83,cqtframenum)*5;
%         templatemix(106:618,:)=temp11025(1:513,:);
        xFrame(84:581)=allspec(16:513,iFrame);
        [hmix(:,iFrame),~] = transcriptionOfMIX(xFrame',templatemix,[],h0(:,iFrame),beta,niter);
        %     allerrs(:,iFrame)=errs;
        specmix(:,iFrame)=xFrame;
    end
end

imagesc(hmix)
