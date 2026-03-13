set shell := ["sh", "-c"]
set windows-shell := ["powershell", "-c"]

_main:
    @just --list

# run source .venv/bin/activate before running this
controlgallery:
	mojo build controlgallery.mojo -o controlgallery -Xlinker libui.a $(pkg-config --libs gtk+-3.0 | xargs -n1 echo -Xlinker)
