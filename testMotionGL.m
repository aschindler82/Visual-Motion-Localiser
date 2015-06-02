function testMotionGL(subjID, runNr)

global GL

subjID = 'test';
runNr = 1;

Screen('Preference', 'SkipSyncTests', 1);

% 'dots2D' / 'movFix' : {0,1}
%
%       Move dots or / and fixation dot in a planar fashion
%       Speed is given by empiric values. Difference is x and y leads to a
%       loopwise movement around the origin.
%
%       x-axis: 
%       -> 4    cycles / 12 secs
%       -> 0.33 cycles /    secs
% 
%       y-axis
%       -> 3    cycles / 12 secs
%       -> 0.25 cycles /    secs
%
%
% 'dots3D' : {0,1}
%       
%       coherent forward / backward flow
%       
%
%
%
% 'semiStaticDots' :
%
% TODO: complete help text ... :-)



%% ================ condition settings ================
% all fields needed: empty fields are auto-filled by 'checkConds.m'
%
% conds(i).name          = 'Optic Flow 3D';
% conds(i).nStars        = nStars;
% conds(i).dur           = trialDur;
% conds(i).semiStaticDots    = 0; % static dot field
% conds(i).dots2D        = 0; % planar motion transl/frame
% conds(i).dots3D        = 1; % flow in z direction transl/frame
% conds(i).radRot        = 0; % radial rotation -> rotation around z-axis in deg/frame
% conds(i).dotScramble3D = 0; % 3D scrambled dots
% conds(i).fov           = 1; % 1 -> full; 2 -> left; 3 -> right
% conds(i).movFix        = 0; % 1 -> fixation dot moves with stars; 2 -> fixation dot moves alone

nStars   = 8000;
trialDur = 12;

% scramble motion
conds(1).name          = 'Scramble Motion 3D';
conds(1).nStars        = nStars;
conds(1).dur           = trialDur;
conds(1).dotScramble3D = 1; % 3D scrambled dots

% 3D flow
conds(2).name          = 'Optic Flow 3D';
conds(2).nStars        = nStars;
conds(2).dur           = trialDur;
conds(2).dots3D        = 1; % flow in z direction transl/frame

% Planar 2D motion
% -> Fixation cross moves
conds(3).name          = 'Planar Motion 2D | Fixation Moving';
conds(3).nStars        = nStars;
conds(3).dur           = trialDur;
conds(3).dots2D        = 1; % planar motion transl/frame
conds(3).movFix        = 1; % 1 -> fixation dot moves with stars; 2 -> fixation dot moves alone

% No Planar 2D motion
% -> Fixation cross moves
conds(4).name          = 'No Planar Motion 2D | Fixation Moving';
conds(4).nStars        = nStars;
conds(4).dur           = trialDur;
conds(4).dots2D        = 1; % planar motion transl/frame
conds(4).movFix        = 2; % 1 -> fixation dot moves with stars; 2 -> fixation dot moves alone

% Left Field: 3D flow
conds(5).name          = 'Left Hemifield Motion';
conds(5).nStars        = nStars;
conds(5).dur           = trialDur;
conds(5).dots3D        = 1;
conds(5).fov           = 2; % 1 -> full; 2 -> left; 3 -> right

% Right Field: 3D flow
conds(6).name          = 'Right Hemifield Motion';
conds(6).nStars        = nStars;
conds(6).dur           = trialDur;
conds(6).dots3D        = 1;
conds(6).fov           = 3; % 1 -> full; 2 -> left; 3 -> right

% Static Dots / TOTALLY STATIC
conds(7).name          = 'Static Dots';
conds(7).nStars        = nStars;
conds(7).dur           = trialDur;
conds(7).staticDots    = 1; % static dot field

% Semi Static Dots
% conds(8).name           = 'Semi Static Dots';
% conds(8).nStars         = nStars;
% conds(8).dur            = trialDur;
% conds(8).semiStaticDots = 1; % static dot field


