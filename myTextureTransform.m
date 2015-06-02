function myTextureTransform



KbName('UnifyKeyNames')

Screen('Preference', 'SkipSyncTests', 2);

% Need OpenGL constants:
global GL;
global moglFDF_OriginalContext;

%% Setup PTB window
% Find the screen to use for display:
scr.ID = max(Screen('Screens'));

scr.ID            = 2;
scr.width         = 1024;
scr.height        =  768;
scr.halfWidthCm   = 18; % half screen width in cm
scr.halfHeightCm  = 13.5; % half screen height in cm
scr.fovY          = 19;

scr.pixPcm        = scr.width / (2*scr.halfWidthCm);

% viewing distances
scr.viewDistMin   =  80; % distance of screen cm -> zNear
scr.viewDistMax   = 430; % location of max visible distance -> zFar

% Setup Psychtoolbox for OpenGL 3D rendering support and initialize the
% mogl OpenGL for Matlab wrapper:
InitializeMatlabOpenGL([], 0);

% Open a double-buffered full-screen window on the main displays screen,
% with fast Offscreen window support enabled and black background clear
% color. Fast Offscreen windows support is needed for moglFDF to work.
PsychImaging('PrepareConfiguration');
PsychImaging('AddTask', 'General', 'UseFastOffscreenWindows');
multiSample = 8;
[scr.win , scr.rect] = PsychImaging('OpenWindow', scr.ID, 0, [], [], [], [], multiSample);


% Backup current GL context binding:
BackupGL;

% Make sure our Screen context is active:
SwitchToPTB;

% Retrieve info about our hosting window. This will implicitely enable
% our parents OpenGL context, so we can do GL query commands safely:
scr.wInfo = Screen('GetWindowInfo', scr.win);

% dots struct
d.nDots = 10000;

%% create frame buffer objects

% Retrieve maximum width or height of textures and offscreen windows
% supported by this GL implementation:
glSetts.maxTexSize = glGetIntegerv(GL.MAX_RECTANGLE_TEXTURE_SIZE_EXT);

% Width of a line in samplebuffer:
glSetts.samplesPerLine = min(glSetts.maxTexSize, 2048);
glSetts.samplesPerLine = min(glSetts.samplesPerLine, d.nDots);

% Our buffer is implemented as a FBO backed floating point offscreen
% window with a pixel size of 128 bits, aka 32 bpc float.
glSetts.sampleLinesTotal    = ceil(d.nDots / glSetts.samplesPerLine);
glSetts.randBuffer          = Screen('OpenOffscreenWindow', scr.win, [0 0 0 0], double([0 0 glSetts.samplesPerLine glSetts.sampleLinesTotal]), 128, 32);
glSetts.bufferScrambledDots = Screen('OpenOffscreenWindow', scr.win, [0 0 0 0], double([0 0 glSetts.samplesPerLine glSetts.sampleLinesTotal]), 128, 32);
glSetts.buffer3Ddots        = Screen('OpenOffscreenWindow', scr.win, [0 0 0 0], double([0 0 glSetts.samplesPerLine glSetts.sampleLinesTotal]), 128, 32);
glSetts.buffer3DdotsBAK     = Screen('OpenOffscreenWindow', scr.win, [0 0 0 0], double([0 0 glSetts.samplesPerLine glSetts.sampleLinesTotal]), 128, 32);
glSetts.bufferTmp           = Screen('OpenOffscreenWindow', scr.win, [0 0 0 0], double([0 0 glSetts.samplesPerLine glSetts.sampleLinesTotal]), 128, 32);
glSetts.randSeedsBuffer     = Screen('OpenOffscreenWindow', scr.win, [0 0 0 0], double([0 0 glSetts.samplesPerLine glSetts.sampleLinesTotal]), 128, 32);
glSetts.dotParamBuffer      = Screen('OpenOffscreenWindow', scr.win, [0 0 0 0], double([0 0 glSetts.samplesPerLine glSetts.sampleLinesTotal]), 128, 32);

glSetts.projectedDotsBuffer = Screen('OpenOffscreenWindow', scr.win, [0 0 0 0], double([0 0 glSetts.samplesPerLine glSetts.sampleLinesTotal]), 128, 32);

