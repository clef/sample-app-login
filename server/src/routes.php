<?php
// Routes

$app->get('/clef/start', function ($request, $response, $args) {
    $settings = $this->get('settings')->get('clef');

    $state = $this->get('clef')->generate_session_state_parameter();

    $base = $settings['base'];
    $application_id = $settings['id'];

    return $response->withRedirect("$base/iframes/login?app_id=$application_id&redirect_url=clefapp://clef/callback&state=$state");
});

$app->get('/clef/callback', function ($request, $response, $args) {
    $params = $request->getQueryParams();

    if (!(isset($params['state']) && $this->get('clef')->validate_session_state_parameter($params['state']))) {
        $this->logger->error("bad state");
        return $response
            ->withBody('Invalid state parameter')
            ->withStatus(400);
    }

    $api_response = $this->get('clef')->get_login_information($params['code']);
    $data = base64_encode(json_encode($api_response['info']));

    return $response->withRedirect("message://$data");
});
