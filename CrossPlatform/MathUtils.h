/*===============================================================================
Copyright (c) 2020, PTC Inc. All rights reserved.
 
Vuforia is a trademark of PTC Inc., registered in the United States and other
countries.
===============================================================================*/

#ifndef __MATH_UTILS_H__
#define __MATH_UTILS_H__

#include <Vuforia/Vectors.h>
#include <Vuforia/Matrices.h>

/// Utility class for Math operations.
/**
 *
 * Provide a set of linear algebra operations for Vufoira vector and matrix.
 * All 4x4 matrix transformation consider row storage
 */
class MathUtils
{
public:
    /// Create a 2D zero vector and return the result (result = (0, 0))
    static Vuforia::Vec2F Vec2FZero();

    /// Create a 2D unit vector and return the result (result = (1, 1))
    static Vuforia::Vec2F Vec2FUnit();

    /// Create the opposite 2D vector and return the result (result = -v)
    static Vuforia::Vec2F Vec2FOpposite(const Vuforia::Vec2F& v);

    /// Addition two 2D vectors and return the result (result = v1 + v2)
    static Vuforia::Vec2F Vec2FAdd(const Vuforia::Vec2F& v1, const Vuforia::Vec2F& v2);

    /// Subtract two 2D vectors and return the result (result = v1 - v2)
    static Vuforia::Vec2F Vec2FSub(const Vuforia::Vec2F& v1, const Vuforia::Vec2F& v2);

    /// Compute the Euclidean distance between two 2D vectors and return the result
    static float Vec2FDist(const Vuforia::Vec2F& v1, const Vuforia::Vec2F& v2);

    /// Multiply 2D vector by a scalar and return the result  (result  = v * s)
    static Vuforia::Vec2F Vec2FScale(const Vuforia::Vec2F&v, float s);

    /// Compute the norm of the 2D vector and return the result (result = ||v||)
    static float Vec2FNorm(const Vuforia::Vec2F& v);

    /// Print a 2D vector
    static void printVector(const Vuforia::Vec2F& v);

    /// Create a 3D zero vector and return the result (result = (0, 0, 0))
    static Vuforia::Vec3F Vec3FZero();

    /// Create a 3D unity vector and return the result (result = (1, 1, 1))
    static Vuforia::Vec3F Vec3FUnit();

    /// Create the opposite 3D vector and return the result (result = -v)
    static Vuforia::Vec3F Vec3FOpposite(const Vuforia::Vec3F& v);

    /// Addition two 3D vectors and return the result (result = v1 + v2)
    static Vuforia::Vec3F Vec3FAdd(const Vuforia::Vec3F& v1, const Vuforia::Vec3F& v2);

    /// Subtract two 3D vectors and return the result (result = v1 - v2)
    static Vuforia::Vec3F Vec3FSub(const Vuforia::Vec3F& v1, const Vuforia::Vec3F& v2);

    /// Compute the Euclidean distance between two 3D vectors and return the result
    static float Vec3FDist(const Vuforia::Vec3F& v1, const Vuforia::Vec3F& v2);

    /// Multiply 3D vector by a scalar and return the result (result = v * s)
    static Vuforia::Vec3F Vec3FScale(const Vuforia::Vec3F& v, float s);

    /// Compute the dot product of two 3D vectors and return the result (result = v1.v2)
    static float Vec3FDot(const Vuforia::Vec3F& v1, const Vuforia::Vec3F& v2);

    /// Compute the cross product of two 3D vectors and return the result (result = v1 x v2)
    static Vuforia::Vec3F Vec3FCross(const Vuforia::Vec3F& v1, const Vuforia::Vec3F& v2);

    /// Normalize a 3D vector and return the result (result = v/||v||)
    static Vuforia::Vec3F Vec3FNormalize(const Vuforia::Vec3F& v);

    /// Transform a 3D vector by 4x4 matrix and return the result (pre multiply,  result = m * v)
    static Vuforia::Vec3F Vec3FTransform(const Vuforia::Matrix44F& m, const Vuforia::Vec3F& v);

