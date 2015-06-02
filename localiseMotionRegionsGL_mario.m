function localiseMotionRegionsGL_mario(subjID, runNr)

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


% Projector width (native resolution)
% 41 x 23

%% ================ condition settings ================
% all fields needed: empty fields are auto-filled by 'checkConds.m'
%
% conds(i).name          = 'Optic Flow 3D';
% conds(i).dur           = trialDur;
% conds(i).dots2D        = 0; % planar motion transl/frame
% conds(i).dots3D        = 1; % flow in z direction transl/frame
% conds(i).radRot        = 0; % radial rotation -> rotation around z-axis in deg/frame (not implemented currently)
% conds(i).dotScramble3D = 0; % 3D scrambled dots
% conds(i).fov           = 1; % 1 -> full; 2 -> left; 3 -> right
% conds(i).movFix        = 0; % 1 -> fixation dot moves with stars; 2 -> fixation dot moves alone

trialDur = 12;

% scramble motion
conds(1).name          = 'Scramble Motion 3D';
conds(1).dur           = trialDur;
conds(1).dotScramble3D = 1; % 3D scrambled dots

% 3D flow
conds(2).name          = 'Optic Flow 3D';
conds(2).dur           = trialDur;
conds(2).dots3D        = 1; % flow in z direction transl/frame

% Planar 2D motion
% -> Fixation cross moves
conds(3).name          = 'Planar Motion 2D | Fixation Moving';
conds(3).dur           = trialDur;
conds(3).dots2D        = 1; % planar motion transl/frame
conds(3).movFix        = 1; % 1 -> fixation dot moves with stars; 2 -> fixation dot moves alone

% No Planar 2D motion
% -> Fixation cross moves
conds(4).name          = 'No Planar Motion 2D | Fixation Moving';
conds(4).dur           = trialDur;
conds(4).dots2D        = 1; % planar motion transl/frame
conds(4).movFix        = 2; % 1 -> fixation dot moves with stars; 2 -> fixation dot moves alone

% Left Field: 3D flow
conds(5).name          = 'Left Hemifield Motion';
conds(5).dur           = trialDur;
conds(5).dots3D        = 1;
conds(5).fov           = 2; % 1 -> full; 2 -> left; 3 -> right

% Right Field: 3D flow
conds(6).name          = 'Right Hemifield Motion';
conds(6).dur           = trialDur;
conds(6).dots3D        = 1;
conds(6).fov           = 3; % 1 -> full; 2 -> left; 3 -> right

% Static Dots / TOTALLY STATIC
conds(7).name          = 'Static Dots';
conds(7).dur           = trialDur;
conds(7).staticDots    = 1; % static dot field

% check fields of condition struct and
% auto-fill empty fields with standard values
% TODO: check values for validity
conds = checkConds(conds);


%% ================ general settings ================
global GL;

% randomise seed
% this also works for older matlab versions
rand('state', sum(100*clock));


% generate matched trial sequence
nDepth = 1;
nReps  = 1;
settings.trialSeq = carryoverCounterbalance(length(conds), nDepth, nReps, 0);
%settings.trialSeq = [1 2 3 4 5 6 7];
%settings.trialSeq = [2 1 1 1 1 1 1];
%settings.trialSeq = [1 2 1 2 1 2 1 2 1 2 1 2];
%settings.trialSeq = [2 1];

% ======== TR =========
%settings.TR = 2.48;
settings.TR = 0.87;
% =====================

KbName('UnifyKeyNames');

% How to record scanner triggers?
% 1 --> serial port
% 2 --> USB port
settings.recordTriggers = 2;

% keys
settings.keyBoardInds      = GetKeyboardIndices;
settings.escapeKey         = KbName('escape');
settings.scannerTriggerKey = 87; %KbName('s'); % only needed if recordTriggers == 2
taskPrefs.key              = 52; % right button box, index finger

settings.scr.ID            = 2;
settings.scr.width         = 1280;
settings.scr.height        = 1024;

settings.scr.widthPhys     = [];
settings.scr.heightPhys    = [];


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

%settings.scr.halfWidthCm   = 18; % half screen width in cm
%settings.scr.halfHeightCm  = 13.5; % half screen height in cm
settings.scr.halfWidthCm   = 20.5; % half screen width in cm
settings.scr.halfHeightCm  = 12; % half screen height in cm


settings.scr.pixPcm        = settings.scr.width / (2*settings.scr.halfWidthCm);

% viewing distances
settings.scr.viewDistMin   =  80; % distance of screen cm -> zNear
settings.scr.viewDistMax   = 430; % location of max visible distance -> zFar

settings.scr.hz            =  60;

settings.oldScr            = Screen('Resolution', settings.scr.ID);

% change resolution
if ~isempty( settings.scr.widthPhys )
    Screen('Resolution', settings.scr.ID, settings.scr.widthPhys, settings.scr.heightPhys, settings.scr.hz);
end

% to do implement mode for goggles
settings.scr.stereoMode    = 0;

% openGL projection settings:
% goggles
%settings.scr.fovY          = 19; % field of view in y direction in visDeg
settings.scr.fovY          = 16; % field of view in y direction in visDeg


% enable sub pixel resolution with anti aliasing
% n = number of samples per pixel
% this will increase the "fluidity" of our moving stimulus
settings.scr.antiAliasingSamples = 8; %4; use 0 for openGL dots


% specify centre of screen in psychtoolbox coordinates
settings.scr.cX = settings.scr.width  / 2;
settings.scr.cY = settings.scr.height / 2;

settings.scr.frameCtr = 0;

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

% subfolder for log files
% lives below script directory
settings.logFolder = 'logs';

%% ================== Attention Task Settings ======================
taskPrefs.scr.scrPtr  = settings.scr.ID;

taskPrefs.xyOffset    = [0 0];

% 0: letter back match task
% 3: char detection task
taskPrefs.type      = 0; % 0,1,2,3
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

% check user input
if nargin < 2
    %error('Please specify subjectID and runNr');
end



