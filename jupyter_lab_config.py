c = get_config()
c.ServerApp.ip = '0.0.0.0'
c.ServerApp.port = 60001
c.PasswordIdentityProvider.password_required = True

c.NotebookApp.open_browser = False
c.LabApp.open_browser = False
c.ServerApp.open_browser = False
c.ExtensionApp.open_browser = False

c.LabApp.password = c.NotebookApp.password = "sha1:197b7fa43b5d83b3a15e89b5b4e893c4e8c91239"