% check fields of condition struct and
% auto-fill empty fields with standard values
% TODO: check values for validity
conds = checkConds(conds);


%% ================ general settings ================

    % randomise seed
    % this also works for older matlab versions
    rand('state', sum(100*clock));

    
    % generate matched trial sequence
    nDepth = 1;
    nReps  = 1;    
	settings.trialSeq = carryoverCounterbalance(length(conds), nDepth, nReps, 0);
    %settings.trialSeq = [1 2 3 4 5 6 7];
    settings.trialSeq = [1 1 1 1 1 1];

    % ======== TR =========
    %settings.TR = 2.48;
    settings.TR = 1.5;
    % =====================
    
    KbName('UnifyKeyNames');
    
    % How to record scanner triggers?
    % 1 --> serial port
    % 2 --> USB port
    settings.recordTriggers = 2;
    
    % keys
    settings.keyBoardInds      = GetKeyboardIndices;
    settings.escapeKey         = KbName('escape');
    settings.scannerTriggerKey = KbName('s'); % only needed if recordTriggers == 2
    taskPrefs.key              = 33; % right button box, index finger
    
        
    settings.scr.ID            = 2;
    settings.scr.width         = 1024;
    settings.scr.height        = 768;
    
    % ----------------------------
    % 3T setup CUSTOM (USED here):
    % viewing distance (from mirrow to screen): ~100cm
    % screen height: ~27 cm
    % screen width:  ~36 cm
    % screen dist:   ~80 cm;
    % -> visdegHeight: ~19?
    % -> visdegWidth:  ~25?
    % ----------------------------
            
    % 3T setup STANDARD (NOT USED here):
    % viewing distance (from mirrow to screen): ~100cm
    % ( screen height: ~26 cm  )
    % ( screen width:  ~33 cm  )
    % ( screen dist:   ~105 cm )
    % ( -> visdegHeight: ~15?  )
    % ( -> visdegWidth:  ~19?  ) 
    
    % desktop setup
    % viewing distance (desk to screen): ~60cm
    % screen height: ~30 cm
    % screen width:  ~40 cm
    % screen dist:   ~60 cm
    % -> visdegHeight: ~28?
    % -> visdegWidth: ~37?
    
    
    settings.scr.halfWidthCm   = 18; % half screen width in cm
    settings.scr.halfHeightCm  = 13.5; % half screen height in cm
    
    settings.scr.pixPcm        = settings.scr.width / (2*settings.scr.halfWidthCm);
    
    % viewing distances
    settings.scr.viewDistMin   =  80; % distance of screen cm -> zNear
    settings.scr.viewDistMax   = 430; % location of max visible distance -> zFar            
    
    settings.scr.hz            =  60;
    
    settings.oldScr            = Screen('Resolution', settings.scr.ID);
    
    % change resolution
    Screen('Resolution', settings.scr.ID, settings.scr.width, settings.scr.height, settings.scr.hz);
    
    
    % to do implement mode for goggles
    settings.scr.stereoMode    = 0;        
    
    % openGL projection settings:
    % goggles
    settings.scr.fovY          = 19; % field of view in y direction in visDeg
        
    % enable sub pixel resolution with anti aliasing
    % n = number of samples per pixel
    % this will increase the "fluidity" of our moving stimulus
    settings.scr.antiAliasingSamples = 0; %4; use 0 for openGL dots
    settings.scr.shaderPath = 'c:/m-files/motion_localiser/shaders/';
    
    % specify centre of screen in psychtoolbox coordinates
    settings.scr.cX = settings.scr.width  / 2;
    settings.scr.cY = settings.scr.height / 2;
    
    settings.scr.frameCtr = 0;
    
    %settings.scr.cols.bg  = round(ones(1,3)/4*255);
    settings.scr.cols.bg  = round(ones(1,3)/3*255);
    settings.scr.contrast = 1;
    
    % calculate white and black according to contrast
    settings.scr.cols.black = ones(1,3)*(settings.scr.cols.bg(1) - settings.scr.cols.bg(1)*settings.scr.contrast); % black
    settings.scr.cols.white = ones(1,3)*(settings.scr.cols.bg(1) + settings.scr.cols.bg(1)*settings.scr.contrast); % white
    
    % range = 0:255 not 1:256
    if settings.scr.cols.white(1) > 255
        settings.scr.cols.white = [255 255 255];
    end
    
    
    % ======> IMPORTANT!
    % For debugging only: Disable Gamma correction
    % to prevent annyoing manual reset of std gamma
    % after script crashed
    % -> ALWAYS use gamma correction during the experiment!
    settings.scr.doGammaCorrection = 0;
    settings.dispFlowAngle = 0;
    
    % how to get triggers?
    settings.useUSBport = 1;
    
    % dummies to scan
    settings.nDummies           = 8; % nTRs
    settings.waitAfterLastTrial = 8; % in secs    
    
    % fov setting for MST condition
    % specify size that will be visible
    % e.g. 1/3 means: 1/3 of screen will be seen
    % the rest covered by background
    settings.fov.size = 2/5;
    
    
    % warning this MUST be off during experiment!
    % calc some dot stats to match nDots across conds
    settings.doDotStats = 0;
    
    % subfolder for log files
    % lives below script directory
    settings.logFolder = 'logs';

    %% ================== Attention Task Settings ======================
    taskPrefs.scr.scrPtr  = settings.scr.ID;
    taskPrefs.xyOffset    = [0 0];
    
    % 0: letter back match task
    % 3: char detection task
    taskPrefs.type     = 0; % 0,1,2,3
    taskPrefs.scr.setup = 'mono';

    taskPrefs.scr.cols.innerDisc = round(ones(1,3)*255*.5);
    taskPrefs.scr.cols.outerDisc = round(ones(1,3)*255*.5);
    taskPrefs.scr.cols.font      = [60 60 60];
    taskPrefs.fontSize           = 25;
    
    % if type = 0
    % repeat a char every within a range of n:m presentations
    taskPrefs.taskItvls     = 5:10;
    
    % intval: no char for at least so many frames.
    taskPrefs.nFramesItv    = 50;

    taskPrefs.recWidth      = 40;
    taskPrefs.fontStyle     = 1; % 0 = normal, 1 = bold
    
    logs.task.tKeyPresses   = [];
    
	%% =============== Initialize dots ===============
    

    
   
    

    
    
    %% ============= Init Psychtoolbox =============
    


    % ======> ONLY FOR DEBUGGING
    % Disable synctests for this quick demo:
    % oldSyncLevel = Screen('Preference', 'SkipSyncTests', 2);

    % do gamma correction
    if settings.scr.doGammaCorrection
        
        %reads gamma table used by mac and saves it in variable oldGamma
        settings.oldScr.gammaTable = Screen('ReadNormalizedGammaTable', settings.scr.ID);
        
        %load table of the screen that you want to use
        settings.scr.gammaTable = load('./spc_mrz3t_gammaLUT.txt')/255; % a filename with values for our monitor
        %use this table instead
        Screen('LoadNormalizedGammaTable', settings.scr.ID, settings.scr.gammaTable);
        
    else
        fprintf('\n============= DEBUGGING ======================');
        fprintf('\nWarning: Gammacorrection is DISABLED!')
        fprintf('\n==============================================');
        fprintf('\n');
        
    end
    
    %% ================ open Psychtoolbox window ========================
    AssertOpenGL;

    % Setup Psychtoolbox for OpenGL 3D rendering support and initialize the
    % mogl OpenGL for Matlab wrapper:
    InitializeMatlabOpenGL;

    % ======> ONLY FOR DEBUGGING
    % comment this out if experiments are carried out
    %PsychDebugWindowConfiguration;

    % Prepare pipeline for configuration. This marks the start of a list of
    % requirements/tasks to be met/executed in the pipeline:
    PsychImaging('PrepareConfiguration');

    % needed for support of fast offscreen buffers
    PsychImaging('AddTask', 'General', 'UseFastOffscreenWindows');
    
    
    
    % open screen
    % Consolidate the list of requirements (error checking etc.), open a
    % suitable onscreen window and configure the imaging pipeline for that
    % window according to our specs. The syntax is the same as for
    % Screen('OpenWindow'):
    %[settings.scr.win settings.scr.rect] = PsychImaging('OpenWindow', settings.scr.ID, settings.scr.cols.bg(1), [], [], [], settings.scr.stereoMode, settings.scr.antiAliasingSamples);                                                   
    [settings.scr.win settings.scr.rect] = Screen('OpenWindow', settings.scr.ID, settings.scr.cols.bg(1), [], [], [], settings.scr.stereoMode, settings.scr.antiAliasingSamples, 1);

    
    % go through each user defined condition
	% and prepare dots according to its needs        
    for currCond = 1 : length(conds)

        % 'd' is an important struct containing all settings regarding
        % the optic flow field        
        d0 = struct;

        d0.type = 2; % for nice smooth dots
        
        % 3D speed in z direction cm / frame
        d0.speed3D = 3;                
        
        d0.maxSize = 10; % pixels : max size of dot on screen
        d0.nStars  = conds(currCond).nStars; % number os stars / dots
                        
        % calculate the cube witdth such that the projection of the far plane of the
        % cube covers the entire screen when projected
        d0.widthCuboid     = 2*(settings.scr.halfWidthCm * (settings.scr.viewDistMax / settings.scr.viewDistMin));        
        d0.lengthCuboid    = settings.scr.viewDistMax - settings.scr.viewDistMin;

        % define rgb vectors
        d0.cols.black    = settings.scr.cols.black; %black
        d0.cols.white    = settings.scr.cols.white; %white
        d0.cols.bg       = settings.scr.cols.bg; %grey/background

        d0.fadingFactor  = 1; % use this to alpha-fade in / out dots

        % adjust color of stars to contrast/luminance
        tmpLums = repmat([d0.cols.white; d0.cols.black], (d0.nStars*0.5), 1);
        d0.cols.luminance = tmpLums(randperm(d0.nStars),:);


        % parameters for motion are initialized
        %d0 = initMotionCuboid(d0, conds(currCond), settings);

        % store dots in cond struct
        %conds(currCond).d = d0;

    end
    
    
    
    % enable alpha blending
    Screen(settings.scr.win, 'BlendFunction', GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    %% ======== setup openGL perspective projection
    % zero disparity (remember: here d.minDistVis == d.screenDist == z projection plane == z near)
    fprintf('\n======================================================');
    fprintf('\nPreparing settings for single viewpoint projection ...');
    fprintf('\n======================================================');
    fprintf('\n');
    
   
    setupOpenGLprojection(settings.scr.win, settings.scr.fovY, settings.scr.viewDistMin, settings.scr.viewDistMax);
    settings.currProj = 1; % 1 --> perspective / 2 --> ortho
    
    %% create fdf context
    fdf = myMoglFDF('CreateContext', settings.scr.win, settings.scr.rect, [], [], [], [], nStars, [], [], []);
    
    
    
    % Does this GPU support shaders?
    extensions = glGetString(GL.EXTENSIONS);
    if isempty(findstr(extensions, 'GL_ARB_shading_language')) || isempty(findstr(extensions, 'GL_ARB_shader_objects')) || isempty(findstr(extensions, 'GL_ARB_vertex_shader'))
        % Ok, no support for shading.
        shadingavail = 0;
    else
        % Use the shader stuff below this point...
        shadingavail = 1;
    end


    % load and compile shader files
    if shadingavail

        % Backup old shader binding:
        oldShader = glGetIntegerv(GL.CURRENT_PROGRAM);
        
        shaderpath = fullfile(settings.scr.shaderPath, 'motionLoc3Dto2D');
        glsl3Dto2D = LoadGLSLProgramFromFiles(shaderpath,1);
        
        shaderpath = fullfile(settings.scr.shaderPath, 'motionLoc3DonlyNew');
        glsl3D     = LoadGLSLProgramFromFiles(shaderpath,1);

        shaderpath   = fullfile(settings.scr.shaderPath, 'motionLocScramble');
        glslScramble = LoadGLSLProgramFromFiles(shaderpath,1);
        
        % load feedback shader
        shaderpath   = fullfile(settings.scr.shaderPath, 'feedBackShader');
        fbShader = LoadGLSLProgramFromFiles(shaderpath,1);
    
        
    else        
        error('Your graphics card does not support shaders!');
        
    end

    % Get duration of a single frame:
    ifi = Screen('GetFlipInterval', settings.scr.win);

    % Initial flip to sync us to VBL and get start timestamp:
    vbl = Screen('Flip', settings.scr.win);

    % =========== create & start KbQueue ===============================
    KbQueueCreate(max(settings.keyBoardInds));
    KbQueueStart();

    %% ======= initialize attention task =======
%    aTask = showAttentionTask('init', taskPrefs);
    
    %% ==================== start animation ====================
    
    trialInd = 0;
    playAnimation = 1;            
    startNewTrial = 1;
    
    
    % for 3Dto2D condition -> planar motion
    % store matrices of current projection
    % --> this is ugly andf should be optimised at some point
    % (but it works :-) )
    Screen('BeginOpenGL', settings.scr.win);                            
    
    %myMats.modViewMat        = reshape(glGetDoublev(GL.MODELVIEW), 4, 4);    
    myMats.modViewMat        = [1 0 0 0
                                0 1 0 0
                                0 0 1 0
                                0 0 0 1];
    myMats.modMat            = reshape(glGetDoublev(GL.MODELVIEW_MATRIX), 4, 4);        
    myMats.projMat           = reshape(glGetDoublev(GL.PROJECTION_MATRIX), 4, 4);    
    myMats.viewPort          = glGetDoublev(GL.VIEWPORT);
       
    myMats.zNearFar          = [settings.scr.viewDistMin, settings.scr.viewDistMax];
    myMats.maxDotSize        = d0.maxSize;
    
    myMats.modViewProjMat    = myMats.modViewMat*myMats.projMat;
    myMats.invModViewProjMat = inv(myMats.modViewProjMat);
    
    Screen('EndOpenGL', settings.scr.win);    
    
    % prepare some variables for dot statistics
    % if dot stats are on
    if settings.doDotStats
        nNewDotOnScreen  = [];
        nDotsLeftScreen  = [];        
        nDotsOnScreen    = [];        
        lastFlownDotInds = [];
    end
    

  
    
    % draw bg
	Screen('FillRect', settings.scr.win, settings.scr.cols.bg);
