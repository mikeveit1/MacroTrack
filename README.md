# MacroTrack

A comprehensive iOS nutrition tracking app built with SwiftUI that helps users monitor their daily macronutrient intake and achieve their fitness goals.

## Overview

MacroTrack is a feature-rich nutrition tracking application that combines modern iOS development practices with powerful backend services to provide users with a seamless macro counting experience. The app integrates with the FatSecret API for comprehensive food data and uses Firebase for secure user authentication and data persistence.

## Features

### 🥗 Food Logging
- **Meal-based tracking**: Log foods across breakfast, lunch, dinner, snacks, and water intake
- **Comprehensive food database**: Search through thousands of foods using FatSecret API integration
- **Accurate macro calculations**: Track calories, protein, carbohydrates, and fat with precision
- **Serving size adjustments**: Easily modify portions and see real-time macro updates
- **Date navigation**: View and edit food logs for any date with intuitive swipe gestures

### 📊 Macro Calculator
- **Personalized calculations**: Uses the Mifflin St. Jeor equation for accurate calorie needs
- **Customizable goals**: Set targets based on weight loss, maintenance, or muscle gain
- **Activity level adjustment**: Accounts for different activity levels (sedentary to super active)
- **Automatic goal setting**: Calculates optimal protein/carb/fat ratios (25/45/30)

### 📈 Progress Tracking
- **Visual progress indicators**: Color-coded progress bars for each macronutrient
- **Daily goal comparison**: Real-time tracking against personalized targets
- **Customizable display**: Toggle visibility of different macro categories
- **Streak tracking**: Monitor consecutive days of food logging

### 👤 User Profile & Analytics
- **Personal dashboard**: View daily goals and average intake statistics
- **Progress analytics**: Track long-term trends and logging consistency
- **Account management**: Secure authentication with email/password
- **Data backup**: All data synced securely to Firebase

### 📱 Sharing & Export
- **Screenshot sharing**: Share daily goals, individual meals, or complete daily logs
- **Multiple export formats**: Choose specific data to share via iOS share sheet
- **Progress visualization**: Beautiful, shareable summaries of nutrition data

## Technical Implementation

### Architecture
- **Pattern**: MVVM (Model-View-ViewModel) architecture
- **Framework**: SwiftUI for modern, declarative UI
- **Platform**: iOS 17.4+ and macOS 14.3+ support
- **Orientation**: Portrait-optimized interface

### Tech Stack
- **Frontend**: SwiftUI, Combine
- **Backend**: Firebase Realtime Database, Firebase Auth, Firebase Storage
- **APIs**: FatSecret API for nutritional data
- **Additional**: RevenueCat for potential monetization features

### Key Dependencies
```swift
// Core Firebase Services
import FirebaseCore
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

// Food Data Integration
import FatSecretSwift

// Additional Features
import RevenueCat
import AVKit (for animated splash screen)
```

### Data Models
- **MacroFood**: Represents food items with nutritional information
- **MacronutrientInfo**: Stores calorie, protein, carb, and fat data
- **UserMacroData**: User's calculated macro targets and personal info
- **MealLogs**: Daily food log organization by meal type

## Project Structure
MacroTrack/
├── App/ # App lifecycle and configuration
├── MainContent/ # Tab-based navigation
├── FoodLog/ # Food logging interface and logic
├── MacroCalculator/ # Macro calculation features
├── Profile/ # User profile and settings
├── SignIn/SignUp/ # Authentication flows
├── Services/ # Firebase and external API services
├── Data/ # Core data models
├── Views/ # Reusable UI components
├── Helpers/ # Utility functions and helpers
└── Constants/ # App-wide constants (colors, etc.)

## Key Features Demonstrated

### iOS Development Skills
- **SwiftUI mastery**: Complex layouts, animations, and state management
- **Firebase integration**: Authentication, real-time database, and cloud storage
- **API integration**: RESTful API consumption with proper error handling
- **Data persistence**: Efficient local and cloud data synchronization
- **User experience**: Intuitive navigation, gesture support, and accessibility

### Software Engineering Practices
- **Clean architecture**: Well-organized MVVM pattern with separation of concerns
- **Modular design**: Reusable components and helper classes
- **Error handling**: Comprehensive error states and user feedback
- **Performance optimization**: Efficient data loading and memory management
- **Security**: Proper authentication and data protection measures

## Installation & Setup

1. **Clone the repository**
2. **Open in Xcode**: Requires Xcode 15.3 or later
3. **Configure Firebase**: Add your `GoogleService-Info.plist`
4. **FatSecret API**: Set up API credentials in Firebase configuration
5. **Build and run**: Deploy to iOS Simulator or device

## App Store Information
- **Bundle ID**: com.buckeyesoftware.MacroTrack
- **Version**: 1.05
- **Target**: iPhone users focused on nutrition and fitness
- **Category**: Health & Fitness
- **Link**: https://apps.apple.com/us/app/macrotrack-nutrition-tracker/id6743007561

## Future Enhancements
- Barcode scanning for quick food entry
- Apple Health integration
- Meal planning and recipe creation
- Social features and community sharing
- Advanced analytics and reporting

## Highlights

This project demonstrates:
- **Full-stack iOS development** with modern SwiftUI
- **Cloud backend integration** using Firebase services
- **Third-party API integration** with proper error handling
- **User authentication and data security** best practices
- **Clean code architecture** with MVVM pattern
- **Professional UI/UX design** with intuitive user flows
