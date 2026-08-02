# imageCompressor

**k-means colour compression, in Haskell** — pure, functional, no mutable state.

Reduces an image's palette to **K colours** by clustering the pixels in RGB space
(k-means), then repainting each pixel with its cluster's average colour.

---

## Build

```sh
make            # stack build + copies the ./imageCompressor binary
# or:  stack build
```

## Usage

```sh
./imageCompressor -n N -l L -f FILE
```

| flag   | meaning                                                        |
|--------|----------------------------------------------------------------|
| `-n N` | number of colours in the output                                |
| `-l L` | convergence limit (smaller = more iterations, finer result)    |
| `-f F` | path to the pixel file                                         |

### Input format

One pixel per line — position then colour: `(x,y) (r,g,b)`

```
(0,0) (135,161,196)
(1,0) (134,160,195)
...
```

## How it works — k-means

1. pick `N` random centroids
2. assign each pixel to the **nearest** centroid (RGB distance)
3. move each centroid to the **mean** colour of its pixels
4. repeat until the centroids stop moving (movement < `L`)

---

## Results

Run on a real photo (Mount Fuji over Lake Tanuki, 256 × 171). Every `.ppm`
output lives in [`result/`](https://github.com/Perry-chouteau/image_compressor/tree/main/result); the previews below are the same images as
PNG (GitHub does not render `.ppm` inline).

| ![](https://raw.githubusercontent.com/Perry-chouteau/image_compressor/main/docs/media/original.png) | ![](https://raw.githubusercontent.com/Perry-chouteau/image_compressor/main/docs/media/compressed_n2.png) | ![](https://raw.githubusercontent.com/Perry-chouteau/image_compressor/main/docs/media/compressed_n4.png) | ![](https://raw.githubusercontent.com/Perry-chouteau/image_compressor/main/docs/media/compressed_n8.png) |
|:---:|:---:|:---:|:---:|
| **original** | **`-n 2`** | **`-n 4`** | **`-n 8`** |
| ![](https://raw.githubusercontent.com/Perry-chouteau/image_compressor/main/docs/media/compressed_n16.png) | ![](https://raw.githubusercontent.com/Perry-chouteau/image_compressor/main/docs/media/compressed_n32.png) | ![](https://raw.githubusercontent.com/Perry-chouteau/image_compressor/main/docs/media/compressed_n64.png) | ![](https://raw.githubusercontent.com/Perry-chouteau/image_compressor/main/docs/media/compressed_n128.png) |
| **`-n 16`** | **`-n 32`** | **`-n 64`** | **`-n 128`** |
| ![](https://raw.githubusercontent.com/Perry-chouteau/image_compressor/main/docs/media/compressed_n256.png) | ![](https://raw.githubusercontent.com/Perry-chouteau/image_compressor/main/docs/media/compressed_n512.png) | ![](https://raw.githubusercontent.com/Perry-chouteau/image_compressor/main/docs/media/original.png) | |
| **`-n 256`** | **`-n 512`** | **original** (ref) | |

Even **8 colours** already reads as "Fuji"; from **32** the scene is clear, and
**256 / 512** recover the smooth shades (sky gradient, snow) that lower counts drop.

## Compression — the real sizes

The tool works on **PPM/pixel data**, and reducing to `K` colours is an
**information** saving. A raw `.ppm` never shrinks — PPM has no palette, it stores
full RGB per pixel — so the gain shows up the moment the result is stored in a
real palette format. Below, each output saved as an **indexed `.png`** (a real
image file), measured against the 24-bit original:

| colours `-n` | image file `.png` | vs original | (`.ppm.gz`) |
|:--:|:--:|:--:|:--:|
| original (24-bit) | 66.5 KB | 1× | 79.8 KB |
| **512** | 38.7 KB *(RGB)* | **1.7×** | 18.1 KB |
| **256** | 12.0 KB | **5.5×** | 14.3 KB |
| **128** | 10.8 KB | **6.2× smaller** | 13.0 KB |
| **64**  | 10.0 KB | **6.7×** | 11.9 KB |
| **32**  |  7.1 KB | **9.4×** |  8.5 KB |
| **16**  |  7.2 KB | **9.2×** |  8.7 KB |
| **8**   |  5.5 KB | **12.0×** |  6.6 KB |
| **4**   |  2.6 KB | **25.7×** |  3.2 KB |
| **2**   |  0.6 KB | **108×** |  0.8 KB |

So the headline result: a **66 KB photo → 5.5 KB at 8 colours (12× smaller)**,
still perfectly readable.

> Why two columns? The raw `.ppm` files in [`result/`](https://github.com/Perry-chouteau/image_compressor/tree/main/result) are **all 128 KB** —
> PPM has no palette, so the format itself gains nothing. The `.png` column is the
> same image stored as a real indexed format; the `.ppm.gz` column is the raw PPM
> gzipped. Both show the true saving from cutting colours.
>
> **`-n 512`** is stored as RGB — a PNG palette maxes out at 256 colours — so its
> `.png` no longer benefits from indexing; read the `.ppm.gz` column there.

---

## Project layout

| file | role |
|------|------|
| `src/Parser.hs` | reads and splits the pixel file |
| `src/Image.hs`  | pixels, clusters, centroids, k-means maths |
| `src/Rand.hs`   | random centroid initialisation |
| `src/Lib.hs`    | argument parsing + the k-means loop |
| `app/Main.hs`   | entry point |
| `result/`       | `.ppm` outputs for N = 2 … 512 |
| `docs/media/`   | PNG previews |
