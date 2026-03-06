# ============================================================================
# ui_highlevel.mojo - High-Level Object-Oriented UI Framework for libui-ng
# ============================================================================
# Explicit style: no globals, explicit .add() calls, with-blocks for nesting
# Example:
#
# with Window("App", 600, 400) as win:
#     with HBox() as toolbar:
#         toolbar.add(Button("New"))
#         toolbar.add(Entry().expand())
#     win.set_child(toolbar)   # or .add() if you prefer
# ============================================================================

from memory import UnsafePointer
# from ui import (
#     c_int, c_char, c_void, c_double,
#     VoidPtr, CharPtr, MutCharPtr, WinPtr, BoxPtr, BtnPtr, EntryPtr,
#     LabelPtr, CheckboxPtr, SpinboxPtr, SliderPtr, ProgressPtr,
#     ComboPtr, GroupPtr, TabPtr, GridPtr, FormPtr, MultiEntryPtr,
#     OnCloseFn, OnClickFn, OnEntryChangeFn, OnCheckboxToggleFn,
#     OnSpinboxChangeFn, OnSliderChangeFn, OnComboSelectedFn,
#     uiControlShow, uiControlHide, uiControlEnable, uiControlDisable, uiControlDestroy
# )
from raw_ui import *

# ============================================================================
# Callbacks
# ============================================================================

fn _on_button_click(btn: BtnPtr, data: VoidPtr) -> None:
    print("Button clicked!")

fn _on_window_close(win: WinPtr, data: VoidPtr) -> c_int:
    print("Closing...")
    uiQuit()
    return 1




# Assume ui.mojo is imported/defined elsewhere with all external_call bindings
# (your original bindings look correct, so not repeating them here)

# ============================================================================
# Utility Functions
# ============================================================================

fn _to_c_str(s: String) -> CharPtr:
    return s.unsafe_ptr().bitcast[c_char]().as_any_origin()

fn _from_c_str(ptr: MutCharPtr) -> String:
    if Int(ptr) == 0:
        return String("")
    var result = String()
    var i = 0
    while True:
        var byte: UInt8 = ptr[i]
        if byte == 0:
            break
        result += chr(Int(byte))
        i += 1
        # Defensive guard against runaway strings
        if i > 1_000_000:
            break
    return result

# ============================================================================
# Base Widget Trait
# ============================================================================

trait Widget:
    fn handle(self) -> VoidPtr:
        ...

    fn show(self):
        uiControlShow(self.handle())

    fn hide(self):
        uiControlHide(self.handle())

    fn enable(self):
        uiControlEnable(self.handle())

    fn disable(self):
        uiControlDisable(self.handle())

    fn destroy(self):
        uiControlDestroy(self.handle())

# ============================================================================
# Expandable Trait (for layout hints)
# ============================================================================

trait Expandable(Widget):
    fn expand(mut self) -> Self:
        ...

# ============================================================================
# Container Trait
# ============================================================================

trait Container(Widget):
    fn add[T: Widget](mut self, child: T, stretchy: Bool = False):
        ...

    fn clear(mut self):
        ...

# ============================================================================
# Context Manager Helpers (no-op for now, can add stack later if needed)
# ============================================================================

# No global push/pop needed — __enter__ just returns self for chaining/with

# ============================================================================
# Button Widget
# ============================================================================


struct Button(Widget):
    var _handle: BtnPtr

    fn __init__(out self, text: String):
        self._handle = uiNewButton(_to_c_str(text))
        uiButtonOnClicked(self._handle, _on_button_click, VoidPtr())

    fn handle(self) -> VoidPtr:
        return self._handle.bitcast[NoneType]()

    fn text(self) -> String:
        return _from_c_str(uiButtonText(self._handle))

    fn set_text(mut self, text: String):
        uiButtonSetText(self._handle, _to_c_str(text))

    # Add callback support later if needed

# ============================================================================
# Entry (Text Input)
# ============================================================================


# struct Entry(Expandable, Widget):
#     var _handle: EntryPtr
# 
#     fn __init__(out self, placeholder: String = ""):
#         self._handle = uiNewEntry()
#         if placeholder != "":
#             uiEntrySetText(self._handle, _to_c_str(placeholder))
# 
#     fn handle(self) -> VoidPtr:
#         return self._handle.bitcast[NoneType]()
# 
#     fn text(self) -> String:
#         return _from_c_str(uiEntryText(self._handle))
# 
#     fn set_text(mut self, text: String):
#         uiEntrySetText(self._handle, _to_c_str(text))
# 
#     fn expand(var self) -> Self:
#         # Could store stretchy if needed for custom layout, but for now no-op
#         return self^
# 
# # ============================================================================
# # HBox - Horizontal Box Container
# # ============================================================================
# 
# 
struct HBox(Container, Movable, Copyable):
    var _handle: BoxPtr

    fn __init__(out self):
        self._handle = uiNewHorizontalBox()

    fn __moveinit__(out self, deinit take: Self):
        self._handle = take._handle

    fn __copyinit__(out self, copy: Self):
        self._handle = copy._handle

    fn __enter__(mut self) -> Self:
        return self.copy()

    fn __exit__(self):
        pass  # Add child destroy logic later if desired

    fn handle(self) -> VoidPtr:
        return self._handle.bitcast[NoneType]()

    fn add[T: Widget](mut self, child: T, stretchy: Bool = False):
        isStretchy = Int32(1) if stretchy else Int32(0)
        uiBoxAppend(self._handle, child.handle(), isStretchy)

    fn clear(mut self):
        # Simplified: delete from end to start
        var count = uiBoxNumChildren(self._handle)
        for i in range(count - 1, -1, -1):
            uiBoxDelete(self._handle, Int32(i))
# 
# # ============================================================================
# # Window (Root Container)
# # ============================================================================
# 
# 
struct Window(Container, Movable, Copyable):
    var _handle: WinPtr

    fn __init__(out self, title: String, width: Int32 = 400, height: Int32 = 300, has_menubar: Bool = False):
        var menubar = Int32(1) if has_menubar else Int32(0);
        self._handle = uiNewWindow(_to_c_str(title), width, height, menubar)
        uiWindowOnClosing(self._handle, _on_window_close, VoidPtr())

    fn __enter__(mut self) -> Self:
        return self.copy()

    fn __copyinit__(out self, copy: Self):
        self._handle = copy._handle


    fn __moveinit__(out self, deinit take: Self):
        self._handle = take._handle

    fn __exit__(self):
        pass

    fn handle(self) -> VoidPtr:
        return self._handle.bitcast[NoneType]()

    fn add[T: Widget](mut self, child: T, stretchy: Bool = False):
        # Window typically has one child
        uiWindowSetChild(self._handle, child.handle())

    fn set_child[T: Widget](mut self, child: T):
        self.add(child)

    fn set_title(mut self, title: String):
        uiWindowSetTitle(self._handle, _to_c_str(title))

    fn clear(mut self):
        pass  # Window has a single child; no-op

# 
#     # Add more: margined, fullscreen, etc. as needed
# 
# # ============================================================================
# # Minimal App Wrapper
# # ============================================================================
# 
# 
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

