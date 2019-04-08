function correctNotes(model_1,model_2,wavdir)
% function input: song_list,model_1,model_2
% example:deviationNotes('CNN','GOOGLE','songList.mat')
% disapperNote  = disapperNote( file1,file2,time_tolerance )
% commonNote = commonNote( file1,file2,time_tolerance )

% directory structure
% model name -> onset tolerance -> mistake classification -> song name
% example:
% GOOGLE\analy_GOOGLE_005\missing\MAPS_MUS-alb_se2_ENSTDkCl.txt
% meaning:the missing notes of MAPS_MUS-alb_se2_ENSTDkCl
% of google model, setting the evaluation onset tolerance to be 0.05 seconds
% the name of all songs are saved in song_list

%model_1 = 'CNN';
%model_2 = 'GOOGLE';

songList = cell(0,0);
audios = dir([wavdir '.\*.wav']);
for i = 1:length(audios)
    songList{i,1} = audios(i).name(1:end-4);
end



ambiAll=[];
unplayedAll =[];
common_paresAll =[];
system(['mkdir ' '.\data_corr\deviated\']);
system(['mkdir ' '.\data_corr\unplayed\']);
system(['mkdir ' '.\data_corr\slow\']);

%% finding common missing note in these two models
for i = 1:size(songList,1)
    slow=[];
    unplayed =[];
    wavpath = fullfile(wavdir,[songList{i} '.wav']);
    midipath = fullfile(wavdir,[songList{i} '.txt']);
    midi = load(midipath);
    
    model_1_005_M_path = fullfile('.',model_1,['analy_' model_1 '_005'],'missing',[songList{i} '.txt']);
    model_1_015_M_path = fullfile('.',model_1,['analy_' model_1 '_015'],'missing',[songList{i} '.txt']);
    disapper_1 = disapperNote( model_1_005_M_path,model_1_015_M_path,0,1 );
    common_1 = commonNote( model_1_005_M_path,model_1_015_M_path,0,1 );
    
    model_2_005_M_path = fullfile('.',model_2,['analy_' model_2 '_005'],'missing',[songList{i} '.txt']);
    model_2_015_M_path = fullfile('.',model_2,['analy_' model_2 '_015'],'missing',[songList{i} '.txt']);
    disapper_2 = disapperNote( model_2_005_M_path,model_2_015_M_path,0,1 );
    common_2 = commonNote( model_2_005_M_path,model_2_015_M_path,0,1 );
    
    model_1_005_S_path = fullfile('.',model_1,['analy_' model_1 '_005'],'surplus',[songList{i} '.txt']);
    model_2_005_S_path = fullfile('.',model_2,['analy_' model_2 '_005'],'surplus',[songList{i} '.txt']);
    missSurPares_1 = commonNote( model_1_005_S_path,model_1_005_M_path,0.15,1 );
    missSurPares_2 = commonNote( model_2_005_S_path,model_2_005_M_path,0.15,1 );
    
    
    common_Disapper = commonNote( disapper_1,disapper_2,0,0);
    common_All = commonNote( common_1,common_2,0,0);
    deviated = commonNote( missSurPares_1,missSurPares_2,0.05,0 );
    deviated = commonNote( common_Disapper,deviated,0,0 );
    
    %load(['.\slopedata\' songList{i}])%slopedata
    [slopedata,absCQT,outputTimeVec] = slopeCompute(wavpath,midi);
    
    %% 基于common_pares的筛选 deviation notes
    for j = 1:size(deviated,1)
        indexfind = find(midi(:,1)==deviated(j,1)&midi(:,3)==deviated(j,3));
        s1 = slopedata{indexfind,1};%(:,15:19);
        s2 = slopedata{indexfind,2};%(:,15:19);
        
        deviated(j,4) = max(max(max(s1(:,10:19)),max(s2(:,10:19))));
        deviated(j,5) = max(max(max(s1),max(s2)));
        
    end
    for j =  size(deviated,1):-1:1
        if deviated(j,4) > deviated(j,5)*0.25
            %slow = [slow;deviated(j,1:3)];
            deviated(j,:)=[];
            continue
        end
    end
    deviated = timeCorrect(model_1_005_S_path,model_2_005_S_path,deviated,midi(:,1:3));
    %% 基于slope的筛选 unplayed notes slow start notes
    
    midiHere = midi(:,1:3);
    for j = 1:size(midiHere,1)
        s1 = slopedata{j,1};
        s2 = slopedata{j,2};
        midiHere(j,4) = max(max(max(s1(:,10:19)),max(s2(:,10:19))));
        midiHere(j,5) = max(max(max(s1),max(s2)));
        
        flag = max(max([s1(:,10:20);s2(:,10:20)]));
        if ~isempty(deviated)
            deviationflag = find(deviated(:,1)==midi(j,1) & deviated(:,3)==midi(j,3));
        else
            deviationflag =[];
        end
        if  flag == 0 && isempty(deviationflag)
            unplayed = [unplayed;midi(j,1:3)];
        end
        
        sAll = s1;
        flag = [];
        for k = 1:size(sAll,1)
            Smax = max(sAll(k,:));
            stableNum = length(find(sAll(k,:) >= Smax*0.5));
            if Smax>0.1 || max(max(s2))>0.1%频率上升很快
                flag(k) = 2;
            else if stableNum >= 10
                    flag(k) = 1;
                else
                    flag(k) = 2; %频率上升过程不稳定
                end
            end
        end
        
        if max(flag) ==1
            slow = [slow;midi(j,1:3)];
        end
        
    end
    
    %% 基于cqtdata的筛选
    noteCQT = cqtmax( absCQT,outputTimeVec,midi(:,1:3));
    %以下代码筛选出共同错误的cqtdata
    for j = 1:size(common_All,1)
        indexthis = find(noteCQT(:,1)==common_All(j,1) & noteCQT(:,3)==common_All(j,3));
        common_All(j,4) = noteCQT(indexthis,4);
    end
    % 音符无效阈值：0.03
    for j = 1:size(noteCQT,1)
        if noteCQT(j,4)<=0.03
            unplayed = [unplayed;noteCQT(1:3)];
        end
    end
    %% 去重 偏移>未演奏>模糊
    slow = unique(slow,'rows');%模糊
    unplayed = unique(unplayed,'rows');%未演奏
    if isempty(deviated)
        deviated = zeros(0,3);
    end
    if isempty(unplayed)
        unplayed = zeros(0,3);
    end
    deviated = unique(deviated,'rows');%偏移
    
    tmp = [deviated(:,1:3);unplayed];
    for j = size(slow):-1:1
        res = find(tmp(:,1)==slow(j,1) & tmp(:,3)==slow(j,3));
        if ~isempty(res)
            slow(j,:) = [];
        end
    end
    
    for j = size(unplayed):-1:1
        res = find(deviated(:,1)==unplayed(j,1) & deviated(:,3)==unplayed(j,3));
        if ~isempty(res)
            unplayed(j,:) = [];
        end
    end
    
    slow = unique(slow,'rows');
    unplayed = unique(unplayed,'rows');
    deviated = unique(deviated,'rows');
    
    slow(slow(:,3)<48,:)=[];
    unplayed(unplayed(:,3)<48,:)=[];
    deviated(deviated(:,3)<48,:)=[];
    
    save([ '.\data_corr\deviated\' songList{i} '.mat'], 'deviated')
    save([ '.\data_corr\unplayed\' songList{i} '.mat'], 'unplayed')
    save([ '.\data_corr\slow\' songList{i} '.mat'], 'slow')
    
end
end