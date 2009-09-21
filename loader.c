#include <string.h>
#include <stdlib.h>
#include <stdio.h>

#include "khrplatform.h"
#include "loader.h"

/* remove these where already defined as functions */
PFNGLTEXIMAGE1DPROC glTexImage1D = NULL;
PFNGLTEXIMAGE3DPROC glTexImage3D = NULL;
PFNGLCOMPRESSEDTEXIMAGE1DPROC glCompressedTexImage1D = NULL;
PFNGLCOMPRESSEDTEXIMAGE2DPROC glCompressedTexImage2D = NULL;
PFNGLCOMPRESSEDTEXIMAGE3DPROC glCompressedTexImage3D = NULL;
PFNGLGENERATEMIPMAPPROC glGenerateMipmap = NULL;

#define KTX_IDENTIFIER_REF  { 0xAB, 0x4B, 0x54, 0x58, 0x20, 0x31, 0x31, 0xBB, 0x0D, 0x0A, 0x1A, 0x0A }
#define KTX_ENDIAN_REF      (0x04030201)
#define KTX_ENDIAN_REF_REV  (0x01020304)
#define KTX_HEADER_SIZE		(64)

#ifndef GL_TEXTURE_1D
#define GL_TEXTURE_1D                    0x0DE0
#endif
#ifndef GL_TEXTURE_3D
#define GL_TEXTURE_3D                    0x806F
#endif
#ifndef GL_TEXTURE_CUBE_MAP
#define GL_TEXTURE_CUBE_MAP              0x8513
#define GL_TEXTURE_CUBE_MAP_POSITIVE_X   0x8515
#endif
/* from GL_EXT_texture_array */
#ifndef GL_TEXTURE_1D_ARRAY_EXT
#define GL_TEXTURE_1D_ARRAY_EXT          0x8C18
#define GL_TEXTURE_2D_ARRAY_EXT          0x8C1A
#endif
#ifndef GL_GENERATE_MIPMAP
#define GL_GENERATE_MIPMAP               0x8191
#endif

#ifndef MAX
#define MAX(x, y) (((x) > (y)) ? (x) : (y))
#endif

typedef struct KTX_header_t
{
	khronos_uint8_t  identifier[12];
	khronos_uint32_t endianness;
	khronos_uint32_t glType;
	khronos_uint32_t glTypeSize;
	khronos_uint32_t glFormat;
	khronos_uint32_t glInternalFormat;
	khronos_uint32_t glBaseInternalFormat;
	khronos_uint32_t pixelWidth;
	khronos_uint32_t pixelHeight;
	khronos_uint32_t pixelDepth;
	khronos_uint32_t numberOfArrayElements;
	khronos_uint32_t numberOfFaces;
	khronos_uint32_t numberOfMipmapLevels;
	khronos_uint32_t bytesOfKeyValueData;
} 
KTX_header;

/* This will cause compilation to fail if the struct size doesn't match */
typedef int KTX_header_SIZE_ASSERT [sizeof(KTX_header) == KTX_HEADER_SIZE];

typedef struct KTX_texinfo_t
{
	/* Data filled in by ReadAndCheckHeader() */
	khronos_uint32_t textureDimensions;
	khronos_uint32_t glTarget;
	khronos_uint32_t compressed;
	khronos_uint32_t generateMipmaps;
} 
KTX_texinfo;


/*
 * SwapEndian16: Swaps endianness in an array of 16-bit values
 */
static void SwapEndian16(khronos_uint16_t* pData16, int count)
{
	int i;
	for (i = 0; i < count; ++i)
	{
		khronos_uint16_t x = *pData16;
		*pData16++ = (x << 8) | (x >> 8);
	}
}

/*
 * SwapEndian32: Swaps endianness in an array of 32-bit values
 */
static void SwapEndian32(khronos_uint32_t* pData32, int count)
{
	int i;
	for (i = 0; i < count; ++i)
	{
		khronos_uint32_t x = *pData32;
		*pData32++ = (x << 24) | ((x & 0xFF00) << 8) | ((x & 0xFF0000) >> 8) | (x >> 24);
	}
}

