function varargout = setupOpenGLprojection(winPtr, fovY, zNear, zFar, iod, zScreen)
% setup projection for openGL drawing
% 
% 
    global GL;

    if nargin == 4
        zScreen = zNear;
        iod     = 0;

    elseif nargin == 5
        zScreen = zNear;

    end

    global GL;
    
    % get screen rect
    scrRect = Screen('Rect', winPtr);
    
    % Get the aspect ratio of the screen:
    ar = RectHeight(scrRect) / RectWidth(scrRect);
    
    % Setup the OpenGL rendering context of the onscreen window for use by
    % OpenGL wrapper. After this command, all following OpenGL commands will
    % draw into the onscreen window 'win':
    Screen('BeginOpenGL', winPtr);

    % Set viewport properly:
    glViewport(0, 0, RectWidth(scrRect), RectHeight(scrRect));
    
    % Enable alpha-blending for smooth dot drawing:
    glEnable(GL.BLEND);
    glBlendFunc(GL.SRC_ALPHA, GL.ONE_MINUS_SRC_ALPHA);
        
    % MK: Hier 1x depth test einschalten:
    glEnable(GL.DEPTH_TEST);

    % MK: One time eanble:
    glEnable(GL.VERTEX_PROGRAM_POINT_SIZE);
    
    % MK: 1x mit glClearColor die gewuenschte Hintergrundfarbe
    % setzen, dann kannst du dir das Screen('FillRect') in der Animationschleife
    % sparen.
    % Set background clear color (RGBA)
    % 
    % => how can we do this for separate (virtual) screens?
    % glClearColor(0.333,0.333,0.333,1);
    
    % Clear out the backbuffer: This also cleans the depth-buffer for
    % proper occlusion handling: You need to glClear the depth buffer whenever
    % you redraw your scene, e.g., in an animation loop. Otherwise occlusion
    % handling will screw up in funny ways...
    glClear;
    
    if iod == 0
        
        % Set projection matrix: This defines a perspective projection,
        % corresponding to the model of a pin-hole camera - which is a good
        % approximation of the human eye and of standard real world cameras --
        % well, the best aproximation one can do with 3 lines of code ;-)
        glMatrixMode(GL.PROJECTION);
        glLoadIdentity;

        % Remember that with the projection commands, the near and far coordinates measure
        % distance from the viewpoint and that (by default) you're looking down the negative z axis.
        % Thus, if the near value is 1.0 and the far 3.0, objects must have z coordinates between
        % -1.0 and -3.0 in order to be visible.
        % Here: zScreen and zNear are the same thing
        %       --> e.g. the near clipping plane is
        %           also the projection plane (screen)
        gluPerspective(fovY, 1/ar, zNear, zFar);
        

        % Setup modelview matrix: This defines the position, orientation and
        % looking direction of the virtual camera:
        glMatrixMode(GL.MODELVIEW);
        glLoadIdentity;

        % Cam is located at 3D position (0,0,0), points upright (0,1,0) and
        % fixates
        % at the origin (0,0,0) of the worlds coordinate system:
        % The OpenGL coordinate system is a right-handed system as follows:
        % Default origin is in the center of the display.
        % Positive x-Axis points horizontally to the right.
        % Positive y-Axis points vertically upwards.
        % Positive z-Axis points to the observer, perpendicular to the display
        % screens surface.
        % we don't need it here as default is:
        gluLookAt (0, 0, 0, 0, 0, -100, 0, 1, 0);


    else
        % Exciting: Setup an "Asymmetric frustum parallel axis projection"
        % for stereo projections based on:
        % http://www.orthostereo.com/geometryopengl.html
        
        glMatrixMode(GL.PROJECTION);
        glLoadIdentity;
        
        glMatrixMode(GL.MODELVIEW);
        glLoadIdentity;
        
        top = zNear * tan(deg2rad(fovY)/2);     % sets top of frustum based on fovY and near clipping plane
        right = ar * top;                       % sets right of frustum based on aspect ratio
        frustumShift = (iod/2) * zNear/zScreen;
        
        cams(1).topFrustum       =  top;
        cams(1).bottomFrustum    = -top;
        cams(1).leftFrustum      = -right + frustumShift;
        cams(1).rightFrustum     =  right + frustumShift;
        cams(1).modelTranslation =  iod/2;
        
        cams(2).topFrustum       =  top;
        cams(2).bottomFrustum    = -top;
        cams(2).leftFrustum      = -right - frustumShift;
        cams(2).rightFrustum     =  right - frustumShift;
        cams(2).modelTranslation = -iod/2;
        
        % return cameras
        varargout{1} = cams;
    end
    
    % Finish OpenGL rendering into PTB window. This will switch back to the
    % standard 2D drawing functions of Screen and will check for OpenGL errors.
    Screen('EndOpenGL', winPtr);
    
return;

end