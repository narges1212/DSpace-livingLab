1&1 VNC local shell access
==========================


* Log in to https://login.1und1.de
* Select correct Vertrag (37496794)
* Click "1&1 Server"
* You are on the Server-Verwaltung page. Click "VNC Remote Konsole"
* Click "VNC Remote Konsole starten"
* A pop-up appears. Take a look at that pop-up's HTML source code.
* Locate the `<applet>...</applet>` HTML tag. Keep note of the `port` (e.g. `VNC_PORT=5901`) and `password` (e.g. `VNC_PASSWORD=blablafoo`) parameters. These parameters change from time to time.
* Open a terminal with VncViewer.jar on the working path, and execute the following command: `java -jar VncViewer.jar host xvp.onlinehome-server.info port $VNC_PORT password $VNC_PASSWORD`, substituting `$VNC_PORT` and `$VNC_PASSWORD` appropriately.
* This shall open a Java GUI and automatically connect to a VNC window. From here on, provide your Unix login username and Unix password.
