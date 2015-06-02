function currProj = updateProjection(settings, projFlag)
% currProj = updateProjection(projFlag)
%
% projFlag: 1 --> perspective
%           2 --> ortho
%
% ___________________________
%
% Written by as 12/2013


    global GL;
    
    
    % setup perspective projection
    if projFlag == 1

        % setup perspective projection. This might be necessary as we will use
        % an ortho projection for drawing but a perspective
        % projection for feedback
        glMatrixMode(GL.PROJECTION);
        glLoadIdentity;

        % Get the aspect ratio of the screen:        
        ar = RectHeight(settings.scr.rect) / RectWidth(settings.scr.rect);

        % set projection
        gluPerspective(settings.scr.fovY, 1/ar, settings.scr.viewDistMin, settings.scr.viewDistMax);
        glMatrixMode (GL.MODELVIEW)
        glLoadIdentity()

        currProj = 1;
        
	% setup orthographic projection
    elseif projFlag == 2
        
        % setup ortho projection
        glMatrixMode(GL.PROJECTION);
        glLoadIdentity;
        glOrtho(0, settings.scr.width, settings.scr.height, 0, 0, 1);
        
        % disable depth, we only use 2D dots
        %glDisable(GL.DEPTH_TEST);
        
        glMatrixMode (GL.MODELVIEW)
        glLoadIdentity()

        % Displacement tricks for exact pixelization:
        % So far not needed, apparently. I compared the Screen('DrawDots') function
        % with the results.
        % If you run into troubles check these websites:
        %
        % as, 12/2013
        %
        % http://stackoverflow.com/questions/14608395/pixel-perfect-2d-rendering-with-opengl
        %
        % http://basic4gl.wikispaces.com/2D+Drawing+in+OpenGL
        %
        %glOrtho(-0.5, (XSize - 1) + 0.5, (YSize - 1) + 0.5, -0.5, 0.0, 1.0);
        %glTranslatef(0.375, 0.375, 0)
        %glTranslatef(0.5, 0.5, 0)        
        
        currProj = 2;
        
    else
        help updateProjection;
        error('Unknown paramaeter!');
    end


    return;

end