%    showAttentionTask('showFix', aTask);
    Screen('Flip', settings.scr.win);        
    
    
    %% ====== Animation Loop ======
    while playAnimation
                
        % Check the state of the keyboard.
        % use KbQueuCheck to prevent intecrruption of program during key
        % press
        [~, firstPress] = KbQueueCheck();

        % press escape to leave the program
        if firstPress(settings.escapeKey)
            userQuit = 1;
            playAnimation = 0;
        
        end
                
        % listen on serial port
        if settings.recordTriggers == 1
            
            % once the end of the dataqueue is reached, simply return an
            % empty 'pktdata'
            % variable immediately:
            [pktdata, packetTimestamp] = IOPort('Read', myport);
            
            % get trigger via serial port
            if isempty(pktdata) == 0
                logs.tTriggers(scannerTrCtr) = packetTimestamp;
                scannerTrCtr = scannerTrCtr+1;
            end
            
        end
        
        


        fdf = myMoglFDF('Update', fdf);
        
        
        % Enable alpha blending and smooth dots for nice looking
        % anti-aliased dots:
         glBlendFunc(GL.SRC_ALPHA, GL.ONE_MINUS_SRC_ALPHA);
         glEnable(GL.BLEND);
         

%         
%         % enable shader point size control
         glEnable(GL.VERTEX_PROGRAM_POINT_SIZE);
         glEnable(GL.POINT_SMOOTH);
