import connection

lab = connection.connect()

user = lab.users.create({'email': 'poudelnovel@gmail.com', 'name': 'Novel','username': 'npoudel','password': 'npoudel21','skip_confirmation': 'True'})
if(user!=None):
    print("A new user is created username: npoudel and password: npoudel21")