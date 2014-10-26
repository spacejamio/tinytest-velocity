if ! process.env.TEST_IN_VELOCITY
  path = Npm.require('path')
  fs = Npm.require('fs')

  TestPackages = practical.Spacejam

  describe 'TestPackages', ->

    spacejam = null

    spawnStub = null

    beforeEach ->
      delete Meteor.settings?.packages?.practicalmeteor?["tinytest-velocity"]?.spacejamOptions
      stubs.restoreAll()
      spies.restoreAll()
      spawnStub?.restore() if spawnStub?.restore?
      spawnStub = sinon.stub()
      spawnStub.returns {
        on: ->
        stdout:
          setEncoding: ->
          on: ->
        stderr:
          setEncoding: ->
          on: ->
      }

      practical.ChildProcess._spawn = spawnStub

    afterEach ->
      stubs.restoreAll()
      spies.restoreAll()
      spawnStub?.restore() if spawnStub?.restore?

    afterAll ->
      stubs.restoreAll()
      spies.restoreAll()
      spawnStub?.restore() if spawnStub?.restore?

    describe 'getMeteorAppPath', ->
      it 'should get the meteor app folder', ()->
        dir = TestPackages.getMeteorAppPath()
        expect(fs.existsSync(dir)).to.be.true
        expect(fs.existsSync(dir + '/.meteor')).to.be.true

    it 'getSpacejamPath() should return the path to spacjam in .meteor/local', ()->
      appPath = TestPackages.getMeteorAppPath()
      spacejamPath = TestPackages.getSpacejamPath(appPath)
      expect(fs.existsSync(spacejamPath)).to.be.true


    describe 'getSpawnArgs', ->
      it 'should have only a test-in-velocity argument, if no options are specified', ()->
        args = TestPackages.getSpawnArgs()
        expect(args).to.deep.equal ['test-in-velocity', '--pid-file', TestPackages.getPidPath()]

      it 'should include all options from Meteor.settings', ()->
        spacejamOptions =
          packages: ['pkg1', 'pkg2']
          production: true
          release: '0.9.4'
          "root-url": "http://myym:3000/"

        packageSettings =
          packages:
            practicalmeteor:
              "tinytest-velocity":
                spacejamOptions: spacejamOptions

        Meteor.settings = {} if not Meteor.settings?

        _.extend Meteor.settings, packageSettings
        args = TestPackages.getSpawnArgs()
        expect(args).to.deep.equal ['test-in-velocity', '--pid-file', TestPackages.getPidPath(), '--production', 'true', '--release', '0.9.4', "--root-url", "http://myym:3000/", 'pkg1', 'pkg2']

    it 'getSpawnOptions() should return the correct spawn options', ()->
      appPath = TestPackages.getMeteorAppPath()
      spawnOptions = TestPackages.getSpawnOptions(appPath)
      expectedSpawnOptions =
        cwd: appPath
        env: process.env
        detached: false

      expect(spawnOptions).to.deep.equal expectedSpawnOptions

    describe 'testInVelocity', ->

      it 'should call spawn with the correct arguments', ->

        spacejam = new TestPackages()
        spacejam.testInVelocity()
        appPath = TestPackages.getMeteorAppPath()
        expect(spawnStub).to.have.been.calledWithExactly TestPackages.getSpacejamPath(appPath),
          TestPackages.getSpawnArgs(appPath), TestPackages.getSpawnOptions(appPath)


    describe 'testInVelocity', ->

      it 'should not call spawn if spacejam is already running', ->
        fs.writeFileSync(TestPackages.getPidPath(), "#{process.pid}")
        spacejam = new TestPackages()
        spacejam.testInVelocity()
        appPath = TestPackages.getMeteorAppPath()
        expect(spawnStub).to.have.not.been.called
