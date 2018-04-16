
using Gtk;

static MicStatusIcon status_icon;

static Pulse pulse;
static ConfigFile config;

extern const string GETTEXT_PACKAGE;

static int main (string[] args) 
{

	Intl.textdomain(GETTEXT_PACKAGE);

	Gtk.init(ref args);
	
	status_icon = new MicStatusIcon();

	config = new ConfigFile();

	pulse = new Pulse();
	pulse.change_callback = () => {status_icon.update();};
	pulse.start();
	
	if (config.load())
	{
		pulse.current_source_name = config.source_name;
	}


	Gtk.main();

	return 0;
}