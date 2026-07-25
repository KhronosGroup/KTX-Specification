/* -*- tab-width: 4; -*- */
/* vi: set sw=2 ts=4 expandtab textwidth=70: */

/*
 * Copyright 2026 The Khronos Group Inc.
 * SPDX-License-Identifier: Apache-2.0
 */

/**
 * @internal
 * @file dxgi2vk.c
 * @~English
 *
 * @brief Test compilation of DXGI-to-Vulkan format mappings.
 *
 * Note that this requires a @c vulkan_core.h and @c dxgiformat.h which is
 * currently hard-coded (i.e., not automatically fetched from some official
 * Microsoft registry due to the non existence of such registry).
 *
 * @author Walid Chtioui, individual contributor (walid.chtioui.main@gmail.com)
 */

#include "vulkan/vulkan_core.h"
#include "dxgi/dxgiformat.h"

/**
 * @brief Return the Vulkan format equivalent to the provided DXGI format.
 *
 * Not all DXGI formats have an equivalent Vulkan format (e.g.,
 * DXGI_\w+_TYPELESS formats are not supported).
 *
 * @param[in] dxgiformat DXGI_FORMAT enumerator value to look up.
 *
 * @return  a VkFormat enum with the equivalent format value.
 *          VK_FORMAT_UNDEFINED if none found.
 */
VkFormat dxgi2vkFormat( DXGI_FORMAT dxgiFormat )
{
    switch ( dxgiFormat )
    {
#include "dxgiFormat2vkFormat.inl"
        default: return VK_FORMAT_UNDEFINED;
    }
}