%% ============ prepare serial port ============
if settings.recordTriggers == 1;
    
    % open serial port
    % ==================================== setup serial port ====================================
    
    portSettings = sprintf('BaudRate=115200 InputBufferSize=10000 ReceiveTimeout=60');
    %obj.portSpec = FindSerialPort('cu.UC-232AC', 1); % USB-to-serial converter device as listed in /dev/
    portSpec = FindSerialPort('cu.usbserial-FTFC4W0K',1);
    
    % Open port portSpec with portSettings, return handle:
    myport = IOPort('OpenSerialPort', portSpec, portSettings);
    
    % Start asynchronous background data collection and timestamping. Use
    % blocking mode for reading data -- easier on the system:
    asyncSetup = sprintf('BlockingBackgroundRead=1 ReadFilterFlags=0 StartBackgroundRead=1');
    IOPort('ConfigureSerialPort', myport, asyncSetup);
    
    %WaitSecs(1);
    IOPort('Read', myport);
    
    % ============================================================================================
end


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

% use panel fitter: use projector full resolution i.e. 1920 x 1080 and
% rescale our 1280 x 1024 content to fit rects
PsychImaging('AddTask', 'General', 'UsePanelFitter', [settings.scr.width settings.scr.height], 'AspectWidth');

% needed for support of fast offscreen buffers
% activates full imaging pipeline
% e.g. required for multisamples with openGL
PsychImaging('AddTask', 'General', 'UseVirtualFramebuffer');

% open screen
% Consolidate the list of requirements (error checking etc.), open a
% suitable onscreen window and configure the imaging pipeline for that
% window according to our specs. The syntax is the same as for
% Screen('OpenWindow'):
%
% Note: There is a high efficient antialasing method for openGL lines and
% points (also textures)
%
[settings.scr.win settings.scr.rect] = PsychImaging('OpenWindow', settings.scr.ID, settings.scr.cols.bg(1), [], [], [], settings.scr.stereoMode, settings.scr.antiAliasingSamples);

% 'd' is an important struct containing all settings regarding
% the optic flow field
d0 = struct;

d0.nDots = 15000;

% 3D speed in z direction cm / frame
d0.speed3D = 2;

d0.maxSize = 10; % pixels : max size of dot on screen

% calculate the cube witdth such that the projection of the far plane of the
% cube covers the entire screen when projected
d0.widthCuboid     = 2*(settings.scr.halfWidthCm * (settings.scr.viewDistMax / settings.scr.viewDistMin));
d0.lengthCuboid    = settings.scr.viewDistMax - settings.scr.viewDistMin;


%% =================== create frame buffer objects ===================

% Retrieve maximum width or height of textures and offscreen windows
% supported by this GL implementation:
glSetts.maxTexSize = glGetIntegerv(GL.MAX_RECTANGLE_TEXTURE_SIZE_EXT);

% Width of a line in samplebuffer:
glSetts.samplesPerLine = min(glSetts.maxTexSize, 2048);
glSetts.samplesPerLine = min(glSetts.samplesPerLine, d0.nDots);

% Our buffer is implemented as a FBO backed floating point offscreen
% window with a pixel size of 128 bits, aka 32 bpc float.
glSetts.sampleLinesTotal    = ceil(d0.nDots / glSetts.samplesPerLine);
glSetts.randBuffer          = Screen('OpenOffscreenWindow', settings.scr.win, [0 0 0 0], double([0 0 glSetts.samplesPerLine glSetts.sampleLinesTotal]), 128, 32);
glSetts.bufferScrambledDots = Screen('OpenOffscreenWindow', settings.scr.win, [0 0 0 0], double([0 0 glSetts.samplesPerLine glSetts.sampleLinesTotal]), 128, 32);
glSetts.buffer3Ddots        = Screen('OpenOffscreenWindow', settings.scr.win, [0 0 0 0], double([0 0 glSetts.samplesPerLine glSetts.sampleLinesTotal]), 128, 32);

glSetts.buffer2Ddots        = Screen('OpenOffscreenWindow', settings.scr.win, [0 0 0 0], double([0 0 glSetts.samplesPerLine glSetts.sampleLinesTotal]), 128, 32);
glSetts.buffer2DdotsBAK     = Screen('OpenOffscreenWindow', settings.scr.win, [0 0 0 0], double([0 0 glSetts.samplesPerLine glSetts.sampleLinesTotal]), 128, 32);

glSetts.bufferTmp           = Screen('OpenOffscreenWindow', settings.scr.win, [0 0 0 0], double([0 0 glSetts.samplesPerLine glSetts.sampleLinesTotal]), 128, 32);
glSetts.randSeedsBuffer     = Screen('OpenOffscreenWindow', settings.scr.win, [0 0 0 0], double([0 0 glSetts.samplesPerLine glSetts.sampleLinesTotal]), 128, 32);
glSetts.dotParamBuffer      = Screen('OpenOffscreenWindow', settings.scr.win, [0 0 0 0], double([0 0 glSetts.samplesPerLine glSetts.sampleLinesTotal]), 128, 32);

glSetts.projectedDotsBuffer = Screen('OpenOffscreenWindow', settings.scr.win, [0 0 0 0], double([0 0 glSetts.samplesPerLine glSetts.sampleLinesTotal]), 128, 32);

glSetts.randBufferHDL          = Screen('GetOpenGLTexture', settings.scr.win, glSetts.randBuffer);
glSetts.randSeedsBufferHDL     = Screen('GetOpenGLTexture', settings.scr.win, glSetts.randSeedsBuffer);
glSetts.bufferScrambledDotsHDL = Screen('GetOpenGLTexture', settings.scr.win, glSetts.bufferScrambledDots);
glSetts.dotParamBufferHDL      = Screen('GetOpenGLTexture', settings.scr.win, glSetts.dotParamBuffer);

% round nDots to sample size per line in dot buffer
d0.nDots = glSetts.sampleLinesTotal * glSetts.samplesPerLine;

% define rgb vectors
colVec = [[settings.scr.cols.white/255 1]' [settings.scr.cols.black/255 1]'];
colVec = repmat(colVec, 1, d0.nDots/2);
colVec = colVec(:,randperm(length(colVec)));
d0.cols = colVec;

