const {app, BrowserWindow} = require('electron');
var mainWindow = null;

app.on('window-all-closed', function() {
    app.quit();
});

app.on('ready', function() {
  mainWindow = new BrowserWindow({
    "frame": true,
    "always-on-top": true,
    "resizable": true
  });
  mainWindow.maximize();
  mainWindow.loadURL('file://' + __dirname + '/../index.html');
  mainWindow.on('closed', function() {
    mainWindow = null;
  });
});
