Package.describe({
  summary: "tinytests and munit tests to test the spacejamio:tinytest-velocity package"
});

Package.onUse(function (api) {
  api.use(['coffeescript', 'meteor']);
});

Package.onTest(function (api) {
  api.use(['tinytest', 'coffeescript']);

  api.addFiles([
    'tests/Tinytests.coffee']);
});
