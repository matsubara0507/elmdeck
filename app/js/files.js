'use strict';

const {remote} = require('electron');
const {dialog, BrowserWindow} = remote;
const fs = require('fs');


function writeFileTo(fileName, data) {
  if (fileName) {
    fs.writeFile(fileName, data, (err) => {
      if (err) {
        console.log(err);
        dialog.showErrorBox('Can not save fiel: ' + fileName, err);
      }
    })
  }
}

module.exports = {
  readFile: function (app) {
    dialog.showOpenDialog(null, {
        properties: ['openFile'],
        title: 'File',
        defaultPath: '.',
        filters: [
            {name: 'マークダウン', extensions: ['md', 'markdown']},
        ]
    }, (fileNames) => {
        fs.readFile(fileNames[0], 'utf8', (err, data) => {
          if (err) console.log(err);
          app.ports.readFile.send({ path: fileNames[0], body: data });
        })
    });
  },
  writeFile: function (app) {
    app.ports.writeFileHook.send(null);
    app.ports.writeFile.subscribe(args => { writeFileTo(args['path'], args['body']) });
  },
  writeFileAs: function (app) {
    dialog.showSaveDialog(null, {
        properties: ['openFile'],
        title: 'File',
        defaultPath: '.',
        filters: [
            {name: 'Markdown', extensions: ['md', 'markdown']},
        ]
    }, (fileName) => {
        if (fileName == undefined) {
          console.log(fileName);
          dialog.showErrorBox('Can not save fiel: ', 'Please select file.');
          return
        }
        app.ports.writeFileHook.send(fileName);
        app.ports.writeFile.subscribe(args => { writeFileTo(args['path'], args['body']) });
    });
  }
}
