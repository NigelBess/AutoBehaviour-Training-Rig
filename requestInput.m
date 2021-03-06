
prompt = {"Mouse ID", "Session Number", "Number of Trials", "Port","Output Monitor Number (zero for single monitor)","Reward On Incorrect (0 or 1)","Rig Number"};
title = "Settings";
dims = [1 35];
defaultValues;
defInput = {mouseID,sessionNum,numTrials,port,screenNum,reward,rig};

val = inputdlg(prompt,title,dims,defInput);
 mouseID = val{1};
 sessionNum = str2num(val{2});
 numTrials = str2num(val{3});
    port = val{4};
    screenNum = str2num(val{5});
    reward = str2num(val{6});
    rig = str2num(val{7});
    
    defaults = fopen('defaultValues.m','w');
    lineEnd = "';\n";
    str = "mouseID = '" + string(mouseID)+lineEnd;
    str = str + "sessionNum = '" + string(num2str(sessionNum))+lineEnd;
    str = str + "numTrials = '" + string(num2str(numTrials))+lineEnd;
    str = str + "port = '" + string(port)+lineEnd;
     str = str + "screenNum = '" + string(screenNum)+lineEnd;
     str = str + "reward = '"+string(1*(reward~=0))+lineEnd;
     str = str + "rig = '"+string(rig) + lineEnd;
    fprintf(defaults,str);
    fclose(defaults);
    
