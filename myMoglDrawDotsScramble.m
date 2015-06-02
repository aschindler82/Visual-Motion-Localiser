function myMoglDrawDotsScramble(windowPtr, dots2Dxy, dots3Dxyz, dotcolor, dot_type, zNear, maxDotSize, glslshader)
% function myMoglDrawDots2D(windowPtr, xy, dotdiameter, dotcolor, dot_type, glslshader)
%
% This function is an adpated version of moglDrawDots3D and meant for
% drawing of 2D dots with shader support. It makes use of custom vertex buffer
% object (VBOs) to submit user defined data to the shader program.
%
% written by as, 12/2013

% ----------------------------------------------------
% TEXT FROM moglDrawDots3D (partly deprecated)
%
% Usage: moglDrawDots3D(windowPtr, xy [,dotdiameter] [,dotcolor] [,center3D] [,dot_type] [, glslshader]);
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
% 'xy' A 3-by-n or 4-by-n matrix of n dots to draw. Each column defines
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

if nargin < 2 || isempty(dots2Dxy)
    % xy dot position matrix is empty! Nothing to do for us:
    return;
end




nrdots = size(dots2Dxy, 2);

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


% prepare data for storing in buffer

% add z and w rows
dots2Dxy  = [dots2Dxy;  zeros(1, size(dots2Dxy, 2)); ones(1, size(dots2Dxy, 2))];

% add w
dots3Dxyz = [dots3Dxyz; ones(1, size(dots3Dxyz, 2))];

% add alpha channel
dotcolor  = [dotcolor; ones(1, size(dotcolor, 2))];

% data x nVertices
bigArray  = [dots2Dxy, dots3Dxyz, dotcolor];

% create buffer with appropriate size
% remember: matlab assigns 8 bytes per
% double variable and 4 bytes per float
myBuffer = glGenBuffers(1);
glBindBuffer(GL.ARRAY_BUFFER, myBuffer);
glBufferData(GL.ARRAY_BUFFER, 8*prod(size(bigArray)), bigArray, GL.STATIC_DRAW);

glBindBuffer(GL.ARRAY_BUFFER, 0);

        
% attribute different VBOs to specific layers
% -> apparently good style as compared to automatic
%    layer association and later query
vertex2DInd = 0;
glBindAttribLocation(glslshader, vertex2DInd, 'vertex2D');

vertex3DInd = 1;
glBindAttribLocation(glslshader, vertex3DInd, 'vertex3D');

colourInd   = 2;
glBindAttribLocation(glslshader, colourInd,   'colour');

% dont forget to link the shader AFTER layer binding! :-)
glLinkProgram(glslshader);

% activate shader
glUseProgram(glslshader);

% enable shader side dot size control
glEnable(GL.VERTEX_PROGRAM_POINT_SIZE);

% submit a few variables to shader
glUniform1f (glGetUniformLocation(glslshader, 'zNear'     ),    zNear     );
glUniform1f (glGetUniformLocation(glslshader, 'maxDotSize'),    maxDotSize);
%glUniform2fv(glGetUniformLocation(glslshader, 'xyOffset'  ), 1, xyOffset2D);


% assign vertex attributes
glBindBuffer(GL.ARRAY_BUFFER, myBuffer);

% enable vertex attributes
glEnableVertexAttribArray(vertex3DInd);
glEnableVertexAttribArray(vertex2DInd);
glEnableVertexAttribArray(colourInd);

% set array pointers:
% -> double: offset of nEntries * 8 bytes ;-)
glVertexAttribPointer(vertex2DInd, 4, GL.DOUBLE, GL.FALSE, 0, 0);
glVertexAttribPointer(vertex3DInd, 4, GL.DOUBLE, GL.FALSE, 0, 8*prod(size(dots2Dxy)));
glVertexAttribPointer(colourInd,   4, GL.DOUBLE, GL.FALSE, 0, 8*prod(size(dots2Dxy)) + 8*prod(size(dots3Dxyz)));

% do actual dot drawing
glDrawArrays(GL.POINTS, 0, nrdots);

% disable vertex attributes
glDisableVertexAttribArray(vertex2DInd);
glDisableVertexAttribArray(vertex3DInd);
glDisableVertexAttribArray(colourInd);

% delete buffer to prevent memory overflow
glDeleteBuffers(1, myBuffer);


if ~isempty(glslshader)
    % Reset old shader binding:
    glUseProgram(oldShader);
end


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
