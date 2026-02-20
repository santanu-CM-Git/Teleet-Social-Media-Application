# Teleet - Social Media Application

## Project Overview

Teleet is a comprehensive Flutter-based social media application that combines multiple communication features including social feeds, audio spaces, chat rooms, stories, and video calling capabilities. The application provides a complete social networking experience similar to platforms like Clubhouse, Twitter, and Instagram combined.

## Key Features

### 1. Social Feed
- Create and share posts with images, videos, and audio
- Like and comment on posts
- View posts by hashtags
- Search posts and hashtags
- View users who liked posts
- Report inappropriate content
- Double-tap to like functionality

### 2. Stories
- Create and share temporary stories (3-second duration)
- View stories from followed users
- Quick reply emojis on stories
- Story viewing analytics

### 3. Audio Spaces
- Create and join audio rooms
- Host and participate in audio conversations
- Raise hand to speak
- Mute/unmute microphone
- Real-time audio communication using Agora SDK

### 4. Chat Rooms
- Create public or private chat rooms
- Join rooms by interest categories
- Room invitations system
- Room admin management
- Mute/unmute room notifications
- Leave or delete rooms

### 5. Direct Messaging
- One-on-one chat conversations
- Send images and videos in chat
- Real-time messaging using Firebase
- Chat notifications

### 6. User Profiles
- Customizable user profiles
- Profile picture upload
- Bio and interest selection
- Follow/unfollow users
- View followers and following lists
- Profile verification system
- Block/unblock users

### 7. Search & Discovery
- Search for users, posts, and hashtags
- Random profile discovery
- Explore rooms by interests
- Everything search functionality

### 8. Video Calling
- One-on-one video calls
- Video call invitations
- Integrated video calling UI using ZegoUIKit

### 9. Notifications
- Push notifications for various activities
- Notification management
- Platform and user-specific notifications

### 10. Content Moderation
- Content moderation using SightEngine API
- Text and media moderation
- Admin moderation tools
- Report system for inappropriate content

### 11. Monetization
- Google Mobile Ads integration
- Banner ads
- Interstitial ads
- RevenueCat subscription management

### 12. Multi-language Support
- Support for 20+ languages including English, Spanish, French, German, Arabic, Chinese, Japanese, Korean, and more
- Language selection in settings

## Technology Stack

- **Framework**: Flutter (Dart SDK >=3.0.6 <4.0.0)
- **State Management**: GetX
- **Backend API**: RESTful API
- **Real-time Communication**: 
  - Firebase Cloud Firestore (Chat)
  - Agora SDK (Audio Spaces)
  - ZegoUIKit (Video Calls)
- **Authentication**: Firebase Auth, Google Sign-In, Apple Sign-In
- **Push Notifications**: Firebase Cloud Messaging
- **Storage**: Firebase Storage
- **Ads**: Google Mobile Ads
- **Subscriptions**: RevenueCat
- **Content Moderation**: SightEngine API

## Project Structure

```
lib/
├── common/
│   ├── api_service/          # API service classes
│   ├── controller/           # Base controllers
│   ├── extensions/           # Dart extensions
│   ├── managers/            # Manager classes (ads, navigation, session, etc.)
│   └── widgets/              # Reusable widgets
├── library/                  # Custom libraries (camera filters, story view, etc.)
├── localization/            # Multi-language support
│   └── languages/           # Language files
├── models/                  # Data models
├── screens/                 # Application screens
│   ├── add_post_screen/    # Post creation
│   ├── audio_space/        # Audio spaces feature
│   ├── chats_screen/       # Chat functionality
│   ├── feed_screen/        # Social feed
│   ├── login_screen/       # Authentication
│   ├── post/               # Post-related screens
│   ├── profile_screen/     # User profiles
│   ├── rooms_screen/       # Chat rooms
│   ├── search_screen/      # Search functionality
│   ├── story_screen/       # Stories feature
│   └── tabbar/             # Main navigation
├── utilities/              # Utility classes and constants
└── main.dart              # Application entry point
```

