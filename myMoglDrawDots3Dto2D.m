function myMoglDrawDots3Dto2D(windowPtr, xyz, myMats, dotcolor, dot_type, xyOff, radAngle, glslshader)
% function myMoglDrawDots2D(windowPtr, xy, dotdiameter, dotcolor, dot_type, glslshader)
%
% This function is an adpated version of moglDrawDots3D and meant for
% drawing of 2D dots with shader support.
%
% This function is actually a big mess and should be cleaned up at some
% poin (feel free!). :-)
%
% To be honest, this function and especially the associated shader is probably horrible to read for anyone
% who is experienced in openGL and there might be a hundred ways to solve this problem more efficiently.
%
% :-) However: It suits our purposes!
%
% Here we basically take a given 3D vertex and project it to screen coords.
% Then we move it in 2D in a pixel wise fashion (read also: motionLoc3Dto2D.vert).
% The openGL projection is orthographic. Thus, we submit the perspective
% projection matrix to the shader to do the manual work (very ugly -> but working :-) ).
%
% PS: I am aware that shifting the viewport instead of the 2D projected
%     dot cloud would be an option.
%
%     However then we would loose the option to
%     introduce radial flow at some point later in time, easily.
% 
% written by as, 11/2013


% TEXT FROM moglDrawDots3D (mostly deprecated)
%
% Usage: moglDrawDots3D(windowPtr, xyz [,dotdiameter] [,dotcolor] [,center3D] [,dot_type] [, glslshader]);
%
% This function is the 3D equivalent of the Screen('DrawDots') subfunction
% for fast drawing of 2D dots. It has mostly the same paramters as that
% function, but extended into the 3D domain. It accepts a subset of the
% parameters for that function, ie., it is less liberal in what it accepts,
% in order to allow for simpler code and maximum efficiency.
%
% As a bonus, it accepts one additional parameter 'glslshader', the
% optional handle to a GLSL shading program, e.g., as loaded from
% filesystem via LoadGLSLProgram().
%
% The routine will draw into the 3D OpenGL userspace rendering context of
% onscreen window or offscreen window (or texture) 'windowPtr'. It will
% automatically switch to that window if it isn't already active in 3D
% mode, and it will restore the drawing target to whatever was set before
% invocation in whatever mode (2D or 3D). This is a convenience feature for
% lazy users that mostly draw in 2D. If you intend to draw more stuff in 3D
% for a given frame, then you should switch your targetwindow 'windowPtr'
% into 3D mode manually via Screen('BeginOpenGL') yourself beforehand. This
% will avoid redundant and expensive context switches and increase the
% execution speed of your code!
%
% Parameters and their meaning:
%
% 'windowPtr' Handle of window or texture to draw into.
% 'xyz' A 3-by-n or 4-by-n matrix of n dots to draw. Each column defines
% one dot to draw, either as 3D position (x,y,z) or 4D position (x,y,z,w).
% Must be a double matrix!
%
% 'dotdiameter' optional: Either a single scalar spec of dot diameter, or a
% vector of as many dotdiameters as dots 'n', or left out. If left out, a
% dot diameter of 1.0 pixels will be used. Drawing of dots of different
% sizes is much less efficient than drawing of dots of identical sizes! Try
% to group many dots of identical size into separate calls to this function
% for best performance!
%
% 'dotcolor' optional: Either a 3 or 4-component [R,G,B] or [R,G,B,A] color
% touple with a common drawing color, or a 3-by-n or 4-by-n matrix of
% colors, one [R;G;B;A] column for each individual dot. A common color for
% all dots is faster.
%
% 'dot_type' optional: A setting of zero will draw rectangular dots, a
% setting of 1 will draw round dots, a setting of 2 will draw round dots of
% extra high quality if the hardware supports that. For anti-aliased dots
% you must select a setting of 1 or 2 and enable alpha blending as well.
%
% 'glslshader' optional: If omitted, shading state is not changed. If set
% to zero, then the standard fixed function OpenGL pipeline is used, like
% in Screen('DrawDots') (under most circumstances). If a positive
% glslshader handle to a GLSL shading program object is provided, that
% shader program will be used. You can use this, e.g., to bind a custom vertex
% shader to perform complex per-dot calculations very fast on the GPU.
%
% See 

% History:
% 03/01/2009  mk  Written.

% Need global GL definitions:
global GL;


% Child protection:
if isempty(GL)
    error('Need OpenGL mode to be enabled, which is not the case! Call InitializeMatlabOpenGL at start of your script first!');
end

if nargin < 1 || isempty(windowPtr)
    error('"windowPtr" window handle missing! This is required!');
end

if nargin < 2 || isempty(xyz)
    % xy dot position matrix is empty! Nothing to do for us:
    return;
end

if ndims(xyz)~=2
    error('"xy" matrix with 2D dot positions is not a 2D matrix! This is required!');
end

% Want single xy vector as a 2 row, 1 column vector:

if size(xyz, 1) ~= 2
    xyz = transpose(xyz);       
end

nvc = size(xyz, 1);
nrdots = size(xyz, 2);




if nargin < 4
    dotcolor = [];
end

if ~isempty(dotcolor)
    % Want single dotcolor vector as a 4 row, 1 column vector:
    if (size(dotcolor, 1) == 1) && (ismember(size(dotcolor, 2), [3,4]))
        dotcolor = transpose(dotcolor);
    end

    ncolors = size(dotcolor, 2);
    ncolcomps = size(dotcolor, 1);
    if  ~ismember(ncolcomps, [3,4]) || (ncolors~=1 && ncolors~=nrdots)
        error('"dotcolor" must be a matrix with 3 or 4 rows and at least 1 column, or as many columns as dots to draw!');
    end
