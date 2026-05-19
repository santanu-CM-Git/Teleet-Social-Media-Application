# Teleet case study

## About project

Teleet is a cross-platform Flutter app (iOS and Android) that combines social networking, real-time messaging, live audio spaces, and video calls in one product. Users post multimedia content, share 24-hour stories, join interest-based rooms, and discover people and hashtags through search and personalized feeds.

## Technology stack

Flutter and Dart (SDK ≥3.0.6), GetX for state management, Firebase (Auth, Firestore, Cloud Messaging), Agora for audio spaces, ZegoUIKit for video calls, SightEngine for content moderation, RevenueCat and Google Mobile Ads for monetization, and 20+ languages with RTL support.

## The client

Teleet ([teleet.com](https://www.teleet.com/)) needed one mobile platform where communities could connect beyond static posts—with live conversation, private and group chat, and monetization in a single app.

## The solution

We delivered a unified Teleet application (v11) with social feed, stories, messaging, audio spaces, video calls, rooms, profiles, search, and push notifications. Authentication supports email, Google, Apple, and phone OTP; content is moderated automatically; revenue comes from subscriptions and ads—all on a shared Firebase backend.

## Problem

Building a modern social product usually means stitching together separate tools for feeds, chat, live audio, and video—leading to a fragmented user experience, higher maintenance, and weaker engagement. Teleet also had to handle real-time communication at scale, user-generated media with safety requirements, multi-platform delivery, and sustainable revenue without pushing users off the platform.


## Result

Teleet launched as a single iOS and Android app where users can post, story, message, join live audio spaces, and take video calls without switching products. Real-time features run on proven third-party engines ( ZegoUIKit) with Firebase as the backbone; automated moderation and reporting support safer communities; subscriptions and ads provide monetization; and 20+ languages with RTL support broaden reach. The product ships at v11 with a maintainable Flutter codebase ready for ongoing feature growth.
