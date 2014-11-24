## CLine

A playground project composed of a command-line utility for [Google Calendar API](https://developers.google.com/google-apps/calendar/), written in Swift.

### What does it do?
* It will allow a user to fetch calendar data on the command line

### Dependencies
* NXOAuth2Client - OAuth2 client
* GCDWebServer - a lightweight server to process OAuth2 callbacks

### Why?
I wanted to try porting [CalBrowser](https://github.com/ivan3bx/CalBrowser) to Swift, but looking through the code, this didn't seem like a productive endeavor as OAuth logic is tied to view controller hierarchy.  To extract this part out, I thought it'd be interesting and relatively painful to create a standalone command-line client in Swift.