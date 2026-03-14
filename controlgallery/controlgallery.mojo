from memory import UnsafePointer
from highlevel import *


struct AppState(Copyable):
    var mainwin: WinPtr
    var spinbox: SpinboxPtr
    var slider: SliderPtr
    var pbar: ProgressPtr
    var open_file_entry: EntryPtr
    var open_folder_entry: EntryPtr
    var save_file_entry: EntryPtr

    fn __init__(out self):
        self.mainwin = WinPtr()
        self.spinbox = SpinboxPtr()
        self.slider = SliderPtr()
        self.pbar = ProgressPtr()
        self.open_file_entry = EntryPtr()
        self.open_folder_entry = EntryPtr()
        self.save_file_entry = EntryPtr()


fn _to_c_str(s: String) -> CharPtr:
    return s.unsafe_ptr().bitcast[c_char]().as_any_origin()


fn _state_ptr(data: VoidPtr) -> UnsafePointer[AppState, MutAnyOrigin]:
    return data.bitcast[AppState]()


fn on_closing(win: WinPtr, data: VoidPtr) -> c_int:
    _ = win
    _ = data
    uiQuit()
    return 1


fn on_spinbox_changed(spinbox: SpinboxPtr, data: VoidPtr):
    var state = _state_ptr(data)
    var value = uiSpinboxValue(spinbox)
    uiSliderSetValue(state[].slider, value)
    uiProgressBarSetValue(state[].pbar, value)


fn on_slider_changed(slider: SliderPtr, data: VoidPtr):
    var state = _state_ptr(data)
    var value = uiSliderValue(slider)
    uiSpinboxSetValue(state[].spinbox, value)
    uiProgressBarSetValue(state[].pbar, value)


fn on_open_file_clicked(btn: BtnPtr, data: VoidPtr):
    _ = btn
    var state = _state_ptr(data)
    var filename = uiOpenFile(state[].mainwin)
    if Int(filename) == 0:
        uiEntrySetText(state[].open_file_entry, _to_c_str("(cancelled)"))
        return
    uiEntrySetText(state[].open_file_entry, filename)
    uiFreeText(filename)


fn on_open_folder_clicked(btn: BtnPtr, data: VoidPtr):
    _ = btn
    var state = _state_ptr(data)
    var foldername = uiOpenFolder(state[].mainwin)
    if Int(foldername) == 0:
        uiEntrySetText(state[].open_folder_entry, _to_c_str("(cancelled)"))
        return
    uiEntrySetText(state[].open_folder_entry, foldername)
    uiFreeText(foldername)


fn on_save_file_clicked(btn: BtnPtr, data: VoidPtr):
    _ = btn
    var state = _state_ptr(data)
    var filename = uiSaveFile(state[].mainwin)
    if Int(filename) == 0:
        uiEntrySetText(state[].save_file_entry, _to_c_str("(cancelled)"))
        return
    uiEntrySetText(state[].save_file_entry, filename)
    uiFreeText(filename)


fn on_msg_box_clicked(btn: BtnPtr, data: VoidPtr):
    _ = btn
    var state = _state_ptr(data)
    uiMsgBox(
        state[].mainwin,
        _to_c_str("This is a normal message box."),
        _to_c_str("More detailed information can be shown here."),
    )


fn on_msg_box_error_clicked(btn: BtnPtr, data: VoidPtr):
    _ = btn
    var state = _state_ptr(data)
    uiMsgBoxError(
        state[].mainwin,
        _to_c_str("This message box describes an error."),
        _to_c_str("More detailed information can be shown here."),
    )


fn make_basic_controls_page() -> VBox:
    with VBox() as page:
        page.set_padded(True)

        with HBox(page) as buttons:
            buttons.set_padded(True)
            _ = Button(buttons, "Button")
            _ = Checkbox(buttons, "Checkbox")

        _ = Label(page, "This is a label.\nLabels can span multiple lines.")
        _ = HSeparator(page)

        with Group(page, "Entries", stretchy=True) as entries_group:
            entries_group.set_margined(True)
            with Form(entries_group) as entry_form:
                entry_form.set_padded(True)
                entry_form.append("Entry", Entry())
                entry_form.append("Password Entry", PasswordEntry())
                entry_form.append("Search Entry", SearchEntry())
                entry_form.append("Multiline Entry", MultilineEntry(), stretchy=True)
                entry_form.append(
                    "Multiline Entry No Wrap",
                    MultilineEntry(non_wrapping=True),
                    stretchy=True,
                )

        return page^


