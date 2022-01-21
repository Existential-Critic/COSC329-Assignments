import re
import string
import glob
from statistics import mean

#Preprocessing - taking the assignment file and making each sentence its own line
def preprocess(filename):
    assignmentFile = open(filename, "r", encoding = "utf-8")
    processedFile = open("test.txt","w+")
    aFString = assignmentFile.read()
    newAFString = re.split("\? |\. |! |: |\n", aFString)
    for x in newAFString:
        lowercase = x.lower()
        replace1 = lowercase.replace("'s"," is")
        replace2 = replace1.replace("'t"," not")
        replace3 = replace2.replace("'m"," am")
        replace4 = replace3.replace("'ve"," have")
        replace5 = replace4.replace("'re"," are")
        replace6 = replace5.replace("'ll"," will")
        noCharacter = re.sub('[^A-Za-z0-9 ]+','',replace6)
        if noCharacter != '':
            processedFile.write(noCharacter + "\n")
    #Finish it off by closing the assignment and processed file
    assignmentFile.close()
    processedFile.close()
#Printing - print out total words, max words, min words, avg words, max syllables, min syllables, average syllables, and FRES
def printFileInfo():
    readFile = open("test.txt","r")
    vowelList = ['a','e','i','o','u']
    vowelListWithoutI = ['a','e','o','u']
    beforeEList = ['c','d','f','g','h','k','m','n','p','q','r','s','t','v','w','x','z']
    totalSyllables = 0
    totalWords = 0
    totalSentences = 0
    maxWPS = 0
    minWPS = 100000
    maxSPW = 0
    minSPW = 100000
    wordList = []
    syllableList = []
    for x in readFile:
        totalSentences = totalSentences + 1
        sentenceWords = len(x.split())
        totalWords += sentenceWords
        if sentenceWords > maxWPS:
            maxWPS = sentenceWords
        if sentenceWords < minWPS:
            minWPS = sentenceWords
        wordList.append(sentenceWords)
        individualSentences = x.split()
        for y in individualSentences:
            vowelCount = 0
            letterList = list(y)
            for i in range(len(letterList)):
                if letterList[i] == 'y':
                    if i != 0 and i != len(letterList)-1: 
                        if letterList[i-1] not in vowelList:
                            if letterList[i+1] not in vowelListWithoutI:
                                vowelCount = vowelCount + 1
                elif letterList[i] == 'e':
                    if i == len(letterList)-1:
                        if len(letterList) != 2 and len(letterList) != 3:
                            if letterList[i-1] not in beforeEList:
                                vowelCount = vowelCount + 1
                    else:
                        if letterList[i+1] not in vowelList:
                            vowelCount = vowelCount + 1
                elif letterList[i] in vowelList:
                    if i != len(letterList)-1:
                        if letterList[i+1] not in vowelList:
                            vowelCount = vowelCount + 1
                    else:
                        vowelCount = vowelCount + 1
            if vowelCount > maxSPW:
                maxSPW = vowelCount
            if vowelCount < minSPW and vowelCount != 0:
                minSPW = vowelCount
            totalSyllables += vowelCount
            syllableList.append(vowelCount)
    print("The total number of words is: " + str(totalWords))
    print("The maximum words per sentence is: " + str(maxWPS))
    print("The minimum words per sentence is: " + str(minWPS))
    print("The average number of words per sentence is: " + str(round(mean(wordList), 2)))
    print("The maximum syllables per word is: " + str(maxSPW))
    print("The minimum syllables per word is: " + str(minSPW))
    print("The average number of syllables per word is: " + str(round(mean(syllableList), 2)))
    sentenceDifficulty = totalWords/totalSentences
    wordDifficulty = totalSyllables/totalWords
    print("The Flesch Reading Ease Score is: " + str(round(206.835 - (1.015*sentenceDifficulty) - (84.6*wordDifficulty), 2)))
    readFile.close()

#Add all m- files to a list
mFilesPre = glob.glob("m-*.txt")
mFiles = []
for x in mFilesPre:
    mFiles.append(x)

#Add all ng- files to a list
ngFilesPre = glob.glob("ng-*.txt")
ngFiles = []
for x in ngFilesPre:
    ngFiles.append(x)

#Merge the file lists into one
files = mFiles + ngFiles

#Run the methods for each file
for f in files:
    print(f)
    preprocess(f)
    printFileInfo()
    print()