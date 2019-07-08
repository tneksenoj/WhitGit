# THIS IS THE MAIN FILE
# AND WILL PROBABLY HAVE THE USER INTERFACE ON THIS FILE

# DO NOT INCLUDE THE PASSWORD GENERATION ALGORITHM IF WE ARE TO PUSH THIS FILE TO GITHUB

# This file should enable the users(instructors) to use the functions written in other files

# To try out some code in python terminal, use /usr/bin/python3 (in lab computer)

# refrences
# https://python-gitlab.readthedocs.io/en/stable/gl_objects/projects.html - documentation of project object in python-gitlab


import connection
import addGroups
import students
import ta
import navigate


print("\nPROGRAM START\n")

# connect to the server
lab = connection.connect()  # this returns the GitLab object made for connection

dir = navigate.traverse("2020/Fall/CS273-01",lab)
# students.addStudentsFromCSV(lab,dir)


print("\nEND OF PROGRAM\n")



# The web app will be the interface for the students,
# one also needs to enter the ssh key for the students and/or instructors to use command line
# But as of yet, i am not able to get the ssh key from my laptop that has windows