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

For the iOS application, you'll need to open [ios/app-login.xcodeproj](ios/app-login.xcodeproj) in Xcode. 

Once you've opened the project, you'll need to configure your app to support the custom URL scheme you added to your Integration Application Domain settings above. To do this, add the following XML to your `Info.plist`.

```xml
<key>CFBundleURLTypes</key>
<array>
        <dict>
                <key>CFBundleURLSchemes</key>
                <array>
                        <string>clefapp</string>
                </array>
        </dict>
</array>
```

After you've added that configuration, you should be able to run your app and do the full login.

#### Server

For the server, you'll need to install the dependencies and start it. If you don't already have it on your computer, you'll need to [download and install Composer](https://getcomposer.org/doc/00-intro.md) from their website. We use Composer to manage the dependencies for the server application.

To start the server, run these commands:

```shell
$ cd server
$ composer install
$ php -S localhost:8080 -t ./public/
```

# Using Clef.swift

`Clef.swift` is a library that makes doing Clef authentication in an iOS app easy. To use it, you'll need to do follow these steps.

## Setup your iOS app and Clef integration

Add a custom URL scheme to your app and Integration Application Domain like `example://clef` as described above.

## Configure

Configure `Clef.swift` in the `didFinishLaunchingWithOptions` method on your `AppDelegate`.

```swift
func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    Clef.sharedInstance.configure(
        startURL: NSURL(string: "http://localhost:8080/clef/start")!, // URL where you will initiate the Clef OAuth handshake on the server
        callbackURL: NSURL(string: "http://localhost:8080/clef/callback")!, // URL where you will handle the Clef OAuth callback on the server
        verifyURL: NSURL(string: "http://localhost:8080/clef/verify")! // (optional) URL where you handle Clef Distributed Auth verify callback on the server
    )
    return true
}
```

## Handle Custom URL Schemes

Next, you need to register the custom URL scheme handler. Do this in the `openURL` method on your `AppDelegate`.

```swift
func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
    Clef.sharedInstance.handleDeepLink(openURL: url, sourceApplication: sourceApplication, annotation: annotation)
    return true
}
```

## Start the authentication flow

To start the Clef authentication flow, you will need to call `Clef.sharedInstance.startAuthentication`. You should do this in a IBAction from a button "Log in with Clef" button.

```swift
@IBAction func onClefButtonTap(sender: UIButton) {
    Clef.sharedInstance.startAuthentication(
        self.view, // UIView that an invisible WKWebView can be inserted into. Use the UIView your button is in.
        onSuccess: self.handleClefAuthenticationSuccess // Function that is called when a user successfully authenticates on your server.
    )
}
```

## Setup your server

On the server, you can reuse much of your web OAuth and Distributed Auth handshake. There are a few mobile-specific tweaks you'll need to make.

### Setup a `startURL`

You can see an example of this [here](https://github.com/clef/sample-app-login/blob/master/server/src/routes.php#L4). Essentially, this is a URL that sets `state` in your session, then redirects to `https://clef.io/iframes/login`1 with your `app_id` and `redirect_url`.

### Use your custom scheme for redirect URLs

For your `redirect_url` for the OAuth handshake you should use `custom://clef/callback` (replace custom with your custom URL scheme of choice). For your `redirect_url` in Distributed Auth, you should use `custom://clef/verify` (replace custom with your custom URL scheme of choice).

### Logging in an authenticated user

Rather than authenticating the user into the web session, you'll need to pass a message back to the iOS library that can be used to authenticat the user in the app. This should likely be an API token. To do this, redirect to `message://<blob>` with a base64-encoded JSON object as `<blob>`. You can see an example of this (and the rest of the OAuth handshake) in [server/src/routes.php](https://github.com/clef/sample-app-login/blob/master/server/src/routes.php#L52).

# Support

If you're working through an integration and have an issue, email us at [support@getclef.com](mailto:support@getclef.com) and we'll help you out.
