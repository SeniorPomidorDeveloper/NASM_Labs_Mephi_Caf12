#include <jpeglib.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>


// Объявление nasm-функции
void mirror_horizontal_asm(uint8_t *image, int width, int height, int channels);

double get_time_ms()
{
    struct timespec ts;
    clock_gettime(CLOCK_MONOTONIC, &ts);
    return (ts.tv_sec * 1e3) + (ts.tv_nsec / 1e6);
}


// Функция для отражения по горизонтали
void mirror_horizontal(uint8_t *image, int width, int height, int channels)
{
    for (int y = 0; y < height; ++y)
    {
        uint8_t *row = image + y * width * channels;
        for (int x = 0; x < width / 2; ++x)
        {
            for (int c = 0; c < channels; ++c)
            {
                uint8_t tmp = row[x * channels + c];
                row[x * channels + c] = row[(width - 1 - x) * channels + c];
                row[(width - 1 - x) * channels + c] = tmp;
            }
        }
    }
}

// Загрузка JPEG
uint8_t *load_jpeg(const char *filename, int *width, int *height, int *channels)
{
    FILE *infile = fopen(filename, "rb");
    if (!infile)
    {
        perror("fopen");
        return NULL;
    }
    struct jpeg_decompress_struct cinfo;
    struct jpeg_error_mgr jerr;
    cinfo.err = jpeg_std_error(&jerr);
    jpeg_create_decompress(&cinfo);
    jpeg_stdio_src(&cinfo, infile);
    jpeg_read_header(&cinfo, TRUE);
    jpeg_start_decompress(&cinfo);

    *width = cinfo.output_width;
    *height = cinfo.output_height;
    *channels = cinfo.output_components;
    size_t row_stride = (*width) * (*channels);
    uint8_t *image = malloc((*width) * (*height) * (*channels));
    if (!image)
    {
        fclose(infile);
        return NULL;
    }

    while (cinfo.output_scanline < cinfo.output_height)
    {
        uint8_t *rowptr = image + cinfo.output_scanline * row_stride;
        jpeg_read_scanlines(&cinfo, &rowptr, 1);
    }
    jpeg_finish_decompress(&cinfo);
    jpeg_destroy_decompress(&cinfo);
    fclose(infile);
    return image;
}

// Сохранение JPEG
int save_jpeg(const char *filename,
              uint8_t *image,
              int width,
              int height,
              int channels,
              int quality)
{
    FILE *outfile = fopen(filename, "wb");
    if (!outfile)
    {
        return 1;
    }
    struct jpeg_compress_struct cinfo;
    struct jpeg_error_mgr jerr;
    cinfo.err = jpeg_std_error(&jerr);
    jpeg_create_compress(&cinfo);
    jpeg_stdio_dest(&cinfo, outfile);
    cinfo.image_width = width;
    cinfo.image_height = height;
    cinfo.input_components = channels;
    cinfo.in_color_space = (channels == 1) ? JCS_GRAYSCALE : JCS_RGB;
    jpeg_set_defaults(&cinfo);
    jpeg_set_quality(&cinfo, quality, TRUE);
    jpeg_start_compress(&cinfo, TRUE);

    size_t row_stride = width * channels;
    while (cinfo.next_scanline < cinfo.image_height)
    {
        uint8_t *rowptr = image + cinfo.next_scanline * row_stride;
        jpeg_write_scanlines(&cinfo, &rowptr, 1);
    }
    jpeg_finish_compress(&cinfo);
    jpeg_destroy_compress(&cinfo);
    fclose(outfile);
    return 0;
}

int main(int argc, char *argv[])
{
    if (argc < 4)
    {
        printf("Usage: %s in.jpg out_c.jpg out_asm.jpg\n", argv[0]);
        return 1;
    }
    int width, height, channels;
    uint8_t *image = load_jpeg(argv[1], &width, &height, &channels);
    if (!image)
    {
        printf("Error loading image\n");
        return 1;
    }

    // // Таймирование C-функции
    uint8_t *clone = malloc(width * height * channels);
    memcpy(clone, image, width * height * channels);

    double t0 = get_time_ms();
    mirror_horizontal(clone, width, height, channels);
    double t1 = get_time_ms();
    printf("C mirror_horizontal: %.3f ms\n", t1 - t0);
    save_jpeg(argv[2], clone, width, height, channels, 90);

    // Таймирование asm-функции
    memcpy(clone, image, width * height * channels); // восстановить данные
    t0 = get_time_ms();
    mirror_horizontal_asm(clone, width, height, channels);
    t1 = get_time_ms();
    printf("ASM mirror_horizontal: %.3f ms\n", t1 - t0);
    save_jpeg(argv[3], clone, width, height, channels, 90);

    free(image);
    free(clone);
    return 0;
}
