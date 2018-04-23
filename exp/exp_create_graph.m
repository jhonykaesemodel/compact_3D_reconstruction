add_paths;
data_paths;

%class = 'diningtable';
%class = 'bicycle';
%class = 'car';
%class = 'chair';
%class = 'motorbike';
%class = 'sofa';
class = 'aeroplane';
%class = 'bus';

class_uid = class2uid(class);

%% create FFD-LDC graph
fgraph = create_graph(class_uid);

%% show models
showGraphModels(fgraph);

%% plot the FFD-LDC graph
figure, drawGraph(fgraph, 'FontSize', 20, ...
                           'MarkerSize', 10, ...
                           'DeltaSize', 10, ...
                           'LineWidth', 1, ...
                           'ColorMap', 'solarized', ...
                           'ScaleFactor', 0.93);
                       
%% show deformations
source = 1;
target = 4;
show_deformed_models(fgraph, source, target, true);
