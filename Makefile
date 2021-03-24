# Copyright (c) 2021 The Khronos Group Inc.
# SPDX-License-Identifier: Apache-2.0

out=out
spec=$(out)/ktxspec_v1.html

default: $(spec)

inlined_images := images/khronos.svg \
                  images/ktx.svg
css := Khronos-App.css default.css
js := generateTOC.js

# To get inliner, "npm install -g inliner".
$(spec): index.html $(out) $(inlined_images) $(css) $(js)
	inliner -n --preserve-comments $< > $@
	# Workaround inliner bug
	sed -e 's%javascript\"/>%javascript\"></script>%' $@ > $(out)/temp
	sed -e 's%toc\"/>%toc\"></div>%' $(out)/temp > $@
	rm $(out)/temp

$(out):
	mkdir -p $@

clean:

clobber: clean
	rm -rf $(out)

# vim: ai noexpandtab tw=72 ts=4 sw=4
