# ============================================================================
# raw_ui.mojo - Raw FFI Bindings for libui-ng
# ============================================================================
# This is the low-level bindings layer providing direct FFI access to libui-ng.
# These bindings are 1:1 mappings to the C library functions.
# ============================================================================

from memory import UnsafePointer
from ffi import external_call

# ============================================================================
# C Standard Types
# ============================================================================
comptime c_int = Int32
comptime c_uint = UInt32
comptime c_char = UInt8
comptime c_double = Float64
comptime c_void = NoneType

# ============================================================================
# Opaque Handle Structs
# ============================================================================
struct uiInitOptions:
    var padding: UInt64
    fn __init__(out self):
        self.padding = 0

# Opaque types for handles (forward declarations)
struct uiWindow: pass
struct uiButton: pass
struct uiEntry: pass
struct uiLabel: pass
struct uiBox: pass
struct uiCheckbox: pass
struct uiSpinbox: pass
struct uiSlider: pass
struct uiProgressBar: pass
struct uiCombobox: pass
struct uiEditableCombobox: pass
struct uiRadioButtons: pass
struct uiSeparator: pass
struct uiGroup: pass
struct uiTab: pass
struct uiGrid: pass
struct uiMultilineEntry: pass
struct uiArea: pass
struct uiFontButton: pass
struct uiColorButton: pass
struct uiForm: pass
struct uiImage: pass
struct uiTable: pass
struct uiMenu: pass
struct uiMenuItem: pass

# ============================================================================
# Pointer Type Aliases
# ============================================================================
comptime VoidPtr    = UnsafePointer[NoneType,      MutAnyOrigin]
comptime CharPtr    = UnsafePointer[c_char,        ImmutAnyOrigin]
comptime MutCharPtr = UnsafePointer[c_char,        MutAnyOrigin]
comptime OptsPtr    = UnsafePointer[uiInitOptions, MutAnyOrigin]

# Widget pointer types
comptime WinPtr      = UnsafePointer[uiWindow,      MutAnyOrigin]
comptime BtnPtr      = UnsafePointer[uiButton,      MutAnyOrigin]
comptime EntryPtr    = UnsafePointer[uiEntry,       MutAnyOrigin]
comptime LabelPtr    = UnsafePointer[uiLabel,       MutAnyOrigin]
comptime BoxPtr      = UnsafePointer[uiBox,         MutAnyOrigin]
comptime CheckboxPtr = UnsafePointer[uiCheckbox,    MutAnyOrigin]
comptime SpinboxPtr  = UnsafePointer[uiSpinbox,     MutAnyOrigin]
comptime SliderPtr   = UnsafePointer[uiSlider,      MutAnyOrigin]
comptime ProgressPtr = UnsafePointer[uiProgressBar, MutAnyOrigin]
comptime ComboPtr    = UnsafePointer[uiCombobox,    MutAnyOrigin]
comptime EditComboPtr = UnsafePointer[uiEditableCombobox, MutAnyOrigin]
comptime RadioPtr    = UnsafePointer[uiRadioButtons, MutAnyOrigin]
comptime SepPtr      = UnsafePointer[uiSeparator,   MutAnyOrigin]
comptime GroupPtr    = UnsafePointer[uiGroup,       MutAnyOrigin]
comptime TabPtr      = UnsafePointer[uiTab,         MutAnyOrigin]
comptime GridPtr     = UnsafePointer[uiGrid,        MutAnyOrigin]
comptime MultiEntryPtr = UnsafePointer[uiMultilineEntry, MutAnyOrigin]
comptime AreaPtr     = UnsafePointer[uiArea,        MutAnyOrigin]
comptime FontBtnPtr  = UnsafePointer[uiFontButton,  MutAnyOrigin]
comptime ColorBtnPtr = UnsafePointer[uiColorButton, MutAnyOrigin]
comptime FormPtr     = UnsafePointer[uiForm,        MutAnyOrigin]
comptime ImagePtr    = UnsafePointer[uiImage,       MutAnyOrigin]
comptime TablePtr    = UnsafePointer[uiTable,       MutAnyOrigin]
comptime MenuPtr     = UnsafePointer[uiMenu,        MutAnyOrigin]
comptime MenuItemPtr = UnsafePointer[uiMenuItem,    MutAnyOrigin]