% define pos of 3D dots
d0.xCub = (rand(1, d0.nDots) * d0.widthCuboid) - d0.widthCuboid / 2;
d0.yCub = (rand(1, d0.nDots) * d0.widthCuboid) - d0.widthCuboid / 2;

% get random height of each dot
% in openGl the z-axis goes negative
% into the screen and out positive
% --> multiply z-coords by -1
d0.zCub = -rand(1, d0.nDots) * d0.lengthCuboid;



%% =================== load shaders ===================
% define shaderpath from calling directory
tmp = mfilename('fullpath');
tmp = fileparts(tmp);
glSetts.shaderPath = fullfile(tmp, 'myShaders');
glSetts.shaderDebuglevel = 2;


glSetts.projectDotsShader = LoadGLSLProgramFromFiles({ ...   
    fullfile(glSetts.shaderPath, 'projectDots.frag.txt') ...
    }, glSetts.shaderDebuglevel);

glSetts.moveDotsShader = LoadGLSLProgramFromFiles({ ...
    fullfile(glSetts.shaderPath, 'moveDots.frag.txt') ...
    }, glSetts.shaderDebuglevel);

glSetts.planarMotionShader = LoadGLSLProgramFromFiles({ ...
    fullfile(glSetts.shaderPath, 'move2Ddots.frag.txt') ...
    }, glSetts.shaderDebuglevel);

glSetts.scrambleDotsShader = LoadGLSLProgramFromFiles({ ...
    fullfile(glSetts.shaderPath, 'scrambleDots.frag.txt') ...
    }, glSetts.shaderDebuglevel);

glSetts.checkDotsShader = LoadGLSLProgramFromFiles({ ...
    fullfile(glSetts.shaderPath, 'checkDots.frag.txt') ...
    }, glSetts.shaderDebuglevel);

glSetts.renderScrambledDotsShader = LoadGLSLProgramFromFiles({ ...
    fullfile(glSetts.shaderPath, 'renderDotsVB.vert.txt') ...
    }, glSetts.shaderDebuglevel);

glSetts.render3DdotsShader = LoadGLSLProgramFromFiles({ ...
    fullfile(glSetts.shaderPath, 'render3DdotsVB.vert.txt') ...
    }, glSetts.shaderDebuglevel);

glSetts.render2DplanarDotsVB = LoadGLSLProgramFromFiles({ ...
    fullfile(glSetts.shaderPath, 'render2DplanarDotsVB.vert.txt') ...
    }, glSetts.shaderDebuglevel);


%% ================ create vertex buffer objects ================

% Lets create the VBO that we need to actually render anything in the
% end. VBO's are not supported yet by PTB's Screen, so we need to
% switch to our GL context for setup:
Screen('BeginOpenGL', settings.scr.win);

glSetts.dotVBO = glGenBuffers(1);
glBindBuffer(GL.ARRAY_BUFFER, glSetts.dotVBO);

% Calculate size of VBO in bytes: Number of dots
% times 4 components per dot (RGBA == xyzw) times 4 Bytes per float
% component:
%buffersize = d.nDots * 4 * 4;

% create a vertex attribute buffer to contain data
% for two vertex vec4 attributes
% this buffer containts xyzw vertex information
% and an rgba dotParam vertex attribute
buffersize = (d0.nDots * 4 * 4)*2;

% Allocate but don't initialize it, ie NULL pointer == 0
glBufferData(GL.ARRAY_BUFFER, buffersize, 0, GL.STREAM_COPY);

% Done.
glBindBuffer(GL.ARRAY_BUFFER, 0);

% Setup another VBO for the vertex indices:
glSetts.dotIBO = glGenBuffers(1);
glBindBuffer(GL.ELEMENT_ARRAY_BUFFER_ARB, glSetts.dotIBO);

% Allocate buffer for number of vertex indices,
% each taking up 4 Bytes (== sizeof(uint32)) of memory.
% Initialize immediately with indices and tell
% OpenGL that this won't change at all during operation
% (STATIC_DRAW):
dotindices = uint32(0:d0.nDots-1);
glBufferData(GL.ELEMENT_ARRAY_BUFFER_ARB, d0.nDots * 4, dotindices, GL.STATIC_DRAW);
glBindBuffer(GL.ELEMENT_ARRAY_BUFFER_ARB, 0);

% Done with VBO setup.
% Restore previous GL context binding:
% RestoreGL;
% 
% BackupGL;

% Switch to OpenGL rendering context to be used for 3D scene rendering,
% and specifically for our silhouette render buffer:
SwitchToPTB;

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

Screen('BeginOpenGL', settings.scr.win);

% set projection params manually to identity matrix
myMats.modViewMat = [1 0 0 0
                     0 1 0 0
                     0 0 1 0
                     0 0 0 1];
                 
myMats.modMat   = reshape(glGetDoublev(GL.MODELVIEW_MATRIX), 4, 4);
myMats.projMat  = reshape(glGetDoublev(GL.PROJECTION_MATRIX), 4, 4);
myMats.viewPort = glGetDoublev(GL.VIEWPORT);

Screen('EndOpenGL', settings.scr.win);

%% ============== assign shader uniforms and vertex buffer layers ==============

% assign uniforms
glUseProgram(glSetts.projectDotsShader);
glUniformMatrix4fv(glGetUniformLocation(glSetts.projectDotsShader,  'modelViewMat'), 1, 0, myMats.modViewMat);
glUniformMatrix4fv(glGetUniformLocation(glSetts.projectDotsShader,  'modelMat'),     1, 0, myMats.modMat);
glUniformMatrix4fv(glGetUniformLocation(glSetts.projectDotsShader,  'projMat'),      1, 0, myMats.projMat);
glUniform4fv(glGetUniformLocation(       glSetts.projectDotsShader, 'viewPortVec'),  1,    myMats.viewPort);
glUniform1i(glGetUniformLocation(        glSetts.projectDotsShader, 'xyDotCoords'), 0);
glUseProgram(0);

