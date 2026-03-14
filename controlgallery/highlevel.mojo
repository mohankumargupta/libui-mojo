# ============================================================================ 
# ui_highlevel.mojo - High-Level Object-Oriented UI Framework for libui-ng
# Completed: wrappers for all functions in raw_ui.mojo
# Style: explicit, no globals, with-block friendly, explicit .add()
# ============================================================================

from memory import UnsafePointer
from raw_ui import *

comptime ALIGN_FILL = Int32(0)
comptime ALIGN_START = Int32(1)
comptime ALIGN_CENTER = Int32(2)

struct uiControl:
    pass


# ============================================================================ 
# Utility Functions (existing)
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
        if i > 1_000_000:
            break
    return result



# ============================================================================ 
# Traits (reusable)
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

trait Expandable(Widget):
    fn expand(mut self) -> Self:
        ...

trait Container(Widget):
    fn add[T: Widget](mut self, child: T, stretchy: Bool = False):
        ...

    fn clear(mut self):
        ...

# ============================================================================ 
# Simple Widgets
# ============================================================================

struct Label(Widget, Copyable):
    var _handle: LabelPtr

    fn __init__(out self, text: String = ""):
        self._handle = uiNewLabel(_to_c_str(text))

    fn __init__[P: Container](out self, mut parent: P, text: String = ""):
        self._handle = uiNewLabel(_to_c_str(text))
        parent.add(self)

    fn __copyinit__(out self, copy: Self):
        self._handle = copy._handle

    fn handle(self) -> VoidPtr:
        return self._handle.bitcast[NoneType]()

    fn text(self) -> String:
        return _from_c_str(uiLabelText(self._handle))

    fn set_text(mut self, text: String):
        uiLabelSetText(self._handle, _to_c_str(text))

# ============================================================================ 
# Entry (single-line) - re-enabled & completed
# ============================================================================

struct Entry(Expandable, Widget, Copyable):
    var _handle: EntryPtr

    fn __init__(out self, placeholder: String = ""):
        self._handle = uiNewEntry()
        if placeholder != "":
            uiEntrySetText(self._handle, _to_c_str(placeholder))

    fn __init__[P: Container](out self, mut parent: P, placeholder: String = ""):
        self._handle = uiNewEntry()
        if placeholder != "":
            uiEntrySetText(self._handle, _to_c_str(placeholder))
        parent.add(self)

    fn __copyinit__(out self, copy: Self):
        self._handle = copy._handle

    fn handle(self) -> VoidPtr:
        return self._handle.bitcast[NoneType]()

    fn text(self) -> String:
        return _from_c_str(uiEntryText(self._handle))

    fn set_text(mut self, text: String):
        uiEntrySetText(self._handle, _to_c_str(text))

    fn expand(mut self) -> Self:
        return self.copy()

    fn read_only(self) -> Bool:
        return uiEntryReadOnly(self._handle) != 0

    fn set_read_only(mut self, readonly: Bool):
        uiEntrySetReadOnly(self._handle, Int32(1) if readonly else Int32(0))

    fn on_changed(mut self, f: OnEntryChangeFn, data: VoidPtr):
        uiEntryOnChanged(self._handle, f, data)

# ============================================================================ 
# Boxes (HBox done, add VBox)
# ============================================================================

struct HBox(Container, Copyable):
    var _handle: BoxPtr

    fn __init__(out self):
        self._handle = uiNewHorizontalBox()

    fn __init__[P: Container](out self, mut parent: P):
        self._handle = uiNewHorizontalBox()
        parent.add(self)

    fn __copyinit__(out self, copy: Self):
        self._handle = copy._handle

    fn __enter__(self) -> Self:
        return self.copy()

    fn __exit__(self):
        pass

    fn handle(self) -> VoidPtr:
        return self._handle.bitcast[NoneType]()

    fn add[T: Widget](mut self, child: T, stretchy: Bool = False):
        uiBoxAppend(self._handle, child.handle(), Int32(1) if stretchy else Int32(0))

    fn clear(mut self):
        pass

    fn set_padded(mut self, padded: Bool):
        uiBoxSetPadded(self._handle, Int32(1) if padded else Int32(0))


