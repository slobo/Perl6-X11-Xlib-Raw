use X11::Xlib::Raw;

use NativeCall;
use NativeHelpers::CStruct;
use NativeHelpers::Pointer;

# Taken from https://github.com/patrickhaller/no-wm/blob/master/x-window-list.c
sub MAIN($raise_window_num?){
  my $display = XOpenDisplay("") or die 'Cannot open display';
  my $wins := Pointer.new;

  # note 'Querying Window Tree';
  XQueryTree($display, $display.DefaultRootWindow, my Window $root, my Window $parent, $wins, my uint32 $nwins);

  my $winptr = nativecast(CArray[Window], $wins);
  my XWindowAttributes $attr .= new;
  my XTextProperty $name .= new;
  my XClassHint $hint .= new;

  my @visible_windows = gather for 0..^$nwins -> $i {
    my $w = $winptr[$i];
    XGetWindowAttributes($display, $w, $attr);
    take $w if $attr.map_state == IsViewable;
  }

  for @visible_windows.reverse.kv -> $i, $w {
    my $res_name = XGetClassHint($display, $w, $hint) ?? $hint.res_name !! '<>';
    my $wm_name  = XGetWMName($display, $w, $name) ?? $name.value !! '<>';
    note sprintf("%02d 0x%-12x %s - %s", $i, $w, $res_name, $wm_name);

    if $raise_window_num && $raise_window_num == $i  {
      XRaiseWindow($display, $w);
      XSetInputFocus($display, $w, RevertToPointerRoot, CurrentTime);
    }
  }
}
