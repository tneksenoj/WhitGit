# THE FOLLOWING TWO CODES ARE SIMILAR BUT THEY HAD TO BE DIFFERENTIATED
# BECASUE IF THE ROOT FOLDER IS A GROUP, WE CANNOT ACCESS GROUPS VARIABLE


# check for the group name
# takes in the name of the group to be searched and lab as the gitlab object
# returns the group if found and None if not found
def searchForGroup(keyword,lab):
    groups = lab.groups.list(search = keyword)
    if (groups.__len__()):
        # CURRENTLY THIS PROGRAM DOES NOT CARE IF THERE ARE MORE THAN 1 GROUPS WITH THE SAME NAME
        return groups[0]
    return None



# check for the subgroup name
# takes in the name of the subgroup to be searched and the parent group object
# returns the subgroup if found and None if not found
def searchForSubGroup(keyword,parentGroup):
    subGroups = parentGroup.subgroups.list(search = keyword)
    if(subGroups.__len__()):
        # Similar to the one above
        return subGroups[0]
    return None


# THE PROJECTS CANNOT HAVE THE SAME NAME IF THEY HAVE THE SAME PARENT GROUP
# BUT THEY CAN IF THEY ARE IN DIFFERENT GROUPS
# check for project name
def searchForProject(keyword, parentGroup):
    projects = parentGroup.projects.list(search = keyword)
    if(projects.__len__()):
        # similar to above function
        return projects[0]
    return None


# check for users
def searchForUser(username,lab):
    users = lab.users.list(search=username)
    if(users.__len__()):     #this one never has more than 1 length as the username has to different for different users
        # same again
        return users[0]
    return None