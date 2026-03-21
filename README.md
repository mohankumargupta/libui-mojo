# libui-mojo

libui-ng bindings for mojo

https://github.com/libui-ng/libui-ng


Tested on Ubuntu Noble on WSL2. 

## Setup

1. Need to compile libui-ng as a static binary for your os/architecture.
   3 choices
   - there is a precompiled static binary avaailable in this fork https://github.com/kojix2/libui-ng
     (when you unzip, look for libui.a or libui.lib)
   - you can go to https://github.com/libui-ng/libui-ng and follow instructions
   - I have a modified fork that uses zig to compile https://github.com/mohankumargupta/libui-ng
2. if on linux need libgtk-3-dev or whatever it is called on your distro


## Project setup

1. git clone this repo.  
2. copy libui.a from setup step.
3. Install mojo, then run the example(controlgallery example from libui-ng)

```sh
	mojo build controlgallery.mojo -o controlgallery -Xlinker libui.a $(pkg-config --libs gtk+-3.0 | xargs -n1 echo -Xlinker)
```
 or if you have just installed

 ```sh
just example
 ```