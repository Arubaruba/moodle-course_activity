<?php

header('Content-Type', 'application/json');

$course_data = [
  [
    'name' => 'ENG-114',
    'daysPast' => 59,
    'students' => [
      [
        'name' => 'Andreas Stocker',
        'daysActive' => [1,2,4,5,20]
      ]
    ]
  ]
];

echo json_encode($course_data);
