use X11::Xlib::Raw;

use NativeCall;
use NativeHelpers::Pointer;

class WindowManager { ... };

sub MAIN($raise_window_num?){
  my $display = XOpenDisplay("") or die 'Cannot open display';

  my $wm = WindowManager.new(display => $display);

  $wm.run;


}

class WindowManager {
  has X11::Xlib::Raw::Display $.display;

  method run {
    $.become-wm or exit 1;

    XSetErrorHandler(-> $disp, $error {
      note "Got error: " ~ $error.gist;
    } );

    my XEvent $event .= new;
    note '/* event loop */';
    loop {
      XNextEvent($.display, $event);
      note $event;
      # given $event.type {
      #   when Expose {
      #     note '/* draw or redraw the window */';
      #     XFillRectangle($display, $window, $display.DefaultGC($s), 20, 20, 10, 10);
      #     XDrawString($display, $window, $display.DefaultGC($s), 50, 50, $msg, $msg.chars);
      #   }
      #   when KeyPress {
      #     note '/* exit on key press */';
      #     last
      #   }
      # }
    };
  }

  method become-wm {
    note "requesting to become WM on " ~ XDisplayName("");
    my Bool $another_wm_detected;
    XSetErrorHandler(-> $disp, $error {
      note "Got error while requesting to become WM: " ~ $error.gist;
      $another_wm_detected = True;
    } );
    XSelectInput($.display, $.display.DefaultRootWindow, SubstructureRedirectMask +| SubstructureNotifyMask);
    XSync($.display, False);

    if $another_wm_detected {
      note "Detected another window manager on display " ~ XDisplayString($.display);
      return False;
    }

    note "Ok, We are the WM";
    return True;
  }
}
