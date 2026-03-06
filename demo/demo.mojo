from highlevel import *

fn main():
    var app = App()
    if not app.init():
        print("UI init failed")
        return

    with Window("Mojo High-Level Test", 500, 400) as win:
        with HBox() as box:
            box.add(Button("Click Me"))
            #box.add(Entry("Type here...").expand())
            #box.add(Label("Status: OK"))
            win.set_child(box)
        uiControlShow(win.handle())  # Ensure visible


    app.run()