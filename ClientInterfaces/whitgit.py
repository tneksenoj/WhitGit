
############################################################################################################# 
# Purpose: Create a simple dialog for students to push projects to the WhitGit repository
#
# Authors: 
#   Kent Jones
#   Abdul Haq
#   Pragalva Dhungana
#   Novel Poudel
#   Sparsh Rawlwani
#
# Date:
#   Summer 2019
##############################################################################################################
#
# Simple enough, just import everything from tkinter.
#
# Resources used in creating this program: 
#
# Change current working directory in python: https://stackoverflow.com/questions/20796355/change-current-working-directory-in-python
# Executing shell commands in python: https://unix.stackexchange.com/questions/238180/execute-shell-commands-in-python
# Getting tkinter to work with visual studio code: https://stackoverflow.com/questions/25905540/importerror-no-module-named-tkinter
# using python in visual studio code and selecting the version: https://blog.usejournal.com/python-with-visual-studio-code-on-macos-60e1fad9e932
# choosing a gui for python: https://blog.resellerclub.com/the-6-best-python-gui-frameworks-for-developers/
# use a button in a tkinter dialog: https://stackoverflow.com/questions/16373887/how-to-set-the-text-value-content-of-an-entry-widget-using-a-button-in-tkinter
# use a button in tkinter dialog: https://www.tutorialspoint.com/python/tk_button.htm
# get rid of a tkinter root dialog window: https://stackoverflow.com/questions/1406145/how-do-i-get-rid-of-python-tkinter-root-window
# tkinter intro: https://pythonprogramming.net/python-3-tkinter-basics-tutorial/
# tkinter menu bar: https://pythonprogramming.net/tkinter-menu-bar-tutorial/?completed=/tkinter-tutorial-python-3-event-handling/
# tkinter dialog module used in python 3: https://stackoverflow.com/questions/673174/which-tkinter-modules-were-renamed-in-python-3
# tkinter simple dialog with multiple text fields: http://www.java2s.com/Code/Python/GUI-Tk/Asimpledialogwithtwolabelsandtwotextfields.htm
# tkinter another file dialog example: https://stackoverflow.com/questions/11295917/how-to-select-a-directory-and-store-the-location-using-tkinter-in-python
# tkinter dialog for a file chooser: https://interactivepython.org/runestone/static/CS152f17/GUIandEventDrivenProgramming/02_standard_dialog_boxes.html
# tkinter use a callback to a class method: https://stackoverflow.com/questions/23262238/tkinter-callback-in-a-class
# tkinter helped us understand how to override OK callback for simpledialog: https://stackoverflow.com/questions/33659401/python-tkinter-simpledialog-how-to-bind-a-key-to-the-ok-button-in-simpledialog
# os.chdir: https://stackoverflow.com/questions/1810743/how-to-set-the-current-working-directory/1810760
#
# 
from tkinter import *
from tkinter import filedialog
import tkinter.simpledialog
from subprocess import call
import os


# This class manages the dialob box that users will use to submit
# simple projects to the WhitGit repository\
class MyDialog(tkinter.simpledialog.Dialog):

    def body(self, master):

        Label(master, text="Whitworth Username:").grid(row=0, sticky=E)
        Label(master, text="Project Folder to Push to WhitGit:").grid(row=1, sticky=E)
        Label(master, text="Commit Message for Project:").grid(row=2, sticky=E)
        

        self.e0 = Entry(master)
        self.e1 = Entry(master)
        self.e2 = Entry(master)
        self.b1 = Button(master, text="Select Project Folder", command = self.select_file )

        
        self.e0.grid(row=0, column=1)
        self.e1.grid(row=1, column=1)
        self.b1.grid(row=1, column=2)
        self.e2.grid(row=2, column=1)

        self.ok =  self.upload_to_whitgit

    
        return self.e1 # initial focus
    
    def select_file(self) :
        proj_dir  = filedialog.askdirectory()
        self.e1.delete(0,END)
        self.e1.insert(0,proj_dir)

    def apply(self):
        first = self.e1.get()
        second = self.e2.get()
        print ( first, second  )

    def upload_to_whitgit(self):
        self.foldername =  self.e1.get()
        os.chdir(self.foldername)
        call(['git','init'])
        call(['git','config',http.sslVerify','false'])
        call([['git','add','.']])


# root window created. Here, that would be the only window, but
# you can later have windows within windows.
root = Tk()
root.withdraw()
d = MyDialog(root)
print ( d.result )
