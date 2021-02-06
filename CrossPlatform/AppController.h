/*===============================================================================
Copyright (c) 2020, PTC Inc. All rights reserved.
 
Vuforia is a trademark of PTC Inc., registered in the United States and other
countries.
===============================================================================*/

#ifndef __APPCONTROLLER_H__
#define __APPCONTROLLER_H__

#ifdef _MSC_VER
#pragma warning(disable:4251)
#endif
#include <Vuforia/CameraDevice.h>
#include <Vuforia/DataSet.h>
#include <Vuforia/Image.h>
#include <Vuforia/Matrices.h>
#include <Vuforia/ModelTarget.h>
#include <Vuforia/Renderer.h>
#include <Vuforia/RenderingPrimitives.h>
#ifdef _MSC_VER
#pragma warning(default:4251)
#endif

#include <cstdio>
#include <functional>
#include <memory>
#include <string>


/// The AppController provides a platform independent encapsulation of the  Vuforia lifecycle
/// and dataset loading.
class AppController
{
    
public:

    // Constants
    static constexpr int IMAGE_TARGET_ID = 0;
    static constexpr int MODEL_TARGET_ID = 1;

    // Type definitions
    using ErrorCallback = std::function<void(const char* errorString)>;
    using InitDoneCallback = std::function<void()>;

    /// Struct to group initialization parameters passed to initAR
    using InitConfig = struct
    {
        int vuforiaInitFlags { 0 };
        void* appData {};
        ErrorCallback showErrorCallback {};
        InitDoneCallback initDoneCallback {};
    };


    /// Initialize Vuforia. When the initialization is completed successfully the callback method initDone callback will be invoked.
    /// If initialization fails the error callback will be invoked.
    /// On Android the appData pointer should be a pointer to the Activity object.
    void initAR(const InitConfig& initConfig, int target);
    
    /// Start the AR session
    bool startAR();
    
    /// Call this method when the app is paused.
    void pauseAR();
    
    /// Call this method when the app resumes from paused.
    void resumeAR();

    /// Stop the AR session
    void stopAR();

    /// Clean up and deinitialize Vuforia.
    void deinitAR();

    /// Request that the camera refocuses in the current position
    void cameraPerformAutoFocus();

    /// Restore the camera to continuous autofocus mode
    void cameraRestoreAutoFocus();

    /// Force an update of the cached RenderingPrimitives
    /// Call if the screen dimensions or orientation change
    void updateRenderingPrimitives();
    
    /// Configure Vuforia rendering.
    /// This method must be called after initAR and startAR are complete.
    /// This should be called from the Rendering thread.
    bool configureRendering(int width, int height, int orientation);

    /// Query whether the camera is currently started
    bool isCameraStarted() { return mCameraIsStarted; }

    /// Call this method at the start of Vuforia rendering.
    /// Gets the latest video background texture from Vuforia.
    bool prepareToRender(double* viewport, Vuforia::RenderData* renderData,
                         Vuforia::TextureUnit* videoBackgroundTextureUnit, Vuforia::TextureData* videoBackgroundTextureData = nullptr);

    /// Call this method when Vuforia rendering is complete, this should be near the end of the
    /// platform render callback.
    void finishRender(Vuforia::RenderData* renderData);
    
    /// Get the current RenderingPrimitives
    /// Will return nullptr until configureRendering has been called
    const Vuforia::RenderingPrimitives* getRenderingPrimitives() { return mCurrentRenderingPrimitives.get(); }

    /// Get rendering information for the world origin position.
    /// Returns false if the world origin position is not currently available.
    bool getOrigin(Vuforia::Matrix44F& projectionMatrix, Vuforia::Matrix44F& modelViewMatrix);

    /// Get rendering information for the Image Target.
    /// Returns false if Vuforia isn't currently tracking the Image Target.
    bool getImageTargetResult(Vuforia::Matrix44F& projectionMatrix,
                              Vuforia::Matrix44F& modelViewMatrix, Vuforia::Matrix44F& scaledModelViewMatrix);

