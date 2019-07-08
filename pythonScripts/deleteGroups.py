import searchServer

def deleteGroup(groupName, lab, parent):
    group = searchServer.searchForGroup(groupName, lab, parent)
    try:
            group!= None
            group.delete()
    except:
            pass



def deleteUser(userName, lab):
    user = searchServer.searchForUser(userName, lab)
    try:
            user!= None
            user.delete()
    except:
            pass


def deleteProject(projectName,lab):
    project = searchServer.searchForProject(projectName,lab)
     try:
            project!= None
            project.delete()
    except:
            pass
