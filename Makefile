# Copyright (c) 2014-2017 The Khronos Group Inc.
# Copyright notice at https://www.khronos.org/registry/speccopyright.html

# Use docs for compatibility with GitHub pages.
out=out
ktxspec=$(out)/ktxspec.v2
ktxfrag=$(out)/ktx-frag

all: $(ktxspec).html $(ktxfrag).html #$(ktxspec).pdf

regdoc: $(out)/ktx-media-registration.txt

ktx_inlined_images := icons/ktx_favicon.ico \
                  images/cubemap_coord_system.svg \
                  images/khronos.svg \
                  images/ktx.svg \
                  images/logo-spec.svg

appendices=appendices

ktx_sources := ktxspec.adoc \
           $(appendices)/basislz-gdata.adoc \
           $(appendices)/basislz-bitstream.adoc \
		   $(appendices)/vendor-metadata.adoc \
           ktx-media-registration.adoc \
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

# Using a multiline define seemed like a good idea at the time.
# However even with the quotes in the recipe, make only passes the first
# line to the shell so we've made everything a single line with \
# which means we also need ; to indicate statement ends to Ruby.
# Note even with .ONESHELL only the frst line gets passed.
define pure.rb
ktxreg = "https://registry.khronos.org/KTX/specs/2.0"; \
while gets ; \
  if $$_.match(/subs=normal/) then ; \
    puts "\n" ; \
  elsif $$_.match(/link:ktx-frag.html/) then ; \
    $$_[" link:ktx-frag.html\[KTX Fragments URI\]."] = "" ; \
    puts $$_ ; \
    puts "\n    #{ktxreg}/ktx-frag.html\n" ; \
  else ; \
    puts $$_ unless $$_.match(/\.\.\.\./) ; \
  end ; \
end
endef

# Creates pure-text version of media-registration for submission to IANA.
$(out)/ktx-media-registration.txt: ktx-media-registration.adoc $(out)
	ruby -e '$(pure.rb)' $< >$@

$(out):
	mkdir -p $@

clean:

clobber: clean
	rm -rf $(out)

# vim: ai noexpandtab tw=72 ts=4 sw=4
