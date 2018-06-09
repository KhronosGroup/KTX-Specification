#!/usr/bin/perl
# Copyright (c) 2014-2017 The Khronos Group Inc.
# Copyright notice at https://www.khronos.org/registry/speccopyright.html

# Determine if base64 needs -w 0 to prevent wrapping. Versions without
# -w default to no wrapping.
my $b64_exit_code = system("base64 -w 0 </dev/null 2>/dev/null");
my $base64 = "";
if ($b64_exit_code != 0) {
    $base64 = "base64";
} else {
    $base64 = "base64 -w 0";
}

while ($input = <>) {
    # For css...
    while (($svgfile) = $input =~ m!(url\((images|icons)/[^.]+.svg)!) {
        $svgfile =~ s!url\(!!;
        open(FILE, "$base64 $svgfile |");
        $encoded = <FILE>;
        close(FILE);
        $input =~ s!$svgfile!data:image/svg+xml;base64,$encoded!;
    }
    # For <img>
    while (($svgfile) = $input =~ m!(src="(images|icons)/[^.]+.svg)!) {
        $svgfile =~ s/src="//;
        open(FILE, "$base64 $svgfile |");
        $encoded = <FILE>;
        close(FILE);
        $input =~ s!$svgfile!data:image/svg+xml;base64,$encoded!;
    }
    # For css...
    while (($pngfile) = $input =~ m!(url\((images|icons)/[^.]+.png)!) {
        $pngfile =~ s!url\(!!;
        open(FILE, "$base64 $pngfile |");
        $encoded = <FILE>;
        close(FILE);
        $input =~ s!$pngfile!data:image/png+xml;base64,$encoded!;
    }
    no re 'debug';
    no re 'debugcolor';
    # For <img>
    while (($pngfile) = $input =~ m!(src="(images|icons)/[^.]+.png)!) {
        $pngfile =~ s/src="//;
        open(FILE, "$base64 $pngfile |");
        $encoded = <FILE>;
        close(FILE);
        $input =~ s!$pngfile!data:image/png+xml;base64,$encoded!;
    }
    # For <link>
    #use re 'debug';
    #use re 'debugcolor';
    while (($icofile) = $input =~ m!(href="(images|icons)/[^.]+.ico)!) {
        $icofile =~ s/href="//;
        #print STDERR "Matched .ico ";
        #print STDERR $icofile;
        open(FILE, "$base64 $icofile |");
        $encoded = <FILE>;
        close(FILE);
        $input =~ s!$icofile!data:image/x-icon+xml;base64,$encoded!;
    }
    print $input;
}
