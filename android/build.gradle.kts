allprojects {
    repositories {
        google()
        mavenCentral()
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
}

// Bazı Flutter eklentileri (ör. geocoding_android) hâlâ compileSdk 33 ile derleniyor;
// AndroidX bağımlılıkları ise en az 34 istiyor. Eklenti kütüphanelerinin compileSdk
// değerini, proje değerlendirilmeden ÖNCE kaydedilen afterEvaluate kancasıyla yükseltiyoruz.
// Not: Bu blok, aşağıdaki evaluationDependsOn(":app") bloğundan önce kalmalıdır.
subprojects {
    val forceLibraryCompileSdk: Project.() -> Unit = {
        extensions.findByType(com.android.build.gradle.LibraryExtension::class.java)
            ?.compileSdkVersion(36)
    }
    if (state.executed) {
        forceLibraryCompileSdk()
    } else {
        afterEvaluate { forceLibraryCompileSdk() }
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
