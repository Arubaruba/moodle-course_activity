# We use a SVG file generated in illustrator with the D3 library to dynamically render an infographic

monthNames = [
  "Jan", "Feb", "Mar",
  "Apr", "May", "Jun", "Jul",
  "Aug", "Sep", "Oct",
  "Nov", "Dec"
]

formatTime = (day) ->
  date = new Date()
  date.setDate(date.getDate() - Math.ceil(day))
  "#{date.getDate()} #{monthNames[date.getMonth()]} '#{date.getFullYear() - 2000}"


d3.json('course_data.php', (courseData) ->
  d3.xml('infographic.svg', 'image/svg+xml',
    (xml) ->
      # append the SVG element with all it's configuration and style definitions to the body
      svg = d3.select(xml.documentElement);
      document.body.appendChild(svg.node())

      # keep the templates stored as variables but remove them from the DOM
      courseBannerTemplate = svg.select("#course-banner-template").remove()
      studentRowTemplate = svg.select("#student-row-template").remove()
      timelineLabelTemplate = svg.select("#timeline-label-template").remove()
      markTemplate = svg.select("#mark-template").remove()
      interactiveSeekerTemplate = svg.select('#interactive-seeker-template').remove()

      markDomain = d3.select('#mark-domain');

      STUDENT_OFFSET_Y = 30
      COURSE_OFFSET_Y = 180
      MARK_DOMAIN_WIDTH = Math.abs(markDomain.attr('x1') - markDomain.attr('x2'))

      totalDocumentHeight = 0 # Keeps track of how far down we've gone

      for course in courseData
        # Create the course layer and move it down depending on how much we've drawn so far
        courseLayer = svg.append('g')
        courseLayer.attr('transform', "matrix(1 0 0 1 0 #{totalDocumentHeight})")
        totalDocumentHeight += COURSE_OFFSET_Y

        # Add the course banner and set the course name
        courseBanner = d3.select(courseLayer.node().appendChild(courseBannerTemplate.node().cloneNode(true)))
        courseBanner.select('#course-name').text(course.name)
        # Add the students
        for student, index in course.students
          # Add the student row and move it down
          studentRow = d3.select(courseLayer.node().appendChild(studentRowTemplate.node().cloneNode(true)))
          .attr('transform', "translate(0 #{index * STUDENT_OFFSET_Y})")
          # Set the student name text
          studentRow.select('#student-name').text(student.name)
          totalDocumentHeight += STUDENT_OFFSET_Y
          # Add activity marks
          for dayActive in student.daysActive when 0 <= dayActive && dayActive <= course.daysPast
            d3.select(studentRow.node().appendChild(markTemplate.node().cloneNode(true)))
            .attr('day_value', dayActive)
            .attr('transform', "translate(#{dayActive / course.daysPast * MARK_DOMAIN_WIDTH} 0)")
            .attr('opacity', 0)
            .transition().delay(800).ease('linear').duration(1200)
            .attr('opacity', 1)

        # Add the timeline labels
        verticalTimelineOffset = STUDENT_OFFSET_Y * (course.students.length - 1)
        createTimelineLabel = (text, day) ->
          timelineLabel = d3.select(courseLayer.node().appendChild(timelineLabelTemplate.node().cloneNode(true)))
          timelineLabel
          .attr('opacity', 0)
          .attr('transform', "translate(#{-MARK_DOMAIN_WIDTH}, #{verticalTimelineOffset})")
          .transition().delay(400).ease('elastic-in-bounce').duration(2000)
          .attr('transform',
            "translate(#{(1 - (day / course.daysPast ) * MARK_DOMAIN_WIDTH)},#{verticalTimelineOffset})")
          .attr('opacity', 1)
          timelineLabel.select('#date-label').text(text)
          timelineLabel.select('#date-value').text(formatTime(day))
          dateLine = timelineLabel.select('#date-line')
          dateLine.attr('y2', dateLine.attr('y2') - verticalTimelineOffset)

        createTimelineLabel('Today', 0)
        createTimelineLabel('Last Week', 7) if 14 < course.daysPast && course.daysPast < 60
        createTimelineLabel('Last Month', 30) if 45 < course.daysPast
        createTimelineLabel('Course Started', course.daysPast)

        # Configure the interactive seeker
        interactiveSeeker = d3.select(courseLayer.node().appendChild(interactiveSeekerTemplate.node().cloneNode(true)))
        interactiveIndicator = interactiveSeeker.select('#interactive-seeker-indicator')
        interactiveTrigger = interactiveSeeker.select('#interactive-trigger')
        interactiveTrigger
        .attr('cursor', 'none')
        .attr('height', STUDENT_OFFSET_Y * (course.students.length + 1))
        .attr('width', 0)
        .attr('opacity', 0)
        .transition().delay(400).ease('cubic-out').duration(1000)
        .attr('width', MARK_DOMAIN_WIDTH)
        .attr('opacity', 1)

        interactiveSeekerLine = interactiveSeeker.select('#seeker-line')
        interactiveSeekerLine.attr('y1', (interactiveSeekerLine.attr('y1') * 1) + verticalTimelineOffset)

        xTriggerOffset = interactiveTrigger.attr('x')

        interactiveTrigger.on('mousemove',
          () ->
            xRelativePosition = d3.mouse(@)[0] - xTriggerOffset

            dayWidth = MARK_DOMAIN_WIDTH / course.daysPast
            day = xRelativePosition / dayWidth

            d3.select(@.parentNode).select('#interactive-seeker-indicator').attr('transform',
              "translate(#{xRelativePosition}, 0)")
            d3.select(@.parentNode).select('#seeker-date').text(formatTime(course.daysPast - day))
            d3.select(@.parentNode.parentNode).selectAll('#mark')
            .attr('stroke-width', () ->
              dayValue = d3.select(@.parentNode).attr('day_value')
              if parseInt(dayValue) == parseInt(day + .5) then 2 else 1
            )
        )

        interactiveIndicator.attr('opacity', 0)
        interactiveTrigger.on('mouseenter',
          () -> d3.select(@.parentNode).select('#interactive-seeker-indicator').transition().duration(200).attr('opacity',
            1))
        interactiveTrigger.on('mouseout',
          () -> d3.select(@.parentNode).select('#interactive-seeker-indicator').transition().duration(200).attr('opacity',
            0))

      # Set the document height
      svg.attr('viewBox', "115 99.7 841.9 #{totalDocumentHeight}")
  )
)
