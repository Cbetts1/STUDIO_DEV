/**
 * bootstrap.c — Studio OS native bootstrap JNI library
 *
 * Provides nativeInit() to Java/Kotlin: verifies the app files dir,
 * creates required sub-directories, and returns success/failure.
 */

#include <jni.h>
#include <android/log.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <unistd.h>
#include <errno.h>

#define TAG "StudioBootstrap"
#define LOGI(...) __android_log_print(ANDROID_LOG_INFO,  TAG, __VA_ARGS__)
#define LOGE(...) __android_log_print(ANDROID_LOG_ERROR, TAG, __VA_ARGS__)

static int mkdirs(const char *path) {
    char tmp[512];
    char *p = NULL;
    size_t len;
    snprintf(tmp, sizeof(tmp), "%s", path);
    len = strlen(tmp);
    if (tmp[len - 1] == '/') tmp[len - 1] = '\0';
    for (p = tmp + 1; *p; p++) {
        if (*p == '/') {
            *p = '\0';
            if (mkdir(tmp, 0755) != 0 && errno != EEXIST) return -1;
            *p = '/';
        }
    }
    if (mkdir(tmp, 0755) != 0 && errno != EEXIST) return -1;
    return 0;
}

JNIEXPORT jboolean JNICALL
Java_com_studio_os_EngineBridge_nativeInit(JNIEnv *env, jobject obj, jstring appFilesDir) {
    const char *dir = (*env)->GetStringUTFChars(env, appFilesDir, NULL);
    if (!dir) {
        LOGE("nativeInit: null appFilesDir");
        return JNI_FALSE;
    }

    LOGI("nativeInit: appFilesDir = %s", dir);

    // Sub-directories that must exist
    const char *subdirs[] = {
        "system",
        "system/state",
        "system/profiles",
        "system/home",
        "projects",
        NULL
    };

    char path[1024];
    jboolean ok = JNI_TRUE;
    for (int i = 0; subdirs[i] != NULL; i++) {
        snprintf(path, sizeof(path), "%s/%s", dir, subdirs[i]);
        if (mkdirs(path) != 0) {
            LOGE("nativeInit: failed to create %s: %s", path, strerror(errno));
            ok = JNI_FALSE;
        } else {
            LOGI("nativeInit: ensured %s", path);
        }
    }

    (*env)->ReleaseStringUTFChars(env, appFilesDir, dir);
    return ok;
}