# ============================================================================
# Callback Types
# ============================================================================
comptime OnCloseFn      = fn (WinPtr, VoidPtr) -> c_int
comptime OnClickFn      = fn (BtnPtr, VoidPtr) -> None
comptime OnEntryChangeFn = fn (EntryPtr, VoidPtr) -> None
comptime OnCheckboxToggleFn = fn (CheckboxPtr, VoidPtr) -> None
comptime OnSpinboxChangeFn = fn (SpinboxPtr, VoidPtr) -> None
comptime OnSliderChangeFn = fn (SliderPtr, VoidPtr) -> None
comptime OnComboSelectedFn = fn (ComboPtr, VoidPtr) -> None
comptime OnEditComboChangedFn = fn (EditComboPtr, VoidPtr) -> None
comptime OnRadioSelectedFn = fn (RadioPtr, VoidPtr) -> None
comptime OnMultiEntryChangeFn = fn (MultiEntryPtr, VoidPtr) -> None

# ============================================================================
# Raw FFI Namespace
# ============================================================================
# All raw bindings are in this namespace for organization


# --- Core Lifecycle ---
fn uiInit(options: OptsPtr) -> MutCharPtr:
    return external_call["uiInit", MutCharPtr](options)

fn uiUninit():
       external_call["uiUninit", NoneType]()

fn uiFreeInitError(err: MutCharPtr):
    external_call["uiFreeInitError", NoneType](err)

fn uiMain():
    external_call["uiMain", NoneType]()

fn uiMainSteps():
    external_call["uiMainSteps", NoneType]()

fn uiMainStep(wait: c_int) -> c_int:
    return external_call["uiMainStep", c_int](wait)

fn uiQuit():
    external_call["uiQuit", NoneType]()

fn uiQueueMain(f: VoidPtr, data: VoidPtr):
    external_call["uiQueueMain", NoneType](f, data)

# --- Control Functions ---
fn uiControlDestroy(c: VoidPtr):
    external_call["uiControlDestroy", NoneType](c)

fn uiControlShow(c: VoidPtr):
    external_call["uiControlShow", NoneType](c)

fn uiControlHide(c: VoidPtr):
    external_call["uiControlHide", NoneType](c)

fn uiControlEnabled(c: VoidPtr) -> c_int:
    return external_call["uiControlEnabled", c_int](c)

fn uiControlEnable(c: VoidPtr):
    external_call["uiControlEnable", NoneType](c)

fn uiControlDisable(c: VoidPtr):
    external_call["uiControlDisable", NoneType](c)

fn uiControlVisible(c: VoidPtr) -> c_int:
    return external_call["uiControlVisible", c_int](c)

# --- Window Functions ---
fn uiNewWindow(title: CharPtr, width: c_int, height: c_int, hasMenubar: c_int) -> WinPtr:
    return external_call["uiNewWindow", WinPtr](title, width, height, hasMenubar)

fn uiWindowTitle(w: WinPtr) -> MutCharPtr:
    return external_call["uiWindowTitle", MutCharPtr](w)

fn uiWindowSetTitle(w: WinPtr, title: CharPtr):
    external_call["uiWindowSetTitle", NoneType](w, title)

fn uiWindowContentSize(w: WinPtr, width: UnsafePointer[c_int, MutAnyOrigin], height: UnsafePointer[c_int, MutAnyOrigin]):
    external_call["uiWindowContentSize", NoneType](w, width, height)

fn uiWindowSetContentSize(w: WinPtr, width: c_int, height: c_int):
    external_call["uiWindowSetContentSize", NoneType](w, width, height)

fn uiWindowFullscreen(w: WinPtr) -> c_int:
    return external_call["uiWindowFullscreen", c_int](w)

fn uiWindowSetFullscreen(w: WinPtr, fullscreen: c_int):
    external_call["uiWindowSetFullscreen", NoneType](w, fullscreen)

fn uiWindowOnClosing(w: WinPtr, f: OnCloseFn, data: VoidPtr):
    external_call["uiWindowOnClosing", NoneType](w, f, data)

fn uiWindowSetChild(w: WinPtr, child: VoidPtr):
    external_call["uiWindowSetChild", NoneType](w, child)

fn uiWindowMargined(w: WinPtr) -> c_int:
    return external_call["uiWindowMargined", c_int](w)

fn uiWindowSetMargined(w: WinPtr, margined: c_int):
    external_call["uiWindowSetMargined", NoneType](w, margined)

fn uiWindowBorderless(w: WinPtr) -> c_int:
    return external_call["uiWindowBorderless", c_int](w)

fn uiWindowSetBorderless(w: WinPtr, borderless: c_int):
    external_call["uiWindowSetBorderless", NoneType](w, borderless)

# --- Button Functions ---
fn uiNewButton(text: CharPtr) -> BtnPtr:
    return external_call["uiNewButton", BtnPtr](text)

