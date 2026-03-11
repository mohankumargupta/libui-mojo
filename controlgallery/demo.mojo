# ============================================================================ 
# Example main using highlevel.mojo
# ============================================================================

from raw_ui import *
from highlevel import *

# ----------------------------------------------------------------------------
# Callbacks (C ABI compatible)
# ----------------------------------------------------------------------------

fn on_button_click(btn: BtnPtr, data: VoidPtr) -> None:
    print("Button was clicked!")

fn on_window_close(win: WinPtr, data: VoidPtr) -> c_int:
    print("Window closing...")
    uiQuit()
    return 1  # allow close

# ----------------------------------------------------------------------------
# Main
# ----------------------------------------------------------------------------

fn main():
    var app = App()
    if not app.init():
        print("Failed to initialize libui")
        return

    # Build UI
    with Window("Mojo libui-ng Demo", on_window_close, 640, 480) as win:
        with VBox() as layout:
            var btn = Button("Click Me")
            btn.on_clicked(on_button_click, VoidPtr())
            layout.add(btn)

            var label = Label("Status: Ready")
            layout.add(label)

            win.set_child(layout)

        win.show()

    # Run UI loop
    app.run()
    app.cleanup()