struct VBox(Container, Movable, Copyable):
    var _handle: BoxPtr

    fn __init__(out self):
        self._handle = uiNewVerticalBox()

    fn __init__[P: Container](out self, mut parent: P):
        self._handle = uiNewVerticalBox()
        parent.add(self)

    fn __moveinit__(out self, deinit take: Self):
        self._handle = take._handle

    fn __copyinit__(out self, copy: Self):
        self._handle = copy._handle

    fn __enter__(mut self) -> Self:
        return self.copy()

    fn __exit__(self):
        pass

    fn handle(self) -> VoidPtr:
        return self._handle.bitcast[NoneType]()

    fn add[T: Widget](mut self, child: T, stretchy: Bool = False):
        isStretchy = Int32(1) if stretchy else Int32(0)
        uiBoxAppend(self._handle, child.handle(), isStretchy)

    fn clear(mut self):
        var count = uiBoxNumChildren(self._handle)
        for i in range(count - 1, -1, -1):
            uiBoxDelete(self._handle, Int32(i))

    fn set_padded(mut self, padded: Bool):
        uiBoxSetPadded(self._handle, Int32(1) if padded else Int32(0))

# ============================================================================ 
# Button (add on_clicked convenience)
# ============================================================================

struct Button(Widget, Copyable):
    var _handle: BtnPtr

    fn __init__(out self, text: String):
        self._handle = uiNewButton(_to_c_str(text))

    fn __init__[P: Container](out self, mut parent: P, text: String):
        self._handle = uiNewButton(_to_c_str(text))
        parent.add(self)

    fn __copyinit__(out self, copy: Self):
        self._handle = copy._handle

    fn handle(self) -> VoidPtr:
        return self._handle.bitcast[NoneType]()

    fn text(self) -> String:
        return _from_c_str(uiButtonText(self._handle))

    fn set_text(mut self, text: String):
        uiButtonSetText(self._handle, _to_c_str(text))

    fn on_clicked(mut self, f: OnClickFn, data: VoidPtr):
        uiButtonOnClicked(self._handle, f, data)

# ============================================================================ 
# Checkbox
# ============================================================================

struct Checkbox(Widget, Copyable):
    var _handle: CheckboxPtr

    fn __init__(out self, text: String = ""):
        self._handle = uiNewCheckbox(_to_c_str(text))

    fn __init__[P: Container](out self, mut parent: P, text: String = ""):
        self._handle = uiNewCheckbox(_to_c_str(text))
        parent.add(self)

    fn __copyinit__(out self, copy: Self):
        self._handle = copy._handle

    fn handle(self) -> VoidPtr:
        return self._handle.bitcast[NoneType]()

    fn text(self) -> String:
        return _from_c_str(uiCheckboxText(self._handle))

    fn set_text(mut self, text: String):
        uiCheckboxSetText(self._handle, _to_c_str(text))

    fn checked(self) -> Bool:
        return uiCheckboxChecked(self._handle) != 0

    fn set_checked(mut self, checked: Bool):
        uiCheckboxSetChecked(self._handle, Int32(1) if checked else Int32(0))

    fn on_toggled(mut self, f: OnCheckboxToggleFn, data: VoidPtr):
        uiCheckboxOnToggled(self._handle, f, data)

# ============================================================================ 
# Spinbox
# ============================================================================

struct Spinbox(Widget, Copyable):
    var _handle: SpinboxPtr

    fn __init__(out self, min_val: Int32, max_val: Int32):
        self._handle = uiNewSpinbox(min_val, max_val)

    fn __init__[P: Container](out self, mut parent: P, min_val: Int32, max_val: Int32):
        self._handle = uiNewSpinbox(min_val, max_val)
        parent.add(self)

    fn __copyinit__(out self, copy: Self):
        self._handle = copy._handle

    fn handle(self) -> VoidPtr:
        return self._handle.bitcast[NoneType]()

    fn value(self) -> Int32:
        return uiSpinboxValue(self._handle)

    fn set_value(mut self, v: Int32):
        uiSpinboxSetValue(self._handle, v)

    fn on_changed(mut self, f: OnSpinboxChangeFn, data: VoidPtr):
        uiSpinboxOnChanged(self._handle, f, data)