else
    ncolors = 0;
end


if nargin < 5 || isempty(dot_type)
    % Default to "no point smoothing set":
    dot_type = 0;
end

if nargin < 6
    % Default to no change of shader bindings:
    glslshader = [];
end

% Is the OpenGL userspace context for this 'windowPtr' active, as required?
[previouswin, IsOpenGLRendering] = Screen('GetOpenGLDrawMode');
PreIsOpenGLRendering = IsOpenGLRendering;

% Our target window windowPtr already active?
if previouswin ~= windowPtr
    % No. Wrong window. OpenGL rendering for this window active?
    if IsOpenGLRendering
        % Yes. We need to disable OpenGL mode for that other window and
        % switch to our window:
        Screen('EndOpenGL', windowPtr);
        
        % Our window is attached, but it is in 2D mode, not 3D mode yet:
        IsOpenGLRendering = 0;
    end
end

% Either a different window than ours is bound in 2D mode, then OpenGL
% rendering is not yet active and we need to switch to our window and to
% OpenGL rendering.
%
% Or we just switched from a different window in 3D mode to our window in
% 2D mode. Then we need to switch our window into 3D mode.
%
% In both cases, IsOpenGLRendering == false will indicate this.
%
% A third option is that our wanted window is already active and 3D OpenGL
% mode is already active. In that case IsOpenGLRendering == true and we
% don't need to do anything to switch modes:
if ~IsOpenGLRendering
    % Either some window, or our window bound in 2D mode. Need to switch to
    % our window in 3D mode:
    Screen('BeginOpenGL', windowPtr);
end

% Ok our target window and userspace OpenGL rendering context is bound, we
% can setup and execute the actual drawing:

% Change of shader binding requested?
if ~isempty(glslshader)
      % Backup old shader binding:
     oldShader = glGetIntegerv(GL.CURRENT_PROGRAM);
end

% Point smoothing wanted?
if dot_type > 0
    glEnable(GL.POINT_SMOOTH);
    
    if dot_type > 1
        % A dot type of 2 requests for highest quality point smoothing:
        glHint(GL.POINT_SMOOTH_HINT, GL.NICEST);
    else
        glHint(GL.POINT_SMOOTH_HINT, GL.DONT_CARE);
    end
end

% Pass a pointer to the start of the point-coordinate array:
glVertexPointer(nvc, GL.DOUBLE, 0, xyz);

% Enable fast rendering of arrays:
glEnableClientState(GL.VERTEX_ARRAY);

% Multiple colors, one per dot, provided?
if ncolors > 0
    if ncolors > 1
        % Yes. Setup a color array for fast drawing:
        glColorPointer(ncolcomps, GL.DOUBLE, 0, dotcolor);
        glEnableClientState(GL.COLOR_ARRAY);
    else
        % No. Just set one single common color:
        if ncolcomps == 4
            glColor4dv(dotcolor);
        else
            glColor3dv(dotcolor);
        end
    end
end

   
% use shader
% a bit ugly but it's working: submit
% dot sizes as z-coord to shader
glUseProgram(glslshader);

glUniformMatrix4fv(glGetUniformLocation(glslshader, 'modelViewMat'), 1, 0, myMats.modViewMat);
glUniformMatrix4fv(glGetUniformLocation(glslshader, 'modelMat'),     1, 0, myMats.modMat);
glUniformMatrix4fv(glGetUniformLocation(glslshader, 'projMat'),      1, 0, myMats.projMat);
glUniform4fv(glGetUniformLocation(glslshader, 'viewPortVec'),        1,    myMats.viewPort);

glUniform2fv(glGetUniformLocation(glslshader, 'zNearFar'),           1,    myMats.zNearFar);
glUniform2fv(glGetUniformLocation(glslshader, 'xyOff'),              1,    xyOff);

glUniform1f(glGetUniformLocation(glslshader, 'maxDotSize'),                myMats.maxDotSize);

% draw dots
glDrawArrays(GL.POINTS, 0, nrdots);


if ~isempty(glslshader)
    % Reset old shader binding:
    glUseProgram(oldShader);
end

if ncolors > 1
    % Disable color array for fast drawing:
    glColorPointer(ncolcomps, GL.DOUBLE, 0, 0);
    glDisableClientState(GL.COLOR_ARRAY);
end

% Disable fast rendering of arrays:
glDisableClientState(GL.VERTEX_ARRAY);
glVertexPointer(nvc, GL.DOUBLE, 0, 0);

if dot_type > 0
    glDisable(GL.POINT_SMOOTH);
end

% if ~isempty(center3D)
%     % Restore old modelview matrix from backup:
%     glPopMatrix;
% end

% Reset dot size to 1.0:
glPointSize(1);

% Our work is done. If a different window than our target window was
% active, we'll switch back to that window and its state:
if previouswin ~= windowPtr
    % Different window was active before our invocation. Need to disable
    % our 3D mode and switch back to that window (in 2D mode):
    Screen('EndOpenGL', previouswin);
    
    % Was that window in 3D mode, i.e., OpenGL rendering for that window was active?
    if PreIsOpenGLRendering
        % Yes. We need to switch that window back into 3D OpenGL mode: 
        Screen('BeginOpenGL', previouswin);
    end
else
    % Our window was active beforehand. Was it in 2D mode? In that case we
    % need to switch our window back to 2D mode. Otherwise we'll just stay
    % in 3D mode:
    if ~PreIsOpenGLRendering
        % Was in 2D mode. We need to switch back to 2D:
        Screen('EndOpenGL', windowPtr);
    end
end

% Switchback complete. The graphics system is the same state as it was
% before our invocation.
return;
