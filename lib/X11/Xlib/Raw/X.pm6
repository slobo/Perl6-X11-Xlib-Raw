# TODO: this actually is not tied to Xlib, should be moved up a namespace perhaps
unit package X11::Xlib::Raw::X;

enum XErrorCodes is export (
  Success             => 0, #= everything's okay
  BadRequest          => 1, #= bad request code
  BadValue            => 2, #= int parameter out of range
  BadWindow           => 3, #= parameter not a Window
  BadPixmap           => 4, #= parameter not a Pixmap
  BadAtom             => 5, #= parameter not an Atom
  BadCursor           => 6, #= parameter not a Cursor
  BadFont             => 7, #= parameter not a Font
  BadMatch            => 8, #= parameter mismatch
  BadDrawable         => 9, #= parameter not a Pixmap or Window

  #| depending on context:
  #|   - key/button already grabbed
  #|   - attempt to free an illegal cmap entry
  #|   - attempt to store into a read-only color map entry.
  #|   - attempt to modify the access control list from other than the local host.
  BadAccess           => 10,

  BadAlloc            => 11, #= insufficient resources
  BadColor            => 12, #= no such colormap
  BadGC               => 13, #= parameter not a GC
  BadIDChoice         => 14, #= choice not in range or already used
  BadName             => 15, #= font or color name doesn't exist
  BadLength           => 16, #= Request length incorrect
  BadImplementation   => 17, #= server is defective

  FirstExtensionError => 128,
  LastExtensionError  => 255,

);
