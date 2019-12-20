using Notify;

class Notification : Object
{
	private Notify.Notification vol_notification;

	construct
	{
		Notify.init ("MicTray");

		vol_notification = new Notify.Notification ("Volume: %d%c".printf(pulse.volume, '%'), "", status_icon.icon_name);
		vol_notification.set_timeout(2000);
		vol_notification.set_hint("transient", new Variant.boolean(true));
	}

	public void update()
	{
		try
		{
			this.vol_notification.update("Volume: %d%c".printf(pulse.volume, '%'), "", status_icon.icon_name);
			this.vol_notification.set_hint("value", new Variant.int32(pulse.volume));
			this.vol_notification.show();
		}
		catch (Error e)
		{
			error ("Error: %s", e.message);
		}
	}

	public void source_changed()
	{
		try
		{
			Notify.Notification notification = new Notify.Notification ("Input source changed", pulse.current_source_description, status_icon.icon_name);
			notification.show();
		}
		catch (Error e)
		{
			error ("Error: %s", e.message);
		}
	}
}