fn make_numbers_page(state_data: VoidPtr) -> HBox:
    with HBox() as page:
        page.set_padded(True)

        with Group(page, "Numbers", stretchy=True) as numbers_group:
            numbers_group.set_margined(True)
            with VBox(numbers_group) as numbers_box:
                numbers_box.set_padded(True)

                var spinbox = Spinbox(numbers_box, 0, 100)
                var slider = Slider(numbers_box, 0, 100)
                var progress = ProgressBar(numbers_box)

                _state_ptr(state_data)[].spinbox = spinbox._handle
                _state_ptr(state_data)[].slider = slider._handle
                _state_ptr(state_data)[].pbar = progress._handle

                spinbox.on_changed(on_spinbox_changed, state_data)
                slider.on_changed(on_slider_changed, state_data)

                var indeterminate = ProgressBar(numbers_box)
                indeterminate.set_value(-1)

        with Group(page, "Lists", stretchy=True) as lists_group:
            lists_group.set_margined(True)
            with VBox(lists_group) as lists_box:
                lists_box.set_padded(True)

                var cbox = Combobox(lists_box)
                cbox.append("Combobox Item 1")
                cbox.append("Combobox Item 2")
                cbox.append("Combobox Item 3")

                var ecbox = EditableCombobox(lists_box)
                ecbox.append("Editable Item 1")
                ecbox.append("Editable Item 2")
                ecbox.append("Editable Item 3")

                var rbuttons = RadioButtons(lists_box)
                rbuttons.append("Radio Button 1")
                rbuttons.append("Radio Button 2")
                rbuttons.append("Radio Button 3")

        return page^


fn make_data_choosers_page(state_data: VoidPtr) -> HBox:
    with HBox() as page:
        page.set_padded(True)

        with VBox(page) as left:
            left.set_padded(True)
            _ = DatePicker(left)
            _ = TimePicker(left)
            _ = DateTimePicker(left)
            _ = FontButton(left)
            _ = ColorButton(left)

        _ = VSeparator(page)

        with VBox(page) as right:
            right.set_padded(True)
            var grid = Grid(right)
            grid.set_padded(True)

#             var open_file_btn = Button("  Open File  ")
#             var open_file_entry = Entry()
#             open_file_entry.set_read_only(True)
#             _state_ptr(state_data)[].open_file_entry = open_file_entry._handle
#             open_file_btn.on_clicked(on_open_file_clicked, state_data)
#             grid.append(open_file_btn, 0, 0, 1, 1, False, ALIGN_FILL, False, ALIGN_FILL)
#             grid.append(open_file_entry, 1, 0, 1, 1, True, ALIGN_FILL, False, ALIGN_FILL)
# 
#             var open_folder_btn = Button("Open Folder")
#             var open_folder_entry = Entry()
#             open_folder_entry.set_read_only(True)
#             _state_ptr(state_data)[].open_folder_entry = open_folder_entry._handle
#             open_folder_btn.on_clicked(on_open_folder_clicked, state_data)
#             grid.append(open_folder_btn, 0, 1, 1, 1, False, ALIGN_FILL, False, ALIGN_FILL)
#             grid.append(open_folder_entry, 1, 1, 1, 1, True, ALIGN_FILL, False, ALIGN_FILL)
# 
#             var save_file_btn = Button("  Save File  ")
#             var save_file_entry = Entry()
#             save_file_entry.set_read_only(True)
#             _state_ptr(state_data)[].save_file_entry = save_file_entry._handle
#             save_file_btn.on_clicked(on_save_file_clicked, state_data)
#             grid.append(save_file_btn, 0, 2, 1, 1, False, ALIGN_FILL, False, ALIGN_FILL)
#             grid.append(save_file_entry, 1, 2, 1, 1, True, ALIGN_FILL, False, ALIGN_FILL)
# 
#             var msg_grid = Grid()
#             msg_grid.set_padded(True)
#             grid.append(msg_grid, 0, 3, 2, 1, False, ALIGN_CENTER, False, ALIGN_START)
# 
#             var msg_btn = Button("Message Box")
#             msg_btn.on_clicked(on_msg_box_clicked, state_data)
#             msg_grid.append(msg_btn, 0, 0, 1, 1, False, ALIGN_FILL, False, ALIGN_FILL)
# 
#             var msg_error_btn = Button("Error Box")
#             msg_error_btn.on_clicked(on_msg_box_error_clicked, state_data)
#             msg_grid.append(msg_error_btn, 1, 0, 1, 1, False, ALIGN_FILL, False, ALIGN_FILL)

        return page^


fn main():
    var app = App()
    if not app.init():
        print("Failed to init libui")
        return

    var state = AppState()
    var state_data = UnsafePointer(to=state).as_any_origin().bitcast[NoneType]()

    with Window("libui Control Gallery", on_closing, 640, 480, has_menubar=True) as win:
        _state_ptr(state_data)[].mainwin = win._handle
        win.set_margined(True)

        var tabs = Tab(win)

        var basic_controls = make_basic_controls_page()
        tabs.append("Basic Controls", basic_controls)
        tabs.set_margined(0, True)

#         var numbers = make_numbers_page(state_data)
#         tabs.append("Numbers and Lists", numbers)
#         tabs.set_margined(1, True)
# 
#         var choosers = make_data_choosers_page(state_data)
#         tabs.append("Data Choosers", choosers)
#         tabs.set_margined(2, True)

    app.run()
    app.cleanup()

