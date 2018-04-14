function score = voxel_iou_score(voxel1, voxel2)
    
score = sum(voxel1(:)&voxel2(:))/sum(voxel1(:)|voxel2(:));
