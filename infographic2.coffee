###
  This file dynamically generates SVG that looks like it's static counterpart designed in Adobe Illustrator
###

courses = [
  name: 'COMP-203'
  started: 1433116800
  students: [
    name: 'Andreas Stocker'
    activeDays: [0.3, 0.4, 0.5]
  ,
    name: 'John Smith'
    activeDays: [0, 0.2, 1]
  ]
,
  name: 'COMP-204'
  started: 1433116800
  students: [
    name: 'Andreas Stocker'
    activeDays: [0.3, 0.4]
  ,
  ]
]

d3.json('course_data.php', (_courses) ->

  # Arbitrary static values that may be adjusted by preference
  STUDENT_SPACING_Y = 30
  BANNER_SPACE_Y = 70
  COURSE_BOTTOM_MARGIN = 50

  STUDENT_NAME_OFFSET_X = 20
  MARK_AREA_BEGIN_X = 200
  MARK_AREA_WIDTH_X = 600

  # Color Scheme "you are beautiful" by Sanguine @colourlovers.com
  C_BACKGROUND = '#424254'
  C_FILL = '#CC2A41'
  C_TEXT = '#E8CAA4'
  C_TEXT_ALT = '#64908A'
  C_LINES = '#351330'

  # Misc

  # Raw geometry data - Copied from auto generated SVG
  GEOM_ARTBOARD_WIDTH = '841.9'
  GEOM_COURSE_BANNER = '841.9,0 309.7,0 295.6,0 51.8,0 37.7,0 0.5,0 0,29.5 37.7,29.5 51.8,45 295.6,45 309.7,29.5
		841.9,29.5'
  GEOM_COURSE_BANNER_TEXT_POSITION =
    x: 173.6
    y: 22.51
  GEOM_MARK = '-3.6,6.2 -7.2,0 -3.6,-6.2 3.6,-6.2 7.2,0 3.6,6.2'

  # Utility functions
  getCourseOffset = (courseIndex) ->
    courses.slice(0, courseIndex)
    .reduce(((acc, course) -> course.students.length * STUDENT_SPACING_Y + BANNER_SPACE_Y + COURSE_BOTTOM_MARGIN + acc),
      0)

  formatTime = (date) -> "#{date.getDate()} #{monthNames[date.getMonth()]} '#{date.getFullYear() - 2000}"

  daysAgo = (date) -> (new Date() - date) / 24*60*60*1000; # hours*minutes*seconds*milliseconds

  # Set the background color
  d3.select document.body
  .style 'background-color', C_BACKGROUND
  .style 'margin', 0
  .style 'font-family', 'Helvetica'

  # Create the container for all SVG elements
  artboard = d3.select document.body
  .append 'svg'
  .attr 'viewBox', () -> "0 0 #{GEOM_ARTBOARD_WIDTH} #{getCourseOffset(courses.length)}"

  # Add courses
  courseGroups = artboard.selectAll 'g'
  .data courses
  .enter().append 'g'
  .attr 'transform', (course, i) -> "translate(0, #{getCourseOffset(i)})"

  # Course banner
  courseBanner = courseGroups.append 'g'

  courseBanner.append 'polygon'
  .attr 'points', GEOM_COURSE_BANNER
  .style 'fill', C_FILL

  courseBanner.append 'text'
  .attr GEOM_COURSE_BANNER_TEXT_POSITION
  .style 'fill', C_TEXT
  .style 'font-size', '37px'
  .attr 'text-anchor', 'middle'
  .attr 'alignment-baseline', 'central'
  .text (course) -> course.name

  # Student List
  studentGroups = courseGroups.append('g').selectAll 'g'
  .data (course) -> course.students
  .enter().append 'g'
  .attr 'transform', (student, i) -> "translate(0, #{STUDENT_SPACING_Y * i + BANNER_SPACE_Y})"

  studentGroups.append 'line'
  .attr(
    x1: 0
    x2: GEOM_ARTBOARD_WIDTH
  )
  .style (
    'stroke': C_LINES
    'stroke-width': '0.3'
  )

  studentGroups.append('g').selectAll 'polygon'
  .data (student) -> student.activeDays
  .enter().append 'polygon'
  .attr 'transform', (activeDay) -> "translate(#{activeDay * MARK_AREA_WIDTH_X + MARK_AREA_BEGIN_X}, 0)"
  .attr 'points', GEOM_MARK
  .style 'fill', C_FILL
  .style 'stroke', C_LINES

  studentGroups.append 'text'
  .attr 'x', STUDENT_NAME_OFFSET_X
  .style 'fill', C_TEXT
  .style 'font-size', '12px'
  .attr 'alignment-baseline', 'central'
  .text (student) -> student.name

  # Labels
  courseGroups.append('g').selectAll 'line'
  .data (course) ->
    daysSinceStart = daysAgo course.started
    [
      text: 'Course Started'
      daysAgo: daysSinceStart
    ,
      text: 'Today'
      daysAgo: 0
    ,
      text: 'Last Week'
      daysAgo: 7
      show: 14 <= daysSinceStart <= 60
    ,
      text: 'Last Month'
      daysAgo: 30
      show: 45 <= daysSinceStart
    ].filter (label) -> label.show != false
  .attr 'transform', () -> "translate()"
)