fn uiButtonText(b: BtnPtr) -> MutCharPtr:
    return external_call["uiButtonText", MutCharPtr](b)

fn uiButtonSetText(b: BtnPtr, text: CharPtr):
    external_call["uiButtonSetText", NoneType](b, text)

fn uiButtonOnClicked(b: BtnPtr, f: OnClickFn, data: VoidPtr):
    external_call["uiButtonOnClicked", NoneType](b, f, data)

# --- Entry Functions ---
fn uiNewEntry() -> EntryPtr:
    return external_call["uiNewEntry", EntryPtr]()

fn uiNewPasswordEntry() -> EntryPtr:
    return external_call["uiNewPasswordEntry", EntryPtr]()

fn uiNewSearchEntry() -> EntryPtr:
    return external_call["uiNewSearchEntry", EntryPtr]()

fn uiEntryText(e: EntryPtr) -> MutCharPtr:
    return external_call["uiEntryText", MutCharPtr](e)

fn uiEntrySetText(e: EntryPtr, text: CharPtr):
    external_call["uiEntrySetText", NoneType](e, text)

fn uiEntryOnChanged(e: EntryPtr, f: OnEntryChangeFn, data: VoidPtr):
    external_call["uiEntryOnChanged", NoneType](e, f, data)

fn uiEntryReadOnly(e: EntryPtr) -> c_int:
    return external_call["uiEntryReadOnly", c_int](e)

fn uiEntrySetReadOnly(e: EntryPtr, readonly: c_int):
    external_call["uiEntrySetReadOnly", NoneType](e, readonly)

# --- Label Functions ---
fn uiNewLabel(text: CharPtr) -> LabelPtr:
    return external_call["uiNewLabel", LabelPtr](text)

fn uiLabelText(l: LabelPtr) -> MutCharPtr:
    return external_call["uiLabelText", MutCharPtr](l)

fn uiLabelSetText(l: LabelPtr, text: CharPtr):
    external_call["uiLabelSetText", NoneType](l, text)

# --- Horizontal Box Functions ---
fn uiNewHorizontalBox() -> BoxPtr:
    return external_call["uiNewHorizontalBox", BoxPtr]()

# --- Vertical Box Functions ---
fn uiNewVerticalBox() -> BoxPtr:
    return external_call["uiNewVerticalBox", BoxPtr]()

fn uiBoxAppend(b: BoxPtr, child: VoidPtr, stretchy: c_int):
    external_call["uiBoxAppend", NoneType](b, child, stretchy)

fn uiBoxDelete(b: BoxPtr, index: c_int):
    external_call["uiBoxDelete", NoneType](b, index)

fn uiBoxPadded(b: BoxPtr) -> c_int:
    return external_call["uiBoxPadded", c_int](b)

fn uiBoxSetPadded(b: BoxPtr, padded: c_int):
    external_call["uiBoxSetPadded", NoneType](b, padded)

fn uiBoxNumChildren(b: BoxPtr) -> c_int:
    return external_call["uiBoxNumChildren", c_int](b)

# --- Checkbox Functions ---
fn uiNewCheckbox(text: CharPtr) -> CheckboxPtr:
    return external_call["uiNewCheckbox", CheckboxPtr](text)

fn uiCheckboxText(c: CheckboxPtr) -> MutCharPtr:
    return external_call["uiCheckboxText", MutCharPtr](c)

fn uiCheckboxSetText(c: CheckboxPtr, text: CharPtr):
    external_call["uiCheckboxSetText", NoneType](c, text)

fn uiCheckboxChecked(c: CheckboxPtr) -> c_int:
    return external_call["uiCheckboxChecked", c_int](c)

fn uiCheckboxSetChecked(c: CheckboxPtr, checked: c_int):
    external_call["uiCheckboxSetChecked", NoneType](c, checked)

fn uiCheckboxOnToggled(c: CheckboxPtr, f: OnCheckboxToggleFn, data: VoidPtr):
    external_call["uiCheckboxOnToggled", NoneType](c, f, data)

# --- Spinbox Functions ---
fn uiNewSpinbox(min_val: c_int, max_val: c_int) -> SpinboxPtr:
    return external_call["uiNewSpinbox", SpinboxPtr](min_val, max_val)

fn uiSpinboxValue(s: SpinboxPtr) -> c_int:
    return external_call["uiSpinboxValue", c_int](s)

fn uiSpinboxSetValue(s: SpinboxPtr, value: c_int):
    external_call["uiSpinboxSetValue", NoneType](s, value)

fn uiSpinboxOnChanged(s: SpinboxPtr, f: OnSpinboxChangeFn, data: VoidPtr):
    external_call["uiSpinboxOnChanged", NoneType](s, f, data)

