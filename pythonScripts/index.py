# THIS IS THE MAIN FILE

# DO NOT INCLUDE THE PASSWORD GENERATION ALGORITHM IF WE ARE TO PUSH THIS FILE TO GITHUB

# refrences
# https://python-gitlab.readthedocs.io/en/stable/gl_objects/projects.html - documentation of project object in python-gitlab


import connection
import addGroups
import students
import ta


print("\nPROGRAM START\n")

# connect to the server
lab = connection.connect()  # this returns the GitLab object made for connection

# initializing the to-be-recently-made semester subgroup
semGroup = None

# only adding 1 year at a time
yearGroup = addGroups.addYear(lab)
if(yearGroup!=None):
    # we will be using this script every semester, so this will only let the user make 1 semester group
    semGroup = addGroups.addSemester(lab, yearGroup)




print("\nEND OF PROGRAM\n")