%         
%         
%         % enable depth culling
%        glEnable(GL.DEPTH_TEST);
               
        % assign shader already here to allow for submission
        % of shader specific variables. This allows us to use the
        % standard PTB 3D draw dot function.
        %glUseProgram(glsl3D);

        % show nice 3D dot flow
        % assign headAngle
        %glUniform1f(glGetUniformLocation(glsl, 'rotAngle'), c.rotAngle);
        %glUniform1f(glGetUniformLocation(glsl3D, 'radAngle'), 0);

        % pointsize
        %glUniform1f(glGetUniformLocation(glsl3D, 'maxPointSize'), .1);

        % nearest zCoord
        %glUniform1f(glGetUniformLocation(glsl3D, 'zNearest'), settings.scr.viewDistMin);

        % alpha values of dots
        %glUniform1f(glGetUniformLocation(glsl3D, 'dotAlpha'), d0.fadingFactor);

        % draw dots using the standard PTB mogl function
        % update projection: perspective        
        %settings.currProj = updateProjection(settings, 1);
                
        fdf = myMoglFDF('Render', fdf, settings.scr.win);
        
        xydots = myMoglFDF('GetResults', fdf);
        
        vbl = Screen('Flip', settings.scr.win);

        
    end % animation loop
    
    % save everything
    tmpPath = which('localiseMotionRegionsGL.m');
    tmpPath = fileparts(tmpPath);        
    tmpPath = fullfile(tmpPath, settings.logFolder);
    
    % create path if necessary
    if exist(tmpPath, 'dir') ~= 7
        mkdir(tmpPath)
    end
    
	currTstamp = datestr(now, 'dd.mm.yy_HH-MM');
    
