[DBus (name = "app.junker.mictray")]
public class DbusServer : Object
{
	public bool muted {
		get { return pulse.muted; }
	}

	public void mute()
	{
		pulse.mute();
	}

	public void unmute()
	{
		pulse.unmute();
	}

	public void toggle_mute()
	{
		pulse.toggle_mute();
	}

	public void increase_volume()
	{
		pulse.increase_volume();
	}

	public void decrease_volume()
	{
		pulse.decrease_volume();
	}
}