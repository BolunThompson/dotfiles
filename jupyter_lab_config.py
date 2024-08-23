c = get_config()
c.ServerApp.ip = '0.0.0.0'
c.ServerApp.port = 60001
c.PasswordIdentityProvider.password_required = True
c.PasswordIdentityProvider.hashed_password = "argon2:$argon2id$v=19$m=10240,t=10,p=8$1D2H/wKMvuydulAk3JKNzg$3hTBWN+bCR43sdNMvo1CHywMrg45dtHHefJKpeNIqMQ"

c.NotebookApp.open_browser = False
c.LabApp.open_browser = False
c.ServerApp.open_browser = False
c.ExtensionApp.open_browser = False