# ============================================================================ 
# Slider
# ============================================================================

struct Slider(Widget, Copyable):
    var _handle: SliderPtr

    fn __init__(out self, min_val: Int32, max_val: Int32):
        self._handle = uiNewSlider(min_val, max_val)

    fn __init__[P: Container](out self, mut parent: P, min_val: Int32, max_val: Int32):
        self._handle = uiNewSlider(min_val, max_val)
        parent.add(self)

    fn __copyinit__(out self, copy: Self):
        self._handle = copy._handle

    fn handle(self) -> VoidPtr:
        return self._handle.bitcast[NoneType]()

    fn value(self) -> Int32:
        return uiSliderValue(self._handle)

    fn set_value(mut self, v: Int32):
        uiSliderSetValue(self._handle, v)

    fn on_changed(mut self, f: OnSliderChangeFn, data: VoidPtr):
        uiSliderOnChanged(self._handle, f, data)

# ============================================================================ 
# ProgressBar
# ============================================================================

struct ProgressBar(Widget, Copyable):
    var _handle: ProgressPtr

    fn __init__(out self):
        self._handle = uiNewProgressBar()

    fn __init__[P: Container](out self, mut parent: P):
        self._handle = uiNewProgressBar()
        parent.add(self)

    fn __copyinit__(out self, copy: Self):
        self._handle = copy._handle

    fn handle(self) -> VoidPtr:
        return self._handle.bitcast[NoneType]()

    fn value(self) -> Int32:
        return uiProgressBarValue(self._handle)

    fn set_value(mut self, n: Int32):
        uiProgressBarSetValue(self._handle, n)

# ============================================================================ 
# Combobox & EditableCombobox
# ============================================================================

struct Combobox(Widget, Copyable):
    var _handle: ComboPtr

    fn __init__(out self):
        self._handle = uiNewCombobox()

    fn __init__[P: Container](out self, mut parent: P):
        self._handle = uiNewCombobox()
        parent.add(self)

    fn __copyinit__(out self, copy: Self):
        self._handle = copy._handle

    fn handle(self) -> VoidPtr:
        return self._handle.bitcast[NoneType]()

    fn append(mut self, text: String):
        uiComboboxAppend(self._handle, _to_c_str(text))

    fn selected(self) -> Int32:
        return uiComboboxSelected(self._handle)

    fn set_selected(mut self, n: Int32):
        uiComboboxSetSelected(self._handle, n)

    fn on_selected(mut self, f: OnComboSelectedFn, data: VoidPtr):
        uiComboboxOnSelected(self._handle, f, data)


struct EditableCombobox(Widget, Copyable):
    var _handle: EditComboPtr

    fn __init__(out self):
        self._handle = uiNewEditableCombobox()

    fn __init__[P: Container](out self, mut parent: P):
        self._handle = uiNewEditableCombobox()
        parent.add(self)

    fn __copyinit__(out self, copy: Self):
        self._handle = copy._handle

    fn handle(self) -> VoidPtr:
        return self._handle.bitcast[NoneType]()

    fn append(mut self, text: String):
        uiEditableComboboxAppend(self._handle, _to_c_str(text))

    fn text(self) -> String:
        return _from_c_str(uiEditableComboboxText(self._handle))

    fn set_text(mut self, text: String):
        uiEditableComboboxSetText(self._handle, _to_c_str(text))

    fn on_changed(mut self, f: OnEditComboChangedFn, data: VoidPtr):
        uiEditableComboboxOnChanged(self._handle, f, data)

# ============================================================================ 
# RadioButtons
# ============================================================================

struct RadioButtons(Widget, Copyable):
    var _handle: RadioPtr

    fn __init__(out self):
        self._handle = uiNewRadioButtons()

    fn __init__[P: Container](out self, mut parent: P):
        self._handle = uiNewRadioButtons()
        parent.add(self)

    fn __copyinit__(out self, copy: Self):
        self._handle = copy._handle

    fn handle(self) -> VoidPtr:
        return self._handle.bitcast[NoneType]()

    fn append(mut self, text: String):
        uiRadioButtonsAppend(self._handle, _to_c_str(text))

    fn selected(self) -> Int32:
        return uiRadioButtonsSelected(self._handle)

    fn set_selected(mut self, n: Int32):
        uiRadioButtonsSetSelected(self._handle, n)

    fn on_selected(mut self, f: OnRadioSelectedFn, data: VoidPtr):
        uiRadioButtonsOnSelected(self._handle, f, data)

