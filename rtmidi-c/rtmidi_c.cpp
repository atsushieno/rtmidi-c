#include <string.h>
#include <stdlib.h>
#include "rtmidi_c.h"
#include "../rtmidi-2.0.1/RtMidi.h"


/* misc */
static int rtmidi_sizeof_rtmidi_api ()
{
	return sizeof (RtMidiApi);
}

/* RtMidi API */
static int rtmidi_get_compiled_api (enum RtMidiApi **apis) // return length for NULL argument.
{
	if (!apis) {
		std::vector<RtMidi::Api> *v = new std::vector<RtMidi::Api> ();
		try {
			RtMidi::getCompiledApi (*v);
			int size = v->size ();
			delete v;
			return size;
		} catch (...) {
			return -1;
		}
	} else {
		std::vector<RtMidi::Api> *v = new std::vector<RtMidi::Api> ();
		try {
			RtMidi::getCompiledApi (*v);
			for (int i = 0; i < v->size (); i++)
				*apis [i] = (RtMidiApi) v->at (i);
			delete v;
			return 0;
		} catch (...) {
			return -1;
		}
	}
}

static void rtmidi_error (enum RtMidiErrorType type, const char* errorString)
{
	std::string msg = errorString;
	RtMidi::error ((RtError::Type) type, msg);
}

void rtmidi_open_port (RtMidiPtr device, unsigned int portNumber, const char *portName)
{
	std::string name = portName;
	((RtMidi*) device)->openPort (portNumber, name);
}

void rtmidi_open_virtual_port (RtMidiPtr device, const char *portName)
{
	std::string name = portName;
	((RtMidi*) device)->openVirtualPort (name);
}

void rtmidi_close_port (RtMidiPtr device)
{
	((RtMidi*) device)->closePort ();
}

unsigned int rtmidi_get_port_count (RtMidiPtr device)
{
	return ((RtMidi*) device)->getPortCount ();
}

const char* rtmidi_get_port_name (RtMidiPtr device, unsigned int portNumber)
{
	std::string name = ((RtMidi*) device)->getPortName (portNumber);
	return name.c_str ();
}

/* RtMidiIn API */
RtMidiInPtr rtmidi_in_create_default ()
{
	return new RtMidiIn ();
}

RtMidiInPtr rtmidi_in_create (enum RtMidiApi api, const char *clientName, unsigned int queueSizeLimit)
{
	std::string name = clientName;
	return new RtMidiIn ((RtMidi::Api) api, name, queueSizeLimit);
}

void rtmidi_in_free (RtMidiInPtr device)
{
	delete (RtMidiIn*) device;
}

enum RtMidiApi rtmidi_in_get_current_api (RtMidiPtr device)
{
	return (RtMidiApi) ((RtMidiIn*) device)->getCurrentApi ();
}

class CallbackProxyUserData
{
  public:
	CallbackProxyUserData (RtMidiCCallback cCallback, void *userData)
		: c_callback (cCallback), user_data (userData)
	{
	}
	RtMidiCCallback c_callback;
	void *user_data;
};

void callback_proxy (double timeStamp, std::vector<unsigned char> *message, void *userData)
{
	CallbackProxyUserData* data = reinterpret_cast<CallbackProxyUserData*> (userData);
	data->c_callback (timeStamp, message->data (), data->user_data);
}

void rtmidi_in_set_callback (RtMidiInPtr device, RtMidiCCallback callback, void *userData)
{
	void *data = (void *) new CallbackProxyUserData (callback, userData);
	((RtMidiIn*) device)->setCallback (callback_proxy, data);
}

void rtmidi_in_cancel_callback (RtMidiInPtr device)
{
	((RtMidiIn*) device)->cancelCallback ();
}

void rtmidi_in_ignore_types (RtMidiInPtr device, bool midiSysex, bool midiTime, bool midiSense)
{
	((RtMidiIn*) device)->ignoreTypes (midiSysex, midiTime, midiSense);
}

double rtmidi_in_get_message (RtMidiInPtr device, unsigned char **message)
{
	try {
		// FIXME: use allocator to achieve efficient buffering
		std::vector<unsigned char> *v = new std::vector<unsigned char> ();
		double ret = ((RtMidiIn*) device)->getMessage (v);
		*message = (unsigned char *) malloc ((int) ret);
		memcpy (*message, v->data (), (int) ret);
		delete v;
		return ret;
	} catch (...) {
		return -1;
	}
}

/* RtMidiOut API */
RtMidiOutPtr rtmidi_out_create_default ()
{
	return new RtMidiOut ();
}

RtMidiOutPtr rtmidi_out_create (enum RtMidiApi api, const char *clientName)
{
	std::string name = clientName;
	return new RtMidiOut ((RtMidi::Api) api, name);
}

void rtmidi_out_free (RtMidiOutPtr device)
{
	delete (RtMidiOut*) device;
}

enum RtMidiApi rtmidi_out_get_current_api (RtMidiPtr device)
{
	return (RtMidiApi) ((RtMidiOut*) device)->getCurrentApi ();
}

int rtmidi_out_send_message (RtMidiOutPtr device, const unsigned char *message, int length)
{
	try {
		// FIXME: use allocator to achieve efficient buffering
		std::vector<unsigned char> *v = new std::vector<unsigned char> (length);
		memcpy (v->data (), message, length);
		((RtMidiOut*) device)->sendMessage (v);
		delete v;
		return 0;
	} catch (...) {
		return -1;
	}
}