    /// Get rendering information for the Model Target.
    /// Returns false if Vuforia isn't currently tracking the Model Target.
    bool getModelTargetResult(Vuforia::Matrix44F& projectionMatrix,
                              Vuforia::Matrix44F& modelViewMatrix, Vuforia::Matrix44F& scaledModelViewMatrix);

    /// Get rendering information for the Model Target Giide View.
    /// Returns false if Guide View rendering isn't required for the current frame.
    bool getModelTargetGuideView(Vuforia::Matrix44F& projectionMatrix,
                                 Vuforia::Matrix44F& modelViewMatrix, Vuforia::Image** guideViewImage);
    
private: // methods
    
    /// Used by initAR to prepare and invoke Vuforia initialization.
    bool initVuforiaInternal(void* appData);
    
    /// Convert orientation parameter to platform specific value and pass to Vuforia.
    void setVuforiaOrientation(int orientation) const;
    
    /// Create the set of Vuforia Trackers needed in the application
    bool initTrackers();
    
    /// Clean up Trackers created by initTrackers
    void deinitTrackers();
    
    /// Load and activate the dataset for the currently selected target.
    bool loadTrackerData();

    /// Deactivate and unload the currently selected target.
    bool unloadTrackerData();
    
    /// Start Vuforia trackers
    bool startTrackers();
    
    /// Stop Vuforia trackers
    void stopTrackers();
    
    /// Convenience method, returns trye if the screen is in portrait orientation.
    bool isScreenPortrait() const { return mOrientation == 0 || mOrientation == 1; }
    
    /// Calculate the video background configuration to pass to Vuforia.
    void configureVideoBackground(float viewWidth, float viewHeight);
    
    /// Utility method to load and activate datasets
    /// Can be used before trackers are started.
    /// During an active Vuforia session dataset activation is only allowed in the Vuforia_onUpdate() callback.
    Vuforia::DataSet* loadAndActivateDataSet(std::string path);
    
private: // data members

    /// Callback to inform the user of an error
    ErrorCallback mShowErrorCallback;
    /// Callback to inform the user that initialization is complete
    InitDoneCallback mInitDoneCallback;
    /// Vuforia initialization flags
    int mVuforiaInitFlags = 0;
    /// The target to use, either IMAGE_TARGET_ID or MODEL_TARGET_ID
    int mTarget = IMAGE_TARGET_ID;

    /// Local cache of current screen orientation for calculating rendering data
    int mOrientation = 0;

    /// The Vuforia camera mode to use, either DEFAULT, SPEED or QUALITY.
    Vuforia::CameraDevice::MODE mCameraMode = Vuforia::CameraDevice::MODE_DEFAULT;
    /// True when the Vuforia camera is currently started.
    bool mCameraIsActive = false;
    /// True when the Vuforia camera has been started. The camera may currently
    /// be stopped because AR has been paused.
    bool mCameraIsStarted = false;

    /// Flag to ensure we only perform once-per-session rendering setup the first time
    /// configureRendering is called
    bool mDoneOneTimeRenderingConfiguration = false;
    /// Local copy of current RenderingPrimitives
    std::unique_ptr<Vuforia::RenderingPrimitives> mCurrentRenderingPrimitives;
    /// Remember the display aspect ratio for later configuration of Guide View rendering
    float mDisplayAspectRatio;

    /// After the first call to prepareToRender this holds a copy of the Vuforia state.
    Vuforia::State mVuforiaState;
    /// The currently activated Vuforia DataSet.
    Vuforia::DataSet*  mCurrentDataSet = nullptr;
    /// If a Model Target Guide View should be displayed this points to the object providing
    /// details of what the App should render.
    const Vuforia::ModelTarget* mGuideViewModelTarget = nullptr;
};

#endif /* __APPCONTROLLER_H__ */
