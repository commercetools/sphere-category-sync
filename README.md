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

In general the CSV is built up of a header row and the content rows.
The most import header is called `root`. It defines the column that contains the root categories. The columns right to it define the sub(sub)categories. On the left hand side of
the `root` column you may find attributes like id, description, slug etc.

#### Example

```
description,root,level1
```

#### Multilanguage support

TODO

## Export

Using the export subcommand allows you to receive your category tree in a CSV file.
The content of the output file is defined by a template that has to be passed as argument.
Please refer to the CSV Format section whereas the header is the only relevant row for the template.

### Usage

```
./bin/category-sync export --help

  Usage: export --projectKey <project-key> --clientId <client-id> --clientSecret <client-secret> --template <file>

  Options:

    -h, --help               output usage information
    -t, --template <file>    CSV file containing your header that defines what you want to export
    -o, --out <file>         Path to the file the exporter will write the resulting CSV in
    -j, --json <file>        Path to the JSON file the exporter will write the resulting products
    -q, --queryString        Query string to specify the sub-set of products to export. Please note that the query must be URL encoded!
    -l, --languages [langs]  Language(s) used on export for category names (default is en)
```