# --- Slider Functions ---
fn uiNewSlider(min_val: c_int, max_val: c_int) -> SliderPtr:
    return external_call["uiNewSlider", SliderPtr](min_val, max_val)

fn uiSliderValue(s: SliderPtr) -> c_int:
    return external_call["uiSliderValue", c_int](s)

fn uiSliderSetValue(s: SliderPtr, value: c_int):
    external_call["uiSliderSetValue", NoneType](s, value)

fn uiSliderOnChanged(s: SliderPtr, f: OnSliderChangeFn, data: VoidPtr):
    external_call["uiSliderOnChanged", NoneType](s, f, data)

# --- ProgressBar Functions ---
fn uiNewProgressBar() -> ProgressPtr:
    return external_call["uiNewProgressBar", ProgressPtr]()

fn uiProgressBarValue(p: ProgressPtr) -> c_int:
    return external_call["uiProgressBarValue", c_int](p)

fn uiProgressBarSetValue(p: ProgressPtr, n: c_int):
    external_call["uiProgressBarSetValue", NoneType](p, n)

# --- Combobox Functions ---
fn uiNewCombobox() -> ComboPtr:
    return external_call["uiNewCombobox", ComboPtr]()

fn uiComboboxAppend(c: ComboPtr, text: CharPtr):
    external_call["uiComboboxAppend", NoneType](c, text)

fn uiComboboxSelected(c: ComboPtr) -> c_int:
    return external_call["uiComboboxSelected", c_int](c)

fn uiComboboxSetSelected(c: ComboPtr, n: c_int):
    external_call["uiComboboxSetSelected", NoneType](c, n)

fn uiComboboxOnSelected(c: ComboPtr, f: OnComboSelectedFn, data: VoidPtr):
    external_call["uiComboboxOnSelected", NoneType](c, f, data)

# --- Editable Combobox Functions ---
fn uiNewEditableCombobox() -> EditComboPtr:
    return external_call["uiNewEditableCombobox", EditComboPtr]()

fn uiEditableComboboxAppend(c: EditComboPtr, text: CharPtr):
    external_call["uiEditableComboboxAppend", NoneType](c, text)

fn uiEditableComboboxText(c: EditComboPtr) -> MutCharPtr:
    return external_call["uiEditableComboboxText", MutCharPtr](c)

fn uiEditableComboboxSetText(c: EditComboPtr, text: CharPtr):
    external_call["uiEditableComboboxSetText", NoneType](c, text)

fn uiEditableComboboxOnChanged(c: EditComboPtr, f: OnEditComboChangedFn, data: VoidPtr):
    external_call["uiEditableComboboxOnChanged", NoneType](c, f, data)

# --- RadioButtons Functions ---
fn uiNewRadioButtons() -> RadioPtr:
    return external_call["uiNewRadioButtons", RadioPtr]()

fn uiRadioButtonsAppend(r: RadioPtr, text: CharPtr):
    external_call["uiRadioButtonsAppend", NoneType](r, text)

fn uiRadioButtonsSelected(r: RadioPtr) -> c_int:
    return external_call["uiRadioButtonsSelected", c_int](r)

fn uiRadioButtonsSetSelected(r: RadioPtr, n: c_int):
    external_call["uiRadioButtonsSetSelected", NoneType](r, n)

fn uiRadioButtonsOnSelected(r: RadioPtr, f: OnRadioSelectedFn, data: VoidPtr):
    external_call["uiRadioButtonsOnSelected", NoneType](r, f, data)

# --- Separator Functions ---
fn uiNewHorizontalSeparator() -> SepPtr:
    return external_call["uiNewHorizontalSeparator", SepPtr]()

fn uiNewVerticalSeparator() -> SepPtr:
    return external_call["uiNewVerticalSeparator", SepPtr]()

# --- Group Functions ---
fn uiNewGroup(title: CharPtr) -> GroupPtr:
    return external_call["uiNewGroup", GroupPtr](title)

fn uiGroupTitle(g: GroupPtr) -> MutCharPtr:
    return external_call["uiGroupTitle", MutCharPtr](g)

fn uiGroupSetTitle(g: GroupPtr, title: CharPtr):
    external_call["uiGroupSetTitle", NoneType](g, title)

fn uiGroupSetChild(g: GroupPtr, child: VoidPtr):
    external_call["uiGroupSetChild", NoneType](g, child)

fn uiGroupMargined(g: GroupPtr) -> c_int:
    return external_call["uiGroupMargined", c_int](g)

