/*
 * Test program for XISF PNG export DLL
 * 
 * This program creates a 16-bit greyscale bitmap with a test pattern
 * and saves it as a PNG file using the XISF DLL.
 */

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <math.h>

// Import the DLL function
__declspec(dllimport) int SaveBitmapAsPNG(
    const uint16_t* bitmap,
    int width,
    int height,
    const char* filename
);

/*
 * Generate a test pattern with multiple features:
 * - Diagonal gradient
 * - Concentric circles
 * - Checkerboard pattern
 */
void generate_test_pattern(uint16_t* bitmap, int width, int height)
{
    int x, y;
    double center_x = width / 2.0;
    double center_y = height / 2.0;
    double max_dist = sqrt(center_x * center_x + center_y * center_y);
    
    for (y = 0; y < height; y++) {
        for (x = 0; x < width; x++) {
            int index = y * width + x;
            
            // Component 1: Diagonal gradient (0-21845 range)
            double gradient = ((double)x / width + (double)y / height) * 0.5;
            uint16_t grad_value = (uint16_t)(gradient * 21845.0);
            
            // Component 2: Concentric circles (0-21845 range)
            double dx = x - center_x;
            double dy = y - center_y;
            double dist = sqrt(dx * dx + dy * dy);
            double circle = fmod(dist / max_dist * 10.0, 1.0); // 10 rings
            uint16_t circle_value = (uint16_t)(circle * 21845.0);
            
            // Component 3: Checkerboard pattern (0-21845 range)
            int check_size = 32; // Size of checkerboard squares
            int checker = ((x / check_size) + (y / check_size)) % 2;
            uint16_t check_value = checker ? 21845 : 0;
            
            // Combine all components (scaled to 16-bit range)
            bitmap[index] = grad_value + circle_value + check_value;
        }
    }
}

/*
 * Generate a simple gradient pattern for testing
 */
void generate_gradient_pattern(uint16_t* bitmap, int width, int height)
{
    int x, y;
    
    for (y = 0; y < height; y++) {
        for (x = 0; x < width; x++) {
            int index = y * width + x;
            
            // Horizontal gradient from black to white
            bitmap[index] = (uint16_t)((double)x / (width - 1) * 65535.0);
        }
    }
}

/*
 * Generate a radial gradient pattern
 */
void generate_radial_pattern(uint16_t* bitmap, int width, int height)
{
    int x, y;
    double center_x = width / 2.0;
    double center_y = height / 2.0;
    double max_dist = sqrt(center_x * center_x + center_y * center_y);
    
    for (y = 0; y < height; y++) {
        for (x = 0; x < width; x++) {
            int index = y * width + x;
            
            double dx = x - center_x;
            double dy = y - center_y;
            double dist = sqrt(dx * dx + dy * dy);
            double normalized = dist / max_dist; // 0.0 at center, 1.0 at corners
            
            // Clamp to [0, 1] range
            if (normalized > 1.0) normalized = 1.0;
            
            bitmap[index] = (uint16_t)(normalized * 65535.0);
        }
    }
}

int main(int argc, char* argv[])
{
    const int width = 512;
    const int height = 512;
    const char* filename_test = "test_pattern.png";
    const char* filename_gradient = "test_gradient.png";
    const char* filename_radial = "test_radial.png";
    
    // Allocate memory for bitmap
    uint16_t* bitmap = (uint16_t*)malloc(width * height * sizeof(uint16_t));
    if (!bitmap) {
        fprintf(stderr, "ERROR: Failed to allocate memory for bitmap\n");
        return 1;
    }
    
    printf("XISF PNG Export Test\n");
    printf("====================\n\n");
    printf("Image dimensions: %d x %d\n", width, height);
    printf("Bit depth: 16-bit greyscale\n\n");
    
    // Test 1: Complex pattern
    printf("Generating complex test pattern...\n");
    generate_test_pattern(bitmap, width, height);
    printf("Saving as '%s'...\n", filename_test);
    int result = SaveBitmapAsPNG(bitmap, width, height, filename_test);
    if (result == 0) {
        printf("SUCCESS: Test pattern saved successfully!\n\n");
    } else {
        fprintf(stderr, "ERROR: Failed to save test pattern (error code: %d)\n", result);
        fprintf(stderr, "Error codes: -1=NULL pointer, -2=Invalid dimensions, -3=Memory allocation, -4=PNG write\n\n");
    }
    
    // Test 2: Simple gradient
    printf("Generating horizontal gradient...\n");
    generate_gradient_pattern(bitmap, width, height);
    printf("Saving as '%s'...\n", filename_gradient);
    result = SaveBitmapAsPNG(bitmap, width, height, filename_gradient);
    if (result == 0) {
        printf("SUCCESS: Gradient saved successfully!\n\n");
    } else {
        fprintf(stderr, "ERROR: Failed to save gradient (error code: %d)\n\n", result);
    }
    
    // Test 3: Radial gradient
    printf("Generating radial gradient...\n");
    generate_radial_pattern(bitmap, width, height);
    printf("Saving as '%s'...\n", filename_radial);
    result = SaveBitmapAsPNG(bitmap, width, height, filename_radial);
    if (result == 0) {
        printf("SUCCESS: Radial gradient saved successfully!\n\n");
    } else {
        fprintf(stderr, "ERROR: Failed to save radial gradient (error code: %d)\n\n", result);
    }
    
    // Clean up
    free(bitmap);
    
    printf("Test complete! Open the PNG files in a browser to inspect them.\n");
    printf("Files created:\n");
    printf("  - %s (complex test pattern)\n", filename_test);
    printf("  - %s (horizontal gradient)\n", filename_gradient);
    printf("  - %s (radial gradient)\n", filename_radial);
    
    return 0;
}
