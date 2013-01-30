Process = require './Process'
coffee = 'node_modules/coffee-script/bin/coffee'

class Runner

  constructor: (groups) ->

    @groups = groups
    @listeners = []

    # Set environmental variables
    @env = process.env
    @env['NODE_PATH'] = process.cwd() + '/node_modules'

  complete: (error, request, response, body) =>

    throw new Error error if error

    res =
      body: body
      statusCode: response.statusCode
      headers: response.headers

    for test in @groups

      script = []
      script.push "should = require 'should'"
      script.push "title = '" + test.title.split("'").join("\\'") + "'"
      script.push "response = " + JSON.stringify res
      script.push "try"
      script.push Runner.indentSource( test.source, ' ', 2 )
      script.push "catch e"
      script.push "  console.log e.message"
      script.push "  process.exit 1"
      script.push "process.exit 0"

      # Spawn child process
      child = new Process coffee, [ '-s' ], { env: @env }, { test: test }

      child.on 'exit', (code, stdout, stderr, data) =>
        @listeners.map (listener) => listener code, stdout, stderr, data

      child.emit 'write', script.join '\n'

  listener: (callback) => @listeners.push callback

  @indentSource: (source,char=' ',indentation=2) ->

    indent = Array(indentation+1).join(char)
    return indent + source.split("\n").join("\n#{indent}")

module.exports = Runner