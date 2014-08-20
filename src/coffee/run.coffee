Importer = require '../lib/import'
Exporter = require '../lib/exporter'
package_json = require '../package.json'
CONS = require '../lib/constants'
GLOBALS = require '../lib/globals'
fs = require 'fs'
Q = require 'q'
program = require 'commander'
prompt = require 'prompt'
{ProjectCredentialsConfig} = require 'sphere-node-utils'
Csv = require 'csv'

module.exports = class

  @run: (argv) ->
    program
      .version package_json.version
      .usage '[globals] [sub-command] [options]'
      .option '-p, --projectKey <key>', 'your SPHERE.IO project-key'
      .option '-i, --clientId <id>', 'your OAuth client id for the SPHERE.IO API'
      .option '-s, --clientSecret <secret>', 'your OAuth client secret for the SPHERE.IO API'
      .option '--sphereHost <host>', 'SPHERE.IO API host to connecto to'
      .option '--timeout [millis]', 'Set timeout for requests (default is 30000)', parseInt, 30000
      .option '--verbose', 'give more feedback during action'
      .option '--debug', 'give as many feedback as possible'


    program
      .command 'import'
      .description 'Import your category tree from CSV into your SPHERE.IO project.'
      .option '-c, --csv <file>', 'CSV file containing the category tree to import'
      .option '-l, --language [lang]', 'Default language for slug generation - default is en', 'en'
      .option '--csvDelimiter [delim]', 'CSV Delimiter that separates the cells (default is comma - ",")', ','
      .option '--continueOnProblems', 'When a product does not validate on the server side (400er response), ignore it and continue with the next products'
      .option '--dryRun', 'Will list all action that would be triggered, but will not POST them to SPHERE.IO'
      .usage '--projectKey <project-key> --clientId <client-id> --clientSecret <client-secret> --csv <file>'
      .action (opts) ->
        GLOBALS.DEFAULT_LANGUAGE = opts.language

        credentialsConfig = ProjectCredentialsConfig.create()
        .fail (err) ->
          console.error "Problems on getting client credentials from config files: #{err}"
          process.exit 2
        .then (credentials) ->
          options =
            config: credentials.enrichCredentials
              project_key: program.projectKey
              client_id: program.clientId
              client_secret: program.clientSecret
            timeout: program.timeout
            show_progress: true
            user_agent: "#{package_json.name} - Import - #{package_json.version}"
            logConfig:
              streams: [
                {level: 'warn', stream: process.stdout}
              ]
            csvDelimiter: opts.csvDelimiter

          options.host = program.sphereHost if program.sphereHost

          if program.verbose
            options.logConfig.streams = [
              {level: 'info', stream: process.stdout}
            ]
          if program.debug
            options.logConfig.streams = [
              {level: 'debug', stream: process.stdout}
            ]

          importer = new Importer options
          importer.continueOnProblems = opts.continueOnProblems
          importer.dryRun = true if opts.dryRun

          fs.readFile opts.csv, 'utf8', (err, content) ->
            if err
              console.error "Problems on reading file '#{opts.csv}': #{err}"
              process.exit 2
            else
              importer.import(content)
              .then (result) ->
                console.log result
                process.exit 0
              .fail (err) ->
                console.error err
                process.exit 1
              .done()
        .done()


    program
      .command 'delete'
      .description 'Allows to delete (all) categories of your SPHERE.IO project.'
      .option '--csv <file>', 'processes products defined in a CSV file by either "sku" or "id". Otherwise all products are processed.'
      .usage '--projectKey <project-key> --clientId <client-id> --clientSecret <client-secret>'
      .option '--continueOnProblems', "When a there is a problem on changing a product's state (400er response), ignore it and continue with the next products"
      .action (opts) ->

        credentialsConfig = ProjectCredentialsConfig.create()
        .fail (err) ->
          console.error "Problems on getting client credentials from config files: #{err}"
          process.exit 2
        .then (credentials) ->
          options =
            config: credentials.enrichCredentials
              project_key: program.projectKey
              client_id: program.clientId
              client_secret: program.clientSecret
            timeout: program.timeout
            show_progress: true
            user_agent: "#{package_json.name} - State - #{package_json.version}"
            logConfig:
              streams: [
                {level: 'warn', stream: process.stdout}
              ]

          options.host = program.sphereHost if program.sphereHost

          if program.verbose
            options.logConfig.streams = [
              {level: 'info', stream: process.stdout}
            ]
          if program.debug
            options.logConfig.streams = [
              {level: 'debug', stream: process.stdout}
            ]

          prompt.start()
          property =
            name: 'ask'
            message: 'Do you really want to delete products?'
            validator: /y[es]*|n[o]?/
            warning: 'Please answer with yes or no'
            default: 'no'

          prompt.get property, (err, result) ->
            if _.isString(result.ask) and result.ask.match(/y(es){0,1}/i)
              importer = new Importer options
              importer.continueOnProblems = opts.continueOnProblems
              importer.deleteAll()
              .then (result) ->
                console.log result
                process.exit 0
              .fail (err) ->
                console.error err
                process.exit 1
              .done()
            else
              console.log 'Cancelled.'
              process.exit 9
        .done()


    program
      .command 'export'
      .description 'Export your products from your SPHERE.IO project to CSV using.'
      .option '-t, --template <file>', 'CSV file containing your header that defines what you want to export'
      .option '-o, --out <file>', 'Path to the file the exporter will write the resulting CSV in'
      .option '-j, --json <file>', 'Path to the JSON file the exporter will write the resulting products'
      .option '-q, --queryString', 'Query string to specify the sub-set of products to export. Please note that the query must be URL encoded!', 'staged=true'
      .option '-l, --languages [langs]', 'Language(s) used on export for category names (default is en)', 'en'
      .usage '--projectKey <project-key> --clientId <client-id> --clientSecret <client-secret> --template <file>'
      .action (opts) ->
        GLOBALS.DEFAULT_LANGUAGE = opts.languages

        options =
          config:
            project_key: program.projectKey
            client_id: program.clientId
            client_secret: program.clientSecret
          timeout: program.timeout
          show_progress: true
          user_agent: "#{package_json.name} - Export - #{package_json.version}"
          queryString: opts.queryString
          logConfig:
            streams: [
              {level: 'warn', stream: process.stdout}
            ]

        options.host = program.sphereHost if program.sphereHost

        if program.verbose
          options.logConfig.streams = [
            {level: 'info', stream: process.stdout}
          ]
        if program.debug
          options.logConfig.streams = [
            {level: 'debug', stream: process.stdout}
          ]

        exporter = new Exporter options
        if opts.json
          exporter.exportAsJson(opts.json)
          .then (result) ->
            console.log result
            process.exit 0
          .fail (err) ->
            console.error err
            process.exit 1
          .done()
        else
          fs.readFile opts.template, 'utf8', (err, content) ->
            if err
              console.error "Problems on reading template file '#{opts.template}': #{err}"
              process.exit 2
            else
            exporter.export(content, opts.out)
            .then (result) ->
              console.log result
              process.exit 0
            .fail (err) ->
              console.error err
              process.exit 1
            .done()

    program.parse argv
    program.help() if program.args.length is 0

module.exports.run process.argv
