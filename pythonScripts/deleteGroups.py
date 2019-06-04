import searchServer

def deleteGroup(groupName, lab):
    group = searchServer.searchForGroup(groupName, lab)  
    if(group!=None):
        group.delete()


def deleteSubGroup(subGroupName, parentGroup):
    subGroup = searchServer.searchForSubGroup(subGroupName, parentGroup)  
    if(subGroup!=None):
        subGroup.delete()


def deleteUser(userName, lab):
    user = searchServer.searchForUser(userName, lab)
    if(user!=None):
        user.delete()


def deleteProject(projectName,lab):
    project = searchServer.searchForProject(projectName,lab)
    if(project != None):
        project.delete()
