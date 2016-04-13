# Clef app login sample

This repository has a sample server and iOS application that demonstrate how to add login with Clef to an app.

## Overview

Login with Clef in your iOS application works similarly to Login with Clef on the web, except all requests are proxied through a custom URL scheme. The overview of the flow is this:

1. _iOS application_ opens a hidden `UIWebView` which points to a route on the _Server_ that starts the Clef authentication process
2. _Server_ generates a `state` variable and redirects to `https://clef.io/iframes/login` with `app_id`, `state`, and `redirect_url`
3. The user authenticates in the _Clef_ app and is then redirected back to `redirect_url` which is a custom URL scheme that opens _iOS Application_
4. _iOS application_ handles the custom URL scheme and redirects the hidden `UIWebView` to it's callback URL with the `state` and `code` provided by the _Clef_ app
5. _Server_ verified `state`, completes the OAuth handshake with the `code`, then passes the verified user information back through the `UIWebView` to the _iOS Application_
6. _iOS application_ uses the user information passed back to log the user in

In this example, we just pass back the `clef_id`, but for a real application this should be replaced with the authentication token necessary to authenticate the app for future web requests.

_*Warning*: do not implement the OAuth handshake in your iOS application code. To do this would require compiling your Clef application secret into your iOS app, essentially making it public. By handling all authentication logic in a `UIWebView` on the server, we don't leak configuration or secrets into the client._

## Setup

### Configuring your Clef integration

To allow login with Clef to work in your app, you'll need to add a custom URL scheme to both your application and the Clef integration Application Domain. For this sample, we've already added the `clefapp://` custom URL scheme, so all you need to do is add this to your Integration Application Domain at getclef.com. Follow these steps to do that:

1. Log in to [getclef.com](getclef.com/user/login)
2. Create a new integration (or navigate to an old one)
3. Go to the Domain settings section
4. Add `clefapp://clef` to the Application Domain settings

### Running the sample

#### iOS Application

For the iOS application, you'll need to open [ios/app-login.xcodeproj](ios/app-login.xcodeproj) in Xcode. Once you've opened the project, you should be able to run it.

#### Server

For the server, you'll need to install the dependencies and start it. If you don't already have it on your computer, you'll need to [download and install Composer](https://getcomposer.org/doc/00-intro.md) from their website. We use Composer to manage the dependencies for the server application.

To start the server, run these commands:

```shell
$ cd server
$ composer install
$ php -S localhost:8080 -t ./public/
```

## Support

If you're working through an integration and have an issue, email us at [support@getclef.com](mailto:support@getclef.com) and we'll help you out.
