# Firebase Messaging
-keep class com.google.firebase.messaging.** { *; }
-keep class com.google.firebase.** { *; }

# Flutter Firebase Messaging Plugin
-keep class io.flutter.plugins.firebase.messaging.FlutterFirebaseMessagingService { *; }
-keep class io.flutter.plugins.firebase.messaging.** { *; }

# Firebase Initialization & Components
-keep class com.google.firebase.components.ComponentRegistrar { *; }
-keep class com.google.firebase.provider.FirebaseInitProvider { *; }
-keep @com.google.firebase.components.ComponentRegistrar class *
-keep @com.google.firebase.messaging.FirebaseMessagingService class *

# Keep background message annotations
-keepclassmembers class ** {
    @android.webkit.JavascriptInterface <methods>;
}
-keep class * extends java.lang.annotation.Annotation { *; }

# If you're using @Keep annotations
-keep @interface androidx.annotation.Keep
