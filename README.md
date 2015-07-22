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
  --language            Language used for slugs when referencing parent.
                                                                 [default: "en"]
  --parentBy            Property used to reference parent - use externalId or
                        slug or id                       [default: "externalId"]
  --continueOnProblems  Continue with creating/updating further categories even
                        if API returned with 400 status code.
                                                      [boolean] [default: false]
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

To export categories, you can pass a CSV file as template. The template needs to contain only the header.
This will allow you to define the content of the output file to your specific needs.
Please have a look at the [CSV Format section](#csv-format) for the different headers supported.
If you don't provide a template, the tools will export all possible information in the languages defined in the project.

The command line to export categories into a CSV file is:
```
Usage: bin/category-sync -p <project-key> [options] export -t <CSV file> -o <CSV file>

Options:
  -t, --template  CSV template file name
  -o, --output    CSV output file name                                [required]

Examples:
  bin/category-sync -p my-project-42          Export categories from SPHERE
  export -t header.csv -o output.csv          project with key "my-project-42"
                                              into "output.csv" file using the
                                              template "header.csv".

  bin/category-sync -p the-project-1          Export categories from SPHERE
  export -o my.csv                            project with key "the-project-1"
                                              into "my.csv".
```

## Resolving parent category

A category without a parent is called `root` category. All other categories have a parent.
To define a parent by default you provide the externalId of the parent category.
```csv
externalId,name,parentId
root123,Root Category,
sub123,Sub Category,root123
```

But you may also use the slug to reference your parent category.
```csv
name,slug.en,parentId
Root Category,root-cat,
Sub Category,sub-cat,root-cat
```

Ensure that you have set the right language to choose the slug. By default it's English.

## CSV Format

In general the CSV is built up of a header row and the content rows.
We support the following headers:
- name: [localized name for the category](#localized-attributes)
- description: [category's description in different languages](#localized-attributes)
- slug: [internationalized slugs for the category](#localized-attributes)
- externalId: id of the category defined by the user
- parentId: id of the parent category - we reference other categories by `externalId` here
- orderHint: a string that is used to order categories of the same parent. We recommend to use values between `0.1` and `0.9`.
- metaTitle: [localized title of category for search engines](#localized-attributes)
- metaDescription: [localized description to be used by search engines](#localized-attributes)
- metaKeywords: [localized SEO keywords for the category](#localized-attributes)

Further you might use the following header during export:
- id: id of category in SPHERE.IO
- createdAt: The UTC time stamp when the category was created.
- lastModifiedAt: The UTC time stamp when the category was changed the last time.

Please find some examples in the [data](https://github.com/sphereio/sphere-category-sync/tree/master/data) folder or in the acceptance tests of the tool in the `*.feature` located [here](https://github.com/sphereio/sphere-category-sync/tree/master/features).

Please note that there is no order in the header.

### Localized attributes

Different languages for the same attribute are defined by a suffix to the actual header delimited by a `.` - examples are `name.de` or `slug.en`. You may define as many languages as you want for those attributes.

# Setup

If you just want to use the tool, we recommend to use [SPHERE.IO's impex platform](https://impex.sphere.io) to avoid any local installation - you only need your browser.

Nevertheless, running the program locally, you need [NodeJS](https://nodejs.org/download/) installed and simply run the following command in your terminal:

```bash
npm install sphere-category-sync
./node_modules/.bin/category-sync
#
```

You may also install it globally if you have sufficent rights on your computer:
```bash
npm install -g sphere-category-sync
category-sync
#
```

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
