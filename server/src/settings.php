<?php

$CLEF_BASE = isset($_ENV['CLEF_BASE']) ? $_ENV['CLEF_BASE'] : 'https://clef.io';

return [
    'settings' => [
        'displayErrorDetails' => true, // set to false in production

        // Renderer settings
        'renderer' => [
            'template_path' => __DIR__ . '/../templates/',
        ],

        // Monolog settings
        'logger' => [
            'name' => 'slim-app',
            'path' => __DIR__ . '/../logs/app.log',
        ],

        'clef' => [
            'id' => '23b52dc4cecf8b75044685c2bc328c3e',
            'secret' => $_ENV['CLEF_APPLICATION_SECRET'],
            'base' => $CLEF_BASE,
            'api_base' => $CLEF_BASE . '/api'
        ]
    ],
];
