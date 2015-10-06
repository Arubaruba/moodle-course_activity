<?php

namespace report_course_activity;

$fake_data = [
  'COMP-114' => [
    'started' => 1444088965,
    'days' => 60,
    'enrolled_users' => [
      'Andreas Stocker' => [1, 10, 32],
      'John Smith' => [0, 33, 38, 40, 50],
      'Dude1' => [],
      'Dude2' => [],
      'Dude3' => [],
    ],
  ],
  'COMP-214' => [
    'days' => 79,
    'enrolled_users' => [
      'John Smith' => [0, 1,2,3, 33, 38, 40, 50],
      'Dude3' => []
    ]
  ]
];

// Setup the DOM and the querying mechanism
$xml = new \DOMDocument();
$xml->loadXML(file_get_contents('./infographic.svg'));
$xpath = new \DOMXPath($xml);

$mark_area = $xpath->query('//*[@id="mark-area"]')->item(0);
$STUDENT_SPACING = 30;
$COURSE_TITLE_SPACING = 160;
$MARK_AREA_WIDTH = abs($mark_area->getAttribute('x1') - $mark_area->getAttribute('x2'));

$course_template = $xpath->query('//*[@id="course-template"]')->item(0);
$course_vertical_incrementor = 0;
foreach ($fake_data as $course_name => $course_data) {
  $course_node = $course_template->parentNode->appendChild($course_template->cloneNode(true));
  $course_node->setAttribute("transform", "matrix(1 0 0 1 0 $course_vertical_incrementor)");
  $xpath->query('.//*[@id="course-name-label"]', $course_node)->item(0)->nodeValue = $course_name;

  // Add the students
  $vertical_incrementor = 0; // Keep track how far we have moved down the list
  $student_template = $xpath->query('.//*[@id="student-template"]', $course_node)->item(0);

  foreach ($course_data['enrolled_users'] as $student => $active_days) {
    $student_node = $student_template->parentNode->appendChild($student_template->cloneNode(true));

    // Move the student line down
    $student_node->setAttribute("transform", "matrix(1 0 0 1 0 $vertical_incrementor)");
    $vertical_incrementor += $STUDENT_SPACING;

    $xpath->query('*[@id="name"]', $student_node)->item(0)->nodeValue = $student;

    // Add the activity marks
    $mark_template = $xpath->query('.//*[@id="mark"]', $student_node)->item(0);
    foreach ($active_days as $day) {
      $mark_node = $mark_template->parentNode->appendChild($mark_template->cloneNode(true));
      $x_offset = (1 - $day / $course_data['days']) * $MARK_AREA_WIDTH;
      $mark_node->setAttribute("transform", "matrix(1 0 0 1 $x_offset 0)");
    }
    $mark_template->parentNode->removeChild($mark_template);
  }
  $course_vertical_incrementor += $vertical_incrementor + $COURSE_TITLE_SPACING;
  $student_template->parentNode->removeChild($student_template);

  // Set the position of the date labels
  $date_line_template = $xpath->query('.//*[@id="date-line"]', $course_node)->item(0);
  $date_line_template->setAttribute('y2', $date_line_template->getAttribute('y1') - $vertical_incrementor);
  $timeline_label_template = $xpath->query('.//*[@id="timeline-label-template"]', $course_node)->item(0);
  $timeline_label_vertical_offset = $vertical_incrementor - $STUDENT_SPACING;
  $timeline_label_template->setAttribute('transform', "matrix(1 0 0 1 0 $timeline_label_vertical_offset)");

  $timeline_labels = [
    'Course Started' => $course_data['days'],
    'Last Month' => ($course_data['days'] > 40) ? 30 : null,
    'Last Week' => (10 < $course_data['days'] && $course_data['days'] < 80) ? 7 : null,
    'Today' => 0
  ];

  foreach ($timeline_labels as $label => $days_passed) {
    if ($days_passed !== null) {
      $timeline_label = $timeline_label_template->parentNode->appendChild($timeline_label_template->cloneNode(true));
      $timeline_label_horizontal_position = ($days_passed / $course_data['days']) * $MARK_AREA_WIDTH;
      $timeline_label->setAttribute('transform', "matrix(1 0 0 1 -$timeline_label_horizontal_position $timeline_label_vertical_offset)");
      $xpath->query('.//*[@id="date-label"]', $timeline_label)->item(0)->nodeValue = $label;
      $date = (new \DateTime())->sub(new \DateInterval('P' . floor($days_passed) . 'D'));
      $xpath->query('.//*[@id="date-value"]', $timeline_label)->item(0)->nodeValue = date_format($date, 'd M \'y');
    }
  }

  $timeline_label_template->parentNode->removeChild($timeline_label_template);
}
$course_vertical_incrementor += $STUDENT_SPACING;
$course_template->parentNode->removeChild($course_template);

// Set the height of the document
header('Content-Type: image/svg+xml');
$xpath->query('//*[@id="background"]')->item(0)->setAttribute('height', $course_vertical_incrementor);
$svg = $xpath->query('//*[@viewBox]')->item(0);
$svg->setAttribute('viewBox', "0 0 841.89 $course_vertical_incrementor");
$svg->setAttribute('style', "enable-background:new 0 0 841.89 $course_vertical_incrementor");

echo $xml->saveXML();

