# basic_wm example ported from https://github.com/jichu4n/basic_wm
use X11::Xlib::Raw;

use NativeCall;
use NativeHelpers::Pointer;
use X11::Xlib::Raw::X;

class WindowManager { ... };

sub MAIN($raise_window_num?){
  my $display = XOpenDisplay("") or die 'Cannot open display';

  WindowManager.new(display => $display).run;
}

class WindowManager {
  has X11::Xlib::Raw::Display $.display;
  has %!clients;

  method run {
    $.become-wm or exit 1;

    $.set-error-handler;

    $.frame-existing-windows;

    $.event-loop;
  }

  method become-wm {
    note "Requesting to become WM on " ~ XDisplayName("");
    my Bool $another_wm_detected;
    XSetErrorHandler(-> $disp, $error {
      # In the case of an already running window manager, the error code from
      # XSelectInput is BadAccess. We don't expect this handler to receive any
      # other errors.
      $error.error_code == BadAccess or note "Unexpected error";

      note "Got error while requesting to become WM: " ~ $error.gist;
      $another_wm_detected = True;
    } );
    XSelectInput($.display, $.display.DefaultRootWindow, SubstructureRedirectMask +| SubstructureNotifyMask);
    # Since Xlib buffers requests, we need to manually sync to see if XSelectInput succeeded
    XSync($.display, False);

    if $another_wm_detected {
      note "Detected another window manager on display " ~ XDisplayString($.display);
      return False;
    }

    note "Ok, We are the WM";
    return True;
  }

  method set-error-handler {
    XSetErrorHandler(-> $disp, $error {
      note "Got error: " ~ $error.gist;
      return 0; # ignored anyways
    } );
  }

  method frame-existing-windows {
    # 1. Grab X server to prevent windows from changing under us.
    XGrabServer($.display);

    # 2. Reparent existing top-level windows.
    # i. Query existing top-level windows.

    my $top_level_windows := Pointer[Window].new;

    XQueryTree($.display, $.display.DefaultRootWindow, my Window $root_return, my Window $parent, $top_level_windows, my uint32 $num_top_level_windows);

    # ii. Frame each top-level window.
    for 0..^$num_top_level_windows -> $i {
      my $window = ($top_level_windows + $i).deref;
      $.frame( $$window );
    }

    # ii. Free top-level window array.
    XFree($top_level_windows);

    # 3. Ungrab X server.
    XUngrabServer($.display);
  }

  method frame(Window $w) {
    note "Framing $w";

    # // Visual properties of the frame to create.
    constant BORDER_WIDTH = 3;
    constant BORDER_COLOR = 0xff0000;
    constant BG_COLOR = 0x0000ff;
    #
    # CHECK(!clients_.count(w));
    #
    # // 1. Retrieve attributes of window to frame.
    my XWindowAttributes $x_window_attrs .= new;
    XGetWindowAttributes($.display, $w, $x_window_attrs);

    # // 2. Create frame.
    my Window $frame = XCreateSimpleWindow(
      $.display,
      $.display.DefaultRootWindow,
      $x_window_attrs.x,
      $x_window_attrs.y,
      $x_window_attrs.width,
      $x_window_attrs.height,
      BORDER_WIDTH,
      BORDER_COLOR,
      BG_COLOR
    );

    # // 3. Select events on frame.
    XSelectInput($.display, $frame, SubstructureRedirectMask +| SubstructureNotifyMask);

    # // 4. Add client to save set, so that it will be restored and kept alive if we
    # // crash.
    XAddToSaveSet($.display, $w);
    # // 5. Reparent client window.
    XReparentWindow($.display, $w, $frame, 0, 0);
    # // 6. Map frame.
    XMapWindow($.display, $frame);
    # // 7. Save frame handle.
    %!clients<$w> = $frame;

    #
    #
    # // 8. Grab universal window management actions on client window.
    # //   a. Move windows with alt + left button.
    # XGrabButton(
    #     display_,
    #     Button1,
    #     Mod1Mask,
    #     w,
    #     false,
    #     ButtonPressMask | ButtonReleaseMask | ButtonMotionMask,
    #     GrabModeAsync,
    #     GrabModeAsync,
    #     None,
    #     None);
    # //   b. Resize windows with alt + right button.
    # XGrabButton(
    #     display_,
    #     Button3,
    #     Mod1Mask,
    #     w,
    #     false,
    #     ButtonPressMask | ButtonReleaseMask | ButtonMotionMask,
    #     GrabModeAsync,
    #     GrabModeAsync,
    #     None,
    #     None);
    # //   c. Kill windows with alt + f4.
    # XGrabKey(
    #     display_,
    #     XKeysymToKeycode(display_, XK_F4),
    #     Mod1Mask,
    #     w,
    #     false,
    #     GrabModeAsync,
    #     GrabModeAsync);
    # //   d. Switch windows with alt + tab.
    # XGrabKey(
    #     display_,
    #     XKeysymToKeycode(display_, XK_Tab),
    #     Mod1Mask,
    #     w,
    #     false,
    #     GrabModeAsync,
    #     GrabModeAsync);
    #
    note "Framed window $w [$frame]";
  }

  #| Main event loop.
  method event-loop {
    my XEvent $e .= new;
    note '/* event loop */';
    loop {
      # 1. Get next event.
      XNextEvent($.display, $e);
      note "Received Event: ", $e;

      # 2. Dispatch event.
      given $e.type {
        # when CreateNotify {
        #   OnCreateNotify($e.xcreatewindow);
        # }
        # when DestroyNotify {
        #   OnDestroyNotify($e.xdestroywindow);
        # }
        # when ReparentNotify {
        #   OnReparentNotify($e.xreparent);
        # }
        # when MapNotify {
        #   OnMapNotify($e.xmap);
        # }
        # when UnmapNotify {
        #   OnUnmapNotify($e.xunmap);
        # }
        # when ConfigureNotify {
        #   OnConfigureNotify($e.xconfigure);
        # }
        # when MapRequest {
        #   OnMapRequest($e.xmaprequest);
        # }
        # when ConfigureRequest {
        #   OnConfigureRequest($e.xconfigurerequest);
        # }
        # when ButtonPress {
        #   OnButtonPress($e.xbutton);
        # }
        # when ButtonRelease {
        #   OnButtonRelease($e.xbutton);
        # }
        # when MotionNotify {
        #   # Skip any already pending motion events.
        #   while (XCheckTypedWindowEvent(
        #       $.display, $e.xmotion.window, MotionNotify, $e)) {}
        #   OnMotionNotify($e.xmotion);
        # }
        # when KeyPress {
        #   OnKeyPress($e.xkey);
        # }
        # when KeyRelease {
        #   OnKeyRelease($e.xkey);
        # }
        default {
          note "Ignored event";
        }
      }
    }
  }
}