glSetts.projectDotsOperator = CreateGLOperator(settings.scr.win, [], glSetts.projectDotsShader, 'Project Dots');


glUseProgram(glSetts.moveDotsShader);
glUniform1i(glGetUniformLocation(glSetts.moveDotsShader, 'xyzDotCoords'), 0);
glUniform1i(glGetUniformLocation(glSetts.moveDotsShader, 'myRandSeeds'),  1);
glUniform1f(glGetUniformLocation(glSetts.moveDotsShader, 'cubeLength'), d0.lengthCuboid);
glUniform1f(glGetUniformLocation(glSetts.moveDotsShader, 'cubeWidth'),  d0.widthCuboid);
glUniform1f(glGetUniformLocation(glSetts.moveDotsShader, 'dotSpeed'),   d0.speed3D);
glUseProgram(0);

glSetts.moveDotsOperator = CreateGLOperator(settings.scr.win, [], glSetts.moveDotsShader, 'Move Dots');

glUseProgram(glSetts.scrambleDotsShader);
glUniform1i(glGetUniformLocation(glSetts.scrambleDotsShader,        'xyDotCoords'),     0);
glUniform1i(glGetUniformLocation(glSetts.scrambleDotsShader,        'xyDotCoordsLast'), 1);
glUniform1i(glGetUniformLocation(glSetts.scrambleDotsShader,        'checkTex'),         2);
glUniform1i(glGetUniformLocation(glSetts.scrambleDotsShader,        'myRandSeeds'),      3);
glUniform1i(glGetUniformLocation(glSetts.scrambleDotsShader,        'xyScramblesLast'),  4);
glUniform4fv(glGetUniformLocation(glSetts.scrambleDotsShader,       'viewPortVec'),      1,    myMats.viewPort);
glUseProgram(0);

glSetts.scrambleDotsShaderOperator = CreateGLOperator(settings.scr.win, [], glSetts.scrambleDotsShader, 'Scramble dots distance');


glUseProgram(glSetts.checkDotsShader);
glUniform1i(glGetUniformLocation(glSetts.checkDotsShader,        'xyDotCoords'),      0);
glUniform1i(glGetUniformLocation(glSetts.checkDotsShader,        'myRandSeeds'),      1);
glUniform1i(glGetUniformLocation(glSetts.checkDotsShader,        'checkTex'),         2);
glUniform4fv(glGetUniformLocation(glSetts.checkDotsShader,       'viewPortVec'),      1,    myMats.viewPort);
glUniform1f(glGetUniformLocation(glSetts.checkDotsShader,        'zNear'),            settings.scr.viewDistMin);
glUniform1f(glGetUniformLocation(glSetts.checkDotsShader,        'zFar'),             settings.scr.viewDistMax);
glUseProgram(0);

glSetts.checkDotsShaderOperator = CreateGLOperator(settings.scr.win, [], glSetts.checkDotsShader, 'Check dot params');



glUseProgram(glSetts.planarMotionShader);
glUniform1i(glGetUniformLocation(glSetts.planarMotionShader,  'xyDotCoords'), 0);
glUniform1i(glGetUniformLocation(glSetts.planarMotionShader,  'myRandSeeds'), 1);
glUniform2fv(glGetUniformLocation(glSetts.planarMotionShader, 'xySpeed'),     1, [0, 0]);
glUniform1fv(glGetUniformLocation(glSetts.planarMotionShader, 'radMotion'),   1, 0);
glUniform4fv(glGetUniformLocation(glSetts.planarMotionShader, 'viewPortVec'), 1,  myMats.viewPort);
glUseProgram(0);

glSetts.doPlaneMotionOperator = CreateGLOperator(settings.scr.win, [], glSetts.planarMotionShader, 'Move dots in xy plane');



% ------------------- scramble render shader ------------------------------
% % bind vertex attribute layer to render dots shader
glSetts.vertex2Dind = 0;
glBindAttribLocation(glSetts.renderScrambledDotsShader, glSetts.vertex2Dind, 'vertex2D');

glSetts.dotColInd = 1;
glBindAttribLocation(glSetts.renderScrambledDotsShader, glSetts.dotColInd, 'dotColour');

% dont forget to link the shader AFTER layer binding! :-)
glLinkProgram(glSetts.renderScrambledDotsShader);

glUseProgram(glSetts.renderScrambledDotsShader);
glUniform1f(glGetUniformLocation(glSetts.renderScrambledDotsShader, 'zNear'), settings.scr.viewDistMin);
glUniform1f(glGetUniformLocation(glSetts.renderScrambledDotsShader, 'maxDotSize'), d0.maxSize);
glUseProgram(0);


% ------------------- flow render shader ------------------------------
% bind vertex attribute layer to render dots shader
glBindAttribLocation(glSetts.render3DdotsShader, glSetts.vertex2Dind, 'vertex2D');
glBindAttribLocation(glSetts.render3DdotsShader, glSetts.dotColInd, 'dotColour');

% dont forget to link the shader AFTER layer binding! :-)
glLinkProgram(glSetts.render3DdotsShader);

glUseProgram(glSetts.render3DdotsShader);
glUniform1f(glGetUniformLocation(glSetts.render3DdotsShader, 'zNear'), settings.scr.viewDistMin);
glUniform1f(glGetUniformLocation(glSetts.render3DdotsShader, 'maxDotSize'), d0.maxSize);
glUseProgram(0);


% ------------------- planar render shader ------------------------------
% bind vertex attribute layer to render dots shader
glBindAttribLocation(glSetts.render2DplanarDotsVB, glSetts.vertex2Dind, 'vertex2D');
glBindAttribLocation(glSetts.render2DplanarDotsVB, glSetts.dotColInd, 'dotColour');

% dont forget to link the shader AFTER layer binding! :-)
glLinkProgram(glSetts.render2DplanarDotsVB);

