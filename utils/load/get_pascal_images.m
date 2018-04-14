function valid_images = get_pascal_images(cls, isValid)

if nargin < 2
    isValid = true;
end

data_paths
img_dir = fullfile(PASCAL3D_dir, 'Images', sprintf('%s_pascal', cls));
sg_dir = fullfile(VOC_dir, 'SegmentationClass');

img_files = dir(img_dir);
img_names = cell(size(img_files));
to_remove = [];
for i = 1:numel(img_files)
    if strcmp(img_files(i).name(1), '.')
        to_remove = [to_remove; i];
    else
        [~, name, ~] = fileparts(img_files(i).name);
        img_names{i} = name;
    end
end
img_names(to_remove) = [];

to_remove = [];
sg_files = dir(sg_dir);
sg_names = cell(size(sg_files));
for i = 1:numel(sg_files)
    if strcmp(sg_files(i).name(1), '.')
        to_remove = [to_remove; i];
    else
        [~, name, ~] = fileparts(sg_files(i).name);
        sg_names{i} = name;
    end
end
sg_names(to_remove) = [];

existSeg = cellfun(@(x) ~isempty(find(strcmp(sg_names, x), 1)) && ...
    ~strcmp(x(1), '.'), img_names);
images = img_names(existSeg~=0);

if isValid
    valid_images = {};
    for i = 1:numel(images)
        fprintf('.');
        Is = load_pascal3D(cls, images{i});
        for j = 1:numel(Is)
            I = Is{j};
            if numel(find(~isnan(I.anchors(:, 1)))) > nA_of_cls(cls)
                valid_images = [valid_images; images{i}];
                break;
            end
        end
    end
    fprintf('\n');
    
    % Remove some files, they are too big to read
    switch cls
        case 'bottle'
            valid_images(strcmp(valid_images, '2009_005302')) = [];
        case 'chair'
            valid_images(strcmp(valid_images, '2008_000760')) = [];
            valid_images(strcmp(valid_images, '2008_000107')) = [];
    end
else
    valid_images = images;
end