glSetts.randBufferHDL      = Screen('GetOpenGLTexture', scr.win, glSetts.randBuffer);
glSetts.randSeedsBufferHDL = Screen('GetOpenGLTexture', scr.win, glSetts.randSeedsBuffer);
glSetts.bufferScrambledDotsHDL    = Screen('GetOpenGLTexture', scr.win, glSetts.bufferScrambledDots);
glSetts.dotParamBufferHDL  = Screen('GetOpenGLTexture', scr.win, glSetts.dotParamBuffer);

d.nDots                  = glSetts.sampleLinesTotal * glSetts.samplesPerLine;
d.maxSize  = 10;
d.dotSpeed = 2.0;

d.widthCuboid  = 2*(scr.halfWidthCm * (scr.viewDistMax / scr.viewDistMin));        
d.lengthCuboid = scr.viewDistMax - scr.viewDistMin;

d.xCub = (rand(1, d.nDots) * d.widthCuboid) - d.widthCuboid / 2;
d.yCub = (rand(1, d.nDots) * d.widthCuboid) - d.widthCuboid / 2;

% get random height of each dot
% in openGl the z-axis goes negative
% into the screen and out positive
% --> multiply z-coords by -1
d.zCub = -rand(1, d.nDots) * d.lengthCuboid;




%% load shaders
tmp = mfilename('fullpath');
shaderPath = fileparts(tmp);
shaderPath = fullfile(shaderPath, 'myShaders');
glSetts.shaderPath = shaderPath;
glSetts.shaderDebuglevel = 2;


glSetts.projectDotsShader = LoadGLSLProgramFromFiles({ ...                                        
                                        ...%fullfile(glSetts.shaderPath, 'projectDots.vert.txt'), ...
                                        fullfile(glSetts.shaderPath, 'projectDots.frag.txt') ...
                                        }, glSetts.shaderDebuglevel); 
                                    
   
glSetts.moveDotsShader = LoadGLSLProgramFromFiles({ ...                                        
                                        ...%fullfile(glSetts.shaderPath, 'projectDots.vert.txt'), ...
                                        fullfile(glSetts.shaderPath, 'moveDots.frag.txt') ...
                                        }, glSetts.shaderDebuglevel); 
                                                                        
glSetts.scrambleDotsShader = LoadGLSLProgramFromFiles({ ...
                                        ...%fullfile(glSetts.shaderPath, 'projectDots.vert.txt'), ...
                                        fullfile(glSetts.shaderPath, 'scrambleDots.frag.txt') ...
                                        }, glSetts.shaderDebuglevel); 
                                    
glSetts.checkDotsShader = LoadGLSLProgramFromFiles({ ...
                                        ...%fullfile(glSetts.shaderPath, 'projectDots.vert.txt'), ...
                                        fullfile(glSetts.shaderPath, 'checkDots.frag.txt') ...
                                        }, glSetts.shaderDebuglevel);

glSetts.renderScrambledDotsShader = LoadGLSLProgramFromFiles({ ...
                                        ...%fullfile(glSetts.shaderPath, 'projectDots.vert.txt'), ...
                                        fullfile(glSetts.shaderPath, 'renderDotsVB.vert.txt') ...
                                        }, glSetts.shaderDebuglevel);
                                    
glSetts.render3DdotsShader = LoadGLSLProgramFromFiles({ ...
                                        ...%fullfile(glSetts.shaderPath, 'projectDots.vert.txt'), ...
                                        fullfile(glSetts.shaderPath, 'render3DdotsVB.vert.txt') ...
                                        }, glSetts.shaderDebuglevel);
                                    
glSetts.render2DplanarDotsVB = LoadGLSLProgramFromFiles({ ...
                                        ...%fullfile(glSetts.shaderPath, 'projectDots.vert.txt'), ...
                                        fullfile(glSetts.shaderPath, 'render2DplanarDotsVB.vert.txt') ...
                                        }, glSetts.shaderDebuglevel); 
                                    

