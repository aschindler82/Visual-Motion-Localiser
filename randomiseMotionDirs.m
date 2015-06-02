function [c d] = randomiseMotionDirs(c, d)

    if c.dots2D || c.movFix
        
        % reset 2D planar index
        d.posInd2D = 0;
        
        % randomise direction of 2D planar motion
        currMoDir = 1-2*round(rand(1,1));
        d.xCo = d.xCo * currMoDir;
        d.yCo = d.yCo * currMoDir;

    end

    
    if c.dots3D || c.dotScramble3D
        
        % set back index of forth and back flow
        d.speedInd3D = 0;
        
        % randomise direction of forth and back flow
        currMoDir = 1-2*round(rand(1,1));
        d.speedVec3D = currMoDir * d.speedVec3D;
                
        if c.dotScramble3D
            
            % randomise dot speeds
            % random sequence of -1 and 1
            c.dotXsign = 1 - 2 * round(rand(1, c.nStars));
            c.dotYsign = 1 - 2 * round(rand(1, c.nStars));
            
        end
        
    end            

    return;

end