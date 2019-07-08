# THE FOLLOWING CODES ARE SIMILAR BUT THEY HAD TO BE DIFFERENTIATED
# BECASUE IF THE ROOT FOLDER IS A GROUP, WE CANNOT ACCESS GROUPS VARIABLE
# AND HAVE TO ACCESS THE SUBGROUP VARIABLE INSTEAD

import gitlab

accessArray = [gitlab.GUEST_ACCESS, gitlab.REPORTER_ACCESS, gitlab.DEVELOPER_ACCESS, gitlab.MAINTAINER_ACCESS, gitlab.OWNER_ACCESS]

# check for the group name
# takes in the name of the group to be searched and lab as the gitlab object
# returns the group if found and None if not found
def searchForGroup(keyword,lab,parentGroup = None):
    # Instead of using if(parentGroup==None), I used try catch
    # Trying to compare a group object to None always gave an error that None does not have get_id attribute
    # That probably means the operator "==" is overloaded to compare the id of the two arguments
    try:
        parentGroup==None
        groups = lab.groups.list(search = keyword)
    except:
        groups = lab.groups.list(search = keyword,id = parentGroup.id)
    if (groups.__len__()):
        # CURRENTLY THIS PROGRAM DOES NOT CARE IF THERE ARE MORE THAN 1 GROUPS WITH THE SAME NAME
        return groups[0]
    return None


# WE DON'T NEED THE FOLLOWING FUNCTION ANYMORE
# # check for the subgroup name
# # takes in the name of the subgroup to be searched and the parent group object
# # returns the subgroup (as a group object) if found and None if not found
# def searchForSubGroup(keyword,lab,parentGroup):
#     subGroups = lab.groups.list(id = parentGroup.id,search=keyword)     #looks for the subgroups in that id, then searches for the specific subgroup with the keyword and returns it as a group
#     if(subGroups.__len__()):
#         # Similar to the one above
#         return subGroups[0]             #even though i have it as a subgroup, this is actually a group object
#         # Might have to use SubGroup = lab.groups.get(subGroups[0].id, lazy = True)
#     return None


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