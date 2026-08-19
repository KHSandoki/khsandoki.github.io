# khsandoki.github.io

Personal portfolio — [khsandoki.github.io](https://khsandoki.github.io/)

Static HTML and CSS with no build step. GitHub Pages serves the repository root as-is.

## Layout

```
index.html              Landing page: hero, work grid, timeline, skills, about
projects/*.html         One page per project
assets/css/site.css     All styling
assets/js/site.js       Gallery lightbox (no dependencies)
assets/src/             Source files offered for download
media/<project>/        Web-ready images, generated — see below
tools/build_media.py    Image pipeline
```

## Images

Source photographs live outside this repository on archive drives. They are 4–7 MB
each and carry EXIF, so they are never committed directly. `tools/build_media.py`
holds the manifest mapping source paths to output names, and for each one emits:

| Output | Size | Used by |
|---|---|---|
| `<name>.webp` | max 1800 px, q84 | Page heroes, lightbox |
| `<name>@thumb.webp` | max 800 px, q76 | Cards, gallery tiles |

Rotation is baked in from EXIF and then **all metadata is dropped**, GPS included.

```bash
python tools/build_media.py     # re-runnable; skips outputs newer than their source
```

Adding a photo means adding one line to `MANIFEST` and re-running. If a source drive
is not mounted the script reports the missing entries and exits non-zero rather than
silently producing a half-built `media/`.

## Local preview

```bash
python -m http.server 8000
```

Then open <http://localhost:8000>. Opening `index.html` from the filesystem works too,
but relative paths behave more like production over HTTP.