glUseProgram(glSetts.render2DplanarDotsVB);
glUniform1f(glGetUniformLocation(glSetts.render2DplanarDotsVB, 'zNear'), settings.scr.viewDistMin);
glUniform1f(glGetUniformLocation(glSetts.render2DplanarDotsVB, 'maxDotSize'), d0.maxSize);
glUseProgram(0);


SwitchToPTB

%% ======= initialize attention task =======
taskPrefs.scr.winPtr  = settings.scr.win;
aTask = showAttentionTask('init', taskPrefs);

%% ============ create initial textures ============

% get buffer texture dims
[bf1w, bf1h] = RectSize(Screen('Rect',glSetts.bufferTmp));

xyz = [d0.xCub d0.yCub d0.zCub ones(size(d0.zCub))];
xyz = reshape(xyz, bf1h, bf1w, 4);
dotTex2D = Screen('MakeTexture', settings.scr.win, xyz, [], [], 2, 0);

% draw dots into buffer
Screen('DrawTexture', glSetts.buffer3Ddots, dotTex2D, [], [], [], 0);

% Release texture:
Screen('Close', dotTex2D);

% random 2D scrambled dots. Each dot will be associated to
% a theoretic 3D flow dot
rand2DdotsX = (rand(1, d0.nDots) *  RectWidth(settings.scr.rect)); % x
rand2DdotsY = (rand(1, d0.nDots) * RectHeight(settings.scr.rect)); % y
xyz = [rand2DdotsX rand2DdotsY ones(size(d0.zCub)) ones(size(d0.zCub))];
xyz = reshape(xyz, bf1h, bf1w, 4);
dotTex2D = Screen('MakeTexture', settings.scr.win, xyz, [], [], 2, 0);

% draw 2D dots into buffer
Screen('DrawTexture', glSetts.bufferScrambledDots, dotTex2D, [], [], [], 0);

% Release texture:
Screen('Close', dotTex2D);


% create random seed texture
myRandSeeds    = rand(size(xyz));
randSeedsTex = Screen('MakeTexture', settings.scr.win, myRandSeeds, [], [], 2, 0);
Screen('DrawTexture', glSetts.randSeedsBuffer, randSeedsTex, [], [], [], 0);

% create initial dots param texture with random xy directions.
% set initial visibility to 1 for all dots. Will be adapted during
% first cycle
tmp       = [1 -1];
xDirs     = tmp(ceil(rand(size(d0.xCub))*length(tmp)));
yDirs     = tmp(ceil(rand(size(d0.xCub))*length(tmp)));
visFlag   = ones(size(xDirs));
dotParams = [xDirs yDirs visFlag visFlag];
dotParams = reshape(dotParams, bf1h, bf1w, 4);

dotParamTex = Screen('MakeTexture', settings.scr.win, dotParams, [], [], 2, 0);
Screen('DrawTexture', glSetts.dotParamBuffer, dotParamTex, [], [], [], 0);


% bind random numbers to texture unit2
glActiveTexture(GL.TEXTURE2);
glBindTexture(GL.TEXTURE_RECTANGLE_EXT, glSetts.dotParamBufferHDL);
glActiveTexture(GL.TEXTURE3);
glBindTexture(GL.TEXTURE_RECTANGLE_EXT, glSetts.randSeedsBufferHDL);
glActiveTexture(GL.TEXTURE4);
glBindTexture(GL.TEXTURE_RECTANGLE_EXT, glSetts.bufferScrambledDotsHDL);
glActiveTexture(GL.TEXTURE0);


%glEnable(GL.POINT_SPRITE);
glEnable(GL.VERTEX_PROGRAM_POINT_SIZE);


glBindBuffer(GL.ARRAY_BUFFER, glSetts.dotVBO);
% important! cast data to single float!
% Otherwise data gets incorrectly written to buffer!
glBufferSubData(GL.ARRAY_BUFFER, 4*prod(size(d0.cols)), 4*prod(size(d0.cols)), single(d0.cols));
glBindBuffer(GL.ARRAY_BUFFER, 0);

% Get duration of a single frame:
ifi = Screen('GetFlipInterval', settings.scr.win);

% Initial flip to sync us to VBL and get start timestamp:
vbl = Screen('Flip', settings.scr.win);

% =========== create & start KbQueue ===============================
%KbQueueCreate(max(settings.keyBoardInds));
KbQueueCreate();
KbQueueStart();



%% ==================== start animation ====================

trialInd = 0;
playAnimation = 1;
startNewTrial = 1;


%% ===== Wait for dummies =====

% draw bg
Screen('FillRect', settings.scr.win, settings.scr.cols.bg);
showAttentionTask('showFix', aTask);
Screen('Flip', settings.scr.win);

% calc nImg that will be scanned
nImgs2scan = ceil(settings.nDummies + ( length(settings.trialSeq)*trialDur + settings.waitAfterLastTrial ) / settings.TR);

% print some information about the current run
fprintf('\n=======================================================');
fprintf('\nStarting Paradigm ...');
fprintf('\n');
fprintf('\nnBlocks    : #%d', length(settings.trialSeq));
fprintf('\nAssumed TR: %2.2f secs', settings.TR);
fprintf('\n -> We will scan #%d images (including #%d dummies)', nImgs2scan, settings.nDummies);
fprintf('\n -> This corresponds to %s', secs2hms(nImgs2scan*settings.TR)); % secs2hms is from matlabcentral
fprintf('\n');

% tell user how we will record triggers
if settings.recordTriggers == 1
    fprintf('\nTriggers are recorded using the serial port!');
    
elseif settings.recordTriggers == 2
    fprintf('\nTriggers are recorded using the USB interface!');
    
end

fprintf('\n');
fprintf('\n=======================================================');
fprintf('\n');


% wait for one manual trigger to actually check
% whether connection to trigger box works
waiting4manualTrigger = 1;
waiting4Dummies = 1;
logs.dummies.nScanned = 0;

fprintf('\n=======================================================');
fprintf('\nPlease give one manual trigger!');
fprintf('\n=======================================================');

gotTrigger = 0;

