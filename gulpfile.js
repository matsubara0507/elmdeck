const g = require('gulp');
const electron = require('electron-connect').server.create();
const packager = require('electron-packager');
const $ = require('gulp-load-plugins')();
const packageJson = require('./package.json');
const extend = require('util')._extend;

g.task('watch', () => {
  g.watch(['app/src/**/*.elm'],['elm']);
  electron.start();
  g.watch(['app/js/*.js', 'app/index.html'], electron.restart);
  g.watch([], electron.reload);
})

g.task('elm', () =>{
  g.src(['app/src/**/*.elm'])
    .pipe($.logger())
    .pipe($.plumber())
    .pipe($.elm.bundle('main.js', debug=true))
    .pipe(g.dest("app/js"));
})

g.task('package', ['elm'], ()=>{
  commonParam = {
    dir: '.',
    out: 'release',
    name: packageJson.name,
    arch: ['x64','ia32'],
    version: '0.31.1',
    ignore: '(icons|release|node_modules|elm-stuff)',
    overwrite: true,
  }

  darwinParam = extend(commonParam, {platform:'darwin', icon: './image/elmdeck.icns'});
  linuxParam  = extend(commonParam, {platform:'linux',  icon: './image/elmdeck.png'});
  win32Param  = extend(commonParam, {platform:'win32',  icon: './image/elmdeck.ico'});
  packager(darwinParam, console.log);
  packager(linuxParam , console.log);
  packager(win32Param , console.log);

})

g.task('default', ['watch',])
