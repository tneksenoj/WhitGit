# THIS IS THE MAIN FILE
# AND WILL PROBABLY HAVE THE USER INTERFACE ON THIS FILE

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






print("\nEND OF PROGRAM\n")