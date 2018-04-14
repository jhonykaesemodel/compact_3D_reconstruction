function varargout = FFD(varargin)
% FFD MATLAB code for FFD.fig
%      FFD, by itself, creates a new FFD or raises the existing
%      singleton*.
%
%      H = FFD returns the handle to a new FFD or the handle to
%      the existing singleton*.
%
%      FFD('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FFD.M with the given input arguments.
%
%      FFD('Property','Value',...) creates a new FFD or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before FFD_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to FFD_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help FFD

% Last Modified by GUIDE v2.5 18-Mar-2017 14:41:59

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @FFD_OpeningFcn, ...
                   'gui_OutputFcn',  @FFD_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

% --- Executes just before FFD is made visible.
function FFD_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to FFD (see VARARGIN)

% Choose default command line output for FFD
handles.output = hObject;

% UIWAIT makes FFD wait for user response (see UIRESUME)
% uiwait(handles.figure1);
add_paths()

%% Layers (4x4) in the X direction
handles.idxLayerX1 = [1;5;9;13; 17;21;25;29; 33;37;41;45; 49;53;57;61];
handles.idxLayerX2 = handles.idxLayerX1 + 1;
handles.idxLayerX3 = handles.idxLayerX2 + 1;
handles.idxLayerX4 = handles.idxLayerX3 + 1;
%% Layers (4x4) in the Y direction
handles.idxLayerY1 = [1;2;3;4; 17;18;19;20; 33;34;35;36; 49;50;51;52];
handles.idxLayerY2 = handles.idxLayerY1 + 4;
handles.idxLayerY3 = handles.idxLayerY2 + 4;
handles.idxLayerY4 = handles.idxLayerY3 + 4;
%% Layers (4x4) in the Z direction
handles.idxLayerZ1 = 1:16;
handles.idxLayerZ2 = handles.idxLayerZ1 + 16;
handles.idxLayerZ3 = handles.idxLayerZ2 + 16;
handles.idxLayerZ4 = handles.idxLayerZ3 + 16;

% Update handles structure
guidata(hObject, handles);


% --- Outputs from this function are returned to the command line.
function varargout = FFD_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

% deform Y layers
handles.P(handles.idxLayerY1,2) = get(hObject,'Value');
set(handles.text17,'String',num2str(get(hObject,'Value'),'%.4f'));
handles.Xffd = handles.B * handles.P;
updateFFD(hObject, handles)

guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider2_Callback(hObject, eventdata, handles)
% hObject    handle to slider2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
% deform Y layers
handles.P(handles.idxLayerY2,2) = get(hObject,'Value');
set(handles.text18,'String',num2str(get(hObject,'Value'),'%.4f'));
handles.Xffd = handles.B * handles.P;
updateFFD(hObject, handles)
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function slider2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider3_Callback(hObject, eventdata, handles)
% hObject    handle to slider3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
% deform Y layers
handles.P(handles.idxLayerY3,2) = get(hObject,'Value');
set(handles.text19,'String',num2str(get(hObject,'Value'),'%.4f'));
handles.Xffd = handles.B * handles.P;
updateFFD(hObject, handles)
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function slider3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider4_Callback(hObject, eventdata, handles)
% hObject    handle to slider4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
% deform Y layers
handles.P(handles.idxLayerY4,2) = get(hObject,'Value');
set(handles.text20,'String',num2str(get(hObject,'Value'),'%.4f'));
handles.Xffd = handles.B * handles.P;
updateFFD(hObject, handles)
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function slider4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

cla

% show pascal3D annotations
if isfield(handles,'class')
    cls = handles.class;
else
    handles.class = 'bunny';
    cls = handles.class;  
end

% load Bunny
if handles.class == "bunny"
    load('bunny.mat');
    cad = bunny;
    % rotate the bunny by 90 degrees around the x axis
    theta = 90;
    Rx = [  1  0           0;
        0  cosd(theta)  -sind(theta);
        0  sind(theta)  cosd(theta)];
    cad.vertices = (Rx*cad.vertices')';
    handles.cad = cad;
else
    % load PASCAL3D+ cad models
    handles.cad_index = 1; % 5
    handles.cad = load_model(handles.class, handles.cad_index, 'dataset', 'pascal', 'load_info', false);
end


handles.face = handles.cad.faces;

meshInfo = get_mesh_info(handles.cad);

%% init the FFD axis - STU coordinate system
ffdObj = ClassFFD;
ffdCoord = ffdObj.initAxes(meshInfo);

%% create the grid of control points (lattice)
% set the number of planes - l+1, m+1, n+1
handles.l = 3;
handles.m = 3;
handles.n = 3;
[handles.lattice, ~] = ffdObj.initControlLattice(ffdCoord, handles.l, handles.m, handles.n);

%% perform the FFD deformation
% get P (numCP X 3)
P = handles.lattice(:);
handles.P = cell2mat(struct2cell(P))';
handles.Po = handles.P;

handles.B = get_deformation_matrix(meshInfo, ffdCoord, handles.l, handles.m, handles.n);

handles.Xffd = handles.B * handles.P;
handles.Xo = handles.Xffd;

handles.modelFFD.vertices = handles.Xffd;
handles.modelFFD.faces = handles.face;
handles.modelFFD.anchor = [];

show_model(handles.modelFFD, 'FaceColor', [38 139 210]/255, 'ColorGCA', [7 54 66]/255);
show_FFD_lattice(handles.P, handles.l, handles.m, handles.n);
%rotate3d on
cameratoolbar('Show');

flagCPinit = true;
if flagCPinit
% get the control point index by click
    h = gcf;
    set(h, 'WindowButtonDownFcn', {@callbackClickA3DPoint, handles.P', handles});
    flagCPinit = false;
end

% set value sliders
set(handles.slider5,'Value', handles.P(handles.idxLayerX1(1), 1));
set(handles.text15,'String', num2str(handles.P(handles.idxLayerX1(1),1),'%.4f'));

set(handles.slider6,'Value', handles.P(handles.idxLayerX2(1), 1));
set(handles.text16,'String', num2str(handles.P(handles.idxLayerX2(1),1),'%.4f'));

set(handles.slider1,'Value', handles.P(handles.idxLayerY1(1), 2));
set(handles.text17,'String', num2str(handles.P(handles.idxLayerY1(1),2),'%.4f'));

set(handles.slider2,'Value', handles.P(handles.idxLayerY2(1), 2));
set(handles.text18,'String', num2str(handles.P(handles.idxLayerY2(1),2),'%.4f'));

set(handles.slider3,'Value', handles.P(handles.idxLayerY3(1), 2));
set(handles.text19,'String', num2str(handles.P(handles.idxLayerY3(1),2),'%.4f'));

set(handles.slider4,'Value', handles.P(handles.idxLayerY4(1), 2));
set(handles.text20,'String', num2str(handles.P(handles.idxLayerY4(1),2),'%.4f'));

set(handles.slider7,'Value', handles.P(handles.idxLayerZ1(1), 3));
set(handles.text21,'String', num2str(handles.P(handles.idxLayerZ1(1),3),'%.4f'));

set(handles.slider8,'Value', handles.P(handles.idxLayerZ2(1), 3));
set(handles.text22,'String', num2str(handles.P(handles.idxLayerZ2(1),3),'%.4f'));

guidata(hObject, handles);

function updateFFD(hObject, handles)
handles.Xffd = handles.B * handles.P;
handles.modelFFD.vertices = handles.Xffd;
hold off
show_model(handles.modelFFD, 'FaceColor', [38 139 210]/255, 'ColorGCA', [7 54 66]/255)
show_FFD_lattice(handles.P, handles.l, handles.m, handles.n)
%rotate3d on
cameratoolbar('Show');

% get the control point index by click
h = gcf;
set(h, 'WindowButtonDownFcn', {@callbackClickA3DPoint, handles.P', handles});

guidata(hObject, handles);

% --- Executes on slider movement.
function slider5_Callback(hObject, eventdata, handles)
% hObject    handle to slider5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

% deform X layers symmetrically
valX_1 = get(hObject,'Value');
valX_4 = handles.P(handles.idxLayerX4(1),1) + (handles.P(handles.idxLayerX1(1),1) - valX_1);
handles.P(handles.idxLayerX1,1) = valX_1;
handles.P(handles.idxLayerX4,1) = valX_4;
set(handles.text15,'String',num2str(valX_1,'%.4f'));
handles.Xffd = handles.B * handles.P;
updateFFD(hObject, handles)

guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function slider5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider6_Callback(hObject, eventdata, handles)
% hObject    handle to slider6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
% deform X layers symmetrically
valX_2 = get(hObject,'Value');
valX_3 = handles.P(handles.idxLayerX3(1),1) + (handles.P(handles.idxLayerX2(1),1) - valX_2);
handles.P(handles.idxLayerX2,1) = valX_2;
handles.P(handles.idxLayerX3,1) = valX_3;
set(handles.text16,'String',num2str(valX_2,'%.4f'));
handles.Xffd = handles.B * handles.P;
updateFFD(hObject, handles)

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function slider6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider7_Callback(hObject, eventdata, handles)
% hObject    handle to slider7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
valZ_1 = get(hObject,'Value');
valZ_4 = handles.P(handles.idxLayerZ4(1),3) + (handles.P(handles.idxLayerZ1(1),3) - valZ_1);
handles.P(handles.idxLayerZ1,3) = valZ_1;
handles.P(handles.idxLayerZ4,3) = valZ_4;
set(handles.text21,'String',num2str(valZ_1,'%.4f'));
handles.Xffd = handles.B * handles.P;
updateFFD(hObject, handles)

guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function slider7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider8_Callback(hObject, eventdata, handles)
% hObject    handle to slider8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
valZ_2 = get(hObject,'Value');
valZ_3 = handles.P(handles.idxLayerZ3(1),3) + (handles.P(handles.idxLayerZ2(1),3) - valZ_2);
handles.P(handles.idxLayerZ2,3) = valZ_2;
handles.P(handles.idxLayerZ3,3) = valZ_3;
set(handles.text22,'String',num2str(valZ_2,'%.4f'));
handles.Xffd = handles.B * handles.P;
updateFFD(hObject, handles)

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function slider8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.slider5,'Value', handles.P(handles.idxLayerX1(1), 1));
set(handles.text15,'String', num2str(handles.P(handles.idxLayerX1(1),1),'%.4f'));

set(handles.slider6,'Value', handles.P(handles.idxLayerX2(1), 1));
set(handles.text16,'String', num2str(handles.P(handles.idxLayerX2(1),1),'%.4f'));

set(handles.slider1,'Value', handles.P(handles.idxLayerY1(1), 2));
set(handles.text17,'String', num2str(handles.P(handles.idxLayerY1(1),2),'%.4f'));

set(handles.slider2,'Value', handles.P(handles.idxLayerY2(1), 2));
set(handles.text18,'String', num2str(handles.P(handles.idxLayerY2(1),2),'%.4f'));

set(handles.slider3,'Value', handles.P(handles.idxLayerY3(1), 2));
set(handles.text19,'String', num2str(handles.P(handles.idxLayerY3(1),2),'%.4f'));

set(handles.slider4,'Value', handles.P(handles.idxLayerY4(1), 2));
set(handles.text20,'String', num2str(handles.P(handles.idxLayerY4(1),2),'%.4f'));

set(handles.slider7,'Value', handles.P(handles.idxLayerZ1(1), 3));
set(handles.text21,'String', num2str(handles.P(handles.idxLayerZ1(1),3),'%.4f'));

set(handles.slider8,'Value', handles.P(handles.idxLayerZ2(1), 3));
set(handles.text22,'String', num2str(handles.P(handles.idxLayerZ2(1),3),'%.4f'));

set(handles.text23,'String',0);
set(handles.text24,'String',0);
set(handles.text25,'String',0);

handles.P = handles.lattice(:);
handles.P = cell2mat(struct2cell(handles.P))';
handles.Xffd = handles.B * handles.P;
updateFFD(hObject, handles)

guidata(hObject, handles);


% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1
% Determine the selected data set.
str = get(hObject, 'String');
val = get(hObject,'Value');
% Set current data to the selected data set.
switch str{val}
case 'bunny' 
   handles.class = 'bunny';    
case 'aeroplane' 
   handles.class = 'aeroplane';
case 'bicycle' 
   handles.class = 'bicycle';
case 'boat' 
   handles.class = 'boat';
case 'bottle'
   handles.class = 'bottle';
case 'bus'
   handles.class = 'bus';
case 'car'
   handles.class = 'car';
case 'chair'
   handles.class = 'chair';
case 'diningtable'
   handles.class = 'diningtable';
case 'motorbike'
   handles.class = 'motorbike';
case 'sofa'
   handles.class = 'sofa';   
case 'train'
   handles.class = 'train'; 
case 'tvmonitor'
   handles.class = 'tvmonitor';      
end
% Save the handles structure.
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function slider9_Callback(hObject, eventdata, handles)
% hObject    handle to slider9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
load('FFD\idxCP.mat');
valX_CP = get(hObject,'Value');
handles.P(idxCP,1) = valX_CP;
set(handles.text23,'String',num2str(valX_CP,'%.4f'));
handles.Xffd = handles.B * handles.P;
updateFFD(hObject, handles)
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function slider9_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider10_Callback(hObject, eventdata, handles)
% hObject    handle to slider10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
load('FFD\idxCP.mat');
valY_CP = get(hObject,'Value');
handles.P(idxCP,2) = valY_CP;
set(handles.text24,'String',num2str(valY_CP,'%.4f'));
handles.Xffd = handles.B * handles.P;
updateFFD(hObject, handles)
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function slider10_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider11_Callback(hObject, eventdata, handles)
% hObject    handle to slider11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
load('FFD\idxCP.mat');
valZ_CP = get(hObject,'Value');
handles.P(idxCP,3) = valZ_CP;
set(handles.text25,'String',num2str(valZ_CP,'%.4f'));
handles.Xffd = handles.B * handles.P;
updateFFD(hObject, handles)
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function slider11_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes during object creation, after setting all properties.
function text32_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text32 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

dataFFD.cad = handles.cad;
dataFFD.FFD.l = handles.l;
dataFFD.FFD.m = handles.m;
dataFFD.FFD.n = handles.n;

dataFFD.FFD.init.B = handles.B;
dataFFD.FFD.init.P = handles.Po;
dataFFD.FFD.init.X = handles.Xo;
dataFFD.FFD.init.vertices = handles.Xo;
dataFFD.FFD.init.faces = handles.cad.faces;
dataFFD.FFD.init.anchor = handles.cad.anchor;
dataFFD.FFD.init.anchor_names = handles.cad.anchor_names;

dataFFD.FFD.def.P = handles.P;
dataFFD.FFD.def.X = handles.Xffd;
dataFFD.FFD.def.vertices = handles.Xffd;
dataFFD.FFD.def.faces = handles.cad.faces;
dataFFD.FFD.def.anchor = handles.cad.anchor;
dataFFD.FFD.def.anchor_names = handles.cad.anchor_names;

% get translation due to the FFD coordinates
tx = handles.cad.vertices(1,1) - handles.modelFFD.vertices(1,1);
ty = handles.cad.vertices(1,2) - handles.modelFFD.vertices(1,2);
tz = handles.cad.vertices(1,3) - handles.modelFFD.vertices(1,3);
t_ffd = [tx, ty, tz];
dataFFD.FFD.t_ffd = t_ffd;
%vert = bsxfun(@minus, handles.cad.vertices, t_ffd);

data_paths
if ~exist(SyntheticData_dir, 'dir')
    mkdir(SyntheticData_dir);
end
r_dir = fullfile(SyntheticData_dir, handles.class);
if ~exist(r_dir, 'dir')
    mkdir(r_dir);
end

defId = handles.cad_index;
filename = fullfile(r_dir, sprintf('dataFFD%s%dCP%d.mat', handles.class, size(handles.P,1), defId));
save(filename, 'dataFFD')
