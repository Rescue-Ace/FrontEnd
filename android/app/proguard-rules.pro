# Firebase
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-keep class io.flutter.plugins.firebase.messaging.** { *; }

# SharedPreferences
-keep class androidx.preference.** { *; }

# Firebase Messaging
-keepclassmembers class com.google.firebase.messaging.** {
    *;
}
-keepattributes *Annotation*

# JSON parsing for notifications
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}

# Prevent Firebase messaging and shared preferences classes from being stripped
-keep class com.google.firebase.messaging.** { *; }
-keep class androidx.preference.** { *; }

# Keep JSON parsing annotations (Gson)
-keepattributes *Annotation*

