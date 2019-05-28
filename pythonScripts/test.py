import connection

lab = connection.connect()

projects = lab.projects.list()
for project in projects:
    print(project)