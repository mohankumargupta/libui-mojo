from raw_ui import *
from highlevel import *

# libui alignment enum values (uiAlignFill = 0, uiAlignStart = 1, uiAlignCenter = 2, uiAlignEnd = 3)
comptime ALIGN_FILL = Int32(0)
comptime ALIGN_START = Int32(1)
comptime ALIGN_CENTER = Int32(2)

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
        if i > 1_000_000:
            break
    return result


# struct HBox(Container, Copyable):
#     var _handle: BoxPtr
# 
#     fn __init__(out self):
#         self._handle = uiNewHorizontalBox()
# 
#     fn __copyinit__(out self, copy: Self):
#         self._handle = copy._handle
# 
#     fn handle(self) -> VoidPtr:
#         return self._handle.bitcast[NoneType]()
# 
#     fn add[T: Widget](mut self, child: T, stretchy: Bool = False):
#         uiBoxAppend(self._handle, child.handle(), Int32(1) if stretchy else Int32(0))
# 
#     fn clear(mut self):
#         pass
# 
#     fn set_padded(mut self, padded: Bool):
#         uiBoxSetPadded(self._handle, Int32(1) if padded else Int32(0))
# 
# 
# struct PasswordEntry(Widget, Copyable):
#     var _handle: EntryPtr
# 
#     fn __init__(out self):
#         self._handle = uiNewPasswordEntry()
# 
#     fn __copyinit__(out self, copy: Self):
#         self._handle = copy._handle
# 
#     fn handle(self) -> VoidPtr:
#         return self._handle.bitcast[NoneType]()
# 
# 
# struct SearchEntry(Widget, Copyable):
#     var _handle: EntryPtr
# 
#     fn __init__(out self):
#         self._handle = uiNewSearchEntry()
# 
#     fn __copyinit__(out self, copy: Self):
#         self._handle = copy._handle
# 
#     fn handle(self) -> VoidPtr:
#         return self._handle.bitcast[NoneType]()


fn on_closing(win: WinPtr, data: VoidPtr) -> c_int:
    uiQuit()
    return 1

fn make_basic_controls_page() -> VBox:
    var vbox = VBox()
    vbox.set_padded(True)

    with HBox() as hbox:
        hbox.set_padded(True)
        vbox.add(hbox)

        var btn = Button("Button")
        var chk = Checkbox("Checkbox")
        hbox.add(btn)
        hbox.add(chk)

    var lbl = Label("This is a label.\nLabels can span multiple lines.")
    vbox.add(lbl)
    
    var sep = HSeparator()
    vbox.add(sep)

    with Group("Entries") as group:
        group.set_margined(True)
        vbox.add(group, stretchy=True)

        with Form() as form:
            form.set_padded(True)
            group.set_child(form)

            var entry = Entry()
            var pass_entry = PasswordEntry()
            var search_entry = SearchEntry()
            var multi_entry = MultilineEntry()
            var multi_nowrap = MultilineEntry(non_wrapping=True)

            form.append("Entry", entry)
            form.append("Password Entry", pass_entry)
            form.append("Search Entry", search_entry)
            form.append("Multiline Entry", multi_entry, stretchy=True)
            form.append("Multiline Entry No Wrap", multi_nowrap, stretchy=True)
            
    return vbox.copy()


# fn make_basic_controls_page() -> VBox:
#     var vbox = VBox()
#     uiBoxSetPadded(vbox._handle, 1)
# 
#     var hbox = HBox()
#     hbox.set_padded(True)
#     vbox.add(hbox)
# 
#     hbox.add(Button("Button"))
#     hbox.add(Checkbox("Checkbox"))
# 
#     vbox.add(Label("This is a label.\nLabels can span multiple lines."))
#     vbox.add(HSeparator())
# 
#     var group = Group("Entries")
#     group.set_margined(True)
#     vbox.add(group, stretchy=True)
# 
#     var form = Form()
#     form.set_padded(True)
#     group.set_child(form)
# 
#     var entry = Entry()
#     uiFormAppend(form._handle, _to_c_str("Entry"), entry.handle(), 0)
# 
#     var password_entry = PasswordEntry()
#     uiFormAppend(form._handle, _to_c_str("Password Entry"), password_entry.handle(), 0)
# 
#     var search_entry = SearchEntry()
#     uiFormAppend(form._handle, _to_c_str("Search Entry"), search_entry.handle(), 0)
# 
#     var multiline_entry = MultilineEntry()
#     uiFormAppend(form._handle, _to_c_str("Multiline Entry"), multiline_entry.handle(), 1)
# 
#     var multiline_no_wrap = MultilineEntry(non_wrapping=True)
#     uiFormAppend(form._handle, _to_c_str("Multiline Entry No Wrap"), multiline_no_wrap.handle(), 1)
#     return vbox^


