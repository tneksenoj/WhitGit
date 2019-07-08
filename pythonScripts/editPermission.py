# These functions are to be used to change the permission
# of the users to interact to the code in a group project

# reference - https://python-gitlab.readthedocs.io/en/stable/gl_objects/projects.html project members

import searchServer

def changePermission(username,lab,project,index):        #index is the order of the access level for a user
    user = searchServer.searchForUser(username,lab)
    member = project.members.get(user.id)
    member.access_level = searchServer.accessArray[index]
    member.save()           #the documentation online 
    return