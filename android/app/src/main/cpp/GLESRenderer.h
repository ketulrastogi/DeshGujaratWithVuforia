/*===============================================================================
Copyright (c) 2020 PTC Inc. All Rights Reserved.

Vuforia is a trademark of PTC Inc., registered in the United States and other
countries.
===============================================================================*/

#ifndef _VUFORIA_GLESRENDERER_H_
#define _VUFORIA_GLESRENDERER_H_

#include <android/asset_manager.h>
#include <GLES3/gl31.h>
#include <GLES3/gl3ext.h>

#include <tiny_obj_loader.h>

#include <Vuforia/Image.h>
#include <Vuforia/Matrices.h>
#include <Vuforia/Vectors.h>

#include <vector>


/// Class to encapsulate OpenGLES rendering for the sample
class GLESRenderer
{
public:
    /// Initialize the renderer ready for use
    bool init(AAssetManager* assetManager);
    /// Clean up objects created during rendering
    void deinit();

    void setAstronautTexture(int width, int height, unsigned char* bytes);
    void setLanderTexture(int width, int height, unsigned char* bytes);

    /// Render the video background
    void renderVideoBackground(Vuforia::Matrix44F& projectionMatrix,
                               const float* vertices, const float* textureCoordinates,
                               const int numTriangles, const unsigned short* indices,
                               int textureUnit);

    /// Render augmentation for the world origin
    void renderWorldOrigin(Vuforia::Matrix44F& projectionMatrix,
                           Vuforia::Matrix44F& modelViewMatrix);

    /// Render a bounding box augmentation on an Image Target
    void renderImageTarget(Vuforia::Matrix44F& projectionMatrix,
                           Vuforia::Matrix44F& modelViewMatrix,
                           Vuforia::Matrix44F& scaledModelViewMatrix);

    /// Render a bounding cube augmentation on a Model Target
    void renderModelTarget(Vuforia::Matrix44F& projectionMatrix,
                           Vuforia::Matrix44F& modelViewMatrix,
                           Vuforia::Matrix44F& scaledModelViewMatrix);

    /// Render the Guide View for a model target
    void renderModelTargetGuideView(Vuforia::Matrix44F& projectionMatrix,
                                    Vuforia::Matrix44F& modelViewMatrix,
                                    const Vuforia::Image* Image);

private: // methods
    /// Attempt to create a texture from bytes
    void createTexture(int width, int height, unsigned char* bytes, int& textureId);

    /// Render a filled 3D cube
    /*
    * by default the cube is centered in 0.0 and has a unit size ([-0.5;0.5] on every axis)
    * projection and modelViewMatrix define the transformation of the model
    * scale defines the size of the cube (implemented as pre-transformation)
    * color will be used for rendering the model
    */
    void renderCube(const Vuforia::Matrix44F& projectionMatrix,
                    const Vuforia::Matrix44F& modelViewMatrix,
                    float scale, const Vuforia::Vec4F &color);

    /// Render 3D Axes
    /*
    * red line is x unit vector, green line is y unit vector, blue line is z unit vector
    * projection and modelViewMatrix define the transformation of the model
    * scale defines a 3D scale of the model (implemented as pre-transformation)
    * lineWidth defines the width of the rendering line style
    */
    void renderAxis(const Vuforia::Matrix44F& projectionMatrix,
                    const Vuforia::Matrix44F& modelViewMatrix,
                    const Vuforia::Vec3F& scale,
                    float lineWidth = 2.0f);

    /// Render a v3d model
    void renderModel(Vuforia::Matrix44F modelViewProjectionMatrix,
                     const int numVertices, const float* vertices, const float* textureCoordinates,
                     GLint textureId);

    /// Read an asset file into a byte vector
    bool readAsset(AAssetManager* assetManager, const char* filename, std::vector<char>& data);

    /// Load a model from an OBJ file
    /*
    * The model is input as the data array, the vertex and texture coordinate
    * vectors are populated by this method as it reads the input.
    */
    bool loadObjModel(const std::vector<char>& data, int& numVertices, std::vector<float>& vertices, std::vector<float>& texCoords);

private: // data members

    // For video background rendering
    unsigned int mVbShaderProgramID     = 0;
    GLint mVbVertexPositionHandle       = 0;
    GLint mVbTextureCoordHandle         = 0;
    GLint mVbMvpMatrixHandle            = 0;
    GLint mVbTexSampler2DHandle         = 0;

    // For augmentation rendering
    unsigned int mUniformColorShaderProgramID   = 0;
    GLint mUniformColorVertexPositionHandle     = 0;
    GLint mUniformColorMvpMatrixHandle          = 0;
    GLint mUniformColorColorHandle              = 0;

    // For model target guide view rendering
    unsigned int mTextureUniformColorShaderProgramID    = 0;
    GLint mTextureUniformColorVertexPositionHandle      = 0;
    GLint mTextureUniformColorTextureCoordHandle        = 0;
    GLint mTextureUniformColorMvpMatrixHandle           = 0;
    GLint mTextureUniformColorTexSampler2DHandle        = 0;
    GLint mTextureUniformColorColorHandle               = 0;
    int mModelTargetGuideViewTextureUnit = -1;

    // For axis rendering
    unsigned int mVertexColorShaderProgramID    = 0;
    GLint mVertexColorVertexPositionHandle      = 0;
    GLint mVertexColorColorHandle               = 0;
    GLint mVertexColorMvpMatrixHandle           = 0;

    int mAstronautVertexCount;
    std::vector<float> mAstronautVertices;
    std::vector<float> mAstronautTexCoords;
    int mAstronautTextureUnit = -1;

    int mLanderVertexCount;
    std::vector<float> mLanderVertices;
    std::vector<float> mLanderTexCoords;
    int mLanderTextureUnit = -1;
};

#endif //_VUFORIA_GLESRENDERER_H_
