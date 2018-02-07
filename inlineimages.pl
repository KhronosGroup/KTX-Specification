#!/usr/bin/perl
# Copyright (c) 2014-2017 The Khronos Group Inc.
# Copyright notice at https://www.khronos.org/registry/speccopyright.html
while ($input = <>) {
    # For css...
    while (($svgfile) = $input =~ m!(url\((images|icons)/[^.]+.svg)!) {
        $svgfile =~ s!url\(!!;
        open(FILE, "base64 $svgfile |");
        $encoded = <FILE>;
        close(FILE);
        $input =~ s!$svgfile!data:image/svg+xml;base64,$encoded!;
    }
    # For <img>
    while (($svgfile) = $input =~ m!(src="(images|icons)/[^.]+.svg)!) {
        $svgfile =~ s/src="//;
        open(FILE, "base64 $svgfile |");
        $encoded = <FILE>;
        close(FILE);
        $input =~ s!$svgfile!data:image/svg+xml;base64,$encoded!;
    }
    # For css...
    while (($pngfile) = $input =~ m!(url\((images|icons)/[^.]+.png)!) {
        $pngfile =~ s!url\(!!;
        open(FILE, "base64 $pngfile |");
        $encoded = <FILE>;
        close(FILE);
        $input =~ s!$pngfile!data:image/png+xml;base64,$encoded!;
    }
    no re 'debug';
    no re 'debugcolor';
    # For <img>
    while (($pngfile) = $input =~ m!(src="(images|icons)/[^.]+.png)!) {
        $pngfile =~ s/src="//;
        open(FILE, "base64 $pngfile |");
        $encoded = <FILE>;
        close(FILE);
        $input =~ s!$pngfile!data:image/png+xml;base64,$encoded!;
    }
    # For <link>
    while (($icofile) = $input =~ m!(href="(images|icons)/[^.]+.ico)!) {
        $icofile =~ s/href="//;
        open(FILE, "base64 $icofile |");
        $encoded = <FILE>;
        close(FILE);
        $input =~ s!$icofile!data:image/x-icon+xml;base64,$encoded!;
    }
    print $input;
}
