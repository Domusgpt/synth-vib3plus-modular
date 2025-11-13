allprojects {
    repositories {
        google()
        mavenCentral()
    }

    // FORCE Java 21 for ALL projects including dependencies
    // Suppress obsolete options warnings from third-party plugins
    afterEvaluate {
        tasks.withType<JavaCompile>().configureEach {
            sourceCompatibility = JavaVersion.VERSION_21.toString()
            targetCompatibility = JavaVersion.VERSION_21.toString()

            // Suppress warnings about obsolete Java versions
            options.compilerArgs.addAll(listOf(
                "-Xlint:-options",
                "-Xlint:-deprecation"
            ))

            // Verify we're using Java 21
            options.isFork = true
            options.forkOptions.javaHome = file("/usr/lib/jvm/java-21-openjdk-amd64")
        }
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)

    // FORCE Java 21 for all subprojects - AGGRESSIVE enforcement
    afterEvaluate {
        tasks.withType<JavaCompile> {
            sourceCompatibility = JavaVersion.VERSION_21.toString()
            targetCompatibility = JavaVersion.VERSION_21.toString()

            // Suppress warnings from legacy third-party plugins
            options.compilerArgs.addAll(listOf(
                "-Xlint:-options",
                "-Xlint:-deprecation"
            ))

            // Force Java 21 JDK for compilation
            options.isFork = true
            options.forkOptions.javaHome = file("/usr/lib/jvm/java-21-openjdk-amd64")
        }
    }
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
