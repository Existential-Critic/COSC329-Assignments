import pandas as pd

#ALL-EASY
#Grab the file names from the text files folder
allEasyTextUnprocessed = "unprocessed\\all-easy.txt"
allEasyTextPreprocessed = "preprocessed\\all-easy.txt"
#Change from colons to commas
easyFileUnprocessed = open(allEasyTextUnprocessed,"r")
easyFilePreprocessed = open(allEasyTextPreprocessed,"w+")
easyLines = easyFileUnprocessed.readlines()
easyLinesProcessed = []
for line in easyLines:
    easyLinesProcessed.append(line.replace(": ",","))
easyFilePreprocessed.writelines(easyLinesProcessed)
easyFileUnprocessed.close()
easyFilePreprocessed.close()
#Read text file and create dataframe
allEasyDataframe = pd.read_csv(allEasyTextPreprocessed,header = None)
#Add column headings
allEasyDataframe.columns = ["Column1","Column2","Column3"]
#Store dataframes into a csv file
allEasyDataframe.to_csv("all-easy.csv", index = None)

#ALL-HARD
#Grab the file names from the text files folder
allHardTextUnprocessed = "unprocessed\\all-hard.txt"
allHardTextPreprocessed = "preprocessed\\all-hard.txt"
#Change from colons to commas
hardFileUnprocessed = open(allHardTextUnprocessed,"r")
hardFilePreprocessed = open(allHardTextPreprocessed,"w+")
hardLines = hardFileUnprocessed.readlines()
hardLinesProcessed = []
for line in hardLines:
    hardLinesProcessed.append(line.replace(": ",","))
hardFilePreprocessed.writelines(hardLinesProcessed)
hardFileUnprocessed.close()
hardFilePreprocessed.close()
#Read text file and create dataframe
allHardDataframe = pd.read_csv(allHardTextPreprocessed,header = None)
#Add column headings
allHardDataframe.columns = ["Column1","Column2","Column3"]
#Store dataframes into a csv file
allHardDataframe.to_csv("all-hard.csv", index = None)