## API Routes

### Base URL
```
https://www.teleet.com/api/
```

### Authentication & User Management

#### User Registration & Login
- `POST /api/addUser` - Register new user
- `POST /api/checkUsername` - Check username availability
- `POST /api/checkPhone` - Check phone number
- `POST /api/validateOtp` - Validate OTP for phone verification
- `POST /api/logOut` - User logout
- `POST /api/deleteUser` - Delete user account

#### User Profile
- `POST /api/fetchProfile` - Get user profile
- `POST /api/editProfile` - Update user profile
- `POST /api/fetchRandomProfile` - Get random user profiles
- `POST /api/searchProfile` - Search users
- `POST /api/followUser` - Follow a user
- `POST /api/unfollowUser` - Unfollow a user
- `POST /api/fetchFollowingList` - Get following list
- `POST /api/fetchFollowersList` - Get followers list
- `POST /api/reportUser` - Report a user
- `POST /api/profileVerification` - Request profile verification
- `POST /api/UserBlockedByUser` - Block a user
- `POST /api/UserUnblockedByUser` - Unblock a user
- `POST /api/fetchBlockedUserList` - Get blocked users list

### Posts & Feed

#### Post Management
- `POST /api/fetchPosts` - Get feed posts
- `POST /api/addPost` - Create new post
- `POST /api/deleteMyPost` - Delete own post
- `POST /api/fetchPostByUser` - Get posts by user
- `POST /api/fetchPostByPostId` - Get single post details
- `POST /api/reportPost` - Report a post
- `POST /api/searchPost` - Search posts
- `POST /api/fetchPostsByHashtag` - Get posts by hashtag
- `POST /api/searchHashtag` - Search hashtags

#### Post Interactions
- `POST /api/likePost` - Like a post
- `POST /api/dislikePost` - Unlike a post
- `POST /api/fetchUsersWhoLikedPost` - Get users who liked a post

#### Comments
- `POST /api/addComment` - Add comment to post
- `POST /api/deleteComment` - Delete comment
- `POST /api/fetchComments` - Get post comments
- `POST /api/likeDislikeComment` - Like/unlike comment

#### File Upload
- `POST /api/uploadFile` - Upload media files (images, videos, audio)

### Stories

- `POST /api/fetchStory` - Get stories feed
- `POST /api/createStory` - Create new story
- `POST /api/deleteStory` - Delete story
- `POST /api/viewStory` - Mark story as viewed
- `POST /api/fetchStoryByID` - Get story by ID

### Chat Rooms

#### Room Management
- `POST /api/createRoom` - Create new chat room
- `POST /api/editRoom` - Edit room details
- `POST /api/deleteRoom` - Delete room
- `POST /api/fetchMyOwnRooms` - Get rooms created by user
- `POST /api/fetchRoomsByInterest` - Get rooms by interest category
- `POST /api/fetchRandomRooms` - Get random rooms
- `POST /api/fetchRoomDetail` - Get room details
- `POST /api/fetchRoomsIAmIn` - Get rooms user is member of
- `POST /api/reportRoom` - Report a room

#### Room Membership
- `POST /api/joinOrRequestRoom` - Join or request to join room
- `POST /api/leaveThisRoom` - Leave a room
- `POST /api/fetchRoomUsersList` - Get room members
- `POST /api/fetchRoomAdmins` - Get room administrators
- `POST /api/removeUserFromRoom` - Remove user from room
- `POST /api/makeRoomAdmin` - Make user room admin
- `POST /api/removeAdminFromRoom` - Remove admin privileges

#### Room Invitations
- `POST /api/inviteUserToRoom` - Invite user to room
- `POST /api/getInvitationList` - Get room invitations
- `POST /api/acceptInvitation` - Accept room invitation
- `POST /api/rejectInvitation` - Reject room invitation
- `POST /api/searchUserForInvitation` - Search users to invite

#### Room Requests
- `POST /api/fetchRoomRequestList` - Get room join requests
- `POST /api/acceptRoomRequest` - Accept join request
- `POST /api/rejectRoomRequest` - Reject join request