% wait for 1st manual trigger & dummies
while waiting4manualTrigger || waiting4Dummies
    
    % listen on serial port
    if settings.recordTriggers == 1
        % once the end of the dataqueue is reached, simply return an empty 'pktdata'
        % variable immediately:
        [pktdata, packetTimestamp] = IOPort('Read', myport);
        
        if isempty(pktdata) == 0
            
            gotTrigger = 1;
            triggertstamp = packetTimestamp;
            
        end
        
        % use USB keyobard to record triggers
    elseif settings.recordTriggers == 2
        
        % Check the state of the keyboard.
        % use KbQueuCheck to prevent interruption of program during key press
        [keyIsDown, firstPress, firstRelease, lastPress, lastRelease] = KbQueueCheck();
        
        % if trigger arrived
        if firstPress(settings.scannerTriggerKey)
            
            gotTrigger = 1;
            triggertstamp = firstPress(settings.scannerTriggerKey);
            
        end
        
    end
    
    
    
    % if trigger arrived
    if gotTrigger
        
        % first listen for manual trigger
        if waiting4manualTrigger
            waiting4manualTrigger = 0;
            fprintf('\nGot it!');
            fprintf('\nNow we are waiting for %d dummy scans', settings.nDummies);
            
        else
            
            % get t0 at first dummy scan
            if logs.dummies.nScanned == 0
                logs.dummies.tFirstDummyArrived = triggertstamp;
            end
            
            % for the first 4 dummies print some text
            if logs.dummies.nScanned < settings.nDummies
                logs.dummies.nScanned = logs.dummies.nScanned+1;
                fprintf('\nGot dummy %d of %d', logs.dummies.nScanned, settings.nDummies);
            else
                % when 5th volume is starting exit while loop
                % and start stimulustt
                fprintf('\nStarting stimulus ...');
                logs.FirstVolOfExp = triggertstamp;
                waiting4Dummies = 0;
                
                % get first trigger timestamp after dummies
                scannerTrCtr = 1;
                logs.tTriggers(scannerTrCtr) = triggertstamp;
            end
            
        end % if manual trigger
        
        % wait for next trigger
        gotTrigger = 0;
        
    end % if trigger arrives
    
end % while dummies & manual trigger

