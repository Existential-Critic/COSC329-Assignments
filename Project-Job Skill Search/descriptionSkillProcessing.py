from nltk.corpus import stopwords
from nltk.stem import WordNetLemmatizer
import pandas as pd
import re
import csv

#Function to preprocess the text of the job descriptions
def preprocessing(jobDesc):
    #Convert all characters to lowercase
    lowerJobDesc = jobDesc.lower()
    #Remove all punctuation, numbers, and special characters
    noPuncJobDesc = re.sub('[^\w\s]','',lowerJobDesc)
    noDigitJobDesc = re.sub('\d+','',noPuncJobDesc)
    #Remove stopwords
    descWords = noDigitJobDesc.split()
    stopWords = stopwords.words("english")
    resultDescWords = [word for word in descWords if word not in stopWords]
    #Remove more specific stop words
    jobStopWords = ['junior', 'senior','experience','etc','job','work','company','technique', 'candidate','skill','skills','language','menu','inc','new','plus','years', 'technology','organization','ceo','cto','account','manager','data','scientist','mobile', 'developer','product','revenue','strong']
    newDescWords = [word for word in resultDescWords if word not in jobStopWords]
    #Lemmatize each word
    lemmatizer = WordNetLemmatizer()
    lemmaDescWords = []
    for word in newDescWords:
        lemmaWord = lemmatizer.lemmatize(word)
        lemmaDescWords.append(lemmaWord)
    #Create a new unified string and return it
    resultDesc = ' '.join(lemmaDescWords)
    return resultDesc
#Function to get a list of lemmatized job skills
def getJobSkills():
    #Open the job skills file and create a list and lemmatizer
    jobSkillsFile = open("jobSkills.txt","r")
    jobSkills = []
    lemmatizer = WordNetLemmatizer()
    #Iterate through all job skills, remove the line break character, and lemmatize the word
    for skill in jobSkillsFile:
        skillText = skill.replace('\n','')
        lemmaSkillText = lemmatizer.lemmatize(skillText)
        jobSkills.append(lemmaSkillText)
    #Finally, close the file and return it
    jobSkillsFile.close()
    return jobSkills
#Function to get the row index of a specific job description
def getDescIndex(jobDesc,dataFrame):
    #Get a list of all row indexes where the Job Description column equals the supplied string, and return the first index
    indexList = dataFrame.index[dataFrame["Job Description"] == jobDesc].tolist()
    return indexList[0]
#Function to get row IDs of a specific job title
def getJobIndexes(jobTitle,dataFrame):
    jobTitleIndexList = []
    #Create a list of all existing indexes, and then double check to see what their job title is before adding them to the list of job title indexes
    for x in dataFrame["Job Description"]:
        xIndex = getDescIndex(x,dataFrame)
        if dataFrame["Job Title"][xIndex] == jobTitle:
            jobTitleIndexList.append(xIndex)
    return jobTitleIndexList
#Function to get count of specific skill for specific job
def getSkillCount(skill,jobIndexes,dataFrame):
    skillCount = 0
    #For each job skill description, check to see if the skill is included in the text and increment the count as needed
    for index in jobIndexes:
        searchDescription = dataFrame["Job Description"][index]
        searchDescription = searchDescription.split()
        if skill in searchDescription:
            skillCount += 1
    return skillCount
#Function to find the 10 most occurring skills for a job title
def getTopSkills(jobSkills):
    #Create a copy of the full list, then sort it by the second element (the count)
    topJobSkills = jobSkills.copy()
    topJobSkills.sort(reverse=True,key=lambda x: int(x[1]))
    #Remove all items with a count of zero, then if the length is greater than 10 remove all items past the 5th item
    for item in topJobSkills:
        if item[1] == 0:
            topJobSkills.remove(item)
    if len(topJobSkills) > 10:
        del topJobSkills[10:]
    return topJobSkills
#Function to get the count for all skills
def getJobSkillCountList(jobIndexes,jobSkills,dataFrame):
    jobSkillsCounts = []
    #Get the count for each job skill
    for skill in jobSkills:
        skillCount = getSkillCount(skill,jobIndexes,dataFrame)
        jobSkillsCounts.append([skill,skillCount])
    return jobSkillsCounts
#Function to save the full skill list of a job to a text file
def saveSkills(jobSkillsList,jobTitle):
    jobTitle = jobTitle.replace(' ','')
    #Create a unique file name for the job skills
    fileName = 'allSkills\\' + jobTitle + 'Skills.csv'
    #Write the list of skills and counts to the file
    skillsFile = open(fileName,'w+',newline = '')
    skillsFileWriter = csv.writer(skillsFile)
    skillsFileWriter.writerows(jobSkillsList)
    skillsFile.close()
#Function to save the top skills of a job to a text file
def saveTopSkills(topSkillsList,jobTitle):
    jobTitle = jobTitle.replace(' ','')
    #Create a unique file name for the job skills
    fileName = 'topSkills\\' + jobTitle + 'TopSkills.txt'
    #Write the list of skills and counts to the file
    skillsFile = open(fileName,'w+')
    for item in topSkillsList:
        itemString = item[0] + '\n'
        skillsFile.write(itemString)
    skillsFile.close()

#Load the CSV file using pandas
columns = ["Job Title","Job Description"]
jobCSV = pd.read_csv("jobResults.csv",usecols=columns)
#Remove blank rows
jobCSV = jobCSV.dropna()
#Remove duplicate rows
jobCSV = jobCSV.drop_duplicates()

