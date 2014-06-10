{exec} = require 'child_process'

task 'tests', 'run tests', ->
    command  = "mocha tests/storage.coffee "
    command += "--compilers coffee:coffee-script --colors"
    exec command, (err, stdout, stderr) ->
      console.log err
      console.log stdout
      console.log stderr