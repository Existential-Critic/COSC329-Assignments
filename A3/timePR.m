%Import the CSV table and read it in MATLAB
timeEasyTable = readtable("all-easy.csv");
%Make an empty array that will store all the times for a student
easyAllIndividualTimesTaken = [];
%Make another array to store all the average times
easyAllAverageTimesTaken = [];
%Get key phrases for searching
individualTimeKeyPhrase = "Estimated task time (ns)";
averageTimeKeyPhrase = "Aerage Response Time Per Question (ns)";
%Get row IDs for all the rows I will need
individualEasyTimeRowIDs = find(strcmp(timeEasyTable.Column2,individualTimeKeyPhrase));
averageEasyTimeRowIDs = find(strcmp(timeEasyTable.Column1,averageTimeKeyPhrase));
%Get all the different indiviual times added to their array
for x = 1:length(individualEasyTimeRowIDs)
    rowNum = individualEasyTimeRowIDs(x);
    timeTakenNS = timeEasyTable.Column3(rowNum);
    timeTakenS = timeTakenNS/1000000000;
    easyAllIndividualTimesTaken(end+1) = timeTakenS;
end
%Get all the different average times added to their array
for x = 1:length(averageEasyTimeRowIDs)
    rowNum = averageEasyTimeRowIDs(x);
    timeTakenNS = str2double(timeEasyTable.Column2(rowNum));
    timeTakenS = timeTakenNS/1000000000;
    easyAllAverageTimesTaken(end+1) = timeTakenS;
end
%Use the standard deviation to get the range of average time taken
minEasyAverageRange = mean(easyAllAverageTimesTaken) - std(easyAllIndividualTimesTaken);
maxEasyAverageRange = mean(easyAllAverageTimesTaken) + std(easyAllIndividualTimesTaken);
%Make counts for how many times are in each category
easySlowCount = 0;
easyAvgCount = 0;
easyFastCount = 0;
totalEasyCount = 0;
%Iterate through all individual times and count them
for x = 1:length(individualEasyTimeRowIDs)
    rowNum = individualEasyTimeRowIDs(x);
    timeTakenNS = timeEasyTable.Column3(rowNum);
    timeTakenS = timeTakenNS/1000000000;
    totalEasyCount = totalEasyCount + 1;
    if timeTakenS < minEasyAverageRange
        easyFastCount = easyFastCount + 1;
    elseif timeTakenS > maxEasyAverageRange
        easySlowCount = easySlowCount + 1;
    else
        easyAvgCount = easyAvgCount + 1;
    end
end
%Use the total count and the individual counts to get the PRs
easySlowPR = easySlowCount/totalEasyCount;
easyAvgPR = easyAvgCount/totalEasyCount;
easyFastPR = easyFastCount/totalEasyCount;
%Repeat the above for when Difficulty = hard
timeHardTable = readtable("all-hard.csv");
hardAllIndividualTimesTaken = [];
hardAllAverageTimesTaken = [];
individualHardTimeRowIDs = find(strcmp(timeEasyTable.Column2,individualTimeKeyPhrase));
averageHardTimeRowIDs = find(strcmp(timeEasyTable.Column1,averageTimeKeyPhrase));
for x = 1:length(individualHardTimeRowIDs)
    rowNum = individualHardTimeRowIDs(x);
    timeTakenNS = timeHardTable.Column3(rowNum);
    timeTakenS = timeTakenNS/1000000000;
    hardAllIndividualTimesTaken(end+1) = timeTakenS;
end
for x = 1:length(averageHardTimeRowIDs)
    rowNum = averageHardTimeRowIDs(x);
    timeTakenNS = str2double(timeHardTable.Column2(rowNum));
    timeTakenS = timeTakenNS/1000000000;
    hardAllAverageTimesTaken(end+1) = timeTakenS;
end
minHardAverageRange = mean(hardAllAverageTimesTaken) - std(hardAllIndividualTimesTaken);
maxHardAverageRange = mean(hardAllAverageTimesTaken) + std(hardAllIndividualTimesTaken);
hardSlowCount = 0;
hardAvgCount = 0;
hardFastCount = 0;
totalHardCount = 0;
for x = 1:length(individualHardTimeRowIDs)
    rowNum = individualHardTimeRowIDs(x);
    timeTakenNS = timeHardTable.Column3(rowNum);
    timeTakenS = timeTakenNS/1000000000;
    totalHardCount = totalEasyCount + 1;
    if timeTakenS < minHardAverageRange
        hardFastCount = hardFastCount + 1;
    elseif timeTakenS > maxHardAverageRange
        hardSlowCount = hardSlowCount + 1;
    else
        hardAvgCount = hardAvgCount + 1;
    end
end
hardSlowPR = hardSlowCount/totalHardCount;
hardAvgPR = hardAvgCount/totalHardCount;
hardFastPR = hardFastCount/totalHardCount;
%Now that we have the PRs for Time for both values of Difficulty, we can
%get the CPT set up
timeCPT = zeros(1,2,3);
timeCPT(1,1,:) = [easySlowPR easyAvgPR easyFastPR];
timeCPT(1,2,:) = [hardSlowPR hardAvgPR hardFastPR];
bnet.CPD{Time} = tabular_CPD(bnet, Time, 'CPT', timeCPT);