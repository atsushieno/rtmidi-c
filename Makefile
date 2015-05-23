THISDIR = $(PWD)
BUILDDIR = $(PWD)/build
RTMIDI_DIR = external/rtmidi

RTMIDI_C_INC = $(BUILDDIR)/include/rtmidi_c.h
RTMIDI_C_LIB = $(BUILDDIR)/lib/librtmidi_c.so
RTMIDI_LIB = $(RTMIDI_DIR)/.libs/librtmidi.a
RTMIDI_C_INC_SRC = rtmidi-c/rtmidi_c.h

NATIVE_SOURCES = \
	$(RTMIDI_C_INC_SRC) \
	rtmidi-c/rtmidi_c.cpp

RTMIDI_C_INC_SRC = \
	rtmidi-c/rtmidi_c.h

NATIVE_OBJ = rtmidi-c/rtmidi_c.o

all: $(RTMIDI_C_LIB) $(RTMIDI_C_INC)

$(RTMIDI_C_INC): 
	mkdir -p build/include
	cp $(RTMIDI_C_INC_SRC) $(RTMIDI_C_INC)

$(RTMIDI_C_LIB): $(NATIVE_OBJ) $(RTMIDI_LIB) 
	mkdir -p build/lib
	gcc -g $(NATIVE_OBJ) $(RTMIDI_LIB) -lasound -lstdc++ -fPIC -shared -Wl,-soname,$(RTMIDI_C_LIB) -o $(RTMIDI_C_LIB)

$(NATIVE_OBJ): $(NATIVE_SOURCES)
	cd rtmidi-c && gcc -g -c -fPIC rtmidi_c.cpp

$(RTMIDI_LIB):
	cp autogen.sh $(RTMIDI_DIR) && cd $(RTMIDI_DIR) && CPPFLAGS=-fPIC ./autogen.sh && make || exit 1

clean:
	rm -rf $(RTMIDI_LIB)
	rm -rf $(RTMIDI_C_LIB)
	rm -rf $(RTMIDI_C_INC)
	rm -rf $(NATIVE_OBJ)
