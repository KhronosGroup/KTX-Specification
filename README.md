## Home of the KTX File Format Specification

[![Build Status](https://travis-ci.org/KhronosGroup/KTX-Specification.svg?branch=master)](https://travis-ci.org/KhronosGroup/KTX-Specification)

KTX is a file format that can be used for storing GPU-ready texture data (with cubemaps, mip levels, etc).
Like DDS but with more features and more formal specification. It supports Basis Universal transcodable formats and supercompression which can yield JPEG-sized universal textures. glTF will use Basis Universal textures in KTX v2 containers.

Click to see the [latest published version](https://github.khronos.org/KTX-Specification/)
(it looks much better than the ersatz view provided by GitHub) or run

```.bash
make
```

in a Unix-like environment with [AsciiDoctor](https://asciidoctor.org/docs/install-toolchain/)
installed to generate the publishable spec. This is the single file `out/index.html`.
Everything needed is inlined.

The canonical spec. text is in the file `ktxspec.adoc`.

### <a id="kwexpansion"></a>$Date$ keyword expansion

A few auxiliary  files have `$Date$` keywords. If you care about having
the proper dates shown on files in your workspace, you **must** follow the
instructions below.

$Date$ keywords are expanded via a smudge & clean filter. To install
the filter, issue the following commands in the root of your clone.

On Unix (Linux, Mac OS X, etc.) platforms and Windows using Git for Windows'
Git Bash or Cygwin's bash terminal:

```bash
./install-gitconfig.sh
rm TODO.md
git checkout TODO.md
```

On Windows with the Command Prompt (requires `git.exe` in a directory
on your %PATH%):

```cmd
install-gitconfig.bat
del TODO.md
git checkout TODO.md
```

The first command adds an [include] of the repo's `.gitconfig` to the
local git config file `.git/config`, i.e. the one in your clone of the repo.
`.gitconfig` contains the config of the "dater" filter. The remaining
commands force a new checkout of the affected files to smudge them with the
date. These two are unnecessary if you plan to edit these files.

