import gitlab
import csv

import searchServer


# NEED TO REVISIT THIS FUNCTION
def addStudentsFromCSV(lab, semGroup):
    # reading the student.csv to add the users and classes in the semester we just made
    with open('pythonScripts/students.csv') as file:
        text = csv.reader(file)
        next(text)          #ignoring the header row
        for line in text:
            # combine strings in 6, 7 and 8 indeces of line to make the class code
            classCode = line[6]+line[7]+"-"+line[8]
            # we look for a subgroup in the semester group
            classGroup = searchServer.searchForGroup(classCode, lab, semGroup)
            try:
                classGroup==None
                classGroup = lab.groups.create({'name': classCode, 'path': classCode,'parent_id': semGroup.get_id()})
                print("We created a new group with name: ",classCode)
            except:
                pass

            # 4th index is the username, so we take that
            studentGroup = searchServer.searchForGroup(line[4], lab, classGroup)
            try:
                studentGroup == None
                studentGroup = lab.groups.create({'name': line[4],'path': line[4],'parent_id':classGroup.get_id()})
                print("We created a new group with name: ",line[4])
            except:
                pass
                
            # after the student-specific groups are made, lets check if the student we just looked at is a user
            studentUser = searchServer.searchForUser(line[4],lab)
            try:
                studentUser == None
                studentUser = lab.users.create({'email': line[5], 'name': line[0]+" "+line[1], 'username': line[4], 'password': '12345678','skip_confirmation': 'True'})
                print("We created a new user with name: ",line[0],line[1], "\n\t\t\t\tusername: ",line[4])
                # this gives maintainer access of the specific group (folder with their username)
                member = studentGroup.members.create({'user_id': studentUser.id,'access_level': gitlab.DEVELOPER_ACCESS})
            except:
                print("Already a member:",studentUser.username,"of",classGroup.name,"/",studentGroup.name)
