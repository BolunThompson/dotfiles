c = get_config()
c.ServerApp.ip = '0.0.0.0'
c.ServerApp.port = 60001
c.PasswordIdentityProvider.password_required = True

c.NotebookApp.open_browser = False
c.LabApp.open_browser = False
c.ServerApp.open_browser = False
c.ExtensionApp.open_browser = False

c.LabApp.password = c.NotebookApp.password = "8a51cf8eb235b1438deb9ccf2497fc49ee1dca1c"
