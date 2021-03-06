all: publish

compile:
	dub build --compiler=gdc

publish:
	dub build --build=release --compiler=gdc

run: compile
	dub run --compiler=gdc
	 
clean:
	dub clean
	rm -rf rterm rterm.exe dub_platform_probe_*

userinstall: publish
	strip rterm
	mkdir -p ~/.local/bin/
	cp rterm ~/.local/bin/

	mkdir -p ~/.local/share/applications/
	cp extra/linux/rterm.desktop ~/.local/share/applications/
	
	mkdir -p ~/.local/share/nautilus-python/extensions
	cp extra/linux/open-rterm.py ~/.local/share/nautilus-python/extensions


useruninstall:
	rm ~/.local/bin/rterm
	rm ~/.local/share/applications/rterm.desktop
	rm ~/.local/share/nautilus-python/extensions/open-rterm.py
