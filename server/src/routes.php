<?php
// Routes

$app->get('/clef/start', function ($request, $response, $args) {
    $settings = $this->get('settings')->get('clef');

    $state = $this->get('clef')->generate_session_state_parameter();

    $base = $settings['base'];
    $application_id = $settings['id'];

    $redirect_url = urlencode("clefapp://clef/callback?state=$state");
    return $response->withRedirect("$base/iframes/login?app_id=$application_id&redirect_url=$redirect_url");
});

$app->get('/clef/callback', function ($request, $response, $args) {
    $params = $request->getQueryParams();

    if (!(isset($params['state']) && $this->get('clef')->validate_session_state_parameter($params['state']))) {
        $this->logger->error("bad state");
        return $response
            ->withStatus(400)
            ->write('Invalid state parameter');
    }

    $settings = $this->get('settings')->get('clef');
    $api_response = $this->get('clef')->get_login_information($params['code']);
    $result = $api_response["info"];

    if (isset($settings['is_distributed_auth_enabled'])) {
        $payload = [
            "nonce" => bin2hex(openssl_random_pseudo_bytes(16)),
            "clef_id" => $result["id"],
            "redirect_url" => "clefapp://clef/verify",
            "session_id" => $_REQUEST["session_id"],
        ];

        $_SESSION["user_id"] = $result["id"];
        $_SESSION["user_public_key"] = $result["public_key"]["bundle"];
        $_SESSION["clef_payload"] = $payload;
        $_SESSION["logged_in_at"] = time();

        $signed_payload = $this->get('clef')->sign_login_payload($payload);
        $this->logger->info('signed_payload', $signed_payload);
        $encoded_signed_payload = $this->get('clef')->encode_payload($signed_payload);
        $base = $settings["base"];


        return $response->withRedirect("$base/api/v1/validate?payload=$encoded_signed_payload");
    } else {
        # if the app isn't distributed auth enabled, we are good to go and can log
        # the user into the app.
        $data = base64_encode(json_encode($result));
        return $response->withRedirect("message://$data");
    }
});

$app->get('/clef/verify', function($request, $response, $args) {
    $payload_bundle = $this->get('clef')->decode_payload($_GET["payload"], $_SESSION['user_public_key']);
    $this->get('clef')->verify_login_payload($payload_bundle, $_SESSION['user_public_key']);

    $data = base64_encode(json_encode(["id" => $_SESSION["user_id"]]));
    return $response->withRedirect("message://$data");
});
