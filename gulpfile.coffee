#
# Gulpfile with:
#
# - Slim
# - Sass
# - Lint
# - Browsersync
# - CSS and HTML compression
#
# Install dependencies:
#
#   $ npm install gulp gulp-concat gulp-uglify event-stream gulp-coffee gulp-sass gulp-cssmin gulp-coffee gulp-coffeelint browser-sync gulp-util gulp-shell
#
# Then start developing:
#
#   $ gulp
#
gulp        = require 'gulp'
concat      = require 'gulp-concat'
es          = require('event-stream')
sass        = require 'gulp-sass'
uglify      = require 'gulp-uglify'
streamqueue = require 'streamqueue' # Preserves file order (vendor...)
coffee      = require 'gulp-coffee'
gutil       = require 'gulp-util'
shell       = require 'gulp-shell'
cssmin      = require 'gulp-cssmin'
coffeelint  = require 'gulp-coffeelint'
browserSync = require 'browser-sync'

isProd = gutil.env.type is 'prod'

sources =
  sass: 'src/css/main.scss'
  watchscss: 'src/css/**/*.scss'
  css: 'src/css/**/*.css'
  html: 'src/**/*.html'
  js: 'src/js/**/*.js'
  coffee: 'src/js/**/*.coffee'
  images: 'src/images/**/*.{png,jpg,svg,gif}'

targets =
  css: 'www/css'
  html: 'www/'
  js: 'www/js'
  images: 'www/images'

# Check for errors
gulp.task 'lint', ->
  gulp.src(sources.js)
    .pipe(coffeelint())
    .pipe(coffeelint.reporter())

# Compile Coffeescript
gulp.task 'js', ->
  stream = streamqueue(objectMode: true)
  # Vendor files
  stream.queue(gulp.src(sources.js))
  # App files use Coffee
  stream.queue(gulp.src(sources.coffee).pipe(coffee(bare:true, onError: browserSync.notify)))
  stream.done()
    .pipe(concat("all.js"))
    .pipe(if isProd then uglify(onError: gutil.log) else gutil.noop())
    .pipe(gulp.dest(targets.js))
    .pipe(browserSync.reload({stream: true}))

# Copy HTML
gulp.task 'html', ->
  gulp.src(sources.html)
    .pipe(gulp.dest(targets.html))

# Copy images
gulp.task 'images', ->
  gulp.src(sources.images)
    .pipe(gulp.dest(targets.images))

# Compile CSS
gulp.task 'css', ->
  stream = streamqueue(objectMode: true)
  # Vendor files
  stream.queue(gulp.src(sources.css))
  # App files
  stream.queue(gulp.src(sources.sass).pipe(sass({ 
    style: 'expanded', 
    onError: browserSync.notify 
  }))
  .pipe(autoprefix({
      browsers: ['last 2 versions'],
      cascade: false
  })))
  stream.done()
    .pipe(concat("all.css"))
    .pipe(if isProd then cssmin(onError: gutil.log) else gutil.noop())
    .pipe(gulp.dest(targets.css))
    .pipe(browserSync.reload({stream: true}))

# Reload browser
gulp.task 'server', ->
  browserSync(
    open: true
    server:
      baseDir: targets.html
    reloadDelay: 2000 # Prevent white screen of death
    watchOptions:
      debounceDelay: 1000
  )

# Watch files for changes
gulp.task 'watch', ->
  gulp.watch sources.coffee, ['js']
  gulp.watch sources.js, ['js']
  gulp.watch sources.css, ['css']
  gulp.watch sources.watchscss, ['css']
  gulp.watch sources.html, ['html']
  gulp.watch sources.images, ['images']
  gulp.watch 'www/**/*.html', (file) ->
    browserSync.reload(file.path) if file.type is "changed"

# Build everything
gulp.task 'build', ['lint', 'js', 'css', 'html', 'images']

# Start a server and watch for file changes
gulp.task 'default', ['watch', 'server']
