function aTask = showAttentionTask(jobStr, varargin)
% --> Initialize with: showLetterTask('init', taskPrefs)
% -->        Run with: showLetterTask('run',  aTask, frameCtr)
% -->        Run with: showLetterTask('showFix', aTask)
%
% This function initializes / presents an attention task at the fixation
% point. To initialize run it once with jobString = 'init'. Then call it
% on every frame within your animation loop.
%
% For initialization 'taskPrefs' requires the following fields:
%
%     type (int): 0 --> normal one-back-matching task: press button / count
%                       whenever one of 24 chars is repeated
%
%                 1 --> same as 0, but only vowel-chars are shown
%
%                 2 --> no task - just show fixation cross
%
%   scr (struct): containing the following screen settings:
%                 --> cols (struct) (size == nScreens / nSplits i.e. for gamma / color correction):
%                       --> innerDisc [r g b]: fixation disc
%                       --> outerDisc [r g b]: fixation disc outer border,
%                                            e.g. for cueing the observer
%                       --> font [r g b] font color
%
%                 --> setup (str) : 'split' / 'mono' (ToDo: implement mono setting)
%                 --> scrPtr (int): pointer to the avtive screen on which a
%                     PTB win is open
%
%   xyOffset [x,y]: Offset task presentation by x and y pixels
%
%   fontSize (int): Size of letters
%
%   fontStyle (0/1): normal / bold
%
%   taskItvls [n:m]: repeat a char every within a range of n:m
%                    presentations
%
%   nFramesItv (int): no char so many *seq* frames
%
%   recWidth (int): fixation dot width
%
% _________________________________________________________________________
%
% Initial version written for Cogent by Andreas Bartels.
% Modified for PTB by as (08/2013)


    % use input parser to validate input
    p = inputParser;
    p.addRequired('jobStr',           @isstr);
    p.parse(jobStr);
    jobStr = p.Results.jobStr;

    %% ========== Init task ================
    if strcmpi(jobStr, 'init')

        % get taskPrefs and check for valid variables
        aTask       = varargin{1};
        aTask.frameCtr  = 0;

        % check if preference struct contains all the fields we need
        fieldMissing = 0;
        missingFields = {};

        field2check = 'scr';
        if ~isfield(aTask, field2check)
            fieldMissing = 1;
            missingFields{end+1} = field2check;
        end

        field2check = 'xyOffset';
        if ~isfield(aTask, field2check)
            fieldMissing = 1;
            missingFields{end+1} = field2check;
        end

        field2check = 'type';
        if ~isfield(aTask, field2check)
            fieldMissing = 1;
            missingFields{end+1} = field2check;
        end

        field2check = 'fontSize';
        if ~isfield(aTask, field2check)
            fieldMissing = 1;
            missingFields{end+1} = field2check;
        end

        field2check = 'taskItvls';
        if ~isfield(aTask, field2check)
            fieldMissing = 1;
            missingFields{end+1} = field2check;
        end

        field2check = 'nFramesItv';
        if ~isfield(aTask, field2check)
            fieldMissing = 1;
            missingFields{end+1} = field2check;
        end

        field2check = 'recWidth';
        if ~isfield(aTask, field2check)
            fieldMissing = 1;
            missingFields{end+1} = field2check;
        end

        field2check = 'fontStyle';
        if ~isfield(aTask, field2check)
            fieldMissing = 1;
            missingFields{end+1} = field2check;
        end


        % return in case we are missing
        % at least one field
        if fieldMissing
            fprintf('\n==========================================================');
            fprintf('\nError: The following fields of ''aTask'' are required:');
            for i = 1 : length(missingFields)
                fprintf('\n--> %s', missingFields{i});
            end
            fprintf('\n==========================================================');
            fprintf('\n');

            return;
        end

        % ================= do the actual initialization ==============

        aTask.log.timeStamp4repLetters = [];

        % get onScrWinPtrs
        if ~isfield(aTask.scr, 'winPtr')
            % try to get scrPtr automatically
            aTask.scr.winPtr = Screen('Windows');
        else
            aTask.scr.winPtr = aTask.scr.winPtr;
        end

        % set TextFont
        Screen('TextFont', aTask.scr.winPtr, 'Arial');
        
        % get screen rect
        aTask.scr.rect = Screen('Rect', aTask.scr.winPtr);


        % split rect in two
        if strcmpi(aTask.scr.setup, 'split')
            aTask.scr.stereoBuffers = 1; % count from 0 -> 1
        else
            aTask.scr.stereoBuffers = [];
        end


        % save init time stamp
        aTask.tInit = GetSecs;

        % log:
        aTask.log.taskOnsets = []; % will contain onset times of tasks
        aTask.log.charOnsets = []; % will contain onset times of char-presentations (including task-char-repeats)

        % preallocate variables that faciliate feedback evaluation        
        aTask.lastChar          = [];


        % NORMAL TASK
        if aTask.type == 0
            aTask.nFramesUp         = round(linspace(30,40,26)); % length should equallength(tchars).   %repmat([45 45 45 80 80 80 80 105 105 105 130 130130],1,2);
            aTask.chars             = 'abcdefghijklmnopqrstuvwxyz';
            aTask.doubleCharTstamps = [];
            
        % NORMAL TASK BUT WITH VOWELS
        elseif aTask.type == 1
            aTask.nFramesUp         = round(linspace(30,60,26)); % length should equallength(tchars).   %repmat([45 45 45 80 80 80 80 105 105 105 130 130130],1,2);
            aTask.chars             = 'aeiou';
            aTask.doubleCharTstamps = [];
            
        % FIXATION CROSS
        elseif aTask.type == 2
            aTask.nFramesUp  = inf; % length should equallength(tchars).   %repmat([45 45 45 80 80 80 80 105 105 105 130 130130],1,2);
            aTask.nFramesItv = 0;	% intval: no char for so many *seq* frames.
            aTask.chars      = '+';
        
        % LETTER DETECTION TASK
        elseif aTask.type == 3
            aTask.nFramesUp        = round(linspace(30,40,26)); % length should equallength(tchars).   %repmat([45 45 45 80 80 80 80 105 105 105 130 130130],1,2);
            aTask.chars            = 'abcdefghijklmnopqrstuvwxyz';
            aTask.targetCharI      = findstr(aTask.chars, aTask.targetChar);
            aTask.targetCharOnsets = [];
            
        end

        aTask.newCharCount   = 0;
        aTask.chars          = aTask.chars(randperm(length(aTask.chars))); % permute letters in char
        aTask.nFramesUp      = aTask.nFramesUp(randperm(length(aTask.nFramesUp)));
        aTask.taskCharFirst  = 1;
        aTask.newCharCount   = 0;
        aTask.iChar          = 1; % index into aTask.chars
        aTask.redraw2buffer2 = 0;
        
        % wait this many new chars till next task.
        tmp = randperm(length(aTask.taskItvls));
        aTask.taskWait = aTask.taskItvls(tmp(1));

        
        % give some feedback:
        fprintf('\n========================================');
        fprintf('\nInitialising attention task:');
        
        if aTask.type == 0 || aTask.type == 1
            fprintf('\nTask type: Letter Backmatch');
        elseif aTask.type == 3
            fprintf('\nTask type: Letter Detection');
            fprintf('\nTarget letter: %s', aTask.targetChar);            
        end        
        
        fprintf('\n========================================');
        
        
        %% ========== Show task ================
    elseif strcmpi(jobStr, 'run')
        % showLetterTask('run')

        % get prefs
        if nargin == 2
            aTask = varargin{1}; % aTask struct with preferences
            stereoBuffer = 1;
            aTask.redraw2buffer2 = 0;
            
        elseif nargin == 3
            aTask = varargin{1}; % aTask struct with preferences
            stereoBuffer = varargin{2}+1;
                
        end

        cc = aTask.frameCtr; % frame counter

        % Start task: match/non match of char
        if cc > aTask.taskCharFirst + aTask.nFramesUp(aTask.iChar) + aTask.nFramesItv || aTask.redraw2buffer2
            
            % do this only once per frame
            % however draw result in each frame buffer
            if stereoBuffer == 1
                
                % ---- a new char needs to be shown, or a char has to be repeated (ie: task!) ----
                aTask.newCharCount = aTask.newCharCount+1; % incr each time youshow a new char.
                
                % do the task
                if aTask.newCharCount == aTask.taskWait, % task
                                        
                    % NORMAL TASK (with all chars or vowels)
                    if aTask.type == 0 || aTask.type == 1
                                                
                        % --- TASK!!: repeat char (or change its color- not implemented here) ----
                        % log:
                        aTask.doubleCharTstamps(end+1) = GetSecs;% time of char onset                                                
                        
                        % LETTER DETECTION TASK
                        % -> show random char
                    elseif aTask.type == 3                                                                        
                        
                        % show target char
                        aTask.iChar = aTask.targetCharI;
                        
                        % save onset tstamp
                        if strcmpi(aTask.targetChar, aTask.chars(aTask.iChar))
                            aTask.targetCharOnsets(end+1) = GetSecs;
                        end
                    end
                    
                    aTask.newCharCount = 0;
                    
                    % no increment of i_char: match according to aTask.ttask_itvls
                    tmp = randperm(length(aTask.taskItvls));
                    aTask.taskWait = aTask.taskItvls(tmp(1)); % wait this many new chars till next task.
                
                    
                    % no task: business as usual
                else
                    
                    % increment only for back match task                   
                    if aTask.type == 0 || aTask.type == 1
                        % --- NO TASK: show next char in sequence (or show 'normal' color, not implemented) ---
                        aTask.iChar = aTask.iChar+1; % increment index to chars

                        % shuffle char sequence only for back match task                        
                        % if index exceeds char, re-order char sequence
                        if aTask.iChar > length(aTask.chars), % reset and mix chars new
                            aTask.iChar = 1;
                            aTask.chars = aTask.chars(randperm(length(aTask.chars)));
                            aTask.nFramesUp = aTask.nFramesUp(randperm(length(aTask.nFramesUp)));
                        end
                        
                        % show random letter for detection task
                    elseif aTask.type == 3
                        
                        % get random char different than
                        % target char
                        gotRandChar = 0;
                        while ~gotRandChar
                            aTask.iChar = randi(length(aTask.chars));
                            if aTask.iChar ~= aTask.targetCharI
                                gotRandChar = 1;
                            end
                        end
                        
                    end % task type
                    
                end % if task
                
                
                
                
                % --- draw char (first frame of new char or of char-repeat ---
                % log:
                aTask.log.charOnsets = GetSecs;
                
                aTask.taskCharFirst = cc; % 1st frame with char on
                
                % draw also to second screen
                aTask.redraw2buffer2 = 1;
                
            else
                aTask.redraw2buffer2 = 0;
            end
            
            % draw task on screen(s)                                    
            rect = [0 0 aTask.recWidth aTask.recWidth];
            rect = CenterRect(rect, aTask.scr.rect);
            rect = OffsetRect(rect, aTask.xyOffset(1), aTask.xyOffset(2));
            Screen('FillOval', aTask.scr.winPtr, aTask.scr.cols(stereoBuffer).innerDisc, rect);
            
            normBoundsRect = Screen('TextBounds', aTask.scr.winPtr, aTask.chars(aTask.iChar));
            letterRect = CenterRect(normBoundsRect, aTask.scr.rect);
            letterRect = OffsetRect(letterRect, aTask.xyOffset(1), aTask.xyOffset(2));
            x = letterRect(RectLeft);
            y = letterRect(RectTop);
            Screen('TextStyle', aTask.scr.winPtr, aTask.fontStyle);
            Screen('TextSize' , aTask.scr.winPtr, aTask.fontSize);
            Screen('DrawText' , aTask.scr.winPtr, aTask.chars(aTask.iChar), x ,y , aTask.scr.cols(stereoBuffer).font);
            
            
        elseif cc > aTask.taskCharFirst + aTask.nFramesUp(aTask.iChar)
            % ---- char interval: draw grey fixation disc (during aTask.tnframes_itv) ---- :            
            rect = [0 0 aTask.recWidth aTask.recWidth];
            rect = CenterRect(rect, aTask.scr.rect);
            rect = OffsetRect(rect, aTask.xyOffset(1), aTask.xyOffset(2));
            Screen('FillOval', aTask.scr.winPtr, aTask.scr.cols(stereoBuffer).innerDisc, rect);                        

            
        elseif cc > aTask.taskCharFirst
            % ---- redraw char to ensure duration of char presentation of aTask.tnframes_up ---:
            
            rect = [0 0 aTask.recWidth aTask.recWidth];
            rect = CenterRect(rect, aTask.scr.rect);
            rect = OffsetRect(rect, aTask.xyOffset(1), aTask.xyOffset(2));
            Screen('FillOval', aTask.scr.winPtr, aTask.scr.cols(stereoBuffer).innerDisc, rect);
                        
            normBoundsRect = Screen('TextBounds', aTask.scr.winPtr, aTask.chars(aTask.iChar));
            letterRect = CenterRect(normBoundsRect, aTask.scr.rect);
            letterRect = OffsetRect(letterRect, aTask.xyOffset(1), aTask.xyOffset(2));
            x = letterRect(RectLeft);
            y = letterRect(RectTop);
            Screen('TextStyle', aTask.scr.winPtr, aTask.fontStyle);
            Screen('TextSize' , aTask.scr.winPtr, aTask.fontSize);
            Screen('DrawText' , aTask.scr.winPtr, aTask.chars(aTask.iChar), x ,y , aTask.scr.cols(stereoBuffer).font);            
            
        end
        
        % show fixation
    elseif strcmpi(jobStr, 'showFix')
        
        % get prefs
        if nargin == 2
            aTask = varargin{1}; % aTask struct with preferences
            stereoBuffer = 1;
            
        elseif nargin == 3
            aTask = varargin{1}; % aTask struct with preferences
            stereoBuffer = varargin{2}+1;
                
        end                        
        rect = [0 0 aTask.recWidth aTask.recWidth];
        rect = CenterRect(rect, aTask.scr.rect);
        rect = OffsetRect(rect, aTask.xyOffset(1), aTask.xyOffset(2));
        Screen('FillOval', aTask.scr.winPtr, aTask.scr.cols(stereoBuffer).innerDisc, rect);
        
    end

end