fprintf('\n');

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
        
        % record scanner triggers
    elseif firstPress(settings.scannerTriggerKey)
        logs.tTriggers(scannerTrCtr) = firstPress(settings.scannerTriggerKey);
        scannerTrCtr = scannerTrCtr+1;
        
        % record task keys presses
    elseif firstPress(taskPrefs.key)
        logs.task.tKeyPresses(end+1) = firstPress(taskPrefs.key);
        
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
    
    
    
    %% ============ prepare new stimulus block ============
    if startNewTrial
        
        trialInd = trialInd + 1; % starts at 0
        currCond = settings.trialSeq(trialInd);
        startNewTrial = 0;
        
        % initialise current dot cloud
        % important: current condition struct is stored in c
        c = conds(currCond);
        d = initMotionCuboid(d0, c, settings);
        
        fprintf('\n========================================================');
        fprintf('\nTrial %d of %d: %s', trialInd, length(settings.trialSeq), conds(currCond).name);
        fprintf('\n========================================================');
        fprintf('\n');
        
        trialOnset = GetSecs;      
        
        % ================= get fresh randomises dots =====================
        xyz = [d.xCub d.yCub d.zCub ones(size(d.zCub))];
        xyz = reshape(xyz, bf1h, bf1w, 4);
        dotTex2D = Screen('MakeTexture', settings.scr.win, xyz, [], [], 2, 0);
        
        % draw dots into buffer
        Screen('DrawTexture', glSetts.buffer3Ddots, dotTex2D, [], [], [], 0);
        
        % Release texture:
        Screen('Close', dotTex2D);
        
        % project 3D dots to screen -> get 2D dots
        glSetts.bufferTmp = Screen('TransformTexture', glSetts.buffer3Ddots, glSetts.projectDotsOperator, [], glSetts.bufferTmp);
        Screen('DrawTexture', glSetts.buffer2Ddots, glSetts.bufferTmp, [], [], [], 0);
        
        % update dot parameters using 2D dots
        glSetts.bufferTmp = Screen('TransformTexture', glSetts.buffer2Ddots, glSetts.checkDotsShaderOperator, glSetts.dotParamBuffer, glSetts.bufferTmp);
        Screen('DrawTexture', glSetts.dotParamBuffer, glSetts.bufferTmp, [], [], [], 0);
        
        % log trial onset
        logs.trialOns(trialInd) = trialOnset;
        
    end
    
    % Clear color and depths buffers:
    Screen('BeginOpenGL', settings.scr.win);
    glClear;
    Screen('EndOpenGL', settings.scr.win);
    
    % draw bg
    Screen('FillRect', settings.scr.win, settings.scr.cols.bg);
    
    
    
    %% ========== move stars according to condition ==========
    [c, d] = threedMotionCuboid(c, d);
        
    
    %% =============== 3D scrambled dots ===============
    
    %% =============== 2D planar dots ===============
    if c.dots2D                               
        currSpeed3D = 0;
        if c.movFix == 1
            xyOff = [d.xCo(d.posInd2D) d.yCo(d.posInd2D)];
        else
            xyOff = [0 0];
        end        
    end
    
    if c.staticDots
        currSpeed3D = 0;
        xyOff = [0 0];
    end
    
    if c.dotScramble3D || c.dots3D
        currSpeed3D = d.speedVec3D(d.speedInd3D);
        xyOff = [d.xCo3D(d.posInd3D) d.yCo3D(d.posInd3D)];
    end
           
    % set dot speed
    glUseProgram(glSetts.moveDotsShader);
    glUniform1f(glGetUniformLocation(glSetts.moveDotsShader, 'dotSpeed'), currSpeed3D);
    glUseProgram(0);
    
    % create random seed texture
    myRandSeeds  = rand(size(xyz));
    randSeedsTex = Screen('MakeTexture', settings.scr.win, myRandSeeds, [], [], 2, 0);
    Screen('DrawTexture', glSetts.randSeedsBuffer, randSeedsTex, [], [], [], 0);
    Screen('Close', randSeedsTex);
  
    % backup 2D dots
    Screen('DrawTexture', glSetts.buffer2DdotsBAK, glSetts.buffer2Ddots, [], [], [], 0);
        
    % move 3D dots    
    glSetts.bufferTmp = Screen('TransformTexture', glSetts.buffer3Ddots, glSetts.moveDotsOperator, glSetts.randSeedsBuffer, glSetts.bufferTmp);
    Screen('DrawTexture', glSetts.buffer3Ddots, glSetts.bufferTmp, [], [], [], 0);

    % project 3D dots to screen -> get 2D dots
    glSetts.bufferTmp = Screen('TransformTexture', glSetts.buffer3Ddots, glSetts.projectDotsOperator, [], glSetts.bufferTmp);
    Screen('DrawTexture', glSetts.buffer2Ddots, glSetts.bufferTmp, [], [], [], 0);
    
    % 2D planar motion    
    glUseProgram(glSetts.planarMotionShader);
    glUniform2fv(glGetUniformLocation(glSetts.planarMotionShader, 'xySpeed'),     1, xyOff);     
    glUseProgram(0);
    glSetts.bufferTmp = Screen('TransformTexture', glSetts.buffer2Ddots, glSetts.doPlaneMotionOperator, [], glSetts.bufferTmp);
    Screen('DrawTexture', glSetts.buffer2Ddots, glSetts.bufferTmp, [], [], [], 0);
    
    % update dot parameters using 2D dots
    glSetts.bufferTmp = Screen('TransformTexture', glSetts.buffer2Ddots, glSetts.checkDotsShaderOperator, glSetts.dotParamBuffer, glSetts.bufferTmp);
    Screen('DrawTexture', glSetts.dotParamBuffer, glSetts.bufferTmp, [], [], [], 0);
    
    % scramble dots using 2D dots   
    glSetts.bufferTmp = Screen('TransformTexture', glSetts.buffer2Ddots, glSetts.scrambleDotsShaderOperator, glSetts.buffer2DdotsBAK, glSetts.bufferTmp);
    Screen('DrawTexture', glSetts.bufferScrambledDots, glSetts.bufferTmp, [], [], [], 0, []);
    
    

    BackupGL;
    
    % Can do this in PTB's Screen 2D context, which is more convenient for
    % our 2D drawing operations, as long as we are careful to restore any
    % changed context state:
    SwitchToPTB;
    
    % The 'GetWindowInfo' binds our ctx.FGDotsBuffer FBO so we can
    % glReadPixels() from it:
    if c.dotScramble3D
        Screen('GetWindowInfo', glSetts.bufferScrambledDots);        
    else            
        Screen('GetWindowInfo', glSetts.buffer2Ddots);        
    end
    
    % Mario says:
    % There is a bug in the X1000 gfx-card driver on OS/X 10.4.11 which
    % causes glReadPixels() readback values to get clamped to 0-1 range
    % if alpha-blending is enabled. Therefore we need to disable alpha
    % blending during glReadPixels() readback and reenable later if
    % needed:
    alphaenabled = glIsEnabled(GL.BLEND);
    glDisable(GL.BLEND);
    
    glBindBuffer(GL.PIXEL_PACK_BUFFER_ARB, glSetts.dotVBO);
    glReadPixels(0, 0, glSetts.samplesPerLine, glSetts.sampleLinesTotal, GL.RGBA, GL.FLOAT, 0);
    glBindBuffer(GL.PIXEL_PACK_BUFFER_ARB, 0);
    
    
    % Reenable alpha blending if it was enabled:
    if alphaenabled
        glEnable(GL.BLEND);
    end
    
    % The 'GetWindowInfo' binds our ctx.parentWin so we can render to it:
    Screen('GetWindowInfo', settings.scr.win);
    
    % Backup old 2D context state bits:
    glPushAttrib(GL.ALL_ATTRIB_BITS);
    
    if c.dotScramble3D
        glUseProgram(glSetts.renderScrambledDotsShader);
        
    elseif c.dots2D || c.staticDots
        glUseProgram(glSetts.render2DplanarDotsVB);
        %glUniform2fv(glGetUniformLocation(glSetts.render2DplanarDotsVB, 'xyOff'), 1, [xyOff(1) xyOff(2)]);
        
    elseif c.dots3D
        glUseProgram(glSetts.render3DdotsShader);
        
    end
    
    % Is point anti-aliasing enabled?
    pSmooth = glIsEnabled(GL.POINT_SMOOTH);
    
    
    % Background render:
    glBindBuffer(GL.ARRAY_BUFFER, glSetts.dotVBO);
    
    % enable vertex attributes
    glEnableVertexAttribArray(glSetts.vertex2Dind);
    glEnableVertexAttribArray(glSetts.dotColInd);
    
    % set array pointers:
    glVertexAttribPointer(glSetts.vertex2Dind,  4, GL.FLOAT, GL.FALSE, 0, 0);
    glVertexAttribPointer(glSetts.dotColInd, 4, GL.FLOAT, GL.FALSE, 0, uint32( (d.nDots * 4 * 4) ));
    
    % Bind vertex index VBO:
    glBindBuffer(GL.ELEMENT_ARRAY_BUFFER_ARB, glSetts.dotIBO);
    
    % Perform draw operation: All vertices, each triggering render for a
    % single GL.POINT primitive. Colors, sizes, anti-aliasing flags etc.
    % can be set from external code as appropriate. Application of textures
    % or shaders is also possible:
    glDrawRangeElements(GL.POINTS, 0, d.nDots-1, d.nDots, GL.UNSIGNED_INT, 0);
    
    % use glDrawArrays -> works as well
    % glDrawArrays(GL.POINTS, 0, d.nDots);
    
    glUseProgram(0);
    
    % disable vertex attributes
    glDisableVertexAttribArray(glSetts.vertex2Dind);
    glDisableVertexAttribArray(glSetts.dotColInd);
    
    % Unbind our VBOs:
    glBindBuffer(GL.ELEMENT_ARRAY_BUFFER_ARB, 0);
    glBindBuffer(GL.ARRAY_BUFFER, 0);
    
    % Restore old 2D context state bits:
    glPopAttrib;
    
    RestoreGL;

    
    
    %% =========== openGL drawing finished ===========
    
    
    % field of view
    if c.fov == 2
        fovRect = [0 0 (1-settings.fov.size)*RectWidth(settings.scr.rect) RectHeight(settings.scr.rect)];
        fovRect = OffsetRect(fovRect, settings.fov.size*RectWidth(settings.scr.rect), 0);
        
    elseif c.fov == 3
        fovRect = [0 0 (1-settings.fov.size)*RectWidth(settings.scr.rect) RectHeight(settings.scr.rect)];
        
    end
    
    if c.fov > 1
        Screen('FillRect', settings.scr.win, settings.scr.cols.bg, fovRect);
    end
    
    
    % move fixation dot
    if c.movFix > 0 && c.movFix < 3
        aTask.xyOffset = [d.xCo(d.posInd2D) d.yCo(d.posInd2D)];
    else
        aTask.xyOffset = [0 0];
    end
    
    % run task in front of arrow
    aTask.frameCtr = aTask.frameCtr +1; % won't be reset
    aTask = showAttentionTask('run', aTask);
    
    vbl = Screen('Flip', settings.scr.win);
    
    
    % check whether end of trial is reached
    % and prepare for new trial
    if GetSecs > trialOnset + c.dur
        
        % log trial offset
        logs.trialOffs(trialInd) = GetSecs;
        
        % start new trial if we did not reach last trial
        if trialInd < length(settings.trialSeq)
            startNewTrial = 1;
            
        else
            % wait a few secs and quit
            % draw bg
            Screen('FillRect', settings.scr.win, settings.scr.cols.bg);
            aTask.xyOffset    = [0 0];
            aTask = showAttentionTask('showFix', aTask);
            Screen('Flip', settings.scr.win);
            WaitSecs(settings.waitAfterLastTrial);
            playAnimation = 0;
            
            % script ended normally
            userQuit = 0;
        end
        
    end
    
    
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

