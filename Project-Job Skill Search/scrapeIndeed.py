import csv
import requests
from bs4 import BeautifulSoup

#Function to get a search for Vancouver with a specific job title
def getURL(jobTitle):
    #Convert the supplied job title to make it url friendly
    jobTitle = jobTitle.replace(' ','+')
    #Using the supplied job title, create a filename and check if the file exists. If it does, use the old saved URl. If it does not, generate a new one with the job title
    fileName = 'searchURLs\\searchURL' + jobTitle + '.txt'
    try:
        fileContent = open(fileName,'r')
        jobSearchURL = fileContent.read()
        print("Got old URL")
        fileContent.close()
    except FileNotFoundError:
        templateURL = 'https://ca.indeed.com/jobs?q={}&l=Vancouver%2C%20BC'
        jobSearchURL = templateURL.format(jobTitle)
        print("Got new URL")
    return jobSearchURL
#Function to save the current working URL to an accessible text file
def saveURL(url, jobTitle):
    jobTitle = jobTitle.replace(' ','+')
    #Create a unique title for the file to differentiate
    fileName = 'searchURLs\\searchURL' + jobTitle + '.txt'
    #Write the URL to the file
    urlFile = open(fileName,'w+')
    urlFile.write(url)
    urlFile.close()
    print('Saved current URL')
#Function to get the job description from a single job card
def getJobInfo(jobTitle,jobCard):
    #Extract job data from a single record
    href = "https://ca.indeed.com" + jobCard.get('href')
    hrefResponse = requests.get(href)
    jobCardSoup = BeautifulSoup(hrefResponse.text,'html.parser')
    #Save the description text, subbing in a blank string if there is no description
    try:
        jobDesc = jobCardSoup.find('div','jobsearch-jobDescriptionText').text.strip()
    except AttributeError:
        jobDesc = ''
    record = (jobTitle,jobDesc)
    return record
#Function to write the data into a CSV file
def writeData(records):
    #Open the CSV with append, and write the list of records to it
    jobCSV = open('jobResults.csv','a+',newline = '',encoding = 'utf-8')
    jobWriter = csv.writer(jobCSV)
    jobWriter.writerows(records)
    print("Finished writing")
    jobCSV.close()
#Function to get all job descriptions for a job title
def createRecord(jobTitle,records):
    #Get the URL
    indeedURL = getURL(jobTitle)
    #Extract the job data
    while True:
        response = requests.get(indeedURL)
        jobSoup = BeautifulSoup(response.text,'html.parser')
        print('Got the next page')
        #Find all job cards on the page and add their info to the records list
        jobCards = jobSoup.find_all('a','tapItem')
        for card in jobCards:
            newRecord = getJobInfo(jobTitle,card)
            records.append(newRecord)
        #Check to see if there is a new page button
        try:
            indeedURL = "https://ca.indeed.com" + jobSoup.find('a',{'aria-label':'Next'}).get('href')
        except (AttributeError,TypeError):
            #Check if there is a captcha
            lastPageTest = jobSoup.find('div','h-captcha')
            try:
                lastPageTest['data-sitekey']
                saveURL(indeedURL,jobTitle)
                print("Not the last page")
            except KeyError:
                print("Last page, move to next job title")
            break

#Set up records list
jobRecords = []

#Add all the job cards to jobRecords
# createRecord('programmer',jobRecords)
# createRecord('analyst',jobRecords)
# createRecord('administrator',jobRecords)
# createRecord('clerk',jobRecords)
# createRecord('cook',jobRecords)
# createRecord('receptionist',jobRecords)
# createRecord('web developer',jobRecords)
# createRecord('software engineer',jobRecords)
# createRecord('mechanical engineer',jobRecords)
# createRecord('nurse',jobRecords)
# createRecord('cashier',jobRecords)
# createRecord('lifeguard',jobRecords)
# createRecord('teacher',jobRecords)
createRecord('Computer Science Professor',jobRecords)

#Write the records list to our job records csv file
writeData(jobRecords)