function callbackClickA3DPoint(src, eventData, pointCloud, handles)
% CALLBACKCLICK3DPOINT mouse click callback function for CLICKA3DPOINT
%
%   The transformation between the viewing frame and the point cloud frame
%   is calculated using the camera viewing direction and the 'up' vector.
%   Then, the point cloud is transformed into the viewing frame. Finally,
%   the z coordinate in this frame is ignored and the x and y coordinates
%   of all the points are compared with the mouse click location and the 
%   closest point is selected.
%
%   Babak Taati - May 4, 2005
%   revised Oct 31, 2007
%   revised Jun 3, 2008
%   revised May 19, 2009

point = get(gca, 'CurrentPoint'); % mouse click position
camPos = get(gca, 'CameraPosition'); % camera position
camTgt = get(gca, 'CameraTarget'); % where the camera is pointing to

camDir = camPos - camTgt; % camera direction
camUpVect = get(gca, 'CameraUpVector'); % camera 'up' vector

% build an orthonormal frame based on the viewing direction and the 
% up vector (the "view frame")
zAxis = camDir/norm(camDir);    
upAxis = camUpVect/norm(camUpVect); 
xAxis = cross(upAxis, zAxis);
yAxis = cross(zAxis, xAxis);

rot = [xAxis; yAxis; zAxis]; % view rotation 

% the point cloud represented in the view frame
rotatedPointCloud = rot * pointCloud; 

% the clicked point represented in the view frame
rotatedPointFront = rot * point' ;

% find the nearest neighbour to the clicked point 
idxCP = dsearchn(rotatedPointCloud(1:2,:)', ... 
    rotatedPointFront(1:2));

h = findobj(gca,'Tag','pt'); % try to find the old point
selectedPoint = pointCloud(:, idxCP); 

if isempty(h) % if it's the first click (i.e. no previous point to delete)
    
    % highlight the selected point
    h = plot3(selectedPoint(1,:), selectedPoint(2,:), ...
        selectedPoint(3,:), 'r.', 'MarkerSize', 20); 
    set(h,'Tag','pt'); % set its Tag property for later use   

else % if it is not the first click

    delete(h); % delete the previously selected point
    
    % highlight the newly selected point
    h = plot3(selectedPoint(1,:), selectedPoint(2,:), ...
        selectedPoint(3,:), 'r.', 'MarkerSize', 40);  
    set(h,'Tag','pt');  % set its Tag property for later use

end

valX_CP = pointCloud(1,idxCP);
set(handles.slider9,'Value',valX_CP);
set(handles.text23,'String',num2str(valX_CP,'%.4f'))

valY_CP = pointCloud(2,idxCP);
set(handles.slider10,'Value',valY_CP);
set(handles.text24,'String',num2str(valY_CP,'%.4f'))

valZ_CP = pointCloud(3,idxCP);
set(handles.slider11,'Value',valZ_CP);
set(handles.text25,'String',num2str(valZ_CP,'%.4f'))

set(handles.text32,'String',num2str(idxCP,'%d'));

fprintf('Control Point: %d | x: %.4f | y: %.4f | z: %.4f\n', idxCP, selectedPoint(1), selectedPoint(2), selectedPoint(3));
save('FFD\idxCP.mat', 'idxCP')
