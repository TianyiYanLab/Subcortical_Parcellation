%% extract result
clear
root = 'D:\research\HCP_parcellation_Lsym-AVR\CamCan\KRR parcel size to cognition';
iterations = 100;
cogTasks = {'Fluid intelligence','Emotion expression recognition',...
    'PicturePriming','Face recognition','FamousFaces','Motor learning'};
cogTasksNames = {'Fluid_intelligence','Emotion_expression_recognition',...
    'PicturePriming','Face_recognition','FamousFaces','Motor_learning'};
all_acc=[];
for i = 1:length(cogTasks)
    currTask = cogTasks{i};
    for j = 1:iterations
        result = load(fullfile(root,'metric=predictiveCOD\prediction',currTask,num2str(j-1),'final_result.mat'));
        all_acc(j,i) = mean(result.optimal_acc,1);
        fprintf('Task: %s iteration: %d finished\n',currTask,j);
    end
end
T = array2table(all_acc,'VariableNames',cogTasksNames);
writetable(T,fullfile(root,'metric=predictiveCOD\evaluation','All cogTasks.csv'));
