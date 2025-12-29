# --------------------
# Google Ads
# --------------------
-keep class com.google.android.gms.ads.** { *; }
-keep interface com.google.android.gms.ads.** { *; }
-keep class com.google.ads.** { *; }

# --------------------
# SQLCipher / SQLite
# --------------------
-keep class net.sqlcipher.** { *; }
-keep class org.sqlite.** { *; }
-keep class androidx.sqlite.** { *; }

-dontwarn net.sqlcipher.**
-dontwarn org.sqlite.**

# --------------------
# Flutter
# --------------------
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.embedding.** { *; }

# --------------------
# Annotations
# --------------------
-keepattributes *Annotation*
