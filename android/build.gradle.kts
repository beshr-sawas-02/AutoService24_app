// build.gradle.kts (Project-level)

buildscript {
    extra.apply {
        set("kotlin_version", "1.8.22")
    }

    repositories {
        google()
        mavenCentral()
    }

    dependencies {
        // Android Gradle Plugin متوافق مع Android Studio
        classpath("com.android.tools.build:gradle:8.3.0")

        // Kotlin plugin
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:${property("kotlin_version")}")

        // Google services
        classpath("com.google.gms:google-services:4.3.15")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// إعادة بناء مجلد build لمكان آخر (اختياري)
val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

subprojects {
    project.evaluationDependsOn(":app")
}

// Task لتنظيف المشروع
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
