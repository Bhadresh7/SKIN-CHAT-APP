# Firebase Messaging
-keep class com.google.firebase.messaging.** { *; }
-keep class com.google.firebase.iid.** { *; }
-keep class com.google.firebase.** { *; }
-keep class io.flutter.plugins.firebase.messaging.FlutterFirebaseMessagingService { *; }
-keep class io.flutter.plugins.firebase.messaging.** { *; }

# Needed for background messages
-keepclassmembers class ** {
    @android.webkit.JavascriptInterface <methods>;
}
-keep class * extends java.lang.annotation.Annotation { *; }