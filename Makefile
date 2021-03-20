# Copyright (c) 2021 The Khronos Group Inc.
# SPDX-License-Identifier: Apache-2.0

out=out

all: $(out)/index.html

inlined_images := images/khronos.svg \
                  images/ktx.svg
css := Khronos-App.css default.css
js := generateTOC.js

# To get inliner, "npm install -g inliner".
$(out)/index.html: index.html $(out) $(inlined_images) $(css) $(js)
	inliner -n --preserve-comments $< > $@
	# Workaround inliner bug
	sed -e 's%javascript\"/>%javascript\"></script>%' $@ > $(out)/temp
	sed -e 's%toc\"/>%toc\"></div>%' $(out)/temp > $@

$(out):
	mkdir -p $@

clean:

clobber: clean
	rm -rf $(out)

# vim: ai noexpandtab tw=72 ts=4 sw=4