/* ReadAndCheckHeader
 * 
 * Reads the KTX file header and performs some sanity checking on the values
 */
static KTX_error_code ReadAndCheckHeader(FILE* file, KTX_header* header, KTX_texinfo* texinfo)
{
	khronos_uint8_t identifier_reference[12] = KTX_IDENTIFIER_REF;
	khronos_uint32_t max_dim;

	if (fread(header, KTX_HEADER_SIZE, 1, file) != 1)
	{
		return KTX_UNEXPECTED_END_OF_FILE;
	}

	/* Compare identifier, is this a KTX file? */
	if (memcmp(header->identifier, identifier_reference, 12) != 0)
	{
		return KTX_UNKNOWN_FILE_FORMAT;
	}

	if (header->endianness == KTX_ENDIAN_REF_REV)
	{
		/* Convert endianness of header fields if necessary */
		SwapEndian32(&header->glType, 12);

		if (header->glTypeSize != 1 &&
			header->glTypeSize != 2 &&
			header->glTypeSize != 4)
		{
			/* Only 8, 16, and 32-bit types supported so far */
			return KTX_INVALID_VALUE;
		}
	}
	else if (header->endianness != KTX_ENDIAN_REF)
	{
		return KTX_INVALID_VALUE;
	}

	/* Check glType and glFormat */
	texinfo->compressed = 0;
	if (header->glType == 0 || header->glFormat == 0)
	{
		if (header->glType + header->glFormat != 0)
		{
			/* either both or none of glType, glFormat must be zero */
			return KTX_INVALID_VALUE;
		}
		texinfo->compressed = 1;
	}

	/* Check texture dimensions. KTX files can store 8 types of textures:
	   1D, 2D, 3D, cube, and array variants of these. There is currently
	   no GL extension that would accept 3D array or cube array textures. */
	if ((header->pixelWidth == 0) ||
		(header->pixelDepth > 0 && header->pixelHeight == 0))
	{
		/* texture must have width */
		/* texture must have height if it has depth */
		return KTX_INVALID_VALUE; 
	}

	texinfo->textureDimensions = 1;
	texinfo->glTarget = GL_TEXTURE_1D;
	texinfo->generateMipmaps = 0;
	if (header->pixelHeight > 0)
	{
		texinfo->textureDimensions = 2;
		texinfo->glTarget = GL_TEXTURE_2D;
	}
	if (header->pixelDepth > 0)
	{
		texinfo->textureDimensions = 3;
		texinfo->glTarget = GL_TEXTURE_3D;
	}

	if (header->numberOfFaces == 6)
	{
		if (texinfo->textureDimensions == 2)
		{
			texinfo->glTarget = GL_TEXTURE_CUBE_MAP;
		}
		else
		{
			/* cube map needs 2D faces */
			return KTX_INVALID_VALUE;
		}
	}
	else if (header->numberOfFaces != 1)
	{
		/* numberOfFaces must be either 1 or 6 */
		return KTX_INVALID_VALUE;
	}

	/* load as 2D texture if 1D textures are not supported */
	if (texinfo->textureDimensions == 1 &&
		((texinfo->compressed && (glCompressedTexImage1D == NULL)) ||
		 (!texinfo->compressed && (glTexImage1D == NULL))))
	{
		texinfo->textureDimensions = 2;
		texinfo->glTarget = GL_TEXTURE_2D;
		header->pixelHeight = 1;
	}

	if (header->numberOfArrayElements > 0)
	{
		if (texinfo->glTarget == GL_TEXTURE_1D)
		{
			texinfo->glTarget = GL_TEXTURE_1D_ARRAY_EXT;
		}
		else if (texinfo->glTarget == GL_TEXTURE_2D)
		{
			texinfo->glTarget = GL_TEXTURE_2D_ARRAY_EXT;
		}
		else
		{
			/* No API for 3D and cube arrays yet */
			return KTX_UNSUPPORTED_TEXTURE_TYPE;
		}
		texinfo->textureDimensions++;
	}

	/* reject 3D texture if unsupported */
	if (texinfo->textureDimensions == 3 &&
		((texinfo->compressed && (glCompressedTexImage3D == NULL)) ||
		 (!texinfo->compressed && (glTexImage3D == NULL))))
	{
		return KTX_UNSUPPORTED_TEXTURE_TYPE;
	}

	/* Check number of mipmap levels */
	if (header->numberOfMipmapLevels == 0)
	{
		texinfo->generateMipmaps = 1;
		header->numberOfMipmapLevels = 1;
	}
	max_dim = MAX(MAX(header->pixelWidth, header->pixelHeight), header->pixelDepth);
	if (max_dim < ((khronos_uint32_t)1 << (header->numberOfMipmapLevels - 1)))
	{
		/* Can't have more mip levels than 1 + log2(max(width, height, depth)) */
		return KTX_INVALID_VALUE;
	}

	/* skip key/value metadata */
	/* TODO: return metadata to the caller in some way */
	if (fseek(file, (long)header->bytesOfKeyValueData, SEEK_CUR) != 0)
	{
		return KTX_UNEXPECTED_END_OF_FILE;
	}

	return KTX_SUCCESS;
}

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
 *
 * Returns: KTX_SUCCESS on success, other KTX_* enum values on error.
 */
