prompt = {"Mouse ID", "Session Number", "Number of Trials", "Port"};
title = "Settings";
dims = [1 35];
defaultValues;
defInput = {mouseID,sessionNum,numTrials,port};

val = inputdlg(prompt,title,dims,defInput);
 mouseID = val{1};
 sessionNum = str2num(val{2});
 numTrials = str2num(val{3});
    port = val{4};
    
    defaults = fopen('defaultValues.m','w');
    lineEnd = "';\n";
    str = "mouseID = '" + string(mouseID)+lineEnd;
    str = str + "sessionNum = '" + string(num2str(sessionNum))+lineEnd;
    str = str + "numTrials = '" + string(num2str(numTrials))+lineEnd;
    str = str + "port = '" + string(port)+lineEnd;
    fprintf(defaults,str);
    fclose(defaults);