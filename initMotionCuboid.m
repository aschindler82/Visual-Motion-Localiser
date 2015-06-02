function d = initMotionCuboid(d, c, settings)
    

    %% ========== generate cube with random dots ==========

    % get n points within a square and randomise the height of these points
    % on tat disc to get random points in our cylinder.
    %
    % Generate a point in polar coordinates: pick ? from [0, 2?) and r2 from [0, R2]
    % (ie. multiply R by the square-root of a random number in [0, 1]
    % - without the square-root it is non-uniform).    
    d.xCub = (rand(1, d.nDots) * d.widthCuboid) - d.widthCuboid / 2;
    d.yCub = (rand(1, d.nDots) * d.widthCuboid) - d.widthCuboid / 2;

    % get random height of each dot
    % in openGl the z-axis goes negative
    % into the screen and out positive
    % --> multiply z-coords by -1    
    d.zCub = -rand(1, d.nDots) * d.lengthCuboid;
    
    
    %% ========== setup dot speeds ==========
    
    % radial speed:
    % rotate flow field around z-axis
    % this variable is later submitted to the shader
    d.radAngle = 0;
    
    % only used for planar motion / fixation cross motion
    d.xCo = 0;
	d.yCo = 0;
    
    % only used for 3D flow and scrambled motion
    d.xCo3D = 0;
	d.yCo3D = 0;
    
    
    % initialise cosine time series for planar component
    
    
    % index to 2D planar motion
    % vector, incremented each frame
    d.posInd2D     = 0;
    d.posInd3D     = 0;    
    
    % randomise motion direction
    currMoDir = 1-2*round(rand(1,1));
    
	% x-axis
	% empiric value from elviras script
    % -> 4 cycles / 12 secs
    % -> 0.33 cyc /    secs
    d.xCo   = genMotionSeq(0.33,   c.dur, currMoDir, settings);    
    d.xCo3D = genMotionSeq(0.33/2, c.dur, currMoDir, settings); % slow it a bit down for 3D flow
    
    % y-axis
    % empiric value from elviras script
    % -> 3 cycles / 12 secs
    % -> 0.25 cyc /    secs    
	d.yCo   = genMotionSeq(0.25,   c.dur, currMoDir, settings);
    d.yCo3D = genMotionSeq(0.25/2, c.dur, currMoDir, settings); % slow it a bit down for 3D flow
    
    
    % index to 3D motion vector, incremented each frame
    % used for forward / backward flow
    d.speedInd3D = 0;
    
    % calculate forward / backward flow time series
    % we want to have one full backward and forward cycle
    % per block
    numFrames = 1 : settings.scr.hz * c.dur;
    speedVec3D = sin(2*pi*numFrames/(settings.scr.hz * c.dur));
    speedVec3D = sign((speedVec3D)).*abs(speedVec3D).^(1/3) * d.speed3D; % convert to power 1/3 (range: -1,1)
    %speed3Dvec = cumsum(speed3Dvec); % take integral of position
    %values --> speed will equal values prior to this integral.
    
    % randomise direction of forth and backward flow
    currMoDir = 1-2*round(rand(1,1));
    d.speedVec3D = speedVec3D * currMoDir;
            
    % randomise dot speeds
    % random sequence of -1 and 1
    d.dotXsign = 1 - 2 * round(rand(1, d.nDots));
    d.dotYsign = 1 - 2 * round(rand(1, d.nDots));
    
       
    % radial rotation
    if c.radRot
        
        % index to 3D motion vector, incremented each frameedit 
        % used for forward / backward flow
        d.radAngleInd = 0;
        
        % calculate left / right radial flow time series
        % we want to have one full left and right cycle
        % per block
        numFrames   = 1 : settings.scr.hz * c.dur;
        radAngleVec = sin(2*pi*numFrames / (settings.scr.hz * c.dur));        
        radAngleVec = sign((radAngleVec)).*abs(radAngleVec).^(1/3) * d.speedRad; % convert to power 1/3 (range: -1,1)
        radAngleVec = cumsum(radAngleVec); % take integral of angle values --> speed will equal values prior to this integral.
        
        d.radAngleVec = radAngleVec;
        
    end
    
    
    return;


    %% Function to calculate planar trajectories
    function mCo = genMotionSeq(cycPerSec, dur, currMotionDir, settings)
        
        nCyc      = round(cycPerSec * dur) / 2;
        numFrames = round(dur / (1/settings.scr.hz));
        mCo   = cos(nCyc*2*pi*[1:numFrames]./(settings.scr.hz * dur)); % define sinusoidal time-series
        scaledCumSum = cumsum(mCo); % take integral of position values --> speed will equal values prior to this integral.
        mCo   = scaledCumSum/(max(scaledCumSum)); % range: -1,1
        mCo   = mCo * (settings.scr.width/4) /range(mCo); % scale range of values
        mCo   = mCo * currMotionDir;
        
        return