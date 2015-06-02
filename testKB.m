function testKB

keyBinds = GetKeyboardIndices;

KbQueueCreate(max(keyBinds));
KbQueueStart();

while 1
    
    [~, firstPress] = KbQueueCheck();
    
    % press escape to leave the program
    if sum(find(firstPress)) > 0
        
        fprintf('\nGot Key: %d', find(firstPress));
        
        
    elseif firstPress(KbName('ESCAPE'))
        return;
        
    end
end

KbQueueStop;
KbQueue

end