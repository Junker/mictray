[DBus (name = "app.junker.mictray")]
public class DbusServer : Object
{
	public bool muted {
		get { return pulse.muted; }
	}

	public void mute() throws GLib.Error
	{
		pulse.mute();
	}

	public void unmute() throws GLib.Error
	{
		pulse.unmute();
	}

	public void toggle_mute() throws GLib.Error
	{
		pulse.toggle_mute();
	}

	public void increase_volume() throws GLib.Error
	{
		pulse.increase_volume();
	}

	public void decrease_volume() throws GLib.Error
	{
		pulse.decrease_volume();
	}
}