% if user quit experiment before all trials
% are through indicate this in the log filename
if ~userQuit
    file2save  = sprintf('%d_%s_motionLoc_%s.mat', runNr, subjID, currTstamp);
else
    file2save  = sprintf('%d_%s_motionLoc_%s_inComplete.mat', runNr, subjID, currTstamp);
end
save(fullfile(tmpPath, file2save));


% close all PTB windows
% get rid of all textures
Screen('CloseAll');

% stop KbQueue
KbQueueFlush;
KbQueueStop;

ShowCursor; % show cursor again;

%Screen('Resolution', settings.scr.ID, settings.oldScr.width, settings.oldScr.height, settings.oldScr.hz);
sca;

% stop KbQueue
KbQueueFlush;
KbQueueStop;

ShowCursor; % show cursor again;

%Screen('Resolution', settings.scr.ID, settings.oldScr.width, settings.oldScr.height, settings.oldScr.hz);

if settings.scr.doGammaCorrection
    
    % load old gamma
    Screen('LoadNormalizedGammaTable', settings.scr.ID, settings.oldScr.gammaTable); %set macs native gammaLUT again
    
end

fprintf('\n');

% do this to prevent user to forget to manally
% close serial port
if settings.recordTriggers == 1
    fprintf('\nPlease give a last manual trigger to close serial port and continue!')
    fprintf('\n')
    clear all
end

sca

return;







%% ---------------- internal helper functions -----------------------------

% Internal helper functions:
function SwitchToGL(win)

% Switch to our OpenGL context, but keep a backup of original
% drawstate. We do lazy switching if possible:
[currentwin, IsOpenGLRendering] = Screen('GetOpenGLDrawMode');

if ~IsOpenGLRendering
    % PTB's context active: Switch to OpenGL rendering for our parent window:
    Screen('BeginOpenGL', win);
else
    % In rendering context. Is it ours? If yes, then there isn't anything
    % to do...
    if currentwin ~= win
        % No, a different windows context is active: First switch to PTB
        % mode, then switch to ours:
        
        % Switch to our parentWin's PTB context:
        Screen('EndOpenGL', currentwin);
        % Switch to our parentWin's GL context:
        Screen('BeginOpenGL', win);
    end
end
return;

function SwitchToPTB

% Switch from our OpenGL context, but keep a backup of original
% drawstate. We do lazy switching if possible:
[currentwin, IsOpenGLRendering] = Screen('GetOpenGLDrawMode');

if ~IsOpenGLRendering
    % PTB's context is already active: Nothing to do.
else
    % In rendering context. Switch back to PTB - and to our parentWin:
    Screen('EndOpenGL', currentwin);
end
return;

function BackupGL
global moglMotion_OriginalContext;

if ~isempty(moglMotion_OriginalContext)
    error('BackupGL called twice in succession without intermediate RestoreGL! Ordering inconsistency!');
end

[currentwin, IsOpenGLRendering] = Screen('GetOpenGLDrawMode');

if IsOpenGLRendering
    moglMotion_OriginalContext = currentwin;
end
return;

function RestoreGL
global moglMotion_OriginalContext;

[currentwin, IsOpenGLRendering] = Screen('GetOpenGLDrawMode');

if isempty(moglMotion_OriginalContext)
    % PTB was in Screen drawing mode: Switch to that mode, if not active:
    if IsOpenGLRendering
        Screen('EndOpenGL', currentwin);
    end
    return;
end

% Need to restore to GL context if not already active:
if ~IsOpenGLRendering
    Screen('BeginOpenGL', moglMotion_OriginalContext);
else
    % OpenGL context active. Ours? If so -> Nothing to do.
    if currentwin ~= moglMotion_OriginalContext
        % Nope. Need to switch:
        Screen('EndOpenGL', currentwin);
        Screen('BeginOpenGL', moglMotion_OriginalContext);
    end
end

% Restore to default:
moglMotion_OriginalContext = [];

return;

