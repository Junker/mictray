
using Gtk;

static MicStatusIcon status_icon;

static Pulse pulse;
static ConfigFile config;
static MicTrayApp app;

extern const string GETTEXT_PACKAGE;

class MicTrayApp : Gtk.Application
{
	protected override void activate ()
	{
		status_icon = new MicStatusIcon();

		config = new ConfigFile();

		pulse = new Pulse();
		pulse.change_callback = () => {status_icon.update();};

		pulse.source_change_callback = () =>
		{
			if (config.show_notifications)
			{
				Notification notification = new Notification("Input source changed");
				notification.set_icon(new ThemedIcon(status_icon.icon_name));
				notification.set_body(pulse.current_source_description);

				app.send_notification("source-changed", notification);
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