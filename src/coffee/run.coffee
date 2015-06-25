Importer = require '../lib/csv/importer'
Exporter = require '../lib/csv/exporter'
package_json = require '../package.json'
{ProjectCredentialsConfig,ExtendedLogger} = require 'sphere-node-utils'

yargs = require 'yargs'
  .usage 'Usage: $0 <command> [options]'
  .describe 'p', 'project key'
  .alias 'p', 'project-key'
  .demand 'p'

  .describe 'i', 'client id'
  .alias 'i', 'client-id'

  .describe 's', 'client secret'
  .alias 's', 'client-secret'

  .describe 'language'
  .nargs 'language', 1
  .default 'language', 'en'

  .describe 'parentBy'
  .nargs 'parentBy', 1
  .default 'parentBy', 'externalId'

  .describe 'continueOnProblems'
  .boolean 'continueOnProblems'

  .command 'export', 'Export categories'
  .command 'import', 'Import categories'

  .help 'h'
  .alias 'h', 'help'

  .version package_json.version

  .epilog 'copyright 2015'

argv = yargs.argv
command = argv._[0]
project_key = argv.p
language = argv.language
parentBy = argv.parentBy
continueOnProblems = argv.continueOnProblems

logger = new ExtendedLogger
  additionalFields:
    project_key: project_key
  logConfig:
    name: "#{package_json.name}-#{package_json.version}"
    streams: [
      { level: 'info', stream: process.stdout }
    ]

ProjectCredentialsConfig.create()
.then (config) ->
  credentials = config.enrichCredentials
    project_key: project_key
    client_id: argv.i
    client_secret: argv.s

  if command is 'import'
    yargs.reset()
    .usage 'Usage: $0 -p <project-key> import -f <CSV file>'
    .example '$0 -p my-project-42 import -f categories.csv', 'Import categories from "categories.csv" file into SPHERE project with key "my-project-42".'

    .describe 'f', 'CSV file name'
    .nargs 'f', 1
    .alias 'f', 'file'
    .demand 'f'
    .argv

    im = new Importer logger,
      config: credentials
      language: language
      parentBy: parentBy
      continueOnProblems: continueOnProblems
    im.run argv.f
    .then (result) ->
      logger.info result

  else if command is 'export'
    yargs.reset()
    .usage 'Usage: $0 -p <project-key> [options] export -t <CSV file> -o <CSV file>'
    .example '$0 -p my-project-42 export -t header.csv -o output.csv', 'Export categories from SPHERE project with key "my-project-42" into "output.csv" file using the template "header.csv".'

    .describe 't', 'CSV template file name'
    .nargs 't', 1
    .alias 't', 'template'
    .demand 't'

    .describe 'o', 'CSV output file name'
    .nargs 'o', 1
    .alias 'o', 'output'
    .demand 'o'
    .argv

    ex = new Exporter logger,
      config: credentials
      language: language
      parentBy: parentBy
      continueOnProblems: continueOnProblems
    ex.run argv.t, argv.o

  else
    yargs.showHelp()

.catch (err) ->
  logger.error err
  process.exit 1
