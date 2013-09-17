using System;
using System.IO;
using System.Runtime.InteropServices;

using RtMidiPtr = System.IntPtr;
using RtMidiInPtr = System.IntPtr;
using RtMidiOutPtr = System.IntPtr;


namespace RtMidiSharp
{
	public enum RtMidiApi {
		Unspecified,
		MacOsxCore,
		LinuxAlsa,
		UnixJack,
		WindowsMultimediaMidi,
		WindowsKernelStreaming,
		RtMidiDummy,
	}

	public enum RtMidiErrorType {
		Warning,
		DebugWarning,
		Unspecified,
		NoDevicesFound,
		InvalidDevice,
		MemoryError,
		InvalidParameter,
		InvalidUse,		
		DriverError,
		SystemError,
		ThreadError,
	}


	public delegate void RtMidiCallback (double timestamp, string message, IntPtr userData);

	public static class RtMidi
	{
		public const string RtMidiLibrary = "rtmidi_c";
		
		/* RtMidi API */
		[DllImport (RtMidiLibrary)]
		static extern int rtmidi_get_compiled_api (out IntPtr/* RtMidiApi ** */ apis); // return length for NULL argument.
		[DllImport (RtMidiLibrary)]
		static extern void rtmidi_error (RtMidiErrorType type, string errorString);

		[DllImport (RtMidiLibrary)]
		static extern void rtmidi_open_port (RtMidiPtr device, uint portNumber, string portName);
		[DllImport (RtMidiLibrary)]
		static extern void rtmidi_open_virtual_port (RtMidiPtr device, string portName);
		[DllImport (RtMidiLibrary)]
		static extern void rtmidi_close_port (RtMidiPtr device);
		[DllImport (RtMidiLibrary)]
		static extern uint rtmidi_get_port_count (RtMidiPtr device);
		[DllImport (RtMidiLibrary)]
		static extern string rtmidi_get_port_name (RtMidiPtr device, uint portNumber);

		/* RtMidiIn API */
		[DllImport (RtMidiLibrary)]
		static extern RtMidiInPtr rtmidi_in_create_default ();
		[DllImport (RtMidiLibrary)]
		static extern RtMidiInPtr rtmidi_in_create (RtMidiApi api, string clientName, uint queueSizeLimit);
		[DllImport (RtMidiLibrary)]
		static extern void rtmidi_in_free (RtMidiInPtr device);
		[DllImport (RtMidiLibrary)]
		static extern RtMidiApi rtmidi_in_get_current_api (RtMidiPtr device);
		[DllImport (RtMidiLibrary)]
		static extern void rtmidi_in_set_callback (RtMidiInPtr device, RtMidiCallback callback, IntPtr userData);
		[DllImport (RtMidiLibrary)]
		static extern void rtmidi_in_cancel_callback (RtMidiInPtr device);
		[DllImport (RtMidiLibrary)]
		static extern void rtmidi_in_ignore_types (RtMidiInPtr device, bool midiSysex, bool midiTime, bool midiSense);
		[DllImport (RtMidiLibrary)]
		static extern double rtmidi_in_get_message (RtMidiInPtr device, /* unsigned char ** */out IntPtr message);

		/* RtMidiOut API */
		[DllImport (RtMidiLibrary)]
		static extern RtMidiOutPtr rtmidi_out_create_default ();
		[DllImport (RtMidiLibrary)]
		static extern RtMidiOutPtr rtmidi_out_create (RtMidiApi api, string clientName);
		[DllImport (RtMidiLibrary)]
		static extern void rtmidi_out_free (RtMidiOutPtr device);
		[DllImport (RtMidiLibrary)]
		static extern RtMidiApi rtmidi_out_get_current_api (RtMidiPtr device);
		[DllImport (RtMidiLibrary)]
		static extern int rtmidi_out_send_message (RtMidiOutPtr device, byte [] message);
	}
}
