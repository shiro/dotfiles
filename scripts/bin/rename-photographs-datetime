#!/bin/zsh


# caveat: if multiple files map to the same filename and not all have sidecars, the sidecars will probably have the
# wrong sequence number at the end

# xmp files
# the `%-7F` is a hack that extracts the last 7 chars, since we need to get a 2nd level extension
exiftool -d "%Y-%m-%d_%Hh%Mm%S%%-03.c" '-FileName<${DateTimeOriginal}.%-7F' -ext xmp -tagsfromfile %f -fileOrder -filename $@

# NEF files
for ext in NEF JPG MOV; do
  exiftool -d "%Y-%m-%d_%Hh%Mm%S%%-03.c" '-FileName<${DateTimeOriginal}.%e' -ext $ext -fileOrder -filename $@
done
