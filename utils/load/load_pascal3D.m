function [images, objects] = load_pascal3D(class, filename)

data_paths
load(fullfile(PASCAL3D_dir, 'Annotations', ...
    sprintf('%s_pascal', class), [filename, '.mat']));
load(fullfile(Anchor_dir, class2uid(class), 'anchor_names.mat'));
%load(fullfile(Anchor_dir_Pascal, class, 'anchor_names.mat'));

images = {};
for iobj = 1:numel(record.objects)
    if strcmp(record.objects(iobj).class, class)
        image.class = class;
        image.filename = filename;
        image.rotation = proj2wproj(record.objects(iobj).viewpoint);
        model_idx = record.objects(iobj).cad_index;
        image.cad = load_model(class, model_idx, 'dataset', 'pascal', ...
            'load_info', false);
        
        % add anchor info
        image.anchors = zeros(numel(anchor_names), 2);
        for ianchor = 1:numel(anchor_names)
            anchor = record.objects(iobj).anchors.(anchor_names{ianchor});
            if isempty(anchor.location)
                image.anchors(ianchor, :) = nan;
            else
                if anchor.location(1) > 0 && anchor.location(2) > 0
                    image.anchors(ianchor, :) = anchor.location;
                else
                    image.anchors(ianchor, :) = nan;
                end
            end
        end
        
        % add image
        image_file = fullfile(PASCAL3D_dir, 'Images', ...
            sprintf('%s_pascal', class), [filename, '.jpg']);
        image.image = imread(image_file);
        
        % add segmentation
        sg_file = fullfile(VOC_dir, 'SegmentationObject', [filename, '.png']);
        if exist(sg_file, 'file')
            sg = imread(sg_file);
            image.segmentation = (sg ~= iobj);
        else
            image.segmentation = [];
        end
        images = [images; image];
    end
end

objects = record.objects;
