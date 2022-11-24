# Copyright (c) 2014-2017 The Khronos Group Inc.
# Copyright notice at https://www.khronos.org/registry/speccopyright.html

# Use docs for compatibility with GitHub pages.
out=out
ktxspec=$(out)/ktxspec_v2
ktxfrag=$(out)/ktx_frag

all: $(ktxspec).html $(ktxfrag).html #$(ktxspec).pdf

ktx_inlined_images := icons/ktx_favicon.ico \
                  images/cubemap_coord_system.svg \
                  images/khronos.svg \
                  images/ktx.svg \
                  images/logo-spec.svg

ktx_sources := ktxspec.adoc \
           ktx-media-registration.txt \
           license.adoc \
           khronos.css \
           $(out) \
           $(ktx_inlined_images) \
           docinfo.html

frag_inlined_images := icons/ktx_favicon.ico

frag_sources := ktx-frag.adoc \
                khronos.css \
                $(out) \
                $(frag_inlined_images) \
                docinfo.html

$(ktxspec).html: $(ktx_sources)
	asciidoctor --trace -v --failure-level INFO -r ./inline-images.rb -r ./formats-include.rb -D $(dir $@) -o $(notdir $@) $<

$(ktxfrag).html: $(frag_sources)
	asciidoctor --trace -v --failure-level INFO -r ./inline-images.rb -D $(dir $@) -o $(notdir $@) $<

$(ktxspec).pdf:

$(out):
	mkdir -p $@

clean:

clobber: clean
	rm -rf $(out)

# vim: ai noexpandtab tw=72 ts=4 sw=4