# ============================================================================ 
# Separators
# ============================================================================

struct HSeparator(Widget, Copyable):
    var _handle: SepPtr

    fn __init__(out self):
        self._handle = uiNewHorizontalSeparator()

    fn __init__[P: Container](out self, mut parent: P):
        self._handle = uiNewHorizontalSeparator()
        parent.add(self)

    fn __copyinit__(out self, copy: Self):
        self._handle = copy._handle

    fn handle(self) -> VoidPtr:
        return self._handle.bitcast[NoneType]()

struct VSeparator(Widget, Copyable):
    var _handle: SepPtr

    fn __init__(out self):
        self._handle = uiNewVerticalSeparator()

    fn __init__[P: Container](out self, mut parent: P):
        self._handle = uiNewVerticalSeparator()
        parent.add(self)

    fn __copyinit__(out self, copy: Self):
        self._handle = copy._handle

    fn handle(self) -> VoidPtr:
        return self._handle.bitcast[NoneType]()

struct DateTimePicker(Widget, Copyable):
    var _handle: VoidPtr

    fn __init__(out self):
        self._handle = uiNewDateTimePicker()

    fn __init__[P: Container](out self, mut parent: P):
        self._handle = uiNewDateTimePicker()
        parent.add(self)

    fn __copyinit__(out self, copy: Self):
        self._handle = copy._handle

    fn handle(self) -> VoidPtr:
        return self._handle

struct DatePicker(Widget, Copyable):
    var _handle: VoidPtr

    fn __init__(out self):
        self._handle = uiNewDatePicker()

    fn __init__[P: Container](out self, mut parent: P):
        self._handle = uiNewDatePicker()
        parent.add(self)

    fn __copyinit__(out self, copy: Self):
        self._handle = copy._handle

    fn handle(self) -> VoidPtr:
        return self._handle

struct TimePicker(Widget, Copyable):
    var _handle: VoidPtr

    fn __init__(out self):
        self._handle = uiNewTimePicker()

    fn __init__[P: Container](out self, mut parent: P):
        self._handle = uiNewTimePicker()
        parent.add(self)

    fn __copyinit__(out self, copy: Self):
        self._handle = copy._handle

    fn handle(self) -> VoidPtr:
        return self._handle

struct FontButton(Widget, Copyable):
    var _handle: FontBtnPtr

    fn __init__(out self):
        self._handle = uiNewFontButton()

    fn __init__[P: Container](out self, mut parent: P):
        self._handle = uiNewFontButton()
        parent.add(self)

    fn __copyinit__(out self, copy: Self):
        self._handle = copy._handle

    fn handle(self) -> VoidPtr:
        return self._handle.bitcast[NoneType]()

struct ColorButton(Widget, Copyable):
    var _handle: ColorBtnPtr

    fn __init__(out self):
        self._handle = uiNewColorButton()

    fn __init__[P: Container](out self, mut parent: P):
        self._handle = uiNewColorButton()
        parent.add(self)

    fn __copyinit__(out self, copy: Self):
        self._handle = copy._handle

    fn handle(self) -> VoidPtr:
        return self._handle.bitcast[NoneType]()
 

# ============================================================================ 
# Group
# ============================================================================

struct Group(Container, Copyable):
    var _handle: GroupPtr

    fn __init__(out self, title: String = ""):
        self._handle = uiNewGroup(_to_c_str(title))

    fn __init__[P: Container](out self, mut parent: P, title: String = "", stretchy: Bool = False):
        self._handle = uiNewGroup(_to_c_str(title))
        parent.add(self, stretchy=stretchy)

    fn __copyinit__(out self, copy: Self):
        self._handle = copy._handle

    fn handle(self) -> VoidPtr:
        return self._handle.bitcast[NoneType]()

    fn title(self) -> String:
        return _from_c_str(uiGroupTitle(self._handle))

    fn __enter__(self) -> Self:
        return self.copy()

    fn __exit__(self):
        pass


    fn set_title(mut self, title: String):
        uiGroupSetTitle(self._handle, _to_c_str(title))

    fn set_child[T: Widget](mut self, child: T):
        uiGroupSetChild(self._handle, child.handle())

    fn margined(self) -> Bool:
        return uiGroupMargined(self._handle) != 0

    fn set_margined(mut self, margined: Bool):
        uiGroupSetMargined(self._handle, Int32(1) if margined else Int32(0))

    fn add[T: Widget](mut self, child: T, stretchy: Bool = False):
        uiGroupSetChild(self._handle, child.handle())

    fn clear(mut self):
        # Group holds single child; no-op
        pass

