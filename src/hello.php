<?php

function hello(array $eventData): array
{
    static $i = 0;
    $i++;

    static $created = null;
    if ($created === null) {
        $created = date('Y-m-d H:i:s');
    }

    $response = [];
    $response["isBase64Encoded"] = false;
    $response["statusCode"] = 200;
    $response["headers"] = ['Content-type' => 'application/json'];
    $response["body"] = json_encode([$i, $created, $eventData]);

    return $response;
}
