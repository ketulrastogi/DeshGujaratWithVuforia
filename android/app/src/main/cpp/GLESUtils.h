/*===============================================================================
Copyright (c) 2020 PTC Inc. All Rights Reserved.

Vuforia is a trademark of PTC Inc., registered in the United States and other
countries.
===============================================================================*/

#ifndef _VUFORIA_GLESUTILS_H_
#define _VUFORIA_GLESUTILS_H_

// Includes:
#include <Log.h>
#include <Vuforia/Image.h>

#include <GLES3/gl31.h>
#include <vector>

/// A utility class used by the Vuforia Engine samples.
class GLESUtils
{
private:
    /// Enable this flag to debug OpenGL errors
    static const bool DEBUG_GL = false;

public:

    /// Prints GL error information.
    static void checkGlError(const char* operation);

    /// Initialize a shader.
    static unsigned int initShader(unsigned int shaderType, 
        const char* source);
    
    /// Create a shader program.
    static unsigned int createProgramFromBuffer(const char* vertexShaderBuffer,
        const char* fragmentShaderBuffer);

    /// Create a texture from a Vuforia Image
    static unsigned int createTexture(const Vuforia::Image* image);

    /// Create a texture from a byte vector
    static unsigned int createTexture(int width, int height,
        unsigned char* data, GLenum format = GL_RGBA);

    /// Clean up texture
    static bool destroyTexture(unsigned int textureId);
};

#endif // _VUFORIA_GLESUTILS_H_