# ============================================================================ 
# Tab
# ============================================================================

struct Tab(Container, Copyable):
    var _handle: TabPtr

    fn __init__(out self):
        self._handle = uiNewTab()

    fn __init__[P: Container](out self, mut parent: P):
        self._handle = uiNewTab()
        parent.add(self)

    fn __copyinit__(out self, copy: Self):
        self._handle = copy._handle

    fn handle(self) -> VoidPtr:
        return self._handle.bitcast[NoneType]()

    fn append[T: Widget](mut self, name: String, c: T):
        uiTabAppend(self._handle, _to_c_str(name), c.handle())

    fn insert_at[T: Widget](mut self, name: String, before: Int32, c: T):
        uiTabInsertAt(self._handle, _to_c_str(name), before, c.handle())

    fn delete(mut self, index: Int32):
        uiTabDelete(self._handle, index)

    fn num_pages(self) -> Int32:
        return uiTabNumPages(self._handle)

    fn margined(self, page: Int32) -> Bool:
        return uiTabMargined(self._handle, page) != 0

    fn set_margined(mut self, page: Int32, margined: Bool):
        uiTabSetMargined(self._handle, page, Int32(1) if margined else Int32(0))

    fn add[T: Widget](mut self, child: T, stretchy: Bool = False):
        # Not meaningful; tabs use append with a string label instead
        pass

    fn clear(mut self):
        # Cannot easily enumerate tab pages from C API; leave no-op
        pass

# ============================================================================ 
# Grid
# ============================================================================

struct Grid(Container, Copyable):
    var _handle: GridPtr

    fn __init__(out self):
        self._handle = uiNewGrid()

    fn __init__[P: Container](out self, mut parent: P, stretchy: Bool = False):
        self._handle = uiNewGrid()
        parent.add(self, stretchy=stretchy)

    fn __copyinit__(out self, copy: Self):
        self._handle = copy._handle

    fn handle(self) -> VoidPtr:
        return self._handle.bitcast[NoneType]()

    fn append(mut self, c: Widget, left: Int32, top: Int32,
              xspan: Int32, yspan: Int32, hexpand: Bool,
              halign: Int32, vexpand: Bool, valign: Int32):
        uiGridAppend(self._handle, c.handle(), left, top, xspan, yspan,
                     Int32(1) if hexpand else Int32(0), halign,
                     Int32(1) if vexpand else Int32(0), valign)

    fn insert_at[T: Widget, E: Widget](mut self, c: T, existing: E, at: Int32,
                 xspan: Int32, yspan: Int32, hexpand: Bool,
                 halign: Int32, vexpand: Bool, valign: Int32):
        uiGridInsertAt(self._handle, c.handle(), existing.handle(), at,
                       xspan, yspan, Int32(1) if hexpand else Int32(0),
                       halign, Int32(1) if vexpand else Int32(0), valign)

    fn padded(self) -> Bool:
        return uiGridPadded(self._handle) != 0

    fn set_padded(mut self, padded: Bool):
        uiGridSetPadded(self._handle, Int32(1) if padded else Int32(0))

    fn add[T: Widget](mut self, child: T, stretchy: Bool = False):
        # Generic add not meaningful for grid; leave no-op
        pass

    fn clear(mut self):
        # raw API doesn't provide delete all; leave no-op
        pass

# ============================================================================ 
# MultilineEntry
# ============================================================================