#### Room Settings
- `POST /api/muteUnmuteRoomNotification` - Mute/unmute room notifications

### Audio Spaces

- `POST /api/generateAgoraToken` - Generate Agora token for audio spaces

### Notifications

- `POST /api/fetchPlatformNotification` - Get platform notifications
- `POST /api/fetchUserNotification` - Get user notifications
- `POST /api/pushNotificationToSingleUser` - Send notification to user

### Settings & Configuration

- `POST /api/fetchSetting` - Get app settings
- `POST /api/fetchFAQs` - Get frequently asked questions

### Moderator Endpoints

- `POST /api/Moderator/deletePostByModerator` - Delete post (moderator)
- `POST /api/Moderator/deleteCommentByModerator` - Delete comment (moderator)
- `POST /api/Moderator/deleteRoomByModerator` - Delete room (moderator)
- `POST /api/Moderator/deleteStoryByModerator` - Delete story (moderator)
- `POST /api/Moderator/userBlockByModerator` - Block user (moderator)

## Major Functions

### PostService
- `searchPosts()` - Search posts by keyword
- `searchHashtags()` - Search hashtags
- `uploadFile()` - Upload media files
- `fetchPost()` - Get single post details
- `fetchPostsByHashtag()` - Get posts filtered by hashtag
- `fetchPosts()` - Get feed posts with pagination
- `addPost()` - Create new post with media
- `likePost()` - Like a post
- `dislikePost()` - Unlike a post
- `deletePost()` - Delete user's post
- `fetchUsersWhoLikedPost()` - Get list of users who liked a post
- `addComment()` - Add comment to post
- `fetchComments()` - Get post comments
- `deleteComment()` - Delete comment
- `likeDislikeComment()` - Like/unlike comment
- `reportPost()` - Report inappropriate post

### UserService
- `fetchProfile()` - Get user profile details
- `editProfile()` - Update user profile information
- `fetchRandomProfile()` - Get random user profiles for discovery
- `searchProfile()` - Search users by keyword
- `followUser()` - Follow a user
- `unfollowUser()` - Unfollow a user
- `fetchFollowingList()` - Get list of users being followed
- `fetchFollowerList()` - Get list of followers
- `fetchBlockedUserList()` - Get blocked users list
- `blockUser()` - Block a user
- `unblockUser()` - Unblock a user
- `profileVerification()` - Request profile verification
- `reportUser()` - Report a user
- `checkUsername()` - Check username availability
- `checkPhone()` - Check phone number
- `validateOtp()` - Validate OTP code
- `addUser()` - Register new user
- `deleteUser()` - Delete user account
- `logOut()` - User logout

### RoomService
- `createRoom()` - Create new chat room
- `editRoom()` - Edit room information
- `deleteRoom()` - Delete room
- `fetchMyOwnRooms()` - Get rooms created by user
- `fetchRoomsByInterest()` - Get rooms by interest category
- `fetchRandomRooms()` - Get random rooms
- `fetchRoomDetail()` - Get room details
- `fetchRoomsIAmIn()` - Get rooms user is member of
- `joinOrRequestRoom()` - Join or request to join room
- `leaveThisRoom()` - Leave a room
- `fetchRoomUsersList()` - Get room members list
- `fetchRoomAdmins()` - Get room administrators
- `removeUserFromRoom()` - Remove user from room
- `makeRoomAdmin()` - Grant admin privileges
- `removeAdminFromRoom()` - Remove admin privileges
- `inviteUserToRoom()` - Invite user to room
- `getInvitationList()` - Get room invitations
- `acceptInvitation()` - Accept room invitation
- `rejectInvitation()` - Reject room invitation
- `fetchRoomRequestList()` - Get room join requests
- `acceptRoomRequest()` - Accept join request
- `rejectRoomRequest()` - Reject join request
- `searchUserForInvitation()` - Search users to invite
- `muteUnmuteRoomNotification()` - Toggle room notification mute
- `reportRoom()` - Report inappropriate room

