THISDIR = $(PWD)
BUILDDIR = $(PWD)/build

NATIVE_LIB = $(BUILDDIR)/librtmidi_c.so
MANAGED_LIB = $(BUILDDIR)/rtmidi-sharp.dll

NATIVE_SOURCES = \
	rtmidi-c/rtmidi_c.h \
	rtmidi-c/rtmidi_c.cpp

MANAGED_SOURCES = \
	RtMidiSharp.cs

all: native managed

.PHONY:
native: $(NATIVE_LIB)

.PHONY:
managed: $(MANAGED_LIB)

configure: rtmidi-2.0.1/configure
	cd rtmidi-2.0.1 && ./configure --prefix=$(THISDIR)/build && make && make install

rtmidi-2.0.1/configure: .download-stamp

.download-stamp:
	wget http://www.music.mcgill.ca/~gary/rtmidi/release/rtmidi-2.0.1.tar.gz
	tar zxvf rtmidi-2.0.1.tar.gz
	touch .download-stamp

$(NATIVE_LIB): .download-stamp $(NATIVE_SOURCES)
	cd rtmidi-c && gcc -g rtmidi_c.cpp ../rtmidi-2.0.1/RtMidi.cpp -lstdc++ -fPIC -shared -Wl,-soname,$(NATIVE_LIB) -o $(NATIVE_LIB)

$(MANAGED_LIB): $(MANAGED_SOURCES)
	mcs -debug $(MANAGED_SOURCES) -t:library -out:$(MANAGED_LIB)

clean:
	rm -rf $(MANAGED_LIB)
	rm -rf $(NATIVE_LIB)
