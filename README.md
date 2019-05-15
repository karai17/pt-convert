# PT Convert

Copy any files you wish to process into the `./data` directory and run the following command:

```sh
love .
```

New `ASE` and `PNG` files will be created in the LOVE save directory with the same directory structure as the raw data. All files except for `ASE`, `BMP`, and `TGA` files will be ignored.

If you place `BMP` files in the `./data/ui` directory, all black pixels will be replaced with transparent pixels.
