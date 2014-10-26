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
    process.on 'exit', (code)=>
      log.debug "Spacejam.process.on 'exit', code=#{code}"
      @exiting = true
      log.info "meteor app is exiting, killing spacejam"
      @spacejamChild?.kill()

    process.once 'SIGINT', =>
      log.debug "Spacejam.process.on 'SIGINT'"
      @exiting = true
      log.info "meteor app is exiting, killing spacejam"
      @spacejamChild?.kill()
      process.kill(process.pid, 'SIGINT')

    @spacejamChild = new practical.ChildProcess()
    Velocity.registerTestingFramework 'tinytest', {}


  isRunning: (pidPath)->
    log.debug 'Spacejam.isRunning()', pidPath
    pidPath = Spacejam.getPidPath(Spacejam.getMeteorAppPath()) if not pidPath
    expect(pidPath).to.be.a('string').that.has.length.above(0)

    return false if not fs.existsSync(pidPath)

    pid = +fs.readFileSync(pidPath)
    log.debug "Found pid file #{pidPath} with pid #{pid}, checking if spacejam is running."
    try
      # Check for the existence of the process without killing it, by sending signal 0.
      process.kill(pid, 0)
      # process is alive, otherwise an exception would have been thrown, so we need to exit.
      log.debug "Process with pid #{pidPath} is already running, will not launch spacejam again."
      return true
    catch err
      log.trace err
      log.warn "pid file #{pidPath} exists, but process is dead, will launch spacejam again."
      return false


  testInVelocity: ->
    log.debug 'Spacejam.testInVelocity()'
    # Setting this to avoid running this package's tests during spacejamChildTestInVelocity
    process.env.TEST_IN_VELOCITY = true
    appPath = Spacejam.getMeteorAppPath()
    pidPath = Spacejam.getPidPath(appPath)
    if @isRunning(pidPath)
      log.debug "spacjam is already running."
      return
    spacejamPath = Spacejam.getSpacejamPath(appPath)
    spawnArgs = Spacejam.getSpawnArgs(appPath)
    spawnOptions = Spacejam.getSpawnOptions(appPath)
    log.info 'Spawning spacejam to launch meteor test-packages and run your package tests in phantomjs'
    @spacejamChild.spawn(spacejamPath, spawnArgs, spawnOptions)

    @spacejamChild.child.on "exit", (code, signal) =>
      log.error "Error: spacejam exited unexpectedly, you will need to restart your app to run your package tests again.\nIf the problem persists, please create a package issue on github.\nAdditional info: exit code #{code}, exit signal #{signal}" if not @exiting


  @getMeteorAppPath: ->
    log.debug 'Spacejam.getMeteorAppPath()'
    dir = process.cwd()
    appPathEnd = dir.lastIndexOf('/.meteor/')
    if appPathEnd is -1
      throw new Error("spacejamChildio:tinytest-velocity - cannot find parent meteor app folder in #{process.cwd()}")
    appPath = dir.slice(0, appPathEnd)
    log.debug "appFolder='#{appPath}'"
    return appPath


  @getPidPath: (appPath)->
    log.debug 'Spacejam.getPidPath()', appPath
    appPath = Spacejam.getMeteorAppPath() if not appPath?
    expect(appPath).to.be.a('string').that.is.ok
    pidPath = path.resolve(appPath, '.meteor/local/spacejam.pid')
    log.debug 'pidPath=#{pidPath}'
    return pidPath


  @getSpacejamPath: (appPath)->
    log.debug 'Spacejam.getSpacejamPath()', appPath
    appPath = Spacejam.getMeteorAppPath() if not appPath?
    expect(appPath).to.be.a('string').that.is.ok
    spacejamRelativePath = '.meteor/local/build/programs/server/npm/spacejamio:tinytest-velocity/node_modules/spacejam/bin/spacejam'
    spacejamPath = path.resolve(appPath, spacejamRelativePath)
    return spacejamPath if fs.existsSync(spacejamPath)
    log.debug "spacejam doesn't exists under current folder, checking if METEOR_APP_PATH is set."
    # If we didn't find it, we are probably in meteor test-packages
    # Let's see if METEOR_APP_PATH is set
    if process.env.METEOR_APP_PATH
      spacejamPath = path.resolve(process.env.METEOR_APP_PATH, spacejamRelativePath)
      return spacejamPath if fs.existsSync(spacejamPath)
    throw new Error "Could not find the spacejam npm package in .meteor/local. If you are running meteor test-packages, set METEOR_APP_PATH to your meteor app's root folder."


  @getSpawnArgs: (appPath)->
    log.debug 'Spacejam.getSpawnArgs()', appPath
    appPath = Spacejam.getMeteorAppPath() if not appPath?
    expect(appPath).to.be.a('string').that.is.ok
    options = Meteor.settings?.packages?.practicalmeteor?["tinytest-velocity"]?.spacejamOptions || {}
    log.debug "Spacejam.getSpawnArgs() spacejamOptions=", options

    pidPath = Spacejam.getPidPath(appPath)

    args = ['test-in-velocity', '--pid-file', "#{pidPath}"]

    for option of options
      if option isnt 'packages'
        args.push(["--#{option}", "#{options[option]}"])

    args.push options['packages'] if options['packages']?

    # flatten nested arrays into args
    args = _.flatten(args)

    log.debug "spacejam args=#{args}"

    return args


  @getSpawnOptions: (appPath)->
    log.debug 'Spacejam.getSpawnOptions()', appPath
    appPath = Spacejam.getMeteorAppPath() if not appPath?
    expect(appPath).to.be.a('string').that.is.ok
    expect(fs.existsSync(appPath), "provided meteor app folder doesn't exist").to.be.true

    out = fs.openSync('/tmp/spacejam.log', 'a')
    err = fs.openSync('/tmp/spacejam.log', 'a')

    options = {
      cwd: appPath,
      env: process.env,
      detached: true,
      stdio: [ 'ignore', out, err ]
    }


if ! process.env.TESTING
  Meteor.startup =>
    practical.Spacejam.get().testInVelocity()