fn on_spinbox_changed(s: SpinboxPtr, data: VoidPtr):
    _ = s
    _ = data


fn on_slider_changed(s: SliderPtr, data: VoidPtr):
    _ = s
    _ = data


fn make_numbers_page() -> HBox:
    var hbox = HBox()
    hbox.set_padded(True)

    var numbers_group = Group("Numbers")
    numbers_group.set_margined(True)
    hbox.add(numbers_group, stretchy=True)

    var left = VBox()
    uiBoxSetPadded(left._handle, 1)
    numbers_group.set_child(left)

    var spinbox = Spinbox(0, 100)
    var slider = Slider(0, 100)
    var pbar = ProgressBar()

    spinbox.on_changed(on_spinbox_changed, slider.handle())
    slider.on_changed(on_slider_changed, spinbox.handle())

    left.add(spinbox)
    left.add(slider)
    left.add(pbar)

    var indeterminate = ProgressBar()
    indeterminate.set_value(-1)
    left.add(indeterminate)

    var lists_group = Group("Lists")
    lists_group.set_margined(True)
    hbox.add(lists_group, stretchy=True)

    var right = VBox()
    uiBoxSetPadded(right._handle, 1)
    lists_group.set_child(right)

    var cbox = Combobox()
    cbox.append("Combobox Item 1")
    cbox.append("Combobox Item 2")
    cbox.append("Combobox Item 3")
    right.add(cbox)

    var ecbox = EditableCombobox()
    ecbox.append("Editable Item 1")
    ecbox.append("Editable Item 2")
    ecbox.append("Editable Item 3")
    right.add(ecbox)

    var radios = RadioButtons()
    radios.append("Radio Button 1")
    radios.append("Radio Button 2")
    radios.append("Radio Button 3")
    right.add(radios)

    return hbox^


fn make_data_choosers_page() -> VBox:
    var vbox = VBox()
    uiBoxSetPadded(vbox._handle, 1)

    vbox.add(Label("Data chooser widgets/dialog APIs are not exposed in current raw_ui.mojo bindings yet."))
    vbox.add(Label("This page is a placeholder until uiNewDatePicker/uiOpenFile/uiMsgBox bindings are added."))

    var grid = Grid()
    grid.set_padded(True)

    var open_btn = Button("Open File")
    var open_entry = Entry("(pending raw bindings)")
    open_entry.set_read_only(True)
    uiGridAppend(grid._handle, open_btn.handle(), 0, 0, 1, 1, 0, ALIGN_FILL, 0, ALIGN_FILL)
    uiGridAppend(grid._handle, open_entry.handle(), 1, 0, 1, 1, 1, ALIGN_FILL, 0, ALIGN_FILL)

    vbox.add(grid)
    return vbox^


fn main():
    var app = App()
    if not app.init():
        print("error initializing libui")
        return

    with Window("libui Control Gallery", on_closing, 900, 600, has_menubar=True) as mainwin:
        var tab = Tab()
        mainwin.set_child(tab)
        mainwin.set_margined(True)

        var basic = make_basic_controls_page()
        uiTabAppend(tab._handle, _to_c_str("Basic Controls"), basic.handle())
        tab.set_margined(0, True)

        var numbers = make_numbers_page()
        uiTabAppend(tab._handle, _to_c_str("Numbers and Lists"), numbers.handle())
        tab.set_margined(1, True)

        var choosers = make_data_choosers_page()
        uiTabAppend(tab._handle, _to_c_str("Data Choosers"), choosers.handle())
        tab.set_margined(2, True)

        mainwin.show()

    app.run()
    app.cleanup()