% Ok, all PTB managed buffers and shaders loaded and set up.
% Lets create the VBO that we need to actually render anything in the
% end. VBO's are not supported yet by PTB's Screen, so we need to
% switch to our GL context for setup:
Screen('BeginOpenGL', scr.win);

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
buffersize = (d.nDots * 4 * 4)*2;

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
dotindices = uint32(0:d.nDots-1);
glBufferData(GL.ELEMENT_ARRAY_BUFFER_ARB, d.nDots * 4, dotindices, GL.STATIC_DRAW);
glBindBuffer(GL.ELEMENT_ARRAY_BUFFER_ARB, 0);

% Done with VBO setup.
% Restore previous GL context binding:
RestoreGL;

BackupGL;

% Switch to OpenGL rendering context to be used for 3D scene rendering,
% and specifically for our silhouette render buffer:
SwitchToPTB;

%% setup projection

% Setup the OpenGL rendering context of the onscreen window for use by
% OpenGL wrapper. After this command, all following OpenGL commands will
% draw into the onscreen window 'win':
%Screen('BeginOpenGL', scr.win);

Screen('BeginOpenGL', scr.win);


% get screen rect
scrRect = Screen('Rect', scr.win);

% Get the aspect ratio of the screen:
scr.ar = RectHeight(scrRect) / RectWidth(scrRect);

% Set viewport properly:
glViewport(0, 0, RectWidth(scrRect), RectHeight(scrRect));

% Enable alpha-blending for smooth dot drawing:
glEnable(GL.BLEND);
glBlendFunc(GL.SRC_ALPHA, GL.ONE_MINUS_SRC_ALPHA);

% MK: Hier 1x depth test einschalten:
glEnable(GL.DEPTH_TEST);




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
gluPerspective(scr.fovY, 1/scr.ar, scr.viewDistMax, scr.viewDistMin);

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

% Set viewport and scissor to full trackbuffer window area:
[bf1w, bf1h] = RectSize(Screen('Rect',glSetts.bufferTmp));
% glViewport(0, 0, bf1w, bf1h);
% glScissor(0, 0, bf1w, bf1h);

% assign projection params manually
myMats.modViewMat        = [1 0 0 0
    0 1 0 0
    0 0 1 0
    0 0 0 1];
myMats.modMat            = reshape(glGetDoublev(GL.MODELVIEW_MATRIX), 4, 4);
myMats.projMat           = reshape(glGetDoublev(GL.PROJECTION_MATRIX), 4, 4);
myMats.viewPort          = glGetDoublev(GL.VIEWPORT);

%myMats.zNearFar          = [settings.scr.viewDistMin, settings.scr.viewDistMax];
%myMats.maxDotSize        = d0.maxSize;

myMats.modViewProjMat    = myMats.modViewMat*myMats.projMat;

Screen('EndOpenGL', scr.win);


% assign uniforms
glUseProgram(glSetts.projectDotsShader);
glUniformMatrix4fv(glGetUniformLocation(glSetts.projectDotsShader, 'modelViewMat'), 1, 0, myMats.modViewMat);
glUniformMatrix4fv(glGetUniformLocation(glSetts.projectDotsShader, 'modelMat'),     1, 0, myMats.modMat);
glUniformMatrix4fv(glGetUniformLocation(glSetts.projectDotsShader, 'projMat'),      1, 0, myMats.projMat);
glUniform4fv(glGetUniformLocation(       glSetts.projectDotsShader, 'viewPortVec'),        1,    myMats.viewPort);
glUniform1i(glGetUniformLocation(        glSetts.projectDotsShader, 'xyzDotCoords'), 0);
glUseProgram(0);

glSetts.projectDotsOperator = CreateGLOperator(scr.win, [], glSetts.projectDotsShader, 'Project Dots');


glUseProgram(glSetts.moveDotsShader);
glUniform1i(glGetUniformLocation(glSetts.moveDotsShader, 'xyzDotCoords'), 0);
glUniform1i(glGetUniformLocation(glSetts.moveDotsShader, 'myRandSeeds'),  1);
glUniform1f(glGetUniformLocation(glSetts.moveDotsShader, 'cubeLength'), d.lengthCuboid);
glUniform1f(glGetUniformLocation(glSetts.moveDotsShader, 'cubeWidth'),  d.widthCuboid);
glUniform1f(glGetUniformLocation(glSetts.moveDotsShader, 'dotSpeed'),   d.dotSpeed);
glUseProgram(0);

