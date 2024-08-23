c = get_config()
c.ServerApp.ip = '0.0.0.0'
c.ServerApp.port = 60001
c.PasswordIdentityProvider.password_required = True
c.PasswordIdentityProvider.password = 'Keilun 1228!'

c.NotebookApp.open_browser = False
c.LabApp.open_browser = False
c.ServerApp.open_browser = False
c.ExtensionApp.open_browser = False
