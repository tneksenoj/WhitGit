# This file will help the user interface to traverse through the folders in server

# This file is free of errors and is ready to go

import searchServer

def traverse(path,lab,dir = None):         #path is a string, for exampe: "2019/Summer/CS171-01"
    word = ""
    for i in path:
        path = path[1:]
        if(i=="/")|(path==""):
            if(word!=""):
                # Since I only used search for group and search for subGroup, I do not want this function to be used to return project objects
                # It seems I cannot compare gitlab object with other group object
                dir = searchServer.searchForGroup(word,lab,dir)
                try:
                    dir==None
                    print("No such directory exist: ",word)
                    return dir
                except:
                    pass
                dir = traverse(path,lab,dir)
                break
        else:
            word+=i
    return dir