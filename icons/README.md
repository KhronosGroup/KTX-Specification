Icon Notes
==========

This directory houses the icon masters, in `masters`, exported PNG
files, in `png`, and a Windows icon in `win/ktx_document.ico`; the
last is used as the `favicon` in the specification.

The icons were designed by Manmohan Bishnoi,
[Renuilus Technologies](http://www.renuilus.com/).

The PNG files were exported from the Blender (KTX\_app) and SVG
(KTX\_document) masters.

When exporting `masters/KTX_app.blend`, a white outline should be
added by checking "Edge" in the Post Processing section of the
camera tab of the Properties view and setting the color to white
as shown in this sreen shot from Blender 2.78b.

![Screen shot of Blender render settings](ktx_blender_settings.png)

To open Properties, click the View menu near the bottom left of the
Blender window and select the Properties view. At the top of the
Properties make sure the tab with a picture of a camera on it is
selected.

iOS icons, `.appiconset` directories, can be created using the
[MakeAppIcon](http://makeappicon.com) website, which can be used
for Android icons as well,
[Image2Icon](https://itunes.apple.com/us/app/image2icon-make-your-own-icons/id992115977?mt=12)
or, on Windows, [Axialis Icon
Workshop](http://www.axialis.com/iconworkshop/).

Mac icons, `.icns` files, can be produced from the SVG or PNG files
by
[Image2Icon](https://itunes.apple.com/us/app/image2icon-make-your-own-icons/id992115977?mt=12).
[Axialis IconWorkshop](http://www.axialis.com/iconworkshop/) was
tested for creating these but the files produced had some strange
images at certain sizes. The cause has not been investigated.

Windows icons, `.ico` files, can be produced from the SVG or PNG
files by [Axialis IconWorkshop](http://www.axialis.com/iconworkshop/).
On macOS,
[Image2Icon](https://itunes.apple.com/us/app/image2icon-make-your-own-icons/id992115977?mt=12)
can be used to create `.ico` files but an in-app purchase is required
to enable this function. Furthermore the size is limited to 256x256.
Windows 10 wants 768x768. This may be fixed in a forthcoming release.

