add_paths;
data_paths;

classes = {'aeroplane', 'bus', 'chair', 'diningtable', 'sofa', 'car', 'bicycle', 'motorbike'};

table = [];
for j = 1:numel(classes)   
    class = classes{j};
    class_uid = class2uid(class);
    % load results
    files = dir(fullfile(Result_dir, class));
    fgraph = create_graph(class_uid);

%% results
error_R_LR = [];
error_P_LR = [];
error_S_LR = [];
error_R_SF = [];
error_P_SF = [];
error_S_SF = [];

for i = 3:numel(files)
    fname = files(i).name;
    load(fullfile(Result_dir, class, fname));   
    obj = result.obj.obj;
    I = result.I;
    c = result.c;
    
    %% eval results FFD-LR
    % reprojection error
    mask = (~isnan(I.anchors(:, 1)));
    W = im2xy(I.anchors(mask, :)', size(I.image));
    S = result.obj.FFD.vtx(result.obj.FFD.anchor(mask),:)';
    What = bsxfun(@plus,result.obj.projection.scale*result.obj.projection.rotation*S, result.obj.projection.translation);
    R_LR_i = mean(sqrt(sum((W - What).^2, 1)));
    
%     figure, plot(W(1,:), W(2,:), 'bo'), hold on
%     plot(What(1,:), What(2,:), 'r.')
    
    theta = 0.1;
    [P_LR_i, S_LR_i] = eval_result(I, result.obj.FFD, result.obj.projection, theta);
    error_R_LR = [error_R_LR, R_LR_i];
    error_P_LR = [error_P_LR, P_LR_i];
    error_S_LR = [error_S_LR, S_LR_i];
    
    %% eval results SF
    % reprojection error
    S = result.model.vtx(result.model.anchor(mask),:)';
    What = bsxfun(@plus,result.sfit.projection.scale*result.sfit.projection.rotation*S, result.sfit.projection.translation);
    R_SF_i = mean(sqrt(sum((W - What).^2, 1)));
    
%     figure, plot(W(1,:), W(2,:), 'bo'), hold on
%     plot(What(1,:), What(2,:), 'r.')

    theta = 0.1;
    [P_SF_i, S_SF_i] = eval_result(I, result.model, result.sfit.projection, theta);
    error_R_SF = [error_R_SF, R_SF_i];
    error_P_SF = [error_P_SF, P_SF_i];
    error_S_SF = [error_S_SF, S_SF_i]; 
end
error_R_LR(isnan(error_R_LR)) = [];
error_R_SF(isnan(error_R_SF)) = [];

lineTable = [str2num(class_uid) mean(error_R_LR) mean(error_P_LR) mean(error_S_LR) mean(error_R_SF) mean(error_P_SF) mean(error_S_SF)];

table = [table; lineTable];

end

table(:,5)*100
save('RESULTS_TABLE', 'table')
