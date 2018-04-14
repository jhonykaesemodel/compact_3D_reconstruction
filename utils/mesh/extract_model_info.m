function info = extract_model_info(class_uid, varargin)

ip = inputParser;
addOptional(ip, 'model_uid', 'all');
addOptional(ip, 'properties', {'uid'});
parse(ip, varargin{:});
option = ip.Results;

% Load CSV file
data_paths
csv_file = fullfile(ShapeNet_dir, [class_uid, '.csv']);
fileID = fopen(csv_file);
C = textscan(fileID, '%q%q%q%q%q%q%q', ...
    'delimiter', {','}, 'EndOfLine', '\n', 'headerlines', 1, ...
    'MultipleDelimsAsOne', true);
fclose(fileID);

% Process info
if strcmp(option.model_uid, 'all')
    if numel(option.properties) == 1
        properties = {'fullid', 'wnsynset', 'wnlemmas', 'up', 'front', ...
                    'name', 'tag', 'uid'};
        iprop = find(cellfun(@(x) strcmpi(x, option.properties{1}), ...
            properties));
        if isempty(iprop)
            error('No property called %s', option.properties{1});
        elseif iprop == 8
            info = cellfun(@get_uid, C{1}, 'UniformOutput', false);
        else
            info = C{iprop};
        end
    else
        error(['Currently cannot output multiple properties for', ...
            'multiple classes']);
    end
else
    uids = cellfun(@get_uid, C{1}, 'UniformOutput', false);
    imodel = find(cellfun(@(x) strcmp(x, option.model_uid), uids));
    info.fullId = C{1}{imodel};
    fullId = strsplit(info.fullId, '.');
    info.prefix = fullId{1};
    info.uid = fullId{2};
    info.wnsynset = C{2}{imodel};
    info.wnlemmas = C{3}{imodel};
    upstr = strsplit(C{4}{imodel}, '\\,');
    info.up = cellfun(@str2num, upstr);
    frontstr = strsplit(C{5}{imodel}, '\\,');
    info.front = cellfun(@str2num, frontstr);
    info.name = C{6}{imodel};
    info.tags = C{7}{imodel};
end
