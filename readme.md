# ForthXISF

Forth package to read and write the XISF file format used by PixInsight.

https://pixinsight.com/doc/docs/XISF-1.0-spec/XISF-1.0-spec.html

## Image context

`IMAGE_CONTEXT` is the shared image representation used by XISF, FITS,
preview, analysis, and solver code. `IMAGE_DESCRIPTOR` remains an alias for
compatibility with existing callers.

The context owns dimensions, pixel data, a `FITS_MAP`, image statistics, and
path buffers. Writers update or project the existing ordered FITS map rather
than maintaining separate metadata objects.

## FITS projection and publication

Load the projection vocabulary through the ForthBase manifest:

```forth
NEED FITS_projection
```

The public words are:

```forth
save-FITSprojection ( img filepath-buffer -- )
replace-file-atomically ( source-buffer destination-buffer -- )
```

`save-FITSprojection` creates the selected directory and writes the image
context's ordered FITS map as UTF-8 `key<TAB>value<CRLF>` lines. It uses an
in-memory buffer before writing the file, avoiding direct map-iterator file
output.

`replace-file-atomically` expects ForthBase buffer descriptors containing
source and destination paths. It appends the required NUL terminators and
uses the native `ReplaceFileAtomic` export, which replaces the destination
only after a completed temporary manifest exists.

## Output pathname policy

`ForthAstroFormats` provides replaceable complete-path composers:

```forth
s" E:\images" $value astro.root
```

The formats package owns this global root; an observatory environment may
replace it with `$-> astro.root`.

```forth
write-preview-image-filepath      ( frame caddr u filepath-buffer -- )
write-preview-stretched-filepath  ( frame caddr u filepath-buffer -- )
write-preview-histogram-filepath  ( frame caddr u filepath-buffer -- )
write-preview-manifest-filepath   ( frame caddr u filepath-buffer -- )
write-metadata-filepath           ( frame caddr u filepath-buffer -- )
write-metadata-manifest-filepath  ( frame caddr u filepath-buffer -- )
write-science-filepath            ( frame caddr u filepath-buffer -- )
```

Each word owns its filename stem and prepares the complete pathname using the
suffix supplied by a filetype writer. Before calling a writer, orchestration
assigns the selected filename creator to:

```forth
write-filepath ( frame caddr u filepath-buffer -- )
```

The writer supplies its own extension. One assignment can therefore be reused
for several filetypes:

```forth
ACTION-OF write-science-filepath TO-DO write-filepath
save-XISFimage ( frame filepath-buffer -- )
save-FITSimage ( frame filepath-buffer -- )
```

A private solver instead temporarily assigns its filename creator directly to
`write-filepath`, calls the FITS writer, and restores the previous action.

`NEED ForthPublication` loads the generic UUID-path and manifest record words.
It owns atomic replacement mechanics; application code retains the policy
deciding which products and manifest keys to publish.

VFXterm is a 32-bit process and must be able to load the Win32 Release
`XISF.dll`. Deploy
`XISF_project\Release\XISF.dll` beside `VFXterm.exe` before exercising any
native XISF export. An unresolved DLL binding can terminate VFX on its first
native call; `FITS_projection_test1.f` verifies the atomic replacement path.

## Preview BMP output

```forth
save-BMPimage ( img bitmap filepath-buffer -- )
```

The native writer saves an 8-bit, top-down grayscale BMP from the high byte of
each 16-bit image sample. The caller supplies the source bitmap and a
ForthBase filepath buffer.

## Tests

`FITS_projection_test1.f` is a standalone `simple-tester` regression suite.
It verifies ordered projection bytes, atomic replacement and source removal,
and XISF/FITS filename generation when `FOCUSPOS` is deliberately empty.
