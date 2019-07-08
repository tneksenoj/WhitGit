import connection
import searchServer

def ppend(path,wordList):         #path is a string, for exampe: "2019/Summer/CS171-01"
    word = ""
    for i in path:
        path = path[1:]
        if(i=="/"):
            if(word!=""):
                # Since I only used search for group and search for subGroup, I do not want this function to be used to return project objects
                ppend(path,wordList)
                break
        else:
            word+=i
    wordList.append(word)
    return

def traverse(wordList,lab,dir):
    word = wordList[0]
    try:
        dir==lab
        print("In lab entered exception code")
        dir = searchServer.searchForGroup(word,lab)
    except:
        print("In",dir.name,"entered exception code")
        dir = searchServer.searchForSubGroup(word,dir)
    print("now in",dir.name)
    wordList.pop(0)
    if(len(wordList)==0):
        print("Found and returned the directory.")
        return dir
    traverse(wordList,lab,dir)
    return dir

wordList = []
ppend("2019/Summer/CS171-01",wordList)
wordList.reverse()

lab = connection.connect()
traverse(wordList,lab,lab)