%     % if user quit experiment before all trials
%     % are through indicate this in the log filename
%     if ~userQuit
%         file2save  = sprintf('%d_%s_motionLoc_%s.mat', runNr, subjID, currTstamp);
%     else
%         file2save  = sprintf('%d_%s_motionLoc_%s_inComplete.mat', runNr, subjID, currTstamp);
%     end
%    
%    save(fullfile(tmpPath, file2save));
    
    
    % close all PTB windows
    % get rid of all textures
    Screen('CloseAll');

    % stop KbQueue
    KbQueueFlush;
    KbQueueStop;

    ShowCursor; % show cursor again;

    Screen('Resolution', settings.scr.ID, settings.oldScr.width, settings.oldScr.height, settings.oldScr.hz);
    sca;

    % stop KbQueue
    KbQueueFlush;
    KbQueueStop;

    ShowCursor; % show cursor again;

    Screen('Resolution', settings.scr.ID, settings.oldScr.width, settings.oldScr.height, settings.oldScr.hz);
    
    if settings.scr.doGammaCorrection
        
        % load old gamma
        Screen('LoadNormalizedGammaTable', settings.scr.ID, settings.oldScr.gammaTable); %set macs native gammaLUT again
        
    end
    
    
    fprintf('\n');
    
    if settings.doDotStats
        
        avgNewDots = mean(nNewDotOnScreen);
        avgLeftDots = mean(nDotsLeftScreen);        
        avgSeenDots = mean(nDotsOnScreen);                
        
        figure; hist(nNewDotOnScreen);
        title('New Dots');
        
        figure; hist(nDotsLeftScreen);
        title('Left Dots');
        
        figure; hist(nDotsOnScreen);
        title('Seen Dots');
    end

    
    % do this to prevent user to forget to manally
    % close serial port
    if settings.recordTriggers == 1
        fprintf('\nPlease give a last manual trigger to close serial port and continue!')
        fprintf('\n')
        clear all
    end
    
    return;

end