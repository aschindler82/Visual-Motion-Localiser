function rc = getShaderFeedback(win, xyz, GL, fbShader)
% rc = getShaderFeedback(win, xyz, GL, fbShader)
%
% win      -> PTB window handle
% xyz      -> 3 x n dot vector
% GL       -> openGL global environment variable
% fbShader -> handle to the pre-loaded shader file
%
% This function will project a given number of 3D dots on the screen and
% provide their 2D coordinates as feedback. To keep each dot's identity
% we apply a little (dirty?) trick inside the vertex shader script:
%
% Every dot that falls outside the screen gets a feedback value of
% [0 0 0.5] i.e. [x y z depthBuffer] and thus theoretically is projected on
% the left upper corner.
%
% Note:
% Of course this is a heuristic approach and theoretically may lead to
% missed dots that would exactly fall on the coordinate 0 0 at a depth of 0.5.
%
% _____________________________________
%
% Written by as, 12/2013


    % Is the OpenGL userspace context for this 'windowPtr' active, as required?
    [previouswin, IsOpenGLRendering] = Screen('GetOpenGLDrawMode');
    PreIsOpenGLRendering = IsOpenGLRendering;

    drawDots = 0;

    % important: Cast array to Single Float precision
    % else we have to change buffer size and readout
    % i.e. to double; float = 4 bytes / value ; double = 8 bytes
    xyz = moglsingle(xyz);
    [nvc nrdots] = size(xyz);

    if ~IsOpenGLRendering
        % Either some window, or our window bound in 2D mode. Need to switch to
        % our window in 3D mode:
        Screen('BeginOpenGL', win);
    end
    
    
    % backup old shader
    oldShader = glGetIntegerv(GL.CURRENT_PROGRAM);
    
    % use feedback shader providing vertex ids
    glUseProgram(fbShader);

    if drawDots

        % Pass a pointer to the start of the point-coordinate array:
        glVertexPointer(nvc, GL.FLOAT, 0, xyz);

        % Enable fast rendering of arrays:
        glEnableClientState(GL.VERTEX_ARRAY);

        % draw dots
        glDrawArrays(GL.POINTS, 0, nrdots);

        glDisableClientState(GL.VERTEX_ARRAY);
        glVertexPointer(nvc, GL.FLOAT, 0, 0);
        
        Screen('Flip', win);

    end

    %% test feedback
           

    % Correct for 0-start of OpenGL/C vs. 1-start of Matlab:
    startidx =  0;
    endidx   = nrdots-1;

    % Total count of vertices to handle:
    ntotal = endidx - startidx + 1;

    % We put OpenGL into feedback mode, do a pure point rendering pass, switch back to
    % normal mode and return the content of the feedback buffer in an easy format.

    % Compute needed capacity of feedbackbuffer, assuming all vertices in the buffer
    % get transformed and none gets clipped away:
    reqbuffersize = ntotal * 4 * 4; % numVertices * 4 float/vertex * 4 bytes/float.

    feedbackptr  = moglmalloc(reqbuffersize);
    feedbacksize = reqbuffersize;

    % Our feedback memory buffer is ready. Assign it to the GL: We request the
    % full transformed 3D pos of the vertex:
    glFeedbackBuffer(reqbuffersize/4, GL.GL_3D, feedbackptr);

    % Enable client-side vertex arrays:
    glEnableClientState(GL.VERTEX_ARRAY);

    % Set pointer to start of vertex array:
    glVertexPointer(size(xyz,1), GL.FLOAT, 0, xyz);

    % Put OpenGL into feedback mode:
    glRenderMode(GL.FEEDBACK);

    % Render vertices: This does not draw, but just transform the vertices
    % into projected screen space and returns their 3D positions in the feedback-buffer:
    glDrawArrays(GL.POINTS, startidx, ntotal);

    % Disable client-side vertex arrays:
    glDisableClientState(GL.VERTEX_ARRAY);

    % Put OpenGL back into normal mode and get number of items:
    nritems = glRenderMode(GL.RENDER);

    tmpbuffer = moglgetbuffer(feedbackptr, GL.FLOAT, nritems * 4);

    % Reshape it to be a n-by-4 matrix:
    tmpbuffer = transpose(reshape(tmpbuffer, 4, floor(nritems / 4)));
    % Cast to double, throw away token column:
    rc(:,1:3) = double(tmpbuffer(:,2:4));
    % Invert y-coordinates so they match again:
    rc(:,2)   = RectHeight(Screen('Rect', win)) - rc(:,2);

    % load old shader
    glUseProgram(oldShader);
    
    % free buffer
    moglfree(feedbackptr);
    %moglfreeall;
    
    % Our window was active beforehand. Was it in 2D mode? In that case we
    % need to switch our window back to 2D mode. Otherwise we'll just stay
    % in 3D mode:
    if ~PreIsOpenGLRendering
        % Was in 2D mode. We need to switch back to 2D:
        Screen('EndOpenGL', win);
    end

    return;

end