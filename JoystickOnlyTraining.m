clc
clear all

requestInput;


r = Results(mouseID, numTrials,sessionNum,e,'joyStickOnly');
    %starting video
    
    %system(['python C:/Users/GoardLab/Documents/AutomatedBehaviorStim/Python/Server.py '...
    %  mouseID ' ' num2str(sessionNum) '&' ]);

    lastReading = 0;
    currSide = roll();
    e.closeServos();
    e.openSide(currSide);
    r.StartTrial(0,0,GetSecs());
    while r.getCurrentTrial < numTrials 
        currReading = e.readEnc();
        if (sign(currSide)==sign(currReading) && lastReading == 0)
                lastReading = 1;
                r.LogJoy(currReading,currSide,GetSecs());
                e.playReward();
%                 e.deactivateServos();
                pause(0.1)
%                 startLickWindow = GetSecs;    
%                 %Wait for mouse to lick
%                 while GetSecs - startLickWindow < .5
%                     if(e.isLicking())
%                         r.LogLick(GetSecs-startLickWindow);
%                         break;
%                     end
%                 end
                e.giveWater(.03);
                currSide = roll();
                e.closeServos();
                e.openSide(currSide);
                r.StartTrial(0,0,GetSecs());
                startTime = GetSecs();
        else
            lastReading = 0;
        end
        e.refillWater(.01)
        pause(.005)
    end
    
    function out = roll()
        out = -1+2*(rand<0.5);%either -1 or 1
    end