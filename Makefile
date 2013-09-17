THISDIR = $(PWD)

all: native

.PHONY:
native: rtmidi-c/librtmidi_c.so

configure: rtmidi-2.0.1/configure
	cd rtmidi-2.0.1 && ./configure --prefix=$(THISDIR)/build && make && make install

rtmidi-2.0.1/configure: .download-stamp

.download-stamp:
	wget http://www.music.mcgill.ca/~gary/rtmidi/release/rtmidi-2.0.1.tar.gz
	tar zxvf rtmidi-2.0.1.tar.gz
	touch .download-stamp

rtmidi-c/librtmidi_c.so: .download-stamp
	cd rtmidi-c && gcc rtmidi_c.cpp ../rtmidi-2.0.1/RtMidi.cpp -lstdc++ 

