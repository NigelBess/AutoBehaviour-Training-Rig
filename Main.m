clc
clear all

mouseID = '000';
sessionNum = 1;
%to do: change session num to look for existing files and increment automatically
numTrials = 10;
isTest = false;
port = 'COM4';




 if isTest
    experiment = DummyExperiment(mouseID, sessionNum,port);
    timeout = 2;
    iti = .5;
else
    experiment = RealExperiment(mouseID, sessionNum,port);
    timeout = 60;
    iti = 3;
 end
 
renderer = Renderer();
results = Results(mouseID, numTrials ,sessionNum,experiment,renderer,'closedLoopTraining');





experiment.closeServos();
experiment.giveWater(.3);
experiment.playReward()
%experiment.waitAndLog(2);
experiment.logEvent('Starting session');


for i = 1:numTrials

    while ~experiment.isBeamBroken()%wait for beam to be broken
        pause(.005)%to do, remove hardcoded time delay 
    end

    experiment.openServos('Center');

    
    choice = rand();%used to decied if grated circle starts on the left or right
    rightProb = results.getLeftProportionOnInterval(i-6,i-1);%returns the proportion of left choices, over the last 5 trials
   %^ to do: remove hardcode
   if isnan(rightProb)
        rightProb = .5;
    end 
    startingOnLeft = choice > rightProb;
    if startingOnLeft
        stimPosition = 'Left';
    else
        stimPosition = 'Right';
    end
    
   gratingNum = renderer.GenerateGrating();
   pos = renderer.InitialFrame(startingOnLeft);



    startRespdisplayWindow = experiment.getExpTime();
    %^ i assume this means the start time of the response window
    %ie when we started rendering
    
    %log information about the start of the trial
    results.StartTrial(i,stimPosition,renderer.currentContrast,experiment.getExpTime());
    
    %initialize values
    finished = 0;%boolean    
    hasHit = 0;%boolean
    experiment.logEvent(['Starting Trial ' num2str(i)]);
    
    
    while ~finished && experiment.getExpTime() - startRespdisplayWindow < timeout
        %float reading = reading of mouse input
        if isTest
            reading = (mod(gratingNum,3)-1)*100;%dummy value
        else
            reading = experiment.readEnc();%input from wheel
        end
        vel = (reading-25*sign(reading))*(10/105);%turn reading from wheel into a screen velocity (in pixels/frame maybe?)
        %to do: get rid of hardcoded values
        %to do: convert velocity to units of pixels/time instead of
        %pixels/frame
        
        if abs(reading) < 50%minimum wheel turn required. to do: remove hardcoded value
            vel = 0;
        end

        if renderer.CheckLeftHit(pos(1)) % x position to the left of the left edge of the screen
            %(this means the circle has collided with the left edge of th screen)
            vel = max(vel,0);%prevent the circle from moving farther
            results.LogLeft();%log trial as hitting left wall
            if(~hasHit)%has Hit is used to prevent repeated noise when hitting the wall during the same trial
                %also hasHit prevents loggin trial as a success if mouse
                %has already failed
                disp('Hit!')
                experiment.logEvent('Hit left side');
            end
            hasHit = 1;%true
        elseif renderer.CheckRightHit(pos(1))% %check right size hit
            vel = min(vel,0);
            if(~hasHit)
                disp('Hit!')
                experiment.logEvent('Hit right side');
            end
            results.LogRight();
            hasHit = 1;
        end

        pos = pos + [vel 0 vel 0];%update position
        %to do: (CRITICAL!)
        %this part absolutely needs to include some Delta Time to account
        %for speed differences in different computers

        if renderer.CheckSuccess(pos(1))%success
            experiment.logEvent('Moved grating to center')
            results.LogSuccess(experiment.getExpTime());
            finished = 1;%true
        end
        
        renderer.NewFrame(pos);
        experiment.logData();
    end %end while
    
    %at this point the mouse has completed or timed out the current trial

    experiment.closeServos()
    experiment.waitAndLog(1);%see what the mouse is doing while the servos close.
    %^ to do: remove hardcoded value

    if finished % the mouse successfully completed the trial (didnt time out)
        experiment.playReward();
        startLickdisplayWindow = experiment.getExpTime();%log the time that the reward stimulus started
        while experiment.getExpTime() - startLickdisplayWindow < .5% mouse has a 0.5 second window to lick the lickmeter
            %^ to do: remove hardcode
            experiment.logData();
            if(experiment.readLickometer() == 0)%returns zero while mouse is licking
                results.firstLickTimes(results.sessionNum) = experiment.getExpTime();%we want to log the time of lick to see if the mouse was anticipating the water
                %if the mouse doesn't lick within this while loop,
                %fistlicktimes retains its default value of -1 (used as a null)
                break;
            end
            pause(.005);%to do: remove hardcode
        end
        experiment.giveWater(.15);%to do: remove hardcode
    else
        experiment.playNoise();
        experiment.waitAndLog(1);
    end
    renderer.EmptyFrame();
    results.endTimes(i) = experiment.getExpTime();
    experiment.logEvent(['Ending Trial ' num2str(i)]);
    experiment.refillWater(.03)
    experiment.waitAndLog(iti/2);
    experiment.resetEnc();
    experiment.waitAndLog(iti/2);
    results.numTrials = i;
    disp(i)
    results.save()
end %end for 1:numtrials



