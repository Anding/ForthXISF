// xisf_png.c : PNG export functionality for XISF library

#include "XISF.h"
#include <stdlib.h>
#include <stdint.h>

#define STB_IMAGE_WRITE_IMPLEMENTATION
#include "stb_image_write.h"

XISF_API int SaveBitmapAsPNG(
    const uint16_t* bitmap,
    int width,
    int height,
    const char* filename
)
{
    // Validate input parameters
    if (bitmap == NULL || filename == NULL) {
        return -1;  // Invalid pointer
    }
    
    if (width <= 0 || height <= 0) {
        return -2;  // Invalid dimensions
    }
    
    // Calculate total number of pixels
    size_t pixel_count = (size_t)width * (size_t)height;
    
    // Allocate temporary buffer for 8-bit data
    uint8_t* output = (uint8_t*)malloc(pixel_count);
    if (output == NULL) {
        return -3;  // Memory allocation failed
    }
    
    // Convert 16-bit to 8-bit by extracting high byte
    for (size_t i = 0; i < pixel_count; i++) {
        output[i] = (uint8_t)(bitmap[i] >> 8);
    }
    
    // Write PNG file (1 channel = greyscale, stride = width)
    int result = stbi_write_png(filename, width, height, 1, output, width);
    
    // Free temporary buffer
    free(output);
    
    // Return result (stbi_write_png returns 0 on failure, non-zero on success)
    return result ? 0 : -4;  // 0 = success, -4 = PNG write failed
}
