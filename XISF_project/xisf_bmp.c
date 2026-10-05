#include "XISF.h"

#include <stdio.h>
#include <stdlib.h>
#include <windows.h>

static int write_u16(FILE* file, uint16_t value)
{
    return fwrite(&value, sizeof(value), 1, file) == 1;
}

static int write_u32(FILE* file, uint32_t value)
{
    return fwrite(&value, sizeof(value), 1, file) == 1;
}

XISF_API int SaveBitmapAsBMP(
    const uint16_t* bitmap,
    int width,
    int height,
    const char* filename
)
{
    if (bitmap == NULL || filename == NULL) {
        return -1;
    }
    if (width <= 0 || height <= 0) {
        return -2;
    }

    const size_t row_stride = ((size_t)width + 3u) & ~3u;
    const size_t image_size = row_stride * (size_t)height;
    if (image_size > UINT32_MAX || 1078u + image_size > UINT32_MAX) {
        return -2;
    }

    FILE* file = fopen(filename, "wb");
    if (file == NULL) {
        return -3;
    }

    int written =
        fwrite("BM", 1, 2, file) == 2 &&
        write_u32(file, (uint32_t)(1078u + image_size)) &&
        write_u16(file, 0) &&
        write_u16(file, 0) &&
        write_u32(file, 1078) &&
        write_u32(file, 40) &&
        write_u32(file, (uint32_t)width) &&
        write_u32(file, (uint32_t)-(int32_t)height) &&
        write_u16(file, 1) &&
        write_u16(file, 8) &&
        write_u32(file, 0) &&
        write_u32(file, (uint32_t)image_size) &&
        write_u32(file, 2835) &&
        write_u32(file, 2835) &&
        write_u32(file, 256) &&
        write_u32(file, 0);

    for (unsigned int value = 0; written && value < 256; ++value) {
        const uint8_t entry[4] = { (uint8_t)value, (uint8_t)value, (uint8_t)value, 0 };
        written = fwrite(entry, 1, sizeof(entry), file) == sizeof(entry);
    }

    uint8_t* row = written ? malloc(row_stride) : NULL;
    if (written && row == NULL) {
        written = 0;
    }
    for (int y = 0; written && y < height; ++y) {
        const uint16_t* source = bitmap + (size_t)y * (size_t)width;
        for (int x = 0; x < width; ++x) {
            row[x] = (uint8_t)(source[x] >> 8);
        }
        for (size_t x = (size_t)width; x < row_stride; ++x) {
            row[x] = 0;
        }
        written = fwrite(row, 1, row_stride, file) == row_stride;
    }
    free(row);

    if (fclose(file) != 0) {
        written = 0;
    }
    return written ? 0 : -4;
}

XISF_API int ReplaceFileAtomic(const char* source, const char* destination)
{
    if (source == NULL || destination == NULL) {
        return -1;
    }
    return MoveFileExA(source, destination, MOVEFILE_REPLACE_EXISTING | MOVEFILE_WRITE_THROUGH)
        ? 0
        : -1;
}