### StoryService
- `fetchStories()` - Get stories feed
- `createStory()` - Create new story
- `deleteStory()` - Delete story
- `viewStory()` - Mark story as viewed
- `fetchStoryByID()` - Get story by ID

### CommonService
- `fetchGlobalSettings()` - Get app global settings
- `fetchFAQs()` - Get frequently asked questions

### Audio Space Functions
- `generateAgoraToken()` - Generate token for Agora audio spaces
- Audio space creation and management
- Real-time audio communication handling
- Participant management (host, speaker, listener roles)

### Notification Functions
- `fetchPlatformNotification()` - Get platform-wide notifications
- `fetchUserNotification()` - Get user-specific notifications
- `pushNotificationToSingleUser()` - Send notification to specific user
- Firebase push notification handling

### Content Moderation Functions
- Text moderation using SightEngine API
- Media moderation (images/videos) using SightEngine API
- Content filtering and reporting

## Screen Structure

### Main Navigation (TabBar)
1. **Feed Screen** - Social media feed with posts
2. **Rooms Screen** - Chat rooms and audio spaces
3. **Random Screen** - Random profile discovery
4. **Chats Screen** - Direct messaging
5. **Profile Screen** - User profile and settings

### Authentication Flow
1. Splash Screen - Initial app loading
2. Onboarding Screen - App introduction
3. Login Screen - User authentication (Email, Google, Apple)
4. Phone Verification Screen - OTP verification
5. Username Screen - Set username
6. Profile Picture Screen - Upload profile picture
7. Interests Screen - Select interests

### Post Flow
1. Add Post Screen - Create post with media
2. Feed Screen - View posts feed
3. Single Post Screen - View post details
4. Comment Screen - View and add comments
5. Post Liked Users Screen - View users who liked post

### Story Flow
1. Create Story Screen - Create story with media
2. Story Screen - View stories feed
3. Story viewing and interaction

### Room Flow
1. Rooms Screen - Browse available rooms
2. Create Room Screen - Create new room
3. Single Room Screen - Room details and chat
4. Room Members Screen - View room members
5. Invite Someone Screen - Invite users to room
6. Rooms By Interest Screen - Browse rooms by category

### Audio Space Flow
1. Audio Spaces Screen - Browse audio spaces
2. Create Audio Space Screen - Create audio space
3. Audio Space Screen - Join and participate in audio space

### Profile Flow
1. Profile Screen - View user profile
2. Edit Profile Screen - Edit profile information
3. Follower/Following Screen - View followers and following
4. Profile Verification Screen - Request verification

### Search Flow
1. Search Screen - Search users, posts, hashtags
2. Tag Screen - View posts by hashtag

## Configuration

### API Configuration
- Base URL: Configured in `lib/utilities/const.dart`
- API Key: Required for API authentication
- Agora Configuration: App ID, Customer ID, and Secret for audio spaces
- Zego Configuration: For video calling functionality

### Firebase Configuration
- Firebase project configuration required
- Cloud Firestore for real-time chat
- Firebase Cloud Messaging for push notifications
- Firebase Storage for media files
- Firebase Authentication for user management

### Third-party Services
- Google Mobile Ads: Ad unit IDs required
- RevenueCat: API keys for subscription management
- SightEngine: API credentials for content moderation

## Limitations & Constraints

- Username limit: 20 characters
- Room description limit: 120 characters
- Bio limit: 120 characters
- Interest selection limit: 5 interests
- Pagination: 20 items per page
- Story duration: 3 seconds
- Image size limit: 720px
- Image quality: 100%

## Development Notes

This is a demo version of the Teleet application. The code structure is visible for demonstration purposes, but the application cannot be run without proper backend API configuration, Firebase setup, and third-party service credentials.

**Important**: When you run this application, it will display a "DEMO VERSION ONLY" screen instead of launching the actual app. This is intentional to protect the full implementation. The demo screen clearly indicates that this is a demonstration version and the code structure is visible for review purposes only.

## License

This project is proprietary software. All rights reserved.
