# Copyright (c) 2014-2017 The Khronos Group Inc.
# Copyright notice at https://www.khronos.org/registry/speccopyright.html

# Use docs for compatibility with GitHub pages.
out=out
intermediate=build

all: $(out)/index.html #$(out)/ktx.pdf

inlined_images := icons/masters/ktx_document.svg \
                  icons/win/ktx_document.ico \
                  images/khronos.svg

$(intermediate)/docinfo.html: docinfo.html $(intermediate) inlineimages.pl $(inlined_images)
	./inlineimages.pl < $< > $@

$(out)/index.html: ktxspec.adoc $(out) $(intermediate)/docinfo.html
	asciidoctor -a docinfodir=$(intermediate) -D $(dir $@) -o $(notdir $@) $<

$(out)/ktx.pdf:

$(intermediate) $(out):
	mkdir -p $@

clean:
	rm -rf $(intermediate)

clobber: clean
	rm -rf $(out)

# vim: ai noexpandtab tw=72 ts=4 sw=4
