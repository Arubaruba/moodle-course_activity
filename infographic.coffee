# We use a SVG file generated in illustrator with the D3 library to dynamically render an infographic

fake_courses = [{
  name: 'ENG-114',
  days_past: 60,
  students: [{
    name: 'Andreas Stocker',
    days_active: [1, 2, 6, 20, 33, 34, 40]
  }, {
    name: 'John Smith',
    days_active: [6, 30, 43, 40]
  }]
}]

d3.xml('infographic.svg', 'image/svg+xml',
  (xml) ->
# append the SVG element with all it's configuration and style definitions to the body
    svg = d3.select(xml.documentElement);
    document.body.appendChild(svg.node())

    getTemplate = (name) -> svg.select("##{name}-template").remove()

    # keep the templates stored as variables but remove them from the DOM
    courseBanner = getTemplate('course-banner')
    studentRow = getTemplate('student-row')
      studentRow = svg.select('#student-row-template').remove()
    mark = s

    svg.node().appendChild(courseBanner.node())
)