glSetts.moveDotsOperator = CreateGLOperator(scr.win, [], glSetts.moveDotsShader, 'Move Dots');

glUseProgram(glSetts.scrambleDotsShader);
glUniform1i(glGetUniformLocation(glSetts.scrambleDotsShader,        'xyzDotCoords'),     0);
glUniform1i(glGetUniformLocation(glSetts.scrambleDotsShader,        'xyzDotCoordsLast'), 1);
glUniform1i(glGetUniformLocation(glSetts.scrambleDotsShader,        'checkTex'),         2);
glUniform1i(glGetUniformLocation(glSetts.scrambleDotsShader,        'myRandSeeds'),      3);
glUniform1i(glGetUniformLocation(glSetts.scrambleDotsShader,        'xyDotsLast'),       4);
glUniformMatrix4fv(glGetUniformLocation(glSetts.scrambleDotsShader, 'modelViewMat'),     1, 0, myMats.modViewMat);
glUniformMatrix4fv(glGetUniformLocation(glSetts.scrambleDotsShader, 'modelMat'),         1, 0, myMats.modMat);
glUniformMatrix4fv(glGetUniformLocation(glSetts.scrambleDotsShader, 'projMat'),          1, 0, myMats.projMat);
glUniform4fv(glGetUniformLocation(glSetts.scrambleDotsShader,       'viewPortVec'),      1,    myMats.viewPort);
glUniform1f(glGetUniformLocation(glSetts.scrambleDotsShader,        'dotSpeed'),               d.dotSpeed);
glUseProgram(0);

glSetts.scrambleDotsShaderOperator = CreateGLOperator(scr.win, [], glSetts.scrambleDotsShader, 'Scramble dots distance');


glUseProgram(glSetts.checkDotsShader);
glUniform1i(glGetUniformLocation(glSetts.checkDotsShader,        'xyzDotCoords'),     0);
glUniform1i(glGetUniformLocation(glSetts.checkDotsShader,        'myRandSeeds'),        1);
glUniform1i(glGetUniformLocation(glSetts.checkDotsShader,        'checkTex'),         2);
glUniformMatrix4fv(glGetUniformLocation(glSetts.checkDotsShader, 'modelViewMat'),     1, 0, myMats.modViewMat);
glUniformMatrix4fv(glGetUniformLocation(glSetts.checkDotsShader, 'modelMat'),         1, 0, myMats.modMat);
glUniformMatrix4fv(glGetUniformLocation(glSetts.checkDotsShader, 'projMat'),          1, 0, myMats.projMat);
glUniform4fv(glGetUniformLocation(glSetts.checkDotsShader,       'viewPortVec'),      1,    myMats.viewPort);
glUniform1f(glGetUniformLocation(glSetts.checkDotsShader,        'zNear'),            scr.viewDistMin);
glUniform1f(glGetUniformLocation(glSetts.checkDotsShader,        'zFar'),             scr.viewDistMax);
glUseProgram(0);

glSetts.checkDotsShaderOperator = CreateGLOperator(scr.win, [], glSetts.checkDotsShader, 'Scramble dots distance');



% ------------------- scramble render shader ------------------------------
% % bind vertex attribute layer to render dots shader
 glSetts.vertex2Dind = 0;
glBindAttribLocation(glSetts.renderScrambledDotsShader, glSetts.vertex2Dind, 'vertex2D');

 glSetts.dotColInd = 1;
glBindAttribLocation(glSetts.renderScrambledDotsShader, glSetts.dotColInd, 'dotColour');

% dont forget to link the shader AFTER layer binding! :-)
glLinkProgram(glSetts.renderScrambledDotsShader);

glUseProgram(glSetts.renderScrambledDotsShader);
glUniform1f(glGetUniformLocation(glSetts.renderScrambledDotsShader,        'zNear'),             scr.viewDistMin);
glUniform1f(glGetUniformLocation(glSetts.renderScrambledDotsShader,        'maxDotSize'),             d.maxSize);
glUseProgram(0);


