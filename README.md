![SPHERE.IO icon](https://admin.sphere.io/assets/images/sphere_logo_rgb_long.png)

# SPHERE.IO category sync

[![Build Status](https://travis-ci.org/sphereio/sphere-category-sync.png?branch=master)](https://travis-ci.org/sphereio/sphere-category-sync) [![Coverage Status](https://coveralls.io/repos/sphereio/sphere-category-sync/badge.png)](https://coveralls.io/r/sphereio/sphere-category-sync) [![Dependency Status](https://david-dm.org/sphereio/sphere-category-sync.png?theme=shields.io)](https://david-dm.org/sphereio/sphere-category-sync) [![devDependency Status](https://david-dm.org/sphereio/sphere-category-sync/dev-status.png?theme=shields.io)](https://david-dm.org/sphereio/sphere-category-sync#info=devDependencies)

This component allows you to manage the category tree of your SPHERE.IO project by importing, updating and exporting categories via CSV files.

# Usage

In general the command uses sub-commands for the different tasks.
- [import and update](#import)
- [export](#export)

Base options are:
```
./bin/category-sync
Usage: bin/category-sync <command> [options]

Commands:
  export    Export categories
  import    Import categories

Options:
  -p, --project-key    project key         [required]
  -i, --client-id      client id
  -s, --client-secret  client secret
  -h, --help           Show help
  --version            Show version number
```
The tool uses the API to talk to SPHERE.IO and therefore needs the 3 access properties - `project key`, `client id` and `client secret`. For automation reason you may use our [project credentials files](https://github.com/sphereio/sphere-node-utils#projectcredentialsconfig) to avoid passing the credentials via command line options.

When you provide a wrong argument or one argument is missing the tool will inform you. Please have a look at the last line of the output. You might find some useful hints like this one:
```
Missing required arguments: p
```

## Import

The command line to import or update categories is shown below:
```
Usage: bin/category-sync -p <project-key> import -f <CSV file>

Options:
  -f, --file  CSV file name                          [required]

Examples:
  bin/category-sync -p my-project-42          Import categories from
  import -f categories.csv                    "categories.csv" file into SPHERE
                                              project with key "my-project-42".
```

During import we match categories to existing categories according to the `externalId`. If a category with the same `externalId` is found we will call it an update as the tool will then update the existing category properties - like name etc. - to those values defined in the CSV file.
If no matching category is found the tool will create a new one.
The `import` sub-command will never delete a category.

## Export

To export categories, you need to pass a CSV file containing only a header row as template.
This will allow you to define the content of the output file to your specific needs.
Please have a look at the [CSV Format section](#csv-format) for the different headers supported.

The command line to export categories into a CSV file is:
```
Usage: bin/category-sync -p <project-key> [options] export -t <CSV file> -o <CSV file>

Options:
  -t, --template  CSV template file name                              [required]
  -o, --output    CSV output file name                                [required]

Examples:
  bin/category-sync -p my-project-42          Export categories from SPHERE
  export -t header.csv -o output.csv          project with key "my-project-42"
                                              into "output.csv" file using the
                                              template "header.csv".
```

## CSV Format

In general the CSV is built up of a header row and the content rows.
We support the following headers:
- name: [localized name for the category](#localized-attribute)
- description: [category's description in different languages](#localized-attribute)
- slug: [internationalized slugs for the category](#localized-attribute)
- externalId: id of the category defined by the user
- parentId: id of the parent category - we reference other categories by `externalId` here
- orderHint: a string that is used to order categories of the same parent. We recommend to use values between `0.1` and `0.9`.

Further you might use the following header during export:
- id: id of category in SPHERE.IO
- createdAt: The UTC time stamp when the category was created.
- lastModifiedAt: The UTC time stamp when the category was changed the last time.

Please find some examples in the [data](https://github.com/sphereio/sphere-category-sync/tree/master/data) folder or in the acceptance tests of the tool in the `*.feature` located [here](https://github.com/sphereio/sphere-category-sync/tree/master/features).

Please note that there is no order in the header.

### Localized attributes

Different languages for the same attribute are defined by a suffix to the actual header delimited by a `.` - examples are `name.de` or `slug.en`. You may define as many languages as you want for those attributes.

# Setup

* Install [NodeJS](http://support.sphere.io/knowledgebase/articles/307722-install-nodejs-and-get-a-component-running) (platform for running application)
* Download the ready to use application as [ZIP](https://github.com/sphereio/sphere-category-sync/archive/latest.zip)
* Extract the latest.zip with `unzip sphere-category-sync-latest.zip`
* Change into the directory `cd sphere-category-sync-latest`

# Development

* Clone this repository and change into the directory
* Install all necessary dependencies with

  ```bash
  npm install
  ```
* Convert CoffeeScript into JavaScript by

  ```bash
  npm run build
  ```
* To run the test do:

  ```bash
  npm test
  ```
* To run the tests on each change you do to any `*.coffee` file run

  ```bash
  npm run watch:test
  ```
