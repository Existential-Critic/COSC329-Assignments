%Import the CSV table and read it in MATLAB
accEasyTable = readtable("all-easy.csv");
%Create an empty array of the accuracy rates for easy questions
easyAccuracyRates = [];
%Get the key phrase to search through the table rows
keyPhrase = "Number Questions Correctly Answered";
%Iterate through the rows of the table and get the IDs for the correctly
%answered numbers
easyRowIDs = find(strcmp(accEasyTable.Column1,keyPhrase));
%Now go through the # of correct answers and get the percentage
for x = 1:length(easyRowIDs)
    rowNum = easyRowIDs(x);
    correctAns = str2double(accEasyTable.Column2(rowNum));
    percentage = correctAns/50;
    easyAccuracyRates(end+1) = percentage;
end
%Do all the above steps again, but this time for the hard questions
accHardTable = readtable("all-hard.csv");
hardAccuracyRates = [];
hardRowIDs = find(strcmp(accHardTable.Column1,keyPhrase));
for x = 1:length(hardRowIDs)
    rowNum = hardRowIDs(x);
    correctAns = str2double(accHardTable.Column2(rowNum));
    percentage = correctAns/50;
    hardAccuracyRates(end+1) = percentage;
end
%Now that we have arrays for Accuracy for both values of Difficulty, we can
%get the CPT set up
avgEasyAcc = mean(easyAccuracyRates);
avgHardAcc = mean(hardAccuracyRates);
accCPT = zeros(1,2,2);
accCPT(1,1,:) = [(1-avgEasyAcc) avgEasyAcc];
accCPT(1,2,:) = [(1-avgHardAcc) avgHardAcc];
bnet.CPD{Acc} = tabular_CPD(bnet, Acc, 'CPT', accCPT);