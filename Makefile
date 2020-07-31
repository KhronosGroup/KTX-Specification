# Copyright (c) 2014-2017 The Khronos Group Inc.
# Copyright notice at https://www.khronos.org/registry/speccopyright.html

# Use docs for compatibility with GitHub pages.
out=out

all: $(out)/index.html $(out)/ktx-frag.html #$(out)/ktx.pdf

inlined_images := icons/masters/ktx_document.svg \
                  icons/win/ktx_document.ico \
                  images/khronos.svg

ktx_sources := ktxspec.adoc \
           ktx-media-registration.txt \
           license.adoc \
           khronos.css \
           $(out) \
           $(inlined_images) \
           docinfo.html

frag_sources : = ktx-frag.adoc \
                 khronos.css

$(out)/index.html: $(ktx_sources)
	asciidoctor --trace -v --failure-level INFO -r ./inline-images.rb -r ./formats-include.rb -D $(dir $@) -o $(notdir $@) $<

$(out)/ktx-frag.html: ktx-frag.adoc
	asciidoctor --trace -v --failure-level INFO -D $(dir $@) -o $(notdir $@) $<

$(out)/ktx.pdf:

$(out):
	mkdir -p $@

clean:

clobber: clean
	rm -rf $(out)

# vim: ai noexpandtab tw=72 ts=4 sw=4
