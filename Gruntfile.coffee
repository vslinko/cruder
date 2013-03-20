module.exports = (grunt) ->
  grunt.initConfig
    simplemocha:
      acceptance:
        src: "test/acceptance/*.coffee"
        options: reporter: process.env.REPORTER or "spec"
      options: ignoreLeaks: true
    coffeelint:
      lib: "crud.coffee"
      test: "test/**/*.coffee"
      grunt: "Gruntfile.coffee"

  grunt.registerTask "default", ["test", "lint"]
  grunt.registerTask "test", ["simplemocha:acceptance"]
  grunt.registerTask "lint", "coffeelint"

  grunt.loadNpmTasks "grunt-simple-mocha"
  grunt.loadNpmTasks "grunt-coffeelint"
