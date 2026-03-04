from raw_ui import *
from memory import UnsafePointer

# --- Callbacks ---
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
    # (Assuming opts pointer conversion works with your Mojo version)
    var err = uiInit(UnsafePointer(to=opts).as_any_origin())

    if Int(err) != 0:
        print("Failed to initialize libui")
        uiFreeInitError(err)
        return

    # 2. Create Window
    var title = String("Hello from Mojo (Raw Bindings)")
    var window = uiNewWindow(
        title.unsafe_ptr().bitcast[UInt8]().as_any_origin(),
        300, 200, 0
    )

    # 3. Create Button
    var btn_text = String("Click Me")
    var button = uiNewButton(
        btn_text.unsafe_ptr().bitcast[UInt8]().as_any_origin()
    )

    # 4. Wire up callbacks (No casting needed!)
    uiButtonOnClicked(button, on_click, VoidPtr())
    uiWindowOnClosing(window, on_close, VoidPtr())

    # 5. Layout and show
    uiWindowSetChild(window, button.bitcast[NoneType]().as_any_origin())
    uiControlShow(window.bitcast[NoneType]().as_any_origin())

    # 6. Run loop
    uiMain()

    # 7. Cleanup
    uiUninit()

  
