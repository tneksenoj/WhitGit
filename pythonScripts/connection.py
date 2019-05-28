import gitlab

def connect():
    # the private token keeps expiring, so if something is not working, check if the token has expired
    with(gitlab.Gitlab('http://10.200.100.31', private_token='aqQAaDUxJ1T6hepHfX9b', ssl_verify=False)) as lab:     # add api_version=4 as a parameter for the class constructor
        lab.auth()
        print("connected to http://10.200.100.31\n")
    
    return lab
