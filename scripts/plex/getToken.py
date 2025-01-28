from plexapi.myplex import MyPlexAccount

# Authenticate with Plex server
try:
    account = MyPlexAccount()
    print("Plex Token:", account.authenticationToken)
except Exception as e:
    print("Failed to retrieve Plex token:", e)
