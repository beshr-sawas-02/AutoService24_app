// build.gradle.kts (Project-level)

buildscript {
    extra.apply {
        set("kotlin_version", "1.9.25")
    }

    repositories {
        google()
        mavenCentral()
    }

    dependencies {
        // ✅ Android Gradle Plugin
        classpath("com.android.tools.build:gradle:8.6.0")



        // ✅ Kotlin Gradle Plugin
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:${property("kotlin_version")}")

        // ✅ Google Services (Firebase, etc.)
        classpath("com.google.gms:google-services:4.4.2")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// (اختياري) نقل build directory
val newBuildDir = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
    project.evaluationDependsOn(":app")
}

// ✅ Clean task
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
