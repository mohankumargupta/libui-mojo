from memory import UnsafePointer
from ffi import external_call

# C Standard Types
comptime c_int = Int32
comptime c_uint = UInt32
comptime c_char = UInt8
comptime c_double = Float64

# Opaque handle structs
struct uiWindow:
    pass

struct uiButton:
    pass

struct uiInitOptions:
    var padding: UInt64
    fn __init__(out self):
        self.padding = 0

# Type aliases
comptime WinPtr     = UnsafePointer[uiWindow,      MutAnyOrigin]
comptime BtnPtr     = UnsafePointer[uiButton,      MutAnyOrigin]
comptime CharPtr    = UnsafePointer[c_char,        ImmutAnyOrigin]
comptime MutCharPtr = UnsafePointer[c_char,        MutAnyOrigin]
comptime VoidPtr    = UnsafePointer[NoneType,      MutAnyOrigin]
comptime OptsPtr    = UnsafePointer[uiInitOptions, MutAnyOrigin]

# Callback types
comptime OnCloseFn = fn (WinPtr, VoidPtr) -> c_int
comptime OnClickFn = fn (BtnPtr, VoidPtr) -> None

# --- Core Lifecycle ---
fn uiInit(options: OptsPtr) -> MutCharPtr:
    return external_call["uiInit", MutCharPtr](options)

fn uiUninit():
    external_call["uiUninit", NoneType]()

fn uiFreeInitError(err: MutCharPtr):
    external_call["uiFreeInitError", NoneType](err)

fn uiMain():
    external_call["uiMain", NoneType]()

fn uiQuit():
    external_call["uiQuit", NoneType]()

# --- Window Functions ---
fn uiNewWindow(title: CharPtr, width: c_int, height: c_int, hasMenubar: c_int) -> WinPtr:
    return external_call["uiNewWindow", WinPtr](title, width, height, hasMenubar)

fn uiWindowOnClosing(w: WinPtr, f: OnCloseFn, data: VoidPtr):
    external_call["uiWindowOnClosing", NoneType](w, f, data)

fn uiControlShow(c: VoidPtr):
    external_call["uiControlShow", NoneType](c)

# --- Button Functions ---
fn uiNewButton(text: CharPtr) -> BtnPtr:
    return external_call["uiNewButton", BtnPtr](text)

fn uiButtonOnClicked(b: BtnPtr, f: OnClickFn, data: VoidPtr):
    external_call["uiButtonOnClicked", NoneType](b, f, data)

fn uiWindowSetChild(w: WinPtr, child: VoidPtr):
    external_call["uiWindowSetChild", NoneType](w, child)

# --- Callbacks (must be top-level fn, not closures) ---
fn on_click(sender: BtnPtr, data: VoidPtr) -> None:
    print("Button clicked!")

fn on_close(sender: WinPtr, data: VoidPtr) -> c_int:
    print("Closing...")
    uiQuit()
    return 1

# --- Main ---
def main():
    # 1. Initialize
    var opts = uiInitOptions()
    var err = uiInit(UnsafePointer(to=opts).as_any_origin())

    if Int(err) != 0:
        print("Failed to initialize libui")
        uiFreeInitError(err)
        return

    # 2. Create Window
    var title = String("Hello from Mojo")
    var window = uiNewWindow(
        title.unsafe_ptr().bitcast[c_char]().as_any_origin(),
        300, 200, 0
    )

    # 3. Create Button
    var btn_text = String("Click Me")
    var button = uiNewButton(
        btn_text.unsafe_ptr().bitcast[c_char]().as_any_origin()
    )

    # 4. Wire up callbacks
    uiButtonOnClicked(button, on_click, VoidPtr())
    uiWindowOnClosing(window, on_close, VoidPtr())

    # 5. Layout and show
    uiWindowSetChild(window, button.bitcast[NoneType]().as_any_origin())
    uiControlShow(window.bitcast[NoneType]().as_any_origin())

    # 6. Run loop
    uiMain()

    # 7. Cleanup
    uiUninit()

 
