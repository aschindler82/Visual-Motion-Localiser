function [coords varargout] = myGluProject(inX, inY, inZ, GL, win, varargin)
% [ coords [,dotSizes] ] = myGluProject(inX, inY, inZ, GL, [,zNearest] [,maxDotSize])
% 
% Custom implemented OpenGL gluProject function.
% The OpenGL function can only handle one vertex at a time.
% This function can take several vertices.
%
% http://snipplr.com/view/10693/
%
% Optionally: get dot sizes
%
% _________________________________
%
% Written by as 12/2013

if nargin <= 4
    win = [];
end

if nargin > 5    
    zNearest   = varargin{1};
    maxDotSize = varargin{2};
else
    zNearest   = [];
    maxDotSize = [];
end

if nargin == 8
    
    % get previously saved matrices from struct
    myMats = varargin{3};
    
    modelMatrix = myMats.modMat;
    projMatrix  = myMats.projMat;
    
    viewPort    = myMats.viewPort;
    
    modelViewMat = myMats.modViewMat;
else
    
    % get matrices from openGL directly
    modelMatrix = glGetDoublev(GL.MODELVIEW_MATRIX);
    modelMatrix = reshape(modelMatrix, 4, 4);

    projMatrix = glGetDoublev(GL.PROJECTION_MATRIX);
    projMatrix = reshape(projMatrix, 4, 4);
    
    viewPort = glGetDoublev(GL.VIEWPORT);
        
    modelViewMat = glGetDoublev(GL.MODELVIEW);
    modelViewMat = reshape(modelViewMat, 4, 4);
end

inW = ones(size(inX));

coords = [inX; inY; inZ; inW];

% get dot sizes
if ~isempty(zNearest)    
    
    tmpCoords = modelViewMat * coords;
    dotSizes = zNearest./(-tmpCoords(3,:))*maxDotSize;
    
    varargout{1} = dotSizes;
end



%coords = modelMatrix * coords;
%coords = projMatrix  * coords;

coords = projMatrix * modelMatrix * coords;

% divide by w
coords(1,:) = coords(1,:) ./ coords(4,:);
coords(2,:) = coords(2,:) ./ coords(4,:);
coords(3,:) = coords(3,:) ./ coords(4,:);

% Map x, y and z to range 0-1
coords(1,:) = coords(1,:) * 0.5 + 0.5;
coords(2,:) = coords(2,:) * 0.5 + 0.5;
coords(3,:) = coords(3,:) * 0.5 + 0.5;

% Map x,y to viewport


coords(1,:) = coords(1,:) * viewPort(3) + viewPort(1);
coords(2,:) = coords(2,:) * viewPort(4) + viewPort(2);

if ~isempty(win)
    coords(2,:) = RectHeight(Screen('Rect', win)) - coords(2,:);
end

return

end