struct MultilineEntry(Expandable, Widget, Copyable):
    var _handle: MultiEntryPtr

    fn __init__(out self, non_wrapping: Bool = False):
        if non_wrapping:
            self._handle = uiNewNonWrappingMultilineEntry()
        else:
            self._handle = uiNewMultilineEntry()

    fn __init__[P: Container](out self, mut parent: P, non_wrapping: Bool = False):
        if non_wrapping:
            self._handle = uiNewNonWrappingMultilineEntry()
        else:
            self._handle = uiNewMultilineEntry()
        parent.add(self)

    fn __copyinit__(out self, copy: Self):
        self._handle = copy._handle

    fn handle(self) -> VoidPtr:
        return self._handle.bitcast[NoneType]()

    fn text(self) -> String:
        return _from_c_str(uiMultilineEntryText(self._handle))

    fn set_text(mut self, text: String):
        uiMultilineEntrySetText(self._handle, _to_c_str(text))

    fn append(mut self, text: String):
        uiMultilineEntryAppend(self._handle, _to_c_str(text))

    fn on_changed(mut self, f: OnMultiEntryChangeFn, data: VoidPtr):
        uiMultilineEntryOnChanged(self._handle, f, data)

    fn read_only(self) -> Bool:
        return uiMultilineEntryReadOnly(self._handle) != 0

    fn set_read_only(mut self, readonly: Bool):
        uiMultilineEntrySetReadOnly(self._handle, Int32(1) if readonly else Int32(0))

    fn expand(mut self) -> Self:
        return self.copy()

# ============================================================================ 
# PasswordEntry
# ============================================================================
struct PasswordEntry(Widget, Copyable):
    var _handle: EntryPtr

    fn __init__(out self):
        self._handle = uiNewPasswordEntry()

    fn __init__[P: Container](out self, mut parent: P):
        self._handle = uiNewPasswordEntry()
        parent.add(self)

    fn __copyinit__(out self, copy: Self):
        self._handle = copy._handle

    fn __enter__(self) -> Self:
        return self.copy()

    fn __exit__(self):
        pass

    fn handle(self) -> VoidPtr:
        return self._handle.bitcast[NoneType]()

# ============================================================================ 
# SearchEntry
# ============================================================================
struct SearchEntry(Widget, Copyable):
    var _handle: EntryPtr

    fn __init__(out self):
        self._handle = uiNewSearchEntry()

    fn __init__[P: Container](out self, mut parent: P):
        self._handle = uiNewSearchEntry()
        parent.add(self)

    fn __copyinit__(out self, copy: Self):
        self._handle = copy._handle

    fn __enter__(self) -> Self:
        return self.copy()

    fn __exit__(self):
        pass

    fn handle(self) -> VoidPtr:
        return self._handle.bitcast[NoneType]()





# ============================================================================ 
# Form
# ============================================================================

struct Form(Container, Copyable):
    var _handle: FormPtr

    fn __init__(out self):
        self._handle = uiNewForm()

    fn __init__[P: Container](out self, mut parent: P, stretchy: Bool = False):
        self._handle = uiNewForm()
        parent.add(self, stretchy=stretchy)

    fn __copyinit__(out self, copy: Self):
        self._handle = copy._handle

    fn __enter__(self) -> Self:
        return self.copy()

    fn __exit__(self):
        pass


    fn handle(self) -> VoidPtr:
        return self._handle.bitcast[NoneType]()

    fn append[T: Widget](mut self, label: String, c: T, stretchy: Bool = False):
        uiFormAppend(self._handle, _to_c_str(label), c.handle(), Int32(1) if stretchy else Int32(0))

    fn delete(mut self, index: Int32):
        uiFormDelete(self._handle, index)

    fn padded(self) -> Bool:
        return uiFormPadded(self._handle) != 0

    fn set_padded(mut self, padded: Bool):
        uiFormSetPadded(self._handle, Int32(1) if padded else Int32(0))

    fn num_children(self) -> Int32:
        return uiFormNumChildren(self._handle)

    fn add[T: Widget](mut self, child: T, stretchy: Bool = False):
        # Form requires label; no generic add
        pass

    fn clear(mut self):
        var n = uiFormNumChildren(self._handle)
        for i in range(n - 1, -1, -1):
            uiFormDelete(self._handle, Int32(i))

