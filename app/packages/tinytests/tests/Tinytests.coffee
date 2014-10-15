Tinytest.add 'passing test', (test)->
  console.log 'passing test'
  test.isTrue true

Tinytest.add 'failing test', (test)->
  console.log 'failing test'
  test.isTrue false, 'failing test message'

Tinytest.add 'throwing test', (test)->
  console.log 'throwing test'
  throw new Error('throwing test message')

Tinytest.addAsync 'async passing test', (test, done)->
  console.log 'async passing test'
  Meteor.defer ->
    test.isTrue true
    done()

Tinytest.addAsync 'async failing test', (test, done)->
  console.log 'async failing test'
  Meteor.defer ->
    test.isTrue false, 'async failing test message'
    done()

Tinytest.addAsync 'async throwing test', (test, done)->
  console.log 'async throwing test'
  Meteor.defer ->
    throw new Error('async throwing test message')
    done()
