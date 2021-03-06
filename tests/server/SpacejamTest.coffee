if ! process.env.TEST_IN_VELOCITY
  path = Npm.require('path')
  fs = Npm.require('fs')

  Spacejam = practical.Spacejam

  log = loglevel.createLogger("SpacejamTest", 'trace')
  log.debug "Test logger created"

  describe 'Spacejam', ->

    spacejam = null

    spawnStub = null

    appPath = null

    beforeAll ->
      appPath = practical.ChildProcessFactory.get().getMeteorAppPath()

    beforeEach ->
      delete Meteor.settings?.packages?.practicalmeteor?["tinytest-velocity"]?.spacejamOptions
      stubs.restoreAll()
      spies.restoreAll()
      spawnStub?.restore() if spawnStub?.restore?
      spawnStub = sinon.stub()
      spawnStub.returns {
        pid: 60000
        on: ->
        stdout:
          setEncoding: ->
          on: ->
        stderr:
          setEncoding: ->
          on: ->
      }

      practical.ChildProcessFactory._spawn = spawnStub

    afterEach ->
      stubs.restoreAll()
      spies.restoreAll()
      spawnStub?.restore() if spawnStub?.restore?

    afterAll ->
      stubs.restoreAll()
      spies.restoreAll()
      spawnStub?.restore() if spawnStub?.restore?

    it 'getSpacejamPath should return the path to spacjam in .meteor/local', ()->
      spacejamPath = Spacejam.getSpacejamPath(appPath)
      expect(fs.existsSync(spacejamPath)).to.be.true


    describe 'getSpawnArgs', ->
      it 'should have only a test-in-velocity argument, if no options are specified', ()->
        args = Spacejam.getSpawnArgs()
        expect(args).to.deep.equal ['test-in-velocity']

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
        args = Spacejam.getSpawnArgs()
        expect(args).to.deep.equal ['test-in-velocity', '--production', 'true', '--release', '0.9.4', "--root-url", "http://myym:3000/", 'pkg1', 'pkg2']

    describe 'testInVelocity', ->

      it 'should call spawn with the correct arguments', ->
        log.debug 'testing spawn'
        spacejam = new Spacejam()
        spacejam.testInVelocity()

        appPath = practical.ChildProcessFactory.get().getMeteorAppPath()
        log.debug "appPath=#{appPath}"
        fout = practical.ChildProcessFactory.get().fout
        expectedSpawnOptions =
          cwd: appPath
          env: process.env,
          detached: true,
          stdio: [ 'ignore', fout, fout ]

        expect(spawnStub).to.have.been.calledWithExactly Spacejam.getSpacejamPath(appPath),
          Spacejam.getSpawnArgs(), expectedSpawnOptions


      it 'should not call spawn if spacejam is already running', ->
        delete practical.ChildProcessFactory.get().child
        fs.writeFileSync(practical.ChildProcessFactory.get().pidDirPath + '/spacejam.pid', "#{process.pid}")
        spacejam = new Spacejam()
        spacejam.testInVelocity()
        expect(spawnStub).to.have.not.been.called
