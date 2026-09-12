// build.gradle.kts (Project-level)

buildscript {
    extra.apply {
        set("kotlin_version", "2.2.20")
    }

    repositories {
        google()
        mavenCentral()
    }

    dependencies {
        // Google Services (Firebase, etc.)
        // AGP + Kotlin versions come from settings.gradle.kts plugins block
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
