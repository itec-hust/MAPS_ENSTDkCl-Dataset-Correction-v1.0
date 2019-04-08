function devCorr = timeCorrect(path1,path2,deviation,midi)
%TIMECORRECT 此处显示有关此函数的摘要
%   此处显示详细说明
surplus1 = load(path1);
surplus2 = load(path2);
tolerance1 = 0.15;
tolerance2 = 0.05;
devCorr = deviation;
if ~isempty(deviation)
    for i = size(deviation,1):-1:1
        %% 起始时间修正
        time = deviation(i,1);
        pitch = deviation(i,3);
        res1 = surplus1(find(abs(surplus1(:,1)-time)<tolerance1 & surplus1(:,3)==pitch),:);
        res2 = surplus2(find(abs(surplus2(:,1)-time)<tolerance1 & surplus2(:,3)==pitch),:);
        flag = 0;
        for j = 1:size(res1,1)
            res3 = find(abs(res2(:,1)-res1(j,1))<tolerance2,1);
            if res3>0
                devCorr(i,4) = (res1(j,1)+res2(res3,1))/2;
                flag = 1;
            end
        end
        if flag == 0
            deviation(i,:)=[];
        end
        %% 结束时间修正
        widerlok = midi(find(abs(midi(:,1)-time)<5 & midi(:,3)==pitch),:);%5s所有相同音调查找
        
        for k = 1:size(widerlok,1) %删除被修正的音符
            if widerlok(k,1)==deviation(i,1)
                widerlok(k,:)=[];
                break
            end
        end
        
        flag = 0;
        for l=1:size(widerlok,1)
            if flag == 1
                continue
            end
            if widerlok(l,1)<devCorr(i,4) && widerlok(l,2)>devCorr(i,4)%起始时间在其他同音调范围内
                devCorr(i,:)=[];
                flag = 1;
                break
            else if widerlok(l,1)<devCorr(i,4)+devCorr(i,2)-devCorr(i,1) && widerlok(l,2)>devCorr(i,4)+devCorr(i,2)-devCorr(i,1)%结束时间在某个音范围内
                    endtime = widerlok(l,1);
                    duration = endtime-devCorr(i,4);
                    if duration<0.05 %时间过短
                        devCorr(i,:)=[];
                        flag = 1;
                    else
                        devCorr(i,5)=endtime;
                        flag = 1;
                    end
                    break
                end
            end
        end
        
        if flag == 0
            devCorr(i,5)=devCorr(i,2)-devCorr(i,1)+devCorr(i,4);%延续持续时间
        end
    end
else
    devCorr=[];
end
end

