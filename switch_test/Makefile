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

khrregistry := https://registry.khronos.org

# This is to use the specially generated vulkan_core.h with the ASTC 3D
# format enumerators.
vkheaderrepo := https://raw.githubusercontent.com/KhronosGroup/dfdutils/main/
vkheaders := vulkan/vk_platform.h
# The following are to use the standard Vulkan headers. Currently these
# do not include the ASTC 3D enumerators so cannot be used to compile
# the generated switches.
#vkheaderrepo := https://raw.githubusercontent.com/KhronosGroup/Vulkan-Headers/main/include
#vkheaders := vulkan/vk_platform.h \
#             vk_video/vulkan_video_codec_h264std.h \
#             vk_video/vulkan_video_codec_h264std_encode.h \
#             vk_video/vulkan_video_codecs_common.h \
#             vk_video/vulkan_video_codec_av1std.h \
#             vk_video/vulkan_video_codec_av1std_decode.h
vkheaders := $(addprefix ${dest}/,${vkheaders})

default: test_compile
switches: $(switches)
headers: $(dest) $(addprefix ${dest}/,GL/glcorearb.h KHR/khrplatform.h vulkan/vulkan_core.h)
test_compile: $(dest)/vk2gl.o

CFLAGS := -I $(switches_dir) -I $(dest) -Werror -c

$(dest)/vk2gl.o: switches headers | $(dest)
	$(CC) $(CFLAGS) -o $@ vk2gl.c

# &: is the "grouping separator" added in GNU make 4.3 to tell Make that
# the command generates all listed targets. Earlier versionsa treat this
# the same as the : separator and will issue the command for each target.
$(switches) &: $(depth)/formats.json $(depth)/formats.schema.json $(depth)/generate_format_switches.rb |$(dest)
	cd $(depth); ./generate_format_switches.rb $(generated_switches_dir)

$(dest)/GL/glcorearb.h:
	curl --create-dirs --output-dir $(dest)/GL -L -O $(khrregistry)/OpenGL/api/GL/glcorearb.h

$(dest)/KHR/khrplatform.h:
	curl --create-dirs --output-dir $(dest)/KHR -L -O $(khrregistry)/EGL/api/KHR/khrplatform.h

$(dest)/vulkan/vulkan_core.h: $(vkheaders)

$(dest)/vulkan/vulkan_core.h $(vkheaders):
	curl --create-dirs --output-dir $(dir $@) -L -O $(vkheaderrepo)/$(subst ${dest}/,,$@)

$(dest):
	mkdir -p $@

# vim: ai noexpandtab ts=4 sw=4
