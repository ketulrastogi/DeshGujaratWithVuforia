/*===============================================================================
Copyright (c) 2020 PTC Inc. All Rights Reserved.

Vuforia is a trademark of PTC Inc., registered in the United States and other
countries.
===============================================================================*/

#include <jni.h>

#include <AppController.h>
#include <Log.h>
#include "GLESRenderer.h"

#include <Vuforia/Tool.h>
#include <Vuforia/GLRenderer.h>

#include <GLES3/gl31.h>
#include <android/asset_manager.h>
#include <android/asset_manager_jni.h>

#include <vector>


// Cross-platform AppController providing high level Vuforia Engine operations
AppController controller;

// Struct to hold data that we need to store between calls
struct
{
    JavaVM* vm = nullptr;
    jobject activity = nullptr;
    jobject assetManagerJava = nullptr;
    AAssetManager* assetManager = nullptr;
    jmethodID presentErrorMethodID = nullptr;
    jmethodID initDoneMethodID = nullptr;

    GLESRenderer renderer;
} gWrapperData;


// JNI Implementation
#ifdef __cplusplus
extern "C"
{
#endif

JNIEXPORT void JNICALL
Java_in_bugle_deshgujarat_VuforiaActivity_initAR(
    JNIEnv *env,
    jobject /* this */,
    jobject activity,
    jobject assetManager,
    jint target)
{
    // Store the Java VM pointer so we can get a JNIEnv in callbacks
    if (env->GetJavaVM(&gWrapperData.vm) != 0)
    {
        return;
    }
    gWrapperData.activity = env->NewGlobalRef(activity);
    jclass clazz = env->GetObjectClass(activity);
    gWrapperData.presentErrorMethodID = env->GetMethodID(clazz, "presentError", "(Ljava/lang/String;)V");
    gWrapperData.initDoneMethodID = env->GetMethodID(clazz, "initDone", "()V");
    env->DeleteLocalRef(clazz);

    AppController::InitConfig initConfig;
    initConfig.vuforiaInitFlags = Vuforia::INIT_FLAGS::GL_30;
    initConfig.appData = activity;

    // Setup callbacks
    initConfig.showErrorCallback = [](const char *errorString)
    {
        LOG("Error callback invoked. Message: %s", errorString);
        JNIEnv* env = nullptr;
        if (gWrapperData.vm->GetEnv((void**)&env, JNI_VERSION_1_6) == 0)
        {
            jstring error = env->NewStringUTF(errorString);
            env->CallVoidMethod(gWrapperData.activity, gWrapperData.presentErrorMethodID, error);
            env->DeleteLocalRef(error);
        }
    };
    initConfig.initDoneCallback = []()
    {
        LOG("InitDone callback");
        JNIEnv* env = nullptr;
        if (gWrapperData.vm->GetEnv((void**)&env, JNI_VERSION_1_6) == 0)
        {
            env->CallVoidMethod(gWrapperData.activity, gWrapperData.initDoneMethodID);
        }
    };

    // Get a native AAssetManager
    gWrapperData.assetManagerJava = env->NewGlobalRef(assetManager);
    gWrapperData.assetManager = AAssetManager_fromJava(env, assetManager);
    if (gWrapperData.assetManager == nullptr)
    {
        initConfig.showErrorCallback("Error: Failed to get the asset manager");
        return;
    }

    // Start Vuforia initialization
    controller.initAR(initConfig, target);
}


JNIEXPORT jboolean JNICALL
Java_in_bugle_deshgujarat_VuforiaActivity_startAR(
        JNIEnv *env,
        jobject /* this */)
{
    return controller.startAR() ? 1 : 0;
}


JNIEXPORT void JNICALL
Java_in_bugle_deshgujarat_VuforiaActivity_pauseAR(
        JNIEnv *env,
        jobject /* this */)
{
    controller.pauseAR();
}


JNIEXPORT void JNICALL
Java_in_bugle_deshgujarat_VuforiaActivity_resumeAR(
        JNIEnv *env,
        jobject /* this */)
{
    controller.resumeAR();
}


JNIEXPORT void JNICALL
Java_in_bugle_deshgujarat_VuforiaActivity_stopAR(
    JNIEnv *env,
    jobject /* this */)
{
    controller.stopAR();
}


JNIEXPORT void JNICALL
Java_in_bugle_deshgujarat_VuforiaActivity_deinitAR(
        JNIEnv *env,
        jobject /* this */)
{
    controller.deinitAR();

    env->DeleteGlobalRef(gWrapperData.assetManagerJava);
    gWrapperData.assetManagerJava = nullptr;
    gWrapperData.assetManager = nullptr;
    env->DeleteGlobalRef(gWrapperData.activity);
    gWrapperData.activity = nullptr;
}


JNIEXPORT void JNICALL
Java_in_bugle_deshgujarat_VuforiaActivity_cameraPerformAutoFocus(
    JNIEnv *env,
    jobject /* this */)
{
    controller.cameraPerformAutoFocus();
}


JNIEXPORT void JNICALL
Java_in_bugle_deshgujarat_VuforiaActivity_cameraRestoreAutoFocus(
    JNIEnv *env,
    jobject /* this */)
{
    controller.cameraRestoreAutoFocus();
}


JNIEXPORT void JNICALL
Java_in_bugle_deshgujarat_VuforiaActivity_initRendering(
        JNIEnv *env,
        jobject /* this */)
{
    // Define clear color
    glClearColor(0.0f, 0.0f, 0.0f, Vuforia::requiresAlpha() ? 0.0f : 1.0f);

    if (!gWrapperData.renderer.init(gWrapperData.assetManager))
    {
        LOG("Error initialising rendering");
    }
}


JNIEXPORT void JNICALL
Java_in_bugle_deshgujarat_VuforiaActivity_setTextures(
    JNIEnv *env,
    jobject /* this */,
    jint astronautWidth, jint astronautHeight, jobject astronautByteBuffer,
    jint landerWidth, jint landerHeight, jobject landerByteBuffer)
{
    // Textures are loaded using the BitmapFactory which isn't available from the NDK.
    // They are loaded in the Kotlin code and passed to this method to create GLES textures.
    auto astronautBytes = static_cast<unsigned char*>(env->GetDirectBufferAddress(astronautByteBuffer));
    gWrapperData.renderer.setAstronautTexture(astronautWidth, astronautHeight, astronautBytes);
    auto landerBytes = static_cast<unsigned char*>(env->GetDirectBufferAddress(landerByteBuffer));
    gWrapperData.renderer.setLanderTexture(landerWidth, landerHeight, landerBytes);
}


JNIEXPORT void JNICALL
Java_in_bugle_deshgujarat_VuforiaActivity_deinitRendering(
    JNIEnv *env,
    jobject /* this */)
{
    gWrapperData.renderer.deinit();
}


JNIEXPORT jboolean JNICALL
Java_in_bugle_deshgujarat_VuforiaActivity_configureRendering(
        JNIEnv *env,
        jobject /* this */,
        jint width, jint height,
        jint orientation)
{
    return controller.configureRendering(width, height, orientation) ? 1 : 0;
}


JNIEXPORT jboolean JNICALL
Java_in_bugle_deshgujarat_VuforiaActivity_renderFrame(
        JNIEnv *env,
        jobject /* this */)
{
    if (!controller.isCameraStarted())
    {
        return JNI_FALSE;
    }

    // Clear colour and depth buffers
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    Vuforia::GLTextureUnit vbTextureUnit;
    vbTextureUnit.mTextureUnit = 0;
    double viewport[6];
    if (controller.prepareToRender(viewport, nullptr, &vbTextureUnit))
    {
        // Set viewport for current view
        glViewport(viewport[0], viewport[1], viewport[2], viewport[3]);

        auto renderingPrimitives = controller.getRenderingPrimitives();
        Vuforia::Matrix44F vbProjectionMatrix = Vuforia::Tool::convert2GLMatrix(
            renderingPrimitives->getVideoBackgroundProjectionMatrix(Vuforia::VIEW_SINGULAR));
        const Vuforia::Mesh& vbMesh = renderingPrimitives->getVideoBackgroundMesh(Vuforia::VIEW_SINGULAR);
        gWrapperData.renderer.renderVideoBackground(vbProjectionMatrix,
            vbMesh.getPositionCoordinates(), vbMesh.getUVCoordinates(),
            vbMesh.getNumTriangles(), vbMesh.getTriangles(),
            vbTextureUnit.mTextureUnit);

        Vuforia::Matrix44F worldOriginProjection;
        Vuforia::Matrix44F worldOriginModelView;
        if (controller.getOrigin(worldOriginProjection, worldOriginModelView))
        {
            gWrapperData.renderer.renderWorldOrigin(worldOriginProjection, worldOriginModelView);
        }

        Vuforia::Matrix44F trackableProjection;
        Vuforia::Matrix44F trackableModelView;
        Vuforia::Matrix44F trackableModelViewScaled;
        Vuforia::Image* modelTargetGuideViewImage = nullptr;
        if (controller.getImageTargetResult(trackableProjection, trackableModelView, trackableModelViewScaled))
        {
            gWrapperData.renderer.renderImageTarget(trackableProjection, trackableModelView, trackableModelViewScaled);
        }
        else if (controller.getModelTargetResult(trackableProjection, trackableModelView, trackableModelViewScaled))
        {
            gWrapperData.renderer.renderModelTarget(trackableProjection, trackableModelView, trackableModelViewScaled);
        }
        else if (controller.getModelTargetGuideView(trackableProjection, trackableModelView, &modelTargetGuideViewImage))
        {
            gWrapperData.renderer.renderModelTargetGuideView(trackableProjection, trackableModelView, modelTargetGuideViewImage);
        }
    }

    controller.finishRender(nullptr);

    return JNI_TRUE;
}


JNIEXPORT jint JNICALL
Java_in_bugle_deshgujarat_VuforiaActivity_00024Companion_getImageTargetId(
    JNIEnv *env,
    jobject /* this */)
{
    return AppController::IMAGE_TARGET_ID;
}


JNIEXPORT jint JNICALL
Java_in_bugle_deshgujarat_VuforiaActivity_00024Companion_getModelTargetId(
    JNIEnv *env,
    jobject /* this */)
{
    return AppController::MODEL_TARGET_ID;
}

#ifdef __cplusplus
}
#endif