% ------------------- flow render shader ------------------------------
% bind vertex attribute layer to render dots shader
glBindAttribLocation(glSetts.render3DdotsShader, glSetts.vertex2Dind, 'vertex2D');
glBindAttribLocation(glSetts.render3DdotsShader, glSetts.dotColInd, 'dotColour');

% dont forget to link the shader AFTER layer binding! :-)
glLinkProgram(glSetts.render3DdotsShader);

glUseProgram(glSetts.render3DdotsShader);
glUniform1f(glGetUniformLocation(glSetts.render3DdotsShader,        'zNear'),             scr.viewDistMin);
glUniform1f(glGetUniformLocation(glSetts.render3DdotsShader,        'maxDotSize'),             d.maxSize);
glUseProgram(0);


% ------------------- planar render shader ------------------------------
% bind vertex attribute layer to render dots shader
glBindAttribLocation(glSetts.render2DplanarDotsVB, glSetts.vertex2Dind, 'vertex2D');
glBindAttribLocation(glSetts.render2DplanarDotsVB, glSetts.dotColInd, 'dotColour');

% dont forget to link the shader AFTER layer binding! :-)
glLinkProgram(glSetts.render2DplanarDotsVB);

glUseProgram(glSetts.render2DplanarDotsVB);
glUniform1f(glGetUniformLocation(glSetts.render2DplanarDotsVB,        'zNear'),             scr.viewDistMin);
glUniform1f(glGetUniformLocation(glSetts.render2DplanarDotsVB,        'maxDotSize'),             d.maxSize);
glUniform2fv(glGetUniformLocation(glSetts.checkDotsShader,            'xyOff'),      1,              [0 0]);
glUseProgram(0);


