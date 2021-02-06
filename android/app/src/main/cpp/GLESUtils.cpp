/*===============================================================================
 Copyright (c) 2020 PTC Inc. All Rights Reserved.

Vuforia is a trademark of PTC Inc., registered in the United States and other
countries.
===============================================================================*/

#include "GLESUtils.h"

#include <stdlib.h>

#include <GLES3/gl31.h>
#include <GLES3/gl3ext.h>


void
GLESUtils::checkGlError(const char* operation)
{
    if (DEBUG_GL)
    {
        for (GLint error = glGetError(); error; error = glGetError())
        {
            LOG("after %s() glError (0x%x)", operation, error);
        }
    }
}


unsigned int
GLESUtils::initShader(unsigned int shaderType, const char* source)
{
    GLuint shader = glCreateShader((GLenum)shaderType);
    if (shader)
    {
        glShaderSource(shader, 1, &source, NULL);
        glCompileShader(shader);
        GLint compiled = 0;
        glGetShaderiv(shader, GL_COMPILE_STATUS, &compiled);
    
        if (!compiled)
        {
            GLint infoLen = 0;
            glGetShaderiv(shader, GL_INFO_LOG_LENGTH, &infoLen);
            if (infoLen)
            {
                char* buf = (char*) malloc(static_cast<size_t>(infoLen));
                if (buf)
                {
                    glGetShaderInfoLog(shader, infoLen, NULL, buf);
                    LOG("Could not compile shader %d: %s", 
                        shaderType, buf);
                    free(buf);
                }
                glDeleteShader(shader);
                shader = 0;
            }
        }
    }
    return shader;
}


unsigned int
GLESUtils::createProgramFromBuffer(const char* vertexShaderBuffer,
                                     const char* fragmentShaderBuffer)
{
    GLuint vertexShader = initShader(GL_VERTEX_SHADER, vertexShaderBuffer);
    if (!vertexShader)
        return 0;    

    GLuint fragmentShader = initShader(GL_FRAGMENT_SHADER,
                                        fragmentShaderBuffer);
    if (!fragmentShader)
        return 0;

    GLuint program = glCreateProgram();
    if (program)
    {
        glAttachShader(program, vertexShader);
        checkGlError("glAttachShader");
        
        glAttachShader(program, fragmentShader);
        checkGlError("glAttachShader");
        
        glLinkProgram(program);
        GLint linkStatus = GL_FALSE;
        glGetProgramiv(program, GL_LINK_STATUS, &linkStatus);
        
        if (linkStatus != GL_TRUE)
        {
            GLint bufLength = 0;
            glGetProgramiv(program, GL_INFO_LOG_LENGTH, &bufLength);
            if (bufLength)
            {
                char* buf = (char*) malloc(static_cast<size_t>(bufLength));
                if (buf)
                {
                    glGetProgramInfoLog(program, bufLength, NULL, buf);
                    LOG("Could not link program: %s", buf);
                    free(buf);
                }
            }
            glDeleteProgram(program);
            program = 0;
        }
    }
    return program;
}


unsigned int
GLESUtils::createTexture(const Vuforia::Image* image)
{
    GLuint gl_TextureID = 0;

    glGenTextures(1, &gl_TextureID);

    glBindTexture(GL_TEXTURE_2D, gl_TextureID);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);

    auto pixelFormat = image->getFormat();

    GLenum format;
    GLenum type;
    switch (pixelFormat)
    {
        case Vuforia::UNKNOWN_FORMAT:
        case Vuforia::NV12:
        case Vuforia::NV21:
            return -1;

        case Vuforia::RGB565:
            type = GL_UNSIGNED_SHORT_5_6_5;
            format = GL_RGB;
            break;
        case Vuforia::RGB888:
            type = GL_UNSIGNED_BYTE;
            format = GL_RGB;
            break;

        case Vuforia::RGBA8888:
            type = GL_UNSIGNED_BYTE;
            format = GL_RGBA;
            break;

        case Vuforia::GRAYSCALE:
            type = GL_UNSIGNED_BYTE;
            format = GL_LUMINANCE;
            break;

        default:
            return -1;
    }

    glTexImage2D(GL_TEXTURE_2D, 0, format, image->getWidth(), image->getHeight(), 0, format, type, image->getPixels());

    glBindTexture(GL_TEXTURE_2D, 0);

    GLESUtils::checkGlError("Creating texture from image");

    return gl_TextureID;
}


unsigned int
GLESUtils::createTexture(int width, int height, unsigned char* data, GLenum format)
{
    GLuint gl_TextureID = -1;

    if (data == nullptr)
    {
        LOG("Error: Cannot create a texture from null data");
        return gl_TextureID;
    }

    glGenTextures(1, &gl_TextureID);

    glBindTexture(GL_TEXTURE_2D, gl_TextureID);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);

    glTexImage2D(GL_TEXTURE_2D, 0, format, width, height, 0, format, GL_UNSIGNED_BYTE, data);

    glBindTexture(GL_TEXTURE_2D, 0);

    GLESUtils::checkGlError("Creating texture from image");

    return gl_TextureID;
}


bool
GLESUtils::destroyTexture(unsigned int textureId)
{
    glDeleteTextures(1, &textureId);
    GLESUtils::checkGlError("After glDeleteTextures");

    return true;
}
