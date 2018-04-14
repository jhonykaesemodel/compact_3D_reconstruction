function voxel_iou = compute_all_voxel_iou(fgraph)

voxel_iou = nan(fgraph.num_nodes);
for i = 1:fgraph.num_nodes
    for j = 1:fgraph.num_nodes
        if i == j
            voxel_iou(i,j) = NaN;
            continue;
        end
        voxelIoU_score = compute_voxel_iou(fgraph, i, j);
        voxel_iou(i,j) = voxelIoU_score;
        
        fprintf('Voxel IoU score of Node %d to %d is %.4f\n', i, j, voxelIoU_score);
    end
end