KTX_error_code KTXLoadTexture(const char* const filename, GLuint* texture, GLenum* target)
{
	GLint				previousUnpackAlignment;
	KTX_header			header;
	KTX_texinfo			texinfo;
	FILE*				file = NULL;
	void*				data = NULL;
	khronos_uint32_t	dataSize = 0;
	GLsizei				pixelWidth;  
	GLsizei				pixelHeight;
	GLsizei				pixelDepth;
	GLuint				texname;
	khronos_uint32_t    faceLodSize;
	khronos_uint32_t    faceLodSizeRounded;
	khronos_uint32_t	level;
	khronos_uint32_t	face;
	GLenum				glInternalFormat;
	KTX_error_code		errorCode = KTX_SUCCESS;

	if (!target)
	{
		return KTX_INVALID_VALUE;
	}

	file = fopen(filename, "rb");
	if (!file) 
	{
		return KTX_FILE_OPEN_FAILED;
	}

	errorCode = ReadAndCheckHeader(file, &header, &texinfo);
	if (errorCode != KTX_SUCCESS)
	{
		fclose(file);
		return errorCode;
	}

	/* KTX files require an unpack alignment of 4 */
	glGetIntegerv(GL_UNPACK_ALIGNMENT, &previousUnpackAlignment);
	glPixelStorei(GL_UNPACK_ALIGNMENT, 4);

	if (texture && *texture)
	{
		texname = *texture;
	}
	else
	{
		glGenTextures(1, &texname);
	}
	glBindTexture(texinfo.glTarget, texname);

	if (texinfo.generateMipmaps && (glGenerateMipmap == NULL))
	{
		glTexParameteri(texinfo.glTarget, GL_GENERATE_MIPMAP, GL_TRUE);
	}

	if (texinfo.glTarget == GL_TEXTURE_CUBE_MAP)
	{
		texinfo.glTarget = GL_TEXTURE_CUBE_MAP_POSITIVE_X;
	}

#if KTX_SUPPORT_SIZEDINTERNALFORMATS
	glInternalFormat = header.glInternalFormat;
#else
	glInternalFormat = header.glBaseInternalFormat;
#endif

	for (level = 0; level < header.numberOfMipmapLevels; ++level)
	{
		pixelWidth  = MAX(1, header.pixelWidth  >> level);
		pixelHeight = MAX(1, header.pixelHeight >> level);
		pixelDepth  = MAX(1, header.pixelDepth  >> level);

		if (fread(&faceLodSize, sizeof(khronos_uint32_t), 1, file) != 1)
		{
			errorCode = KTX_UNEXPECTED_END_OF_FILE;
			goto cleanup;
		}
		if (header.endianness == KTX_ENDIAN_REF_REV)
		{
			SwapEndian32(&faceLodSize, 1);
		}
		faceLodSizeRounded = (faceLodSize + 3) & ~(khronos_uint32_t)3;
		if (!data)
		{
			/* allocate memory sufficient for the first level */
			data = malloc(faceLodSizeRounded);
			if (!data)
			{
				errorCode = KTX_OUT_OF_MEMORY;
				goto cleanup;
			}
			dataSize = faceLodSizeRounded;
		}
		else if (dataSize < faceLodSizeRounded)
		{
			/* subsequent levels cannot be larger than the first level */
			errorCode = KTX_INVALID_VALUE;
			goto cleanup;
		}

		for (face = 0; face < header.numberOfFaces; ++face)
		{
			if (fread(data, faceLodSizeRounded, 1, file) != 1)
			{
				errorCode = KTX_UNEXPECTED_END_OF_FILE;
				goto cleanup;
			}

			/* Perform endianness conversion on texture data */
			if (header.endianness == KTX_ENDIAN_REF_REV && header.glTypeSize == 2)
			{
				SwapEndian16((khronos_uint16_t*)data, faceLodSize / 2);
			}
			else if (header.endianness == KTX_ENDIAN_REF_REV && header.glTypeSize == 4)
			{
				SwapEndian32((khronos_uint32_t*)data, faceLodSize / 4);
			}

			if (texinfo.textureDimensions == 1)
			{
				if (texinfo.compressed)
				{
					glCompressedTexImage1D(texinfo.glTarget + face, level, 
						glInternalFormat, pixelWidth, 0,
						faceLodSize, data);
				}
				else
				{
					glTexImage1D(texinfo.glTarget + face, level, 
						glInternalFormat, pixelWidth, 0, 
						header.glFormat, header.glType, data);
				}
			}
			else if (texinfo.textureDimensions == 2)
			{
				if (header.numberOfArrayElements)
				{
					pixelHeight = header.numberOfArrayElements;
				}
				if (texinfo.compressed)
				{
					glCompressedTexImage2D(texinfo.glTarget + face, level, 
						glInternalFormat, pixelWidth, pixelHeight, 0,
						faceLodSize, data);
				}
				else
				{
					glTexImage2D(texinfo.glTarget + face, level, 
						glInternalFormat, pixelWidth, pixelHeight, 0, 
						header.glFormat, header.glType, data);
				}
			}
			else if (texinfo.textureDimensions == 3)
			{
				if (header.numberOfArrayElements)
				{
					pixelDepth = header.numberOfArrayElements;
				}
				if (texinfo.compressed)
				{
					glCompressedTexImage3D(texinfo.glTarget + face, level, 
						glInternalFormat, pixelWidth, pixelHeight, pixelDepth, 0,
						faceLodSize, data);
				}
				else
				{
					glTexImage3D(texinfo.glTarget + face, level, 
						glInternalFormat, pixelWidth, pixelHeight, pixelDepth, 0, 
						header.glFormat, header.glType, data);
				}
			}

			if (glGetError() != GL_NO_ERROR)
			{
				errorCode = KTX_GL_ERROR;
				goto cleanup;
			}
		}
	}

cleanup:
	free(data);
	fclose(file);

	/* restore previous GL state */
	glPixelStorei(GL_UNPACK_ALIGNMENT, previousUnpackAlignment);

	if (errorCode == KTX_SUCCESS)
	{
		if (texinfo.generateMipmaps && glGenerateMipmap)
		{
			glGenerateMipmap(texinfo.glTarget);
		}
		*target = texinfo.glTarget;
		if (texture)
		{
			*texture = texname;
		}
	}
	return errorCode;
}
