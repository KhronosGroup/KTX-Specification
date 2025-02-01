## Home of the KTX File Format Specification

[![Build Status](https://travis-ci.org/KhronosGroup/KTX-Specification.svg?branch=master)](https://travis-ci.org/KhronosGroup/KTX-Specification)

KTX is a file format that can be used for storing GPU-ready texture data (with cubemaps, mip levels, etc).
Like DDS but with more features and more formal specification. It supports Basis Universal transcodable formats and supercompression which can yield JPEG-sized universal textures. glTF will use Basis Universal textures in KTX v2 containers.

Click these links to see the latest published versions of the
[KTX File Format Specification](https://registry.khronos.org/KTX/specs/2.0/ktxspec.v2.html) 
or the [KTX Fragment URI Specification](https://registry.khronos.org/KTX/specs/2.0/ktx-frag.html)
from the Khronos KTX Registry, visit the project's
[GitHub Pages](https://github.khronos.org/KTX-Specification/) to see formatted
versions of the latest commits to `main` (both options look much better than
the ersatz views provided by GitHub) or run

```bash
make
```

in a Unix-like environment with [AsciiDoctor](https://asciidoctor.org/docs/install-toolchain/)
installed to generate the publishable specs. They are the files `out/specs/ktxspec.v2.html` and `out/specs/ktx-frag.html`.
Everything needed is inlined.

The canonical KTX spec. text is in the file `ktxspec.adoc`. The canonical fragment URI spec. text is in the file `ktx-frag.html`.

If you have questions or comments that don't merit creating an issue such as "why did you do
so-and-so?" use GitHub [Discussions](https://github.com/KhronosGroup/KTX-Specification/discussions).

### GPU texture format mappings

To ensure correct mappings from Vulkan's `VkFormat` to other GPU APIs, this repo additionally contains:

- [JSON database](formats.json) ([schema](formats.schema.json)) with mappings to OpenGL, Direct3D, and Metal enums.
- [Switch-case generator](generate_format_switches.rb) that produces 5 files with simple C-like case-return statements.
  > **Usage:** `./generate_format_switches.rb [<out_dir>]`
- [Compile test of the case statements](switch_test/vk2gl.c) that serves as an example of use. To try the compile test do

 ```bash
 cd switch_test
 make
 ```
 or
 
 ```bash
 make testswitches
 ```
 

