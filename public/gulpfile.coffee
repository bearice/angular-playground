gulp = require 'gulp'
concat = require 'gulp-concat'
coffee = require 'gulp-coffee'
uglify = require 'gulp-uglify'
sourcemaps = require 'gulp-sourcemaps'
ngAnnotate = require 'gulp-ng-annotate'

gulp.task 'app.js', ->
  gulp.src(['scripts/main.coffee', 'scripts/**/*.coffee'])
    .pipe(sourcemaps.init())
      .pipe(coffee())
      .pipe(ngAnnotate())
      .pipe(concat('app.js'))
      .pipe(uglify())
    .pipe(sourcemaps.write('.'))
    .pipe(gulp.dest('.'))

