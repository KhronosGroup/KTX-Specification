# Copyright (c) 2019 The Khronos Group Inc.

require 'asciidoctor/extensions' unless RUBY_ENGINE == 'opal'
require 'json'

Asciidoctor::Extensions.register do
  include_processor do
    process do |doc, reader, target, attributes|
      return reader unless target == 'formats.json'

      METAL_URL_BASE = 'https://developer.apple.com/documentation/metal/mtlpixelformat/'
      DXGI_URL = 'https://docs.microsoft.com/en-us/windows/desktop/api/dxgiformat/ne-dxgiformat-dxgi_format'
      WEBGL_EX_URL_BASE = 'https://www.khronos.org/registry/webgl/extensions/'

      formats = JSON.parse(File.read(File.join(reader.dir, target)), :symbolize_names => true).freeze

      content = ''
      formats.each do |format|
        content << "#{format[:vkFormat]}::\n"

        content << "Layout:::\n"
        content << "* Type Size: #{format[:typeSize]}.\n"
        if format[:blockWidth] > 0
          content << "* Texel Block Dimensions: #{format[:blockWidth]}x#{format[:blockHeight]}x#{format[:blockDepth]}.\n"
        end

        content << "OpenGL:::\n"
        if format[:glInternalFormat]
          content << "* `glInternalFormat`: #{format[:glInternalFormat]}.\n"

          if format[:glFormat] && format[:glType]
            content << "* `glFormat`: #{format[:glFormat]}.\n"
            content << "* `glType`: #{format[:glType]}.\n"
          end

          write_gl_api_support('OpenGL', format[:glVersion], format[:glExtensions], content)
          write_gl_api_support('OpenGL ES', format[:glEsVersion], format[:glEsExtensions], content)
          write_gl_api_support('WebGL', format[:glWebVersion], format[:glWebExtensions], content)

        else
          content << "* No mapping available.\n"
        end

        content << "Direct3D:::\n"
        if format[:dxgiFormat]
          content << "* `DXGI_FORMAT`: #{DXGI_URL}[#{format[:dxgiFormat]}].\n"
        else
          content << "* No mapping available.\n"
        end

        content << "Metal:::\n"
        if format[:mtlFormat]
          content << "* `MTLPixelFormat`: #{METAL_URL_BASE}#{format[:mtlFormat]}[#{format[:mtlFormat]}].\n"
        else
          content << "* No mapping available.\n"
        end
      end

      reader.push_include content
    end
  end
end

def write_gl_api_support(name, version, extensions, content)
  content << "#{name} Support::::\n"
  
  if version
    content << "** Core #{version}+.\n"
  end

  if extensions
    extensions.each do |exts|
      content << "** "
      content << exts.map{|ext| name == 'WebGL' ? "#{WEBGL_EX_URL_BASE}#{ext}[`#{ext}`]" : "`#{ext}`"}.join(' + ')
      content << ".\n"
    end
  end
  
  if !(version || extensions)
    content << "** None.\n"
  end
end