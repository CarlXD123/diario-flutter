# Mantener clases de Google Ads
-keep class com.google.android.gms.ads.** { *; }
-keep interface com.google.android.gms.ads.** { *; }

# Mantener clases necesarias de Google Play Services
-keep class com.google.android.gms.** { *; }
-keep interface com.google.android.gms.** { *; }

# Mantener clases usadas por Google Ads SDK
-keep class com.google.ads.** { *; }

# Evita remover clases con anotaciones necesarias
-keepattributes *Annotation*

-keep class net.sqlcipher.** { *; }
-dontwarn net.sqlcipher.**