# ============================================================================ 
# Menu & MenuItem (more complete)
# ============================================================================

struct MenuItem(Copyable):
    var _handle: MenuItemPtr

    fn __init__(out self, handle: MenuItemPtr):
        self._handle = handle

    fn __copyinit__(out self, copy: Self):
        self._handle = copy._handle

    fn enable(self):
        uiMenuItemEnable(self._handle)

    fn disable(self):
        uiMenuItemDisable(self._handle)

    fn is_checked(self) -> Bool:
        return uiMenuItemChecked(self._handle) != 0

    fn set_checked(mut self, checked: Bool):
        uiMenuItemSetChecked(self._handle, Int32(1) if checked else Int32(0))

    fn on_clicked(mut self, f: VoidPtr, data: VoidPtr):
        # raw signature expects generic function pointer; forward it
        uiMenuItemOnClicked(self._handle, f, data)

struct Menu(Copyable):
    var _handle: MenuPtr

    fn __init__(out self, name: String):
        self._handle = uiNewMenu(_to_c_str(name))

    fn __copyinit__(out self, copy: Self):
        self._handle = copy._handle

    fn append_item(mut self, name: String) -> MenuItem:
        var h = uiMenuAppendItem(self._handle, _to_c_str(name))
        return MenuItem(h)

    fn append_check_item(mut self, name: String) -> MenuItem:
        var h = uiMenuAppendCheckItem(self._handle, _to_c_str(name))
        return MenuItem(h)

    fn append_quit_item(mut self) -> MenuItem:
        var h = uiMenuAppendQuitItem(self._handle)
        return MenuItem(h)

    fn append_preferences_item(mut self) -> MenuItem:
        var h = uiMenuAppendPreferencesItem(self._handle)
        return MenuItem(h)

    fn append_about_item(mut self) -> MenuItem:
        var h = uiMenuAppendAboutItem(self._handle)
        return MenuItem(h)

    fn append_separator(mut self):
        uiMenuAppendSeparator(self._handle)

# ============================================================================ 
# Image & Table (simple wrappers)
# ============================================================================

struct ImageWidget(Widget, Copyable):
    var _handle: ImagePtr

    fn __init__(out self, h: ImagePtr):
        # There is no uiNewImage signature in raw_ui.mojo as string-based loader,
        # so accept a raw ImagePtr. Construct as needed at call site.
        self._handle = h

    fn __copyinit__(out self, copy: Self):
        self._handle = copy._handle

    fn handle(self) -> VoidPtr:
        return self._handle.bitcast[NoneType]()

struct TableWidget(Widget, Copyable):
    var _handle: TablePtr

    fn __init__(out self, h: TablePtr):
        self._handle = h

    fn __copyinit__(out self, copy: Self):
        self._handle = copy._handle

    fn handle(self) -> VoidPtr:
        return self._handle.bitcast[NoneType]()

# ============================================================================ 
# Window: add more convenience methods
# ============================================================================

comptime WindowCloseFn = fn(win: WinPtr, data: VoidPtr) -> c_int

