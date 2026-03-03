#pragma once
#define _CRT_SECURE_NO_WARNINGS 
#define _USE_MATH_DEFINES
#include <math.h>
#include <stdint.h>

// Always export - this DLL is only built, never imported in the same project
#define XISF_API __declspec(dllexport)

#ifdef __cplusplus
extern "C" {
#endif

/**
 * Save a 16-bit greyscale bitmap as an 8-bit greyscale PNG file
 * 
 * @param bitmap   Pointer to 16-bit greyscale bitmap data
 * @param width    Width of the bitmap in pixels
 * @param height   Height of the bitmap in pixels
 * @param filename Output filename (zero-terminated string)
 * @return 0 on success, negative error code on failure:
 *         -1: Invalid pointer (NULL bitmap or filename)
 *         -2: Invalid dimensions (width or height <= 0)
 *         -3: Memory allocation failed
 *         -4: PNG write failed
 */
XISF_API int SaveBitmapAsPNG(
	const uint16_t* bitmap,
	int width,
	int height,
	const char* filename
);

/**
 * Save a 16-bit greyscale bitmap as a raw binary file with minimal header
 * 
 * File format:
 *   [Magic: 4 bytes "AIMG"]
 *   [Width: 4 bytes uint32_t]
 *   [Height: 4 bytes uint32_t]
 *   [Bit depth: 2 bytes uint16_t (always 16)]
 *   [Reserved: 2 bytes]
 *   [Pixel data: width × height × 2 bytes, 16-bit little-endian]
 * 
 * @param bitmap   Pointer to 16-bit greyscale bitmap data
 * @param width    Width of the bitmap in pixels
 * @param height   Height of the bitmap in pixels
 * @param filename Output filename (zero-terminated string)
 * @return 0 on success, negative error code on failure:
 *         -1: Invalid pointer (NULL bitmap or filename)
 *         -2: Invalid dimensions (width or height <= 0)
 *         -3: Cannot open file
 *         -4: Write failed

XISF_API int SaveBitmapAsBinary(
	const uint16_t* bitmap,
	int width,
	int height,
	const char* filename
);
 */
 
#ifdef __cplusplus
}
#endif

