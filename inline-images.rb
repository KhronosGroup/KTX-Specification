# Copyright (c) 2019 The Khronos Group Inc.

require 'asciidoctor/extensions' unless RUBY_ENGINE == 'opal'
require 'base64'

Asciidoctor::Extensions.register do
  postprocessor do
    process do |document, output|
      _replace_urls(output) if document.basebackend? 'html'
    end
  end
end

MIME_TYPES = {
    '.png' => 'image/png',
    '.svg' => 'image/svg+xml',
    '.ico' => 'image/x-icon'}.freeze

REGEX = /(?<=url\()[^.]+.(svg|png)(?=\))|(?<=href=")[^.]+.(ico|png|svg)(?=")/

def _replace_urls(content)
  content.gsub(REGEX) do |filename|
    file = File.binread(filename)
    mime_type = MIME_TYPES[File.extname(filename)]
    "data:#{mime_type};base64,#{Base64.strict_encode64(file)}"
  end
end