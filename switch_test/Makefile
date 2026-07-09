# -*- tab-width: 4; -*-

# Copyright 2024 Mark Callow.
# SPDX-License-Identifier: Apache-2.0

depth := ..
dest := build
switches_dir ?= $(dest)
switches := vkFormat2glFormat.inl \
            vkFormat2glInternalFormat.inl \
            vkFormat2glType.inl
switches := $(addprefix ${switches_dir}/,${switches})

# Make a switches dir relative to the directory $(depth) because that is where
# generate_format_switches must be run.
ifeq ($(switches_dir), $(dest))
  # Produces a full path name. $(dir ...) results ends in a'/' so $(notdir ...)
  # would return an empty string.
  generated_switches_dir := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))$(dest)
else
  generated_switches_dir := $(subst $(depth)/,,${switches_dir})
endif


glheaders_list := $(addprefix GL/,glcorearb.h)
glheaders_installed := $(addprefix ${dest}/,${glheaders_list})
khrheaders_list := $(addprefix KHR/,khrplatform.h)
khrheaders_installed := $(addprefix ${dest}/,${khrheaders_list})
vkheaders_list := $(addprefix vulkan/,vulkan.h)
vkheaders_installed := $(addprefix ${dest}/,${vkheaders_list})

vkdeps_vulkan_list := $(addprefix vulkan/,vk_platform.h vulkan_core.h)
vkdeps_vkvid_list := $(addprefix vk_video/, \
             vulkan_video_codecs_common.h \
             vulkan_video_codec_h264std.h \
             vulkan_video_codec_h264std_encode.h \
             vulkan_video_codec_h265std.h \
             vulkan_video_codec_h265std_encode.h \
             vulkan_video_codec_av1std.h \
             vulkan_video_codec_av1std_decode.h \
             vulkan_video_codec_vp9std.h \
             vulkan_video_codec_vp9std_decode.h)
vkdeps_vulkan_installed := $(addprefix ${dest}/,${vkdeps_vulkan_list})
vkdeps_vkvid_installed := $(addprefix ${dest}/,${vkdeps_vkvid_list})

khrregistry := https://registry.khronos.org
vkheaderrepo := https://raw.githubusercontent.com/KhronosGroup/Vulkan-Headers/main/include

switches := $(switches)
headers := ${glheaders_installed} ${khrheaders_installed} ${vkheaders_installed}

default: test_compile
test_compile: $(dest)/vk2gl.o

CFLAGS := -I $(switches_dir) -I $(dest) -Werror -c

$(dest)/vk2gl.o: $(switches) $(headers) | $(dest)
	$(CC) $(CFLAGS) -o $@ vk2gl.c

# &: is the "grouping separator" added in GNU make 4.3 to tell Make that
# the command generates all listed targets. Earlier versionsa treat this
# the same as the : separator and will issue the command for each target.
$(switches) &: $(depth)/formats.json $(depth)/formats.schema.json $(depth)/generate_format_switches.rb | $(dest)
	cd $(depth); ./generate_format_switches.rb $(generated_switches_dir)

wget := wget --user-agent "KtxSpecBot/1.0; (+https://github.com/khronosgroup/KTX-Specification)"
ifdef GH_TOKEN
  wget := $(wget) --header="Authorization: token $(GH_TOKEN)"
endif

$(glheaders_installed)&: | $(dest)
	$(wget) -P $(dir $@) $(addprefix $(khrregistry)/OpenGL/api/,${glheaders_list})

$(khrheaders_installed)&: | $(dest)
	$(wget) -P $(dir $@) $(addprefix $(khrregistry)/EGL/api/,${khrheaders_list})

$(vkheaders_installed)&: | $(dest) $(vkdeps_vulkan_installed) $(vkdeps_vkvid_installed)
	$(wget) -P $(dir $@) $(addprefix ${vkheaderrepo}/,${vkheaders_list})

$(vkdeps_vulkan_installed)&: | $(dest)
	$(wget) -P $(dir $@) $(addprefix ${vkheaderrepo}/,${vkdeps_vulkan_list})

$(vkdeps_vkvid_installed)&: | $(dest)
	$(wget) -P $(dir $@) $(addprefix ${vkheaderrepo}/,${vkdeps_vkvid_list})

$(dest):
	mkdir -p $@

clean:
	rm -rf $(addprefix ${dest}/,GL KHR vk_video vulkan)

clobber: clean
	rm -f $(dest)/vk2gl.o ${dest}/*.inl
	rmdir ${dest}

# vim: ai noexpandtab ts=4 sw=4
