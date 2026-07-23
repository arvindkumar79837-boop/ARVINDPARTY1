# Firebase
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**

# Firebase Auth
-keep class com.google.firebase.auth.** { *; }

# Firebase Messaging
-keep class com.google.firebase.messaging.** { *; }

# MoEngage
-keep class com.moengage.** { *; }
-dontwarn com.moengage.**

# LiveKit
-keep class io.livekit.** { *; }
-dontwarn io.livekit.**

# Flutter
-keep class io.flutter.** { *; }
-dontwarn io.flutter.**

# Keep annotation classes
-keepattributes *Annotation*
-keepattributes SourceFile,LineNumberTable
-keep public class * extends java.lang.Exception

# General Android
-keep class * extends android.app.Activity
-keep class * extends android.app.Service
-keep class * extends android.content.BroadcastReceiver
-keep class * extends android.content.ContentProvider