#Create a test copy of the original CSV to be edited with processed text for the job descriptions
processedJobCSV = jobCSV.copy()
for x in processedJobCSV["Job Description"]:
    jobDescText = x
    processedJobCSV.replace(jobDescText,preprocessing(jobDescText),inplace=True)

#Get a list of job skills to scan for
jobSkills = getJobSkills()

#Get all the row IDs for a specific job title
programmerIndexList = getJobIndexes("programmer",processedJobCSV)
analystIndexList = getJobIndexes('analyst',processedJobCSV)
administratorIndexList = getJobIndexes('administrator',processedJobCSV)
clerkIndexList = getJobIndexes('clerk',processedJobCSV)
cookIndexList = getJobIndexes('cook',processedJobCSV)
receptionistIndexList = getJobIndexes('receptionist',processedJobCSV)
webDeveloperIndexList = getJobIndexes('web developer',processedJobCSV)
softwareEngineerIndexList = getJobIndexes('software engineer',processedJobCSV)
mechanicalEngineerIndexList = getJobIndexes('mechanical engineer',processedJobCSV)
nurseIndexList = getJobIndexes('nurse',processedJobCSV)
cashierIndexList = getJobIndexes('cashier',processedJobCSV)
lifeguardIndexList = getJobIndexes('lifeguard',processedJobCSV)
teacherIndexList = getJobIndexes('teacher',processedJobCSV)

print(programmerIndexList)
#Get the skill counts for all jobs
programmerSkills = getJobSkillCountList(programmerIndexList,jobSkills,processedJobCSV)
analystSkills = getJobSkillCountList(analystIndexList,jobSkills,processedJobCSV)
administratorSkills = getJobSkillCountList(administratorIndexList,jobSkills,processedJobCSV)
clerkSkills = getJobSkillCountList(clerkIndexList,jobSkills,processedJobCSV)
cookSkills = getJobSkillCountList(cookIndexList,jobSkills,processedJobCSV)
receptionistSkills = getJobSkillCountList(receptionistIndexList,jobSkills,processedJobCSV)
webDeveloperSkills = getJobSkillCountList(webDeveloperIndexList,jobSkills,processedJobCSV)
softwareEngineerSkills = getJobSkillCountList(softwareEngineerIndexList,jobSkills,processedJobCSV)
mechanicalEngineerSkills = getJobSkillCountList(mechanicalEngineerIndexList,jobSkills,processedJobCSV)
nurseSkills = getJobSkillCountList(nurseIndexList,jobSkills,processedJobCSV)
cashierSkills = getJobSkillCountList(cashierIndexList,jobSkills,processedJobCSV)
lifeguardSkills = getJobSkillCountList(lifeguardIndexList,jobSkills,processedJobCSV)
teacherSkills = getJobSkillCountList(teacherIndexList,jobSkills,processedJobCSV)

#Get the top job skills for each job title
topProgrammerSkills = getTopSkills(programmerSkills)
topAnalystSkills = getTopSkills(analystSkills)
topAdministratorSkills = getTopSkills(administratorSkills)
topClerkSkills = getTopSkills(clerkSkills)
topCookSkills = getTopSkills(cookSkills)
topReceptionistSkills = getTopSkills(receptionistSkills)
topWebDeveloperSkills = getTopSkills(webDeveloperSkills)
topSoftwareEngineerSkills = getTopSkills(softwareEngineerSkills)
topMechanicalEngineerSkills = getTopSkills(mechanicalEngineerSkills)
topNurseSkills = getTopSkills(nurseSkills)
topCashierSkills = getTopSkills(cashierSkills)
topLifeguardSkills = getTopSkills(lifeguardSkills)
topTeacherSkills = getTopSkills(teacherSkills)

#Save all skills to respective text files
saveSkills(programmerSkills,'programmer')
saveSkills(analystSkills,'analyst')
saveSkills(administratorSkills,'administrator')
saveSkills(clerkSkills,'clerk')
saveSkills(cookSkills,'cook')
saveSkills(receptionistSkills,'receptionist')
saveSkills(webDeveloperSkills,'web developer')
saveSkills(softwareEngineerSkills,'software engineer')
saveSkills(mechanicalEngineerSkills,'mechanical engineer')
saveSkills(nurseSkills,'nurse')
saveSkills(cashierSkills,'cashier')
saveSkills(lifeguardSkills,'lifeguard')
saveSkills(teacherSkills,'teacher')

#Save all top skills to respective text files
saveTopSkills(topProgrammerSkills,'programmer')
saveTopSkills(topAnalystSkills,'analyst')
saveTopSkills(topAdministratorSkills,'administrator')
saveTopSkills(topClerkSkills,'clerk')
saveTopSkills(topCookSkills,'cook')
saveTopSkills(topReceptionistSkills,'receptionist')
saveTopSkills(topWebDeveloperSkills,'web developer')
saveTopSkills(topSoftwareEngineerSkills,'software engineer')
saveTopSkills(topMechanicalEngineerSkills,'mechanical engineer')
saveTopSkills(topNurseSkills,'nurse')
saveTopSkills(topCashierSkills,'cashier')
saveTopSkills(topLifeguardSkills,'lifeguard')
saveTopSkills(topTeacherSkills,'teacher')