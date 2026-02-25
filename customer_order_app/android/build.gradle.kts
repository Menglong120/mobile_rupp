allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    // Only redirect build outputs for projects that live inside this Android project.
    // Flutter plugin subprojects can live in the Pub cache (often on a different drive on Windows).
    // Forcing their buildDir to this repo's build folder can break Kotlin incremental compilation.
    val rootAndroidDir = rootProject.projectDir.canonicalFile
    val thisProjectDir = project.projectDir.canonicalFile

    if (thisProjectDir.toPath().startsWith(rootAndroidDir.toPath())) {
        val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
        project.layout.buildDirectory.value(newSubprojectBuildDir)
    }
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
