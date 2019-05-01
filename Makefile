# Copyright (c) 2014-2017 The Khronos Group Inc.
# Copyright notice at https://www.khronos.org/registry/speccopyright.html

# Use docs for compatibility with GitHub pages.
out=out

all: $(out)/index.html #$(out)/ktx.pdf

inlined_images := icons/masters/ktx_document.svg \
                  icons/win/ktx_document.ico \
                  images/khronos.svg

$(out)/index.html: ktxspec.adoc $(out) $(inlined_images) docinfo.html
	asciidoctor -v --failure-level INFO -r ./inline-images.rb -r ./formats-include.rb -D $(dir $@) -o $(notdir $@) $<

$(out)/ktx.pdf:

$(out):
	mkdir -p $@

clean:

clobber: clean
	rm -rf $(out)

# vim: ai noexpandtab tw=72 ts=4 sw=4