SwitchToPTB


    %d.zCub = d.zCub +1;
    %d.zCub(d.zCub>0) = d.zCub(d.zCub>0)-d.lengthCuboid;    
    xyz = [d.xCub d.yCub d.zCub ones(size(d.zCub))];
    xyz = reshape(xyz, bf1h, bf1w, 4);
    %dotTex2D = Screen('MakeTexture', scr.win, xyz, [], [], 2, 0, glSetts.projectDotsShader);
    dotTex2D = Screen('MakeTexture', scr.win, xyz, [], [], 2, 0);
    
    % draw dots into buffer
    Screen('DrawTexture', glSetts.buffer3Ddots, dotTex2D, [], [], [], 0);
   
    % Release texture:
    Screen('Close', dotTex2D);
    
    % random 2D seeds
        
    % draw dots into buffer
    rand2DdotsX = (rand(1, d.nDots) *  RectWidth(scr.rect)); % x
    rand2DdotsY = (rand(1, d.nDots) * RectHeight(scr.rect)); % y
    xyz = [rand2DdotsX rand2DdotsY ones(size(d.zCub)) ones(size(d.zCub))];    
    xyz = reshape(xyz, bf1h, bf1w, 4);    
    dotTex2D = Screen('MakeTexture', scr.win, xyz, [], [], 2, 0);
      
    Screen('DrawTexture', glSetts.bufferScrambledDots, dotTex2D, [], [], [], 0);
   
    % Release texture:
    Screen('Close', dotTex2D);
    
    
    % create random seed texture
    myRandSeeds    = rand(size(xyz));
    randSeedsTex = Screen('MakeTexture', scr.win, myRandSeeds, [], [], 2, 0);     
    Screen('DrawTexture', glSetts.randSeedsBuffer, randSeedsTex, [], [], [], 0);
    
    % create initial dots param texture with random xy directions.
    % set initial visibility to 1 for all dots. Will be adapted during
    % first cycle
    tmp = [1 -1];
    xDirs   = tmp(ceil(rand(size(d.xCub))*length(tmp)));
    yDirs   = tmp(ceil(rand(size(d.xCub))*length(tmp)));
    visFlag = ones(size(xDirs));
    w       = visFlag;    
    dotParams = [xDirs yDirs visFlag w];
    dotParams = reshape(dotParams, bf1h, bf1w, 4);
    
    dotParamTex = Screen('MakeTexture', scr.win, dotParams, [], [], 2, 0);     
    Screen('DrawTexture', glSetts.dotParamBuffer, dotParamTex, [], [], [], 0);
    
        
    % bind random numbers to texture unit2
    glActiveTexture(GL.TEXTURE2);
    glBindTexture(GL.TEXTURE_RECTANGLE_EXT, glSetts.dotParamBufferHDL);
    glActiveTexture(GL.TEXTURE3);
    glBindTexture(GL.TEXTURE_RECTANGLE_EXT, glSetts.randSeedsBufferHDL);
    glActiveTexture(GL.TEXTURE4);
    glBindTexture(GL.TEXTURE_RECTANGLE_EXT, glSetts.bufferScrambledDotsHDL);        
    glActiveTexture(GL.TEXTURE0);
    
    ctr = 0;
    
    
    %glEnable(GL.POINT_SPRITE);
    glEnable(GL.VERTEX_PROGRAM_POINT_SIZE);
    
    colVec = [ones(1,d.nDots/2) zeros(1,d.nDots/2)];
    colVec = colVec(randperm(length(colVec)));
    colVec = repmat(colVec,4,1);
    
    % important! cast data to single float!
    % Otherwise data gets incorrectly written to buffer!
    buffMat  = single(colVec);
     
    glBindBuffer(GL.ARRAY_BUFFER, glSetts.dotVBO);
    glBufferSubData(GL.ARRAY_BUFFER, 4*prod(size(buffMat)), 4*prod(size(buffMat)), buffMat);
    glBindBuffer(GL.ARRAY_BUFFER, 0);
    
    renderMode = 1;
    
    KbQueueCreate();
    KbQueueStart();
    
    xOff = 0;
    yOff = 0;
    
    while 1
        
        xOff = xOff+1;
        yOff = yOff+1;
        
        [~, firstPress] = KbQueueCheck();

        % press escape to leave the program
        if firstPress(KbName('ESCAPE'))
            break;            
        elseif firstPress(KbName('space'))
           renderMode = renderMode+1;
           % as we only have 3 modes set back to one if > 3
           if renderMode > 3
               renderMode = 1;
           end
        elseif firstPress(KbName('c'))
            d.dotSpeed = -d.dotSpeed;
            
            glUseProgram(glSetts.scrambleDotsShader);
            glUniform1f(glGetUniformLocation(glSetts.scrambleDotsShader, 'dotSpeed'), d.dotSpeed);
            
            glUseProgram(glSetts.moveDotsShader);
            glUniform1f(glGetUniformLocation(glSetts.moveDotsShader, 'dotSpeed'), d.dotSpeed);
           
            glUseProgram(0);
        end
        
        SwitchToPTB
        
        Screen('FillRect', scr.win, 255/2);
        
        if renderMode ~= 2
            
            % create random seed texture
            myRandSeeds  = rand(size(xyz));
            randSeedsTex = Screen('MakeTexture', scr.win, myRandSeeds, [], [], 2, 0);
            Screen('DrawTexture', glSetts.randSeedsBuffer, randSeedsTex, [], [], [], 0);
            Screen('Close', randSeedsTex);
            
            % backup dots
            Screen('DrawTexture', glSetts.buffer3DdotsBAK, glSetts.buffer3Ddots, [], [], [], 0);
            
            % move dots
            glSetts.bufferTmp = Screen('TransformTexture', glSetts.buffer3DdotsBAK, glSetts.moveDotsOperator, glSetts.randSeedsBuffer, glSetts.bufferTmp);
            Screen('DrawTexture', glSetts.buffer3Ddots, glSetts.bufferTmp, [], [], [], 0);
            
        end
        
        % project dots to buffer. For debugging only
        glSetts.bufferTmp = Screen('TransformTexture', glSetts.buffer3Ddots, glSetts.projectDotsOperator, [], glSetts.bufferTmp);
        Screen('DrawTexture', glSetts.projectedDotsBuffer, glSetts.bufferTmp, [], [], [], 0);
        
        % update dot parameters
        glSetts.bufferTmp = Screen('TransformTexture', glSetts.buffer3Ddots, glSetts.checkDotsShaderOperator, glSetts.dotParamBuffer, glSetts.bufferTmp);
        Screen('DrawTexture', glSetts.dotParamBuffer, glSetts.bufferTmp, [], [], [], 0);
        
        % scramble dots
        glSetts.bufferTmp = Screen('TransformTexture', glSetts.buffer3Ddots, glSetts.scrambleDotsShaderOperator, glSetts.buffer3DdotsBAK, glSetts.bufferTmp);
        Screen('DrawTexture', glSetts.bufferScrambledDots, glSetts.bufferTmp, [], [], [], 0, []);
        
        BackupGL;
        
        % Can do this in PTB's Screen 2D context, which is more convenient for
        % our 2D drawing operations, as long as we are careful to restore any
        % changed context state:
        SwitchToPTB;
        
        % Yes: Copy content of FGDotsBuffer into VBO, using PBO extension.
        % The 'GetWindowInfo' binds our ctx.FGDotsBuffer FBO so we can
        % glReadPixels() from it:        
        if renderMode == 1
            Screen('GetWindowInfo', glSetts.bufferScrambledDots);
            
        elseif renderMode == 2
            Screen('GetWindowInfo', glSetts.projectedDotsBuffer);
        
        elseif renderMode == 3
            Screen('GetWindowInfo', glSetts.projectedDotsBuffer);
                       
        end
        
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
        Screen('GetWindowInfo', scr.win);
        
        % Backup old 2D context state bits:
        glPushAttrib(GL.ALL_ATTRIB_BITS);
        
        if renderMode == 1
            glUseProgram(glSetts.renderScrambledDotsShader);
            
        elseif renderMode == 2
            glUseProgram(glSetts.render2DplanarDotsVB);
            glUniform2fv(glGetUniformLocation(glSetts.render2DplanarDotsVB, 'xyOff'), 1, [xOff yOff]);                        
            
        elseif renderMode == 3
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
        Screen('Flip', scr.win);
        
        ctr = ctr+1;
        
    end
    
    sca
    KbQueueStop;
    clear all;
    
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
global moglFDF_OriginalContext;