    /// Transform a 3D vector by 4x4 matrix and return the result (post multiply, result = v * m)
    static Vuforia::Vec3F Vec3FTransformR(const Vuforia::Vec3F& v, const Vuforia::Matrix44F& m);

    /// Transform a normal by a 4x4 matrix (rotation only) and return the result (pre multiply,  result = m * v)
    static Vuforia::Vec3F Vec3FTransformNormal(const Vuforia::Matrix44F& m, const Vuforia::Vec3F& v);

    /// Transform a normal by a 4x4 matrix (rotation only) and return the result (post multiply,  result = v * m)
    static Vuforia::Vec3F Vec3FTransformNormalR(const Vuforia::Vec3F& v, const Vuforia::Matrix44F& m);

    /// Compute the norm of the 3D vector and return the result (result = ||v||)
    static float Vec3FNorm(const Vuforia::Vec3F& v);

    /// Print a 3D vector
    static void printVector(const Vuforia::Vec3F& v);

    /// Create a 4D zero vector and return the result (result = (0, 0, 0, 0))
    static Vuforia::Vec4F Vec4FZero();

    /// Create a 4D unit vector and return the result (result = (1, 1, 1, 1))
    static Vuforia::Vec4F Vec4FUnit();

    /// Multiply 4D vector by a scalar and return the result (result  = v * s)
    static Vuforia::Vec4F Vec4FScale(const Vuforia::Vec4F& v1, float s);

    /// Transform a 4D vector by matrix and return the result (pre multiply, result = m * v)
    static Vuforia::Vec4F Vec4FTransform(const Vuforia::Matrix44F& m, const Vuforia::Vec4F& v);

    /// Transform a 4D vector by matrix and return the result (post multiply, result = v * m)
    static Vuforia::Vec4F Vec4FTransformR(const Vuforia::Vec4F& v, const Vuforia::Matrix44F& m);

    /// Print a 4D vector
    static void printVector(const Vuforia::Vec4F& m);

    // COMPOSITION METHODS (can be chained)

    /// Return an identity 3x4 matrix
    static Vuforia::Matrix34F Matrix34FIdentity();

    /// Return an identify 4x4 matrix
    static Vuforia::Matrix44F Matrix44FIdentity();

    /// Transpose a 4x4 matrix and return the result (result = transpose(m))
    static Vuforia::Matrix44F Matrix44FTranspose(const Vuforia::Matrix44F& m);

    /// Compute the determinate of a 4x4 matrix and return the result ( result = det(m) )
    static float Matrix44FDeterminate(const Vuforia::Matrix44F& m);

    /// Computer the inverse of the matrix and return the result ( result = inverse(m) )
    static Vuforia::Matrix44F Matrix44FInverse(const Vuforia::Matrix44F& m);

    /// Translate the matrix m by a vector v and return the result (post-multiply, result = M * T(trans) )
    static Vuforia::Matrix44F Matrix44FTranslate(const Vuforia::Vec3F& trans, const Vuforia::Matrix44F& m);

    /// Rotate the matrix m by the axis/angle rotation and return the result (post-multiply, result = M * R(angle, axis) )
    /// Angle is in degrees
    static Vuforia::Matrix44F Matrix44FRotate(float angle, const Vuforia::Vec3F& axis, const Vuforia::Matrix44F& m);

    /// Scale the matrix m by a vector scale and return the result (post-multiply, result = M * S (scale) )
    static Vuforia::Matrix44F Matrix44FScale(const Vuforia::Vec3F& scale, const Vuforia::Matrix44F& m);

    /// Create a perspective projection matrix and return the result (using a CV CS convention, z positive)
    /// FOV is in degrees
    static Vuforia::Matrix44F Matrix44FPerspective(float fovy, float aspectRatio, float near, float far);

    /// Create a perspective projection matrix and return the result (using a GL CS convention, z negative)
    /// FOV is in degrees
    static Vuforia::Matrix44F Matrix44FPerspectiveGL(float fovy, float aspectRatio, float near, float far);

    /// Create an orthographic projection matrix and return the result (using a CV CS convention, z positive)
    static Vuforia::Matrix44F Matrix44FOrthographic(float left, float right, float bottom, float top, float near, float far);

