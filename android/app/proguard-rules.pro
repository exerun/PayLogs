# Keep only the Latin text recognizer classes
-keep class com.google.mlkit.vision.text.latin.** { *; }

# Suppress warnings for other scripts (not used)
-dontwarn com.google.mlkit.vision.text.chinese.**
-dontwarn com.google.mlkit.vision.text.japanese.**
-dontwarn com.google.mlkit.vision.text.korean.**
-dontwarn com.google.mlkit.vision.text.devanagari.** 