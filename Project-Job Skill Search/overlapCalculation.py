import math
import csv

#Function to normalize the values of a dictionary
def normalizeDict(dictionary):
    dictValues = dictionary.values()
    dictSum = sum(dictValues)
    for x in dictionary:
        dictionary[x] = dictionary[x]/dictSum
    return dictionary
#Function to download the total job skill count from a text file
def getTotalJobSkillCount(jobTitle):
    jobTitle = jobTitle.replace(' ','')
    fileName = 'allSkills\\' + jobTitle + 'Skills.csv'
    #Open the file and for each line, save the 1st element (the skill name) and the 2nd element (the actual count)
    totalSkillCount = {}
    skillsCountFile = open(fileName,'r')
    skillsCountFileReader = csv.reader(skillsCountFile)
    for item in skillsCountFileReader:
        totalSkillCount[item[0]] = int(item[1])
    #Normalize each count for use in the Bhattacharyya coefficient calc
    totalSkillCount = normalizeDict(totalSkillCount)
    return totalSkillCount
#Function to calculate the Bhattacharrya Coefficient
def getBhattacharyyaCoefficient(dictA,dictB):
    coefficientCalc = []
    #Get a list of all the square roots of each lists skill value multiplied together
    for x in dictA:
        newNum = math.sqrt(dictA[x]*dictB[x])
        coefficientCalc.append(newNum)
    #Sum all the values and round to the fourth decimal point
    bhattacharyyaCoefficient = round(sum(coefficientCalc),4)
    return bhattacharyyaCoefficient
#Function to get a full list of each job's BC
def getBCMatrix(skillCountList):
    bhatCoMatrix = []
    for x in skillCountList:
        bhatCoSublist = [x[0]]
        for y in skillCountList:
            bhatCoValue = getBhattacharyyaCoefficient(x[1],y[1])
            bhatCoSublist.append(bhatCoValue)
        bhatCoMatrix.append(bhatCoSublist)
    return bhatCoMatrix
#Function to save the BC values to a csv file
def saveBCMatrix(bhatCoValueList):
    bhatCoCSV = open('bhatCoValues.csv','w+',newline = '',encoding = 'utf-8')
    bhatCoWriter = csv.writer(bhatCoCSV)
    header = ["","programmer","analyst","administrator","clerk","cook","receptionist","web developer","software engineer","mechanical engineer","nurse","cashier","lifeguard","teacher"]
    bhatCoWriter.writerow(header)
    bhatCoWriter.writerows(bhatCoValueList)
    bhatCoCSV.close()

#Get the total job skill count for each job and add it to a superlist
programmerCount = getTotalJobSkillCount('programmer')
analystCount = getTotalJobSkillCount('analyst')
administratorCount = getTotalJobSkillCount('administrator')
clerkCount = getTotalJobSkillCount('clerk')
cookCount = getTotalJobSkillCount('cook')
receptionistCount = getTotalJobSkillCount('receptionist')
webDeveloperCount = getTotalJobSkillCount('web developer')
softwareEngineerCount = getTotalJobSkillCount('software engineer')
mechanicalEngineerCount = getTotalJobSkillCount('mechanical engineer')
nurseCount = getTotalJobSkillCount('nurse')
cashierCount = getTotalJobSkillCount('cashier')
lifeguardCount = getTotalJobSkillCount('lifeguard')
teacherCount = getTotalJobSkillCount('teacher')
countList = [['programmer',programmerCount],['analyst',analystCount],['administrator',administratorCount],['clerk',clerkCount],['cook',cookCount],['receptionist',receptionistCount],['web developer',webDeveloperCount],['software engineer',softwareEngineerCount],['mechanical engineer',mechanicalEngineerCount],['nurse',nurseCount],['cashier',cashierCount],['lifeguard',lifeguardCount],['teacher',teacherCount]]

#Get the Bhattacharyya coefficients for each list
bhatCoList = getBCMatrix(countList)

#Save the BC values to a csv file
saveBCMatrix(bhatCoList)