    /// Create an orthographic projection matrix and return the result (using a GL CS convention, z negative)
    static Vuforia::Matrix44F Matrix44FOrthographicGL(float left, float right, float bottom, float top, float near, float far);

    /// Create a look at model view matrix and return the result
    static Vuforia::Matrix44F Matrix44FLookAt(const Vuforia::Vec3F& eye, const Vuforia::Vec3F& center, const Vuforia::Vec3F& up);

    /// Create copy of the 4x4 matrix and return the result
    static Vuforia::Matrix44F copyMatrix(const Vuforia::Matrix44F& m);

    // ARGUMENT METHODS (result always returned in argument)

    /// Print a 4x4 matrix.
    static void printMatrix(const Vuforia::Matrix44F& m);

    /// Create a rotation matrix with the axis/angle rotation
    /// Angle is in degrees
    static void makeRotationMatrix(float angle, const Vuforia::Vec3F& axis, Vuforia::Matrix44F& m);

    /// Create a translation matrix with the vector v
    static void makeTranslationMatrix(const Vuforia::Vec3F& v, Vuforia::Matrix44F& m);

    /// Create a scaling matrix with the vector scale
    static void makeScalingMatrix(const Vuforia::Vec3F& scale, Vuforia::Matrix44F& m);

    /// Create a perspective projection matrix with the perspective parameters  (using a CV CS convention, z positive)
    static void makePerspectiveMatrix(float fovy, float aspectRatio, float near, float far, Vuforia::Matrix44F& m);

    /// Create a perspective projection matrix with the perspective parameters (using a GL CS convention, z negative)
    static void makePerspectiveMatrixGL(float fovy, float aspectRatio, float near, float far, Vuforia::Matrix44F& m);

    /// Create an orthographic projection matrix with the orthographic parameters (using a CV CS convention, z positive)
    static void makeOrthographicMatrix(float left, float right, float bottom, float top, float near, float far, Vuforia::Matrix44F& m);

    /// Create an orthographic projection matrix with the orthographic parameters (using a GL CS convention, z negative)
    static void makeOrthographicMatrixGL(float left, float right, float bottom, float top, float near, float far, Vuforia::Matrix44F& m);

    /// Create a look at model view matrix with the viewpoint parameters
    static void makeLookAtMatrix(const Vuforia::Vec3F& eye, const Vuforia::Vec3F& center, const Vuforia::Vec3F& up, Vuforia::Matrix44F& m);

    /// Translate the matrix m by a vector v (post-multiply, result = M * T(trans) )
    static void translateMatrix(const Vuforia::Vec3F& v, Vuforia::Matrix44F& m);

    // Rotate the matrix m by the axis/angle rotation (post-multiply, result = M * R(angle, axis) )
    // Angle is in degrees
    static void rotateMatrix(float angle, const Vuforia::Vec3F& axis, Vuforia::Matrix44F& m);

    /// Scale the matrix m by a vector scale and return the result (post-multiply, result = M * S (scale) )
    static void scaleMatrix(const Vuforia::Vec3F& scale, Vuforia::Matrix44F& m);

    /// Multiply the two matrices A and B and writes the result to C (C = mA*mB)
    static void multiplyMatrix(const Vuforia::Matrix44F& mA, const Vuforia::Matrix44F& mB, Vuforia::Matrix44F& mC);

    /// Use the matrix to project the extents of the video background to the viewport
    /// This will generate normalized coordinates (i.e. full viewport has -1,+1 range)
    /// to create a rectangle that can be used to set a scissor on the video background
    static void getScissorRect(const Vuforia::Matrix44F& projectionMatrix,
                               const Vuforia::Vec4I& viewport,
                               Vuforia::Vec4I& scissorRect);

    /// Convert world pose matrix to camera pose matrix or camera pose matrix to world pose matrix
    static void convertPoseBetweenWorldAndCamera(const Vuforia::Matrix44F& matrixIn, Vuforia::Matrix44F& matrixOut);
};


#endif  // __MATH_UTILS_H__
