# Clef app login sample

This repository has a sample server and iOS application that demonstrate how to add login with Clef to an app.

## iOS Application

For the iOS application, you'll need to open [ios/app-login.xcodeproj](ios/app-login.xcodeproj) in Xcode. Once you've opened the project, you should be able to run it.

## Server

For the server, you'll need to install the dependencies and start it. If you don't already have it on your computer, you'll need to [download and install Composer](https://getcomposer.org/doc/00-intro.md) from their website. We use Composer to manage the dependencies for the server application.

To start the server, run these commands:

```shell
$ cd server
$ composer install
$ php -S localhost:8080 -t ./public/
```

If you're working through an integration and have an issue, email us at [support@getclef.com](mailto:support@getclef.com) and we'll help you out.
