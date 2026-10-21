# flutter_local_notifications 17.x uses Gson TypeToken to persist scheduled
# notifications. R8 must retain the generic type used by its subclasses.
-keepattributes Signature
-keep class com.google.gson.reflect.TypeToken { *; }
-keep class * extends com.google.gson.reflect.TypeToken { *; }

# Gson reads the plugin's notification models through reflection.
-keep class com.dexterous.flutterlocalnotifications.models.** { *; }