struct Window(Container, Movable, Copyable):
    var _handle: WinPtr

    fn __init__(out self, title: String, on_close: WindowCloseFn, width: Int32 = 400, height: Int32 = 300, has_menubar: Bool = False):
        var menubar = Int32(1) if has_menubar else Int32(0)
        self._handle = uiNewWindow(_to_c_str(title), width, height, menubar)
        uiWindowOnClosing(self._handle, on_close, VoidPtr())

    fn __enter__(mut self) -> Self:
        return self.copy()

    fn __copyinit__(out self, copy: Self):
        self._handle = copy._handle

    fn __moveinit__(out self, deinit take: Self):
        self._handle = take._handle

    fn __exit__(self):
        if uiControlVisible(self.handle()) == 0:
            self.show()

    fn handle(self) -> VoidPtr:
        return self._handle.bitcast[NoneType]()

    fn add[T: Widget](mut self, child: T, stretchy: Bool = False):
        uiWindowSetChild(self._handle, child.handle())

    fn set_child[T: Widget](mut self, child: T):
        self.add(child)

    fn set_title(mut self, title: String):
        uiWindowSetTitle(self._handle, _to_c_str(title))

    fn content_size(self) -> (Int32, Int32):
        var w: Int32 = 0
        var h: Int32 = 0
        uiWindowContentSize(self._handle, UnsafePointer(to=w).as_any_origin(), UnsafePointer(to=h).as_any_origin())
        return (w, h)

    fn set_content_size(mut self, width: Int32, height: Int32):
        uiWindowSetContentSize(self._handle, width, height)

    fn fullscreen(self) -> Bool:
        return uiWindowFullscreen(self._handle) != 0

    fn set_fullscreen(mut self, fullscreen: Bool):
        uiWindowSetFullscreen(self._handle, Int32(1) if fullscreen else Int32(0))

    fn margined(self) -> Bool:
        return uiWindowMargined(self._handle) != 0

    fn set_margined(mut self, margined: Bool):
        uiWindowSetMargined(self._handle, Int32(1) if margined else Int32(0))

    fn borderless(self) -> Bool:
        return uiWindowBorderless(self._handle) != 0

    fn set_borderless(mut self, borderless: Bool):
        uiWindowSetBorderless(self._handle, Int32(1) if borderless else Int32(0))


    fn open_file(self) -> String:
        var filename = uiOpenFile(self._handle)
        if Int(filename) == 0:
            return String("")
        var text = _from_c_str(filename)
        uiFreeText(filename)
        return text

    fn open_folder(self) -> String:
        var foldername = uiOpenFolder(self._handle)
        if Int(foldername) == 0:
            return String("")
        var text = _from_c_str(foldername)
        uiFreeText(foldername)
        return text

    fn save_file(self) -> String:
        var filename = uiSaveFile(self._handle)
        if Int(filename) == 0:
            return String("")
        var text = _from_c_str(filename)
        uiFreeText(filename)
        return text

    fn msg_box(self, title: String, description: String):
        uiMsgBox(self._handle, _to_c_str(title), _to_c_str(description))

    fn msg_box_error(self, title: String, description: String):
        uiMsgBoxError(self._handle, _to_c_str(title), _to_c_str(description))
 

    fn clear(mut self):
        uiWindowSetChild(self._handle, VoidPtr())

# ============================================================================ 
# App wrapper (init, run, cleanup, timer, queue_main)
# ============================================================================

struct App:
    var _initialized: Bool

    fn __init__(out self):
        self._initialized = False

    fn init(mut self) -> Bool:
        var opts = uiInitOptions()
        opts.padding = 0
        var ptr = UnsafePointer(to=opts).as_any_origin()
        var err = uiInit(ptr)
        if Int(err) != 0:
            uiFreeInitError(err)
            return False
        self._initialized = True
        return True

    fn run(self):
        if self._initialized:
            uiMain()

    fn main_steps(self):
        if self._initialized:
            uiMainSteps()

    fn main_step(self, wait: Bool) -> Bool:
        if self._initialized:
            return uiMainStep(Int32(1) if wait else Int32(0)) != 0
        return False

    fn quit(self):
        if self._initialized:
            uiQuit()

    fn cleanup(self):
        if self._initialized:
            uiUninit()

    fn queue_main(self, f: VoidPtr, data: VoidPtr):
        uiQueueMain(f, data)

    fn timer(self, milliseconds: Int32, f: VoidPtr, data: VoidPtr):
        uiTimer(milliseconds, f, data)

    fn on_should_quit(self, f: VoidPtr, data: VoidPtr):
        uiOnShouldQuit(f, data)

# ============================================================================ 
# Misc small helpers
# ============================================================================

fn control_handle(c: Widget) -> UInt:
    return uiControlHandle(c.handle())

fn control_parent(c: Widget) -> VoidPtr:
    return uiControlParent(c.handle())

fn set_control_parent(c: Widget, parent: Widget):
    uiControlSetParent(c.handle(), parent.handle())

fn control_toplevel(c: Widget) -> Bool:
    return uiControlToplevel(c.handle()) != 0

fn control_verify_set_parent(c: Widget, parent: Widget):
    uiControlVerifySetParent(c.handle(), parent.handle())

fn control_enabled_to_user(c: Widget) -> Bool:
    return uiControlEnabledToUser(c.handle()) != 0

