spacejamExports = Npm.require('spacejam')
log.info spacejamExports

class SpacejamRunner

  instance = null

  spacejam: null

  @get: ->
    instance ?= new SpacejamRunner()

  constructor: ->
    spacejam = new Spacejam()
    Velocity.registerTestingFramework 'tinytest', {}
    Meteor.startup =>
      @testInVelocity()


  testInVelocity: ->
    spacejam.testInVelocity()


SpacejamRunner.get()
