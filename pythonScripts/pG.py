# file I got from Pragalva

import gitlab

gl = gitlab.Gitlab('http://10.200.100.31', private_token='pEs4pkFkDwkULZSYQFsi', api_version=4, ssl_verify=False)
gl.auth()

#creating a project
year = input("Enter a year: ")
semester = input("Enter a semster: ")
classes =  input("Enter a class: ")
section = input("Enter a section: ")
name = input("Enter the name of the project: ")

group_id = gl.groups.list(search = section)[0].id
project = gl.projects.create({'name': name, 'namespace_id': group_id})

# deleting a project
project_id = gl.projects.list(search = name)[0].id
gl.projects.delete(project_id)

#deleting a class
group_id = group_id = gl.groups.list(search = classes)[0].id
gl.groups.delete(group_id)

