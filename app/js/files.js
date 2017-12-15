'use strict';

const {remote} = require('electron');
const {dialog, BrowserWindow} = remote;
const fs = require('fs');

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
  }
}
