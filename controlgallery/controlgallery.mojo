from highlevel import *


fn on_closing(win: WinPtr, data: VoidPtr) -> c_int:
    _ = win
    _ = data
    uiQuit()
    return 1


fn main():
    var app = App()
    if not app.init():
        print("Failed to init libui")
        return

    with Window("Hello Mojo UI", on_closing, 900, 600) as win:
        with VBox() as main_content:
            _ = Label(main_content, "Welcome to the app!")
            with HBox(main_content) as hbox:
                 _ = Button(hbox, "New")
                 #button.expand()
                 _ = Button(hbox, "Open")
                 _ = Entry(hbox, placeholder="Search...")
                 #entry.expand()
                 _ = Button(hbox, "Save")            
            with HBox(main_content) as row:
                 _ = Checkbox(row, "Dark mode")
                 _ = Slider(row, 0, 100)
            var pbar = ProgressBar(main_content)
            pbar.set_value(75)

            # add vbox to main content
            win.set_child(main_content)   # or win.add(main_content) if you keep .add()
    app.run()
    app.cleanup()
