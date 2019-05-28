# THIS IS SERVER-SIDE CODE
# WE WILL HAVE TO WRITE A CLIENT SIDE CODE WITH A DIFFERENT LANGUAGE FOR THE 'UI'

# this file will not be the main file

# resources
# https://python-gitlab.readthedocs.io/en/stable/api-usage.html - documentation about Gitlab objects in python-gitlab
# https://python-gitlab.readthedocs.io/en/stable/gl_objects/groups.html - documentation of Group objects i python-gitlab

import searchServer


# fucntion to create the year group
def addYear(lab):
    yearName = input("Year to add: ")
    if( yearName == "skip"):
        return None
    thisYearGroup = searchServer.searchForGroup(yearName,lab)
    if (thisYearGroup==None):
        # make one if the given year does not exist
        thisYearGroup = lab.groups.create({'name': yearName, 'path': yearName})
        print("We created a new group with the name: ",yearName)
    else:
        # returns name and id of the group when the year group exists
        print("This group already exists!!\nName: ",thisYearGroup._attrs.get('name'),"\nID: ",thisYearGroup._attrs.get('id'))
    return thisYearGroup
    

def addSemester(lab, yearGroup):
    semName = input("Semester to add (type 'skip' to skip): ")
    if (semName == "skip"):
        return None
    thisSemGroup = searchServer.searchForSubGroup(semName, yearGroup)
    if(thisSemGroup == None):
        # creating the semester group if it does not exist
        thisSemGroup = lab.groups.create({'name': semName,'path': semName, 'parent_id': yearGroup.get_id()})
        print("We created a new group with the name: ",semName)
    else:
        print("This group already exists!!\nName: ",thisSemGroup._attrs.get('name'),"\nID: ",thisSemGroup._attrs.get('id'))
    return thisSemGroup