import glob
import re
from nltk import ngrams
import csv

def processFile(dataFile):
    #Open the file and save the text to variable
    testFile = open(dataFile,'r')
    testText = testFile.read()
    #Turn each sentence into its own string in a list
    sentences = re.split('\. |\? |\! |; |\.|\?|\!|;|\n',testText)
    #Remove empty items in the list
    sentences = [x for x in sentences if x]
    #Go through items in the list and remove punctuation, conjunctions, and make all lowercase
    for i in range(len(sentences)):
        newSentence = re.sub(r'[^\w\s]','',sentences[i])
        newSentence = re.sub('  ',' ',newSentence)
        newSentence = re.sub('\'','',newSentence)
        newSentence = newSentence.lower()
        sentences[i] = newSentence
    testFile.close()
    return sentences

def writeNGrams(fileNGrams,fileName):
    #Create file to write ngrams to
    file = 'NGrams\\' + fileName
    writeFile = open(file,'w+')
    nCount = 1
    for x in fileNGrams:
        header = "%s-grams of file %s:\n" % (nCount,fileName)
        writeFile.write(header)
        nGramListString = ''
        for y in x:
            smallListString = ','.join(y)
            if nGramListString == '':
                nGramListString = '(' + smallListString + ')'
            else:
                nGramListString += ', (' + smallListString + ')'
        nGramListString += '\n'
        writeFile.write(nGramListString)
        writeFile.write('\n')
        nCount += 1

def getMaxSentenceLength(file):
    maxSentenceLength = 0
    for x in file:
        sentenceLength = len(x.split())
        if sentenceLength > maxSentenceLength:
            maxSentenceLength = sentenceLength
    return maxSentenceLength

def getNGram(n,sentence):
    #Get n-grams for the sentence provided
    nGrams = []
    n = n
    nGram = ngrams(sentence.split(),n)
    for gram in nGram:
        nGrams.append(gram)
    return nGrams

def getAllNGrams(file):
    fileNGrams = []
    maxSentenceLength = getMaxSentenceLength(file)
    for i in range(1,maxSentenceLength+1):
        iNGrams = []
        for sentence in file:
            iNGrams = iNGrams + getNGram(i,sentence)
        fileNGrams.append(iNGrams)
    return fileNGrams

def setContainment(nGramsA,nGramsB):
    #Get intersection of A and B for n
    intersectAB = intersection(nGramsA,nGramsB)
    #Get nGramsB as a set
    setB = set(nGramsB)
    containmentAB = 0
    if len(setB) != 0:
        containmentAB = round((len(intersectAB)/len(setB)),4)
    return containmentAB

def intersection(listA,listB):
    setA = set(listA)
    setB = set(listB)
    setC = setA.intersection(setB)
    return setC

#Process data for each file
bFile = processFile('Data\\b.txt')
cFile = processFile('Data\\c.txt')
fFile = processFile('Data\\f.txt')
gFile = processFile('Data\\g.txt')
hFile = processFile('Data\\h.txt')
kFile = processFile('Data\\k.txt')
pFile = processFile('Data\\p.txt')
yFile = processFile('Data\\y.txt')
zFile = processFile('Data\\z.txt')
allFiles = [bFile,cFile,fFile,gFile,hFile,kFile,pFile,yFile,zFile]

#Get all ngrams for all files
bNGrams = getAllNGrams(bFile)
cNGrams = getAllNGrams(cFile)
fNGrams = getAllNGrams(fFile)
gNGrams = getAllNGrams(gFile)
hNGrams = getAllNGrams(hFile)
kNGrams = getAllNGrams(kFile)
pNGrams = getAllNGrams(pFile)
yNGrams = getAllNGrams(yFile)
zNGrams = getAllNGrams(zFile)

#Add all ngram lists to a new superlist
allNGrams = [('b.txt',bNGrams),('c.txt',cNGrams),('f.txt',fNGrams),('g.txt',gNGrams),('h.txt',hNGrams),('k.txt',kNGrams),('p.txt',pNGrams),('y.txt',yNGrams),('z.txt',zNGrams)]

#Write the ngrams of each file into a folder
for x in allNGrams:
    writeNGrams(x[1],x[0])

#Open a path to write to a CSV file
csvPath = open('cvals.csv','w+',newline='')
csvWriter = csv.writer(csvPath)
#Get the maximum sentence length of all files so we know how many columns to print
totalMaxSentenceLength = 0
for x in allFiles:
    if getMaxSentenceLength(x) > totalMaxSentenceLength:
        totalMaxSentenceLength = getMaxSentenceLength(x)
#Create a header as the first row of the csv file
header = ['A','B']
for x in range(1,totalMaxSentenceLength+1):
    appendText = 'C%s(A,B)' % x
    header.append(appendText)
csvWriter.writerow(header)
#Now, go through each ngram and save its containment with all other file ngrams, for each value of n
for x in allNGrams:
    aName = x[0]
    aNGram = x[1]
    for y in allNGrams:
        bName = y[0]
        bNGram = y[1]
        newRow = [aName,bName]
        for z in range(totalMaxSentenceLength):
            try:
                aValue = aNGram[z]
            except IndexError:
                aValue = []
            try:
                bValue = bNGram[z]
            except IndexError:
                bValue = []
            cValue = setContainment(aValue,bValue)
            newRow.append(cValue)
        csvWriter.writerow(newRow)
csvPath.close()