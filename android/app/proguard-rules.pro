# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.engine.** { *; }
-keep class io.flutter.plugin.common.** { *; }
-keep class io.flutter.plugin.platform.** { *; }

# Drift database
-keep class com.example.monolith_tasks.generated.** { *; }
-keep class *.generated.* { *; }

# Keep native methods
-keep class * extends java.lang.Object {
    native <methods>;
}

# Keep R classes
-keep class **.R$* { *; }

# Keep classes that have custom serialization
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private <fields>;
    private <methods>;
}

# Keep all WebSocket related classes
-keep class org.java_websocket.** { *; }

# SQLite3 Flutter Libs
-keep class org.sqlite.** { *; }

# Keep all Dart libraries
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.plugin.** { *; }
