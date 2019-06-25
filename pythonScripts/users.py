# username and email have to be unique to the users
# but gitlab does not check if the email address is real
# it checks if the user entered email has the format of an email address
# so we can check the users based on their username, which will be their whitworth username

# WHEN I LOOKED AT THE USER LIST FROM TERMINAL, I SAW A USER WITH THE USERNAME: 'ghost'
# THIS USER COULD NOT BE PERMANENTLY DELETED. EVERYTIME I DELETED IT, THE USER WAS STILL IN THE USER LIST
# THE PROGRAM NEVER GAVE ME ANY ERRORS WHEN I TRIED TO DELETE THIS USER

import searchServer


# Since all the group, subgroup and project classes have 'member' as their member-variable,
# One function can be used for all the directories
def addUserToDir(username, lab, dir, index):            #index is the required item of the access array in searchServer.py
    user = searchServer.searchForUser(username, lab)
    if(user!=None):
        member = dir.members.create({'user_id':user.id,'access_level':searchServer.accessArray[index]})
        print(username, "is now a member for ", dir.name,".")
        return member       #returning member in case we need the member variable
    else:
        print("No user with the username exists.")
        return None