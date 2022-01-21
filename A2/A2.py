import re
from nltk.stem import PorterStemmer
import glob
import math
from numpy import dot, array
from numpy.linalg import norm
from datetime import datetime
from tabulate import tabulate
from sklearn.cluster import AgglomerativeClustering
import scipy.cluster.hierarchy as sch
from matplotlib import pyplot as plt

now = datetime.now()
begin_time = now.strftime("%H:%M:%S")
print("Begin Time =", begin_time)

#Add all k- files to a list
kFilesPre = glob.glob("unprocessed\\k*.txt")
kFiles = []
for x in kFilesPre:
    kFiles.append(x)
#Add all t- files to a list
tFilesPre = glob.glob("unprocessed\\t*.txt")
tFiles = []
for x in tFilesPre:
    tFiles.append(x)
#Merge the file lists into one
totalFileList = kFiles + tFiles
processedFileList = []
for f in totalFileList:
    processedFile = f.replace("unprocessed","preprocessed")
    processedFileList.append(processedFile)
#Get stopwords
stopWords = open("stopwords.txt","r")
stopWordsList = []
for line in stopWords:
    for word in line.split():
        stopWordsList.append(word)
for f in totalFileList:
    assignmentFile = open(f,"r",encoding = "utf-8")
    newFile = open(processedFileList[totalFileList.index(f)],"w+")
    ps = PorterStemmer()
    for line in assignmentFile:
        for word in line.split(): 
            lowercase = word.lower()
            noCharacter = re.sub('[^A-Za-z0-9]+','',lowercase)
            if noCharacter not in stopWordsList:
                if noCharacter.isalpha():
                    if len(noCharacter) > 2:
                        newFile.write(ps.stem(noCharacter) + " ")
    #Close all open files just in case
    assignmentFile.close()
    newFile.close()
    stopWords.close()
#Get a list of every unique word in all documents
totalWordList = []
for file in processedFileList:
    newFile = open(file,"r")
    newFileWordList = []
    for line in newFile:
        for word in line.split():
            newFileWordList.append(word)
    for x in newFileWordList:
        if x not in totalWordList:
            totalWordList.append(x)
    newFile.close()
def getDocWordList(file):
    newFile = open(file,"r")
    newFileNewWordList = []
    wordList = []
    for line in newFile:
        for word in line.split():
            newFileNewWordList.append(word)
    for x in newFileNewWordList:
            if x not in wordList:
                wordList.append(x)
    newFile.close()
    return wordList
def getWordVectors(file):
    docWordList = getDocWordList(file)
    countedWords = []
    for x in totalWordList:
        countedWords.append(docWordList.count(x))
    return countedWords
def getWordCount(file):
    newFile = open(file,"r")
    newFileWordList = []
    for line in newFile:
        for word in line.split():
            newFileWordList.append(word)
    wordCount = len(newFileWordList)
    newFile.close()
    return wordCount
#Get TF values for all docs
allDocTF = []
for f in processedFileList:
    wordCount = getWordCount(f)
    wordList = getWordVectors(f)
    termFrequency = []
    for x in wordList:
        termFrequency.append(round(x/wordCount,6))
    allDocTF.append((f,termFrequency))
# Get IDF values for all unique words
allTermIDF = []
bigD = abs(len(totalFileList))
for term in totalWordList:
    docFrequency = 0
    for file in processedFileList:
        wordList = getDocWordList(file)
        if term in wordList:
            docFrequency += 1
    idf = math.log(bigD/docFrequency,10)
    allTermIDF.append((term,idf))
# #Get tfidf values for all documents to save time
allDocTFIDF = []
for f in processedFileList:
    tfidf = []
    tf = []
    for tuple in allDocTF:
        if tuple[0] == f:
            tf = tuple[1]
    for term in totalWordList:
        termIDF = 0
        for tuple in allTermIDF:
            if tuple[0] == term:
                termIDF = tuple[1]
        tfidf.append(round(termIDF * tf[totalWordList.index(term)],6))
    allDocTFIDF.append((f,tfidf))
def getCosineSimilarity(document1,document2):
    doc1TFIDF = []
    for tuple in allDocTFIDF:
        if tuple[0] == document1:
            doc1TFIDF = tuple[1]
    doc2TFIDF = []
    for tuple in allDocTFIDF:
        if tuple[0] == document2:
            doc2TFIDF = tuple[1]
    d1d2CosineSimilarityTopRow = dot(doc1TFIDF,doc2TFIDF)
    d1d2CosineSimilarityBottomRow = norm(doc1TFIDF)*norm(doc2TFIDF)
    d1d2CosineSimilarity = round(d1d2CosineSimilarityTopRow/d1d2CosineSimilarityBottomRow,6)
    return d1d2CosineSimilarity
cosineMatrix = []
for file in processedFileList:
    cosineSimilarities = []
    for file2 in processedFileList:
        cosineSimilarities.append(getCosineSimilarity(file,file2))
    cosineMatrix.append(cosineSimilarities)
#Print cosine matrix as a table to a text file
matrixFile = open("cosineMatrix.txt","w+")
headStuff = []
headStuff.append("                    ")
for f in processedFileList:
    headStuff.append(f)
printedMatrix = []
rowCount = 0
for row in cosineMatrix:
    newRow = row.copy()
    rowBegin = processedFileList[rowCount]
    newRow.insert(0,rowBegin)
    printedMatrix.append(newRow)
    rowCount += 1
matrixFile.write(tabulate(printedMatrix, headers=headStuff, tablefmt='orgtbl'))
matrixFile.close()

clustering = AgglomerativeClustering(n_clusters=2, linkage="single").fit_predict(cosineMatrix)
clusterFile = open("clusteringResults.txt","w+")
for f in processedFileList:
    clusterFile.write(f + " ")
clusterFile.write("\n")
for x in clustering:
    clusterFile.write("          " + str(x) + "          ")
clusterFile.close()

plt.figure(figsize=(10,7))  
plt.title("Dendrogram of Document Clustering")
dendrogramLabels = array(processedFileList)
dend = sch.dendrogram(sch.linkage(cosineMatrix, method='single'), labels=dendrogramLabels)
plt.savefig("dendrogram.png",dpi=100,format='png')

now = datetime.now()
end_time = now.strftime("%H:%M:%S")
print("End Time =", end_time)