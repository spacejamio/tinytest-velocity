Npm.depends({
  'spacejam': '1.1.0-rc9'
});

Package.describe({
  name: "spacejamio:tinytest-velocity",
  summary: "Runs your tinytest and munit package tests with your app and reports the results to velocity.",
  git: "https://github.com/spacejamio/tinytest-velocity.git",
  version: '0.1.0'
});


Package.onUse(function (api) {
  // XXX this should go away, and there should be a clean interface
  // that tinytest and the driver both implement?
  api.use('meteor');
  api.use('underscore');
  api.use('coffeescript');

  api.use(['velocity:core', 'velocity:shim']);

  api.use(['spacejamio:loglevel@1.1.0_2', 'spacejamio:chai']);

  api.imply('velocity:html-reporter', 'client');

  api.addFiles([
    'src/server/log.js',
    'src/server/Pipe.coffee',
    'src/server/ChildProcessFactory.coffee',
    'src/server/Spacejam.coffee'], 'server');

  api.export('TestPackages', 'server');
});


Package.onTest(function (api) {
  // XXX this should go away, and there should be a clean interface
  // that tinytest and the driver both implement?
  api.use(['coffeescript', 'spacejamio:tinytest-velocity', 'spacejamio:loglevel', 'spacejamio:munit']);

  api.addFiles('tests/server/SpacejamTest.coffee', 'server');
});
