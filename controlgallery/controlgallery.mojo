from highlevelgrok import *

fn _on_button_click(btn: BtnPtr, data: VoidPtr) -> None:
    print("Button clicked!")

fn _on_window_close(win: WinPtr, data: VoidPtr) -> c_int:
    print("Closing...")
    uiQuit()
    return 1

struct App:
    var _initialized: Bool

    fn __init__(out self):
        self._initialized = False

    fn init(mut self) -> Bool:
        var opts = uiInitOptions()
        opts.padding = 0
        var err = uiInit(UnsafePointer(to=opts).as_any_origin())
        if Int(err) != 0:
            # Handle error
            uiFreeInitError(err)
            return False
        self._initialized = True
        return True

    fn run(self):
        if self._initialized:
            uiMain()

    fn cleanup(self):
        if self._initialized:
            uiUninit()


fn main():
    var app = App()
    _= app.init()

    var fileMenu = Menu("File")
    _= fileMenu.append_item("Open")
    
    with Window("control gallery example", _on_window_close, Int32(800), Int32(600), has_menubar=True) as win:
        #win.set_margined(True)
        uiControlShow(win.handle())
    app.run()
    app.cleanup()


