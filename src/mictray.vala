
using Gtk;
using Notify;

static MicStatusIcon status_icon;

static Pulse pulse;
static ConfigFile config;
static MicTrayApp app;
static Notify.Notification vol_notification;

extern const string GETTEXT_PACKAGE;

class MicTrayApp : Gtk.Application
{
	protected override void activate ()
	{
		status_icon = new MicStatusIcon();

		config = new ConfigFile();

		pulse = new Pulse();

		Notify.init ("MicTray");
		vol_notification = new Notify.Notification ("Volume: %d%c".printf(pulse.volume, '%'), "", status_icon.icon_name);
		vol_notification.set_timeout(2000);
		vol_notification.set_hint("transient", new Variant.boolean(true));

		pulse.change_callback = () =>
		{
			status_icon.update();

			if (config.show_notifications && pulse.old_volume != pulse.volume || pulse.old_muted != pulse.muted)
			{
				try
				{
					vol_notification.update("Volume: %d%c".printf(pulse.volume, '%'), "", status_icon.icon_name);
					vol_notification.set_hint("value", new Variant.int32(pulse.volume));
					vol_notification.show();
				}
				catch (Error e)
				{
					error ("Error: %s", e.message);
				}
			}
		};

		pulse.source_change_callback = () =>
		{
			if (config.show_notifications)
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
		};

		if (config.load() && !config.use_default_source)
		{
			pulse.current_source_name = config.source_name;
		}

		Gtk.main();
	}

	public MicTrayApp()
	{
		Object (application_id: "app.junker.mictray");
	}
}

static int main (string[] args) 
{
	app = new MicTrayApp();

	return app.run(args);
}