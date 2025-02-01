# Copyright (c) 2014-2017 The Khronos Group Inc.
# Copyright notice at https://www.khronos.org/registry/speccopyright.html

out=out
out.specs = $(out)/specs
out.switches = $(out)/switches
out.ghpages = ${out}/ghpages

ktxspec = $(out.specs)/ktxspec.v2
ktxfrag = $(out.specs)/ktx-frag

all: $(ktxspec).html $(ktxfrag).html #$(ktxspec).pdf

regdoc: $(out.specs)/ktx-media-registration.txt

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
           $(ktx_inlined_images) \
           docinfo.html

frag_inlined_images := icons/ktx_favicon.ico

frag_sources := ktx-frag.adoc \
                khronos.css \
                $(frag_inlined_images) \
                docinfo.html

ghpages.index := $(out.ghpages)/index.html
ghpages.ktxspec := $(out.ghpages)/ktxspec.v2.html
ghpages.ktxfrag := $(out.ghpages)/ktx-frag.html

# For GitHub CI to build GitHub Pages site.
ghpages: $(ghpages.index) $(ghpages.ktxspec) $(ghpages.ktxfrag) images/khronos.svg images/ktx.svg


switches := vkFormat2dxgiFormat.inl \
              vkFormat2glInternalFormat.inl  \
              vkFormat2mtlFormat.inl \
              vkFormat2glFormat.inl \
              vkFormat2glType.inl
switches := $(addprefix ${out.switches}/,${switches})

switches: $(switches)

$(ktxspec).html: $(ktx_sources) | $(out.specs)
	asciidoctor --trace -v --failure-level INFO -r ./inline-images.rb -r ./formats-include.rb -D $(dir $@) -o $(notdir $@) $<

$(ktxfrag).html: $(frag_sources) | $(out.specs)
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
$(out.specs)/ktx-media-registration.txt: ktx-media-registration.adoc | $(out.specs)
	ruby -e '$(pure.rb)' $< >$@

$(ghpages.index): ghpages-index.adoc
	asciidoctor --trace -v --failure-level INFO -r ./inline-images.rb -D $(dir $@) -o $(notdir $@) $<

${out.ghpages}/%.html: ${out.specs}/%.html
	cp $< $@

# &: is the "grouping separator" added in GNU make 4.3 to tell Make that
# the command generates all listed targets. Earlier versionsa treat this
# the same as the : separator and will issue the command for each target.
$(switches) &: formats.json formats.schema.json generate_format_switches.rb | $(out.switches)
	./generate_format_switches.rb $(out.switches)

testswitches: $(switches)
	cd switch_test; $(MAKE) switches_dir=../$(out.switches)

$(out):
	mkdir -p $@

$(out.specs) $(out.switches): | $(out)
	mkdir -p $@

clean:

clobber: clean
	rm -rf $(out.specs) $(out.switches) $(out.ghpages) $(out)

# vim: ai noexpandtab tw=72 ts=4 sw=4
