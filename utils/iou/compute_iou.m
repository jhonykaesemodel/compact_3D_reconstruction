function [c, idxIoU, JD] = compute_iou(objs, I, isShow)

if nargin < 4
    isShow = false;
end

% have a look at the IOU to try to pick a better CAD
%% generate the silhouettes
segmentation = cell(numel(objs),1);
disp('Generating silhouettes to compute IoU...')
for i = 1:numel(objs)
    if ~isempty(objs{i}.FFD)
        iptsetpref('ImshowBorder','tight');
        fig = figure;
        set(fig, 'Visible', 'off')
        
        imshow(I.image);
        hold on;
         
        Hmask = imshow(ones(size(I.image, 1), size(I.image, 2)));      
        scale = objs{i}.projection.scale;
        rotation = objs{i}.projection.rotation;
        translation = objs{i}.projection.translation;
        vertex = bsxfun(@plus, scale*rotation*objs{i}.FFD.vtx', translation);
        face = objs{i}.FFD.mesh;
        vertex = im2xy(vertex, size(I.image));
        patch('Vertices', vertex', 'Faces', face, ...
            'FaceColor', 'k', 'FaceAlpha', 1, 'EdgeColor', 'none');
        
        frame = getframe(fig);
        segmentation_aux = frame2im(frame);
        segmentation_aux = reshape(segmentation_aux, size(I.image, 1), size(I.image,2), size(I.image,3));
        segmentation{i} = logical(rgb2ind(segmentation_aux, 256));
        segmentation{i} = ~segmentation{i};   
    else
        segmentation{i} = [];
    end
end
disp('Done!')
close all

% show segmentations
if isShow
    figure
    for i = 1:numel(objs)
        imshow(segmentation{i});
        hold off
        pause
    end
end

%% compute IoU
target_seg = ~I.segmentation;

JD = zeros(numel(objs),1);
for i = 1:numel(objs)
   % Jaccard index
    if ~isempty(segmentation{i})
        JD(i) = 1 - sum(segmentation{i} & target_seg)/sum(segmentation{i} | target_seg);  
    else
        JD(i) = NaN;
    end
end

% sort Jaccard index
[JD_sorted, JD_idx] = sort(JD, 'ascend');

% CAD model chosen
idxIoU = JD_sorted(1);
c = JD_idx(1);


%% show
% iou_gt_est = target_seg + segmentation{i};
% figure, 
% imagesc(iou_gt_est)
% cmap = jet(max(iou_gt_est(:)));
% cmap(1,:) = 0;
% cmap(2,:) = 0.6;
% cmap(3,:) = 1;
% colormap(cmap);
% colorbar

% % if the estimated silhouette completely matches the GT we have
% % 2X the number of 1s in the silhouette
% iou_num_2s_target = sum(target_seg(target_seg == 1)) * 2;
% % the number of 2s in the IOU
% iou_gt_est_2s = sum(iou_gt_est(iou_gt_est == 2));
% 
% iou_num_2s_target - iou_gt_est_2s 
% 
% % numbers of 1s in the IOU, if it's high it means that the silhouette is
% % overfilling the GT silhouette
% iou_gt_est_1s = sum(iou_gt_est(iou_gt_est == 1));