fn uiGroupSetMargined(g: GroupPtr, margined: c_int):
    external_call["uiGroupSetMargined", NoneType](g, margined)

# --- Tab Functions ---
fn uiNewTab() -> TabPtr:
    return external_call["uiNewTab", TabPtr]()

fn uiTabAppend(t: TabPtr, name: CharPtr, c: VoidPtr):
    external_call["uiTabAppend", NoneType](t, name, c)

fn uiTabInsertAt(t: TabPtr, name: CharPtr, before: c_int, c: VoidPtr):
    external_call["uiTabInsertAt", NoneType](t, name, before, c)

fn uiTabDelete(t: TabPtr, index: c_int):
    external_call["uiTabDelete", NoneType](t, index)

fn uiTabNumPages(t: TabPtr) -> c_int:
    return external_call["uiTabNumPages", c_int](t)

fn uiTabMargined(t: TabPtr, page: c_int) -> c_int:
    return external_call["uiTabMargined", c_int](t, page)

fn uiTabSetMargined(t: TabPtr, page: c_int, margined: c_int):
    external_call["uiTabSetMargined", NoneType](t, page, margined)

# --- Grid Functions ---
fn uiNewGrid() -> GridPtr:
    return external_call["uiNewGrid", GridPtr]()

fn uiGridAppend(g: GridPtr, c: VoidPtr, left: c_int, top: c_int, 
                xspan: c_int, yspan: c_int, hexpand: c_int, 
                halign: c_int, vexpand: c_int, valign: c_int):
    external_call["uiGridAppend", NoneType](g, c, left, top, xspan, yspan, hexpand, halign, vexpand, valign)

fn uiGridInsertAt(g: GridPtr, c: VoidPtr, existing: VoidPtr, at: c_int,
                  xspan: c_int, yspan: c_int, hexpand: c_int,
                  halign: c_int, vexpand: c_int, valign: c_int):
    external_call["uiGridInsertAt", NoneType](g, c, existing, at, xspan, yspan, hexpand, halign, vexpand, valign)

fn uiGridPadded(g: GridPtr) -> c_int:
    return external_call["uiGridPadded", c_int](g)

fn uiGridSetPadded(g: GridPtr, padded: c_int):
    external_call["uiGridSetPadded", NoneType](g, padded)

# --- Multiline Entry Functions ---
fn uiNewMultilineEntry() -> MultiEntryPtr:
    return external_call["uiNewMultilineEntry", MultiEntryPtr]()

fn uiNewNonWrappingMultilineEntry() -> MultiEntryPtr:
    return external_call["uiNewNonWrappingMultilineEntry", MultiEntryPtr]()

fn uiMultilineEntryText(e: MultiEntryPtr) -> MutCharPtr:
    return external_call["uiMultilineEntryText", MutCharPtr](e)

fn uiMultilineEntrySetText(e: MultiEntryPtr, text: CharPtr):
    external_call["uiMultilineEntrySetText", NoneType](e, text)

fn uiMultilineEntryAppend(e: MultiEntryPtr, text: CharPtr):
    external_call["uiMultilineEntryAppend", NoneType](e, text)

fn uiMultilineEntryOnChanged(e: MultiEntryPtr, f: OnMultiEntryChangeFn, data: VoidPtr):
    external_call["uiMultilineEntryOnChanged", NoneType](e, f, data)

fn uiMultilineEntryReadOnly(e: MultiEntryPtr) -> c_int:
    return external_call["uiMultilineEntryReadOnly", c_int](e)

fn uiMultilineEntrySetReadOnly(e: MultiEntryPtr, readonly: c_int):
    external_call["uiMultilineEntrySetReadOnly", NoneType](e, readonly)

# --- Form Functions ---
fn uiNewForm() -> FormPtr:
    return external_call["uiNewForm", FormPtr]()

fn uiFormAppend(f: FormPtr, label: CharPtr, c: VoidPtr, stretchy: c_int):
    external_call["uiFormAppend", NoneType](f, label, c, stretchy)

fn uiFormDelete(f: FormPtr, index: c_int):
    external_call["uiFormDelete", NoneType](f, index)

fn uiFormPadded(f: FormPtr) -> c_int:
    return external_call["uiFormPadded", c_int](f)

fn uiFormSetPadded(f: FormPtr, padded: c_int):
    external_call["uiFormSetPadded", NoneType](f, padded)

fn uiFormNumChildren(f: FormPtr) -> c_int:
    return external_call["uiFormNumChildren", c_int](f)

# --- Free Text Function ---
fn uiFreeText(text: MutCharPtr):
    external_call["uiFreeText", NoneType](text)

