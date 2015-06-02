function [c, d] = threedMotionCuboid(c, d)
% d, [flownDotsZ] = threedMotionCuboid(d, c)

    %% ========= move stars according to user settings =========
    % Note: Radial Rotation around z-axis and planar motion
    % is done by shader. i.e. we here only update the indices to the
    % current angle / xy-offset and submit these values to the shader in
    % the main script
    
    
    % move dots along x and y axes
    if ~c.staticDots
        
        % save last posInd2D to calc relative
        % xy dist later on
        d.posInd2Dlast = d.posInd2D;
        
        % index to 2D plana rmotion vector
        d.posInd2D = d.posInd2D + 1;
        if d.posInd2D > length(d.xCo)
           d.posInd2D = 1;
        end
        
        % index to 2D plana rmotion vector
        d.posInd3D = d.posInd3D + 1;
        if d.posInd3D > length(d.xCo3D)
           d.posInd3D = 1;
        end
       
    end

    
    % move dots along z axis
    if ~c.staticDots && ~c.dots2D
        
        % index to 3D forth and back motion vector
        d.speedInd3D = d.speedInd3D + 1;
        if d.speedInd3D > length(d.speedVec3D)
           d.speedInd3D = 1;
        end

    end
    
    
    % increase angle by which dots are rotated radially
    % i.e. aorund z-axis.
    % we will use a shader for that as matrix rotations of huge dot clouds
    % cost a lot of CPU power and would lead to frame losses
    if c.radRot
        
        % index to radial motion angle vector
        d.radAngleInd = d.radAngleInd + 1;
        if d.radAngleInd > length(d.radAngleVec)
           d.radAngleInd = 0;
        end
                
    end
    

    
    
    return;
    
end