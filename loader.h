#ifndef _KTX_LOADER_H_
#define _KTX_LOADER_H_

#if KTX_OPENGL
	#ifdef _WIN32
	#include <windows.h>
	#define GL_APIENTRY APIENTRY
	#endif

	#include <GL/gl.h>
	/* TODO: use runtime checks for sized internalformat support */
	#define KTX_SUPPORT_SIZEDINTERNALFORMATS 1

#elif KTX_OPENGL_ES1

	#include <GLES/gl.h>
	#include <GLES/glext.h>

	#define KTX_SUPPORT_SIZEDINTERNALFORMATS 0

#elif KTX_OPENGL_ES2

	#include <GLES2/gl2.h>
	#include <GLES2/gl2ext.h>

	#define KTX_SUPPORT_SIZEDINTERNALFORMATS 0

#else
#error Please #define one of KTX_OPENGL, KTX_OPENGL_ES1, KTX_OPENGL_ES2 as 1
#endif

#ifdef __cplusplus
extern "C" {
#endif

typedef void (GL_APIENTRY* PFNGLTEXIMAGE1DPROC) (GLenum target, GLint level, GLint internalformat, GLsizei width, GLint border, GLenum format, GLenum type, const GLvoid *pixels);
typedef void (GL_APIENTRY* PFNGLTEXIMAGE3DPROC) (GLenum target, GLint level, GLint internalformat, GLsizei width, GLsizei height, GLsizei depth, GLint border, GLenum format, GLenum type, const GLvoid *pixels);
typedef void (GL_APIENTRY* PFNGLCOMPRESSEDTEXIMAGE1DPROC) (GLenum target, GLint level, GLenum internalformat, GLsizei width, GLint border, GLsizei imageSize, const GLvoid *data);
typedef void (GL_APIENTRY* PFNGLCOMPRESSEDTEXIMAGE2DPROC) (GLenum target, GLint level, GLenum internalformat, GLsizei width, GLsizei height, GLint border, GLsizei imageSize, const GLvoid *data);
typedef void (GL_APIENTRY* PFNGLCOMPRESSEDTEXIMAGE3DPROC) (GLenum target, GLint level, GLenum internalformat, GLsizei width, GLsizei height, GLsizei depth, GLint border, GLsizei imageSize, const GLvoid *data);
typedef void (GL_APIENTRY* PFNGLGENERATEMIPMAPPROC) (GLenum target);

/* remove these where already defined as functions */
extern PFNGLTEXIMAGE1DPROC glTexImage1D;
extern PFNGLTEXIMAGE3DPROC glTexImage3D;
extern PFNGLCOMPRESSEDTEXIMAGE1DPROC glCompressedTexImage1D;
extern PFNGLCOMPRESSEDTEXIMAGE2DPROC glCompressedTexImage2D;
extern PFNGLCOMPRESSEDTEXIMAGE3DPROC glCompressedTexImage3D;
extern PFNGLGENERATEMIPMAPPROC glGenerateMipmap;

typedef enum KTX_error_code_t
{
	KTX_SUCCESS = 0,
	KTX_FILE_OPEN_FAILED,
	KTX_UNEXPECTED_END_OF_FILE,
	KTX_UNKNOWN_FILE_FORMAT,
	KTX_INVALID_VALUE,
	KTX_UNSUPPORTED_TEXTURE_TYPE,
	KTX_OUT_OF_MEMORY,
	KTX_GL_ERROR,
}
KTX_error_code;

/* KTXLoadTexture
 *
 * Loads a texture from a KTX file
 *
 * Input:
 * filename - pointer to a C string that contains the path of the file to load
 * texture - if texture == NULL, the function will generate a texture name and
 *           bind it to the texture target returned in *target, before loading
 *           the texture data.
 *           If *texture == 0, the function will do the above and also return
 *           the texture name in *texture.
 *           Otherwise the function will use the texture name given in *texture
 *           and bind it to the texture target returned in *target.
 * target - the function will choose the texture target to use based on the
 *          file contents. If target == NULL, the function will return an
 *          error. Otherwise, *target will contain the chosen texture target. 
 */
KTX_error_code KTXLoadTexture(const char* const filename, GLuint* texture, GLenum* target);

#ifdef __cplusplus
}
#endif

#endif /* _KTX_LOADER_H_ */
