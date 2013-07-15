module.exports = (grunt) ->
  grunt.initConfig
    simplemocha:
      example: "test/example.coffee"
      coverage: src: "test/*.coffee", options: reporter: "travis-cov"
      coveralls: src: "test/*.coffee", options: reporter: "mocha-lcov-reporter"
      options: reporter: process.env.REPORTER or "spec"
    coffeelint:
      example: "example/**/*.coffee"
      lib: "lib/**/*.coffee"
      test: "test/**/*.coffee"
      grunt: "Gruntfile.coffee"
    coffeeCoverage: lib: src: "lib", dest: "lib", options: path: "relative"
    clean: coffeeCoverage: "lib/**/*.js"

  grunt.loadNpmTasks "grunt-simple-mocha"
  grunt.loadNpmTasks "grunt-coffeelint"
  grunt.loadNpmTasks "grunt-coffee-coverage"
  grunt.loadNpmTasks "grunt-contrib-clean"

  grunt.registerTask "default", [
    "coffeeCoverage:lib"
    "simplemocha:example"
    "clean:coffeeCoverage"
    "coffeelint"
    "simplemocha:coverage"
  ]

  grunt.registerTask "coveralls", [
    "coffeeCoverage:lib"
    "simplemocha:coveralls"
    "clean:coffeeCoverage"
  ]
