spacejamExports = Npm.require('spacejam')
Spacejam = spacejamExports.Spacejam
path = Npm.require('path')


class PackagesTester

  instance = null

  spacejam: null

  @get: ->
    instance ?= new PackagesTester()

  constructor: ->
    log.debug 'PackagesTester.constructor()'
    @spacejam = new Spacejam()
    Velocity.registerTestingFramework 'tinytest', {}
    Meteor.startup =>
      @testInVelocity()


  testInVelocity: ->
    log.debug 'PackagesTester.testInVelocity()'
    appDir = PackagesTester.getMeteorAppFolder()
    options = {dir: appDir}
    packagesToTest = Meteor.settings?.packages?.spacejamio?["tinytest-velocity"]?.packagesToTest || []
    if packagesToTest.length > 0
      expect(packagesToTest).to.be.an 'array'
      options._ = packagesToTest
    # Setting this to avoid running this package's tests during testInVelocity
    process.env.TEST_IN_VELOCITY = true
    @spacejam.testInVelocity({dir: appDir})


  # TODO: refactor to just look for .meteor in cwd
  @getMeteorAppFolder: ->
    log.debug 'PackagesTester.getMeteorAppFolder()'
    dir = process.cwd()
    appFolderEnd = dir.lastIndexOf('/.meteor/')
    if appFolderEnd is -1
      throw new Error("spacejamio:tinytest-velocity - cannot find parent meteor app folder in #{process.cwd()}")
    appFolder = dir.slice(0, appFolderEnd)
    log.debug "appFolder='#{appFolder}'"
    return appFolder


if ! process.env.TESTING
  PackagesTester.get()
