
using Gtk;

static MicStatusIcon status_icon;

static Pulse pulse;
static ConfigFile config;
static MicTrayApp app;
static Notification notification;

extern const string GETTEXT_PACKAGE;

class MicTrayApp : Gtk.Application
{
	protected override void activate ()
	{
		status_icon = new MicStatusIcon();
		config = new ConfigFile();
		pulse = new Pulse();
		notification = new Notification();

		pulse.change_callback = () =>
		{
			status_icon.update();

			if (config.show_notifications && !pulse.first_change && (pulse.old_volume != pulse.volume || pulse.old_muted != pulse.muted))
			{
				notification.update();
			}
		};

		pulse.source_change_callback = () =>
		{
			if (config.show_notifications)
			{
				notification.source_changed();
			}
		};

		if (config.load() && !config.use_default_source)
		{
			pulse.current_source_name = config.source_name;
		}

		Bus.own_name(BusType.SESSION, "app.junker.mictray", BusNameOwnerFlags.ALLOW_REPLACEMENT, on_dbus_aquired);

		Gtk.main();
	}

	private void on_dbus_aquired(DBusConnection conn) {
		try {
			conn.register_object("/app/junker/mictray", new DbusServer());
		} catch (IOError e) {
			stderr.printf("Could not register DBUS service\n");
		}
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