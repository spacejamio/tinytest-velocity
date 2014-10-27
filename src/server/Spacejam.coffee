spacejam = Npm.require('spacejam')
path = Npm.require('path')
fs = Npm.require('fs')

@practical ?= {}

class practical.Spacejam

  instance = null

  spacejamChild: null

  exiting: false

  @get: ->
    instance ?= new practical.Spacejam()

  constructor: ->
    log.debug 'Spacejam.constructor()'

    @spacejamChild = practical.ChildProcessFactory.get()
    Velocity.registerTestingFramework 'tinytest', {}


  testInVelocity: ->
    log.debug 'Spacejam.testInVelocity()'
    # Setting this to avoid running this package's tests during spacejamChildTestInVelocity
    process.env.TEST_IN_VELOCITY = true
    appPath = @spacejamChild.getMeteorAppPath()

    spawnOptions =
      taskName: 'spacejam'
      command: Spacejam.getSpacejamPath(appPath)
      args: Spacejam.getSpawnArgs()

    log.info 'Spawning spacejam to launch meteor test-packages and run your package tests in phantomjs'
    if not @spacejamChild.spawnSingleton(spawnOptions)
      log.debug "spacejam is already running."
      return

    @spacejamChild.child.on "exit", (code, signal) =>
      log.error "Error: spacejam exited unexpectedly, you will need to restart your app to run your package tests again.\nIf the problem persists, please create a package issue on github.\nAdditional info: exit code #{code}, exit signal #{signal}" if not @exiting


  @getSpacejamPath: (appPath)->
    log.debug 'Spacejam.getSpacejamPath()', appPath
    expect(appPath).to.be.a('string').that.is.ok
    spacejamRelativePath = '.meteor/local/build/programs/server/npm/spacejamio:tinytest-velocity/node_modules/spacejam/bin/spacejam'
    spacejamPath = path.resolve(appPath, spacejamRelativePath)
    return spacejamPath if fs.existsSync(spacejamPath)
    throw new Error "Could not find the spacejam npm package in .meteor/local. If you are running meteor test-packages, set METEOR_APP_PATH to your meteor app's root folder."


  @getSpawnArgs: ->
    log.debug 'Spacejam.getSpawnArgs()'
    options = Meteor.settings?.packages?.practicalmeteor?["tinytest-velocity"]?.spacejamOptions || {}
    log.debug "Spacejam.getSpawnArgs() spacejamOptions=", options

    args = ['test-in-velocity']

    for option of options
      if option isnt 'packages'
        args.push(["--#{option}", "#{options[option]}"])

    args.push options['packages'] if options['packages']?

    # flatten nested arrays into args
    args = _.flatten(args)

    log.debug "spacejam args=#{args}"

    return args


if ! process.env.TESTING
  Meteor.startup =>
    practical.Spacejam.get().testInVelocity()
