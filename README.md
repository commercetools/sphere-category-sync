![SPHERE.IO icon](https://admin.sphere.io/assets/images/sphere_logo_rgb_long.png)

# SPHERE.IO category CSV sync

[![Build Status](https://travis-ci.org/sphereio/sphere-category-sync.png?branch=master)](https://travis-ci.org/sphereio/sphere-category-sync) [![Coverage Status](https://coveralls.io/repos/sphereio/sphere-category-sync/badge.png)](https://coveralls.io/r/sphereio/sphere-category-sync) [![Dependency Status](https://david-dm.org/sphereio/sphere-category-sync.png?theme=shields.io)](https://david-dm.org/sphereio/sphere-category-sync) [![devDependency Status](https://david-dm.org/sphereio/sphere-category-sync/dev-status.png?theme=shields.io)](https://david-dm.org/sphereio/sphere-category-sync#info=devDependencies)

This component allows you to manage the category tree of your SPHERE.IO project via CSV.

# Setup

* install [NodeJS](http://support.sphere.io/knowledgebase/articles/307722-install-nodejs-and-get-a-component-running) (platform for running application)

### From scratch

* install [npm](http://gruntjs.com/getting-started) (NodeJS package manager, bundled with node since version 0.6.3!)
* install [grunt-cli](http://gruntjs.com/getting-started) (automation tool)
*  resolve dependencies using `npm`
```bash
$ npm install
```
* build javascript sources
```bash
$ grunt build
```

### From ZIP

* Just download the ready to use application as [ZIP](https://github.com/sphereio/sphere-category-sync/archive/latest.zip)
* Extract the latest.zip with `unzip sphere-category-sync-latest.zip`
* Change into the directory `cd sphere-category-sync-latest`

## General Usage

This tool uses sub commands for the various task. Please refer to the usage of the concrete action:
- [import](#import)
- [export](#export)
- [delete](#delete)

General command line options can be seen by simply executing the command `./bin/category-sync`.
```
./bin/category-sync
```

For all sub command specific options please call `./bin/category-sync <sub command> --help`.


## Import

TODO

### Usage

```
./bin/category-sync import --help
```

### CSV Format

TODO

## Export

TODO

### Usage

```
./bin/category-sync export --help
```

