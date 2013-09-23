THISDIR = $(PWD)
BUILDDIR = $(PWD)/build
RTMIDI_DIR = rtmidi-2.0.1

NATIVE_LIB = $(BUILDDIR)/librtmidi_c.so
RTMIDI_LIB = $(RTMIDI_DIR)/librtmidi.a
MANAGED_LIB = $(BUILDDIR)/rtmidi-sharp.dll

NATIVE_SOURCES = \
	rtmidi-c/rtmidi_c.h \
	rtmidi-c/rtmidi_c.cpp

NATIVE_OBJ = rtmidi-c/rtmidi_c.o

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

$(NATIVE_LIB): $(NATIVE_OBJ) $(RTMIDI_LIB) 
	mkdir -p build
	gcc -g $(NATIVE_OBJ) $(RTMIDI_LIB) -lstdc++ -fPIC -shared -Wl,-soname,$(NATIVE_LIB) -o $(NATIVE_LIB)

$(NATIVE_OBJ): $(NATIVE_SOURCES) .download-stamp
	cd rtmidi-c && gcc -g -c -fPIC rtmidi_c.cpp

$(RTMIDI_LIB): .download-stamp
	cd rtmidi-2.0.1 && ./configure && make || exit 1

$(MANAGED_LIB): $(MANAGED_SOURCES)
	mcs -debug $(MANAGED_SOURCES) -t:library -out:$(MANAGED_LIB)

clean:
	rm -rf $(MANAGED_LIB)
	rm -rf $(RTMIDI_LIB)
	rm -rf $(NATIVE_LIB)
	rm -rf $(NATIVE_OBJ)
