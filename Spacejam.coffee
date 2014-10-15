class Spacejam

  instance = null

  @get: ->
    instance ?= new Spacejam()

  constructor: ->
    Velocity.registerTestingFramework 'tinytest', {}


Spacejam.get()