if ~isempty(moglFDF_OriginalContext)
    error('BackupGL called twice in succession without intermediate RestoreGL! Ordering inconsistency!');
end

[currentwin, IsOpenGLRendering] = Screen('GetOpenGLDrawMode');

if IsOpenGLRendering
    moglFDF_OriginalContext = currentwin;
end
return;

function RestoreGL
global moglFDF_OriginalContext;

[currentwin, IsOpenGLRendering] = Screen('GetOpenGLDrawMode');

if isempty(moglFDF_OriginalContext)
    % PTB was in Screen drawing mode: Switch to that mode, if not active:
    if IsOpenGLRendering
        Screen('EndOpenGL', currentwin);
    end
    return;
end

% Need to restore to GL context if not already active:
if ~IsOpenGLRendering
    Screen('BeginOpenGL', moglFDF_OriginalContext);
else
    % OpenGL context active. Ours? If so -> Nothing to do.
    if currentwin ~= moglFDF_OriginalContext
        % Nope. Need to switch:
        Screen('EndOpenGL', currentwin);
        Screen('BeginOpenGL', moglFDF_OriginalContext);        
    end
end

% Restore to default:
moglFDF_OriginalContext = [];

return;

function deleteContextBuffers(ctx)
    BackupGL;
    
    SwitchToGL(ctx.parentWin);
    
    % Delete VBO's:
    glDeleteBuffers(1, ctx.FGibo);
    glDeleteBuffers(1, ctx.FGvbo);
    glDeleteBuffers(1, ctx.BGibo);
    glDeleteBuffers(1, ctx.BGvbo);
    
    SwitchToPTB;
    
    % Close all offscreen windows and their associated textures:
    Screen('Close', [ctx.BGDotsBuffer, ctx.FGDotsBuffer, ctx.trackingBuffer, ctx.silhouetteBuffer, ctx.sampleBuffer]);
    
    % Close our operators:
    Screen('Close', ctx.createFGDotsoperator);
    
return;





