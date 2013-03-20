module.exports = (grunt) ->
  grunt.initConfig
    simplemocha:
      unit:
        src: "test/*.coffee"
        options: reporter: process.env.REPORTER or "spec"
      acceptance:
        src: "test/acceptance/*.coffee"
        options: reporter: process.env.REPORTER or "spec"
      options: ignoreLeaks: true
    coffeelint:
      lib: "crud.coffee"
      test: "test/**/*.coffee"
      grunt: "Gruntfile.coffee"

  grunt.registerTask "default", ["test", "lint"]
  grunt.registerTask "test", ["simplemocha:acceptance", "simplemocha:unit"]
  grunt.registerTask "lint", "coffeelint"

  grunt.loadNpmTasks "grunt-simple-mocha"
  grunt.loadNpmTasks "grunt-coffeelint"
