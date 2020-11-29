# Copyright (c) 2020 The Khronos Group Inc.
# SPDX-License-Identifier: Apache-2.0

require 'json'
formats = JSON.parse(File.read('formats.json'), :symbolize_names => true).freeze
targets = [:glFormat, :glType, :glInternalFormat, :dxgiFormat, :mtlFormat].freeze
HEADER = %{// Copyright 2020 The Khronos Group Inc.
// SPDX-License-Identifier: Apache-2.0

/***************************** Do not edit.  *****************************
             Automatically generated by generate_format_switches.rb
 *************************************************************************/
}

files = targets.map { |target| [target, File.open("vkFormat2#{target}.inl", 'w')] }.to_h.freeze
files.values.each { |file| file << HEADER }
formats.each do |format|
  files.each do |target, file|
    file << "case #{format[:vkFormat]}: return #{format[target]};\n" if format[target]
  end
end
files.values.each(&:close)
