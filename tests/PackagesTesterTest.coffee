if ! process.env.TEST_IN_VELOCITY
  path = Npm.require('path')
  fs = Npm.require('fs')

  #Tinytest.addAsync 'getMeteorAppFolder()', (test, done)->
  #  dir = SpacejamRunner.getMeteorAppFolder()
  #  cb = (res)=>
  #
  #    test.isTrue res, dir
  #    done() if path.basename(dir) is '.meteor'
  #  fs.exists(dir, cb)
  #  dir += '/.meteor'
  #  fs.exists(dir, cb)

  describe 'PackagesTester', ->
    describe 'getMeteorAppFolder()', ->
      it 'should get the meteor app folder', ()->
        dir = PackagesTester.getMeteorAppFolder()
        expect(fs.existsSync(dir)).to.be.true
        expect(fs.existsSync(dir + '/.meteor')).to.be.true
