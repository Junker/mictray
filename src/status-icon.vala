using Gtk;

public class MicStatusIcon : StatusIcon 
{
	public Gtk.Menu context_menu;

	construct 
	{
		this.set_from_icon_name("microphone-sensitivity-muted");

		this.popup_menu.connect(() => 
		{
			this.context_menu.popup_at_pointer();
		});

		this.scroll_event.connect((event) => 
		{
			if (event.direction == Gdk.ScrollDirection.UP)
			{
				pulse.increase_volume();
			}
			if (event.direction == Gdk.ScrollDirection.DOWN)
			{
				pulse.decrease_volume();
			}
		});

		this.button_release_event.connect((event) =>
		{
			if (event.button == 1)
			{
				if (pulse.muted)
					pulse.unmute();
				else
					pulse.mute();
			}
		});

		this.buildContextMenu();
	}

	public void buildContextMenu()
	{
		context_menu = new Gtk.Menu();

		var menu_mixer = new Gtk.MenuItem.with_mnemonic("_Mixer");
		menu_mixer.activate.connect(menu_mixer_clicked);
		context_menu.append(menu_mixer);

	    var menu_settings = new Gtk.MenuItem.with_mnemonic("_Settings");
	    menu_settings.activate.connect(menu_settings_clicked);
	    context_menu.append(menu_settings);

		var menu_about = new Gtk.MenuItem.with_mnemonic(_("_About"));
		menu_about.activate.connect(menu_about_clicked);
		context_menu.append(menu_about);

		context_menu.append(new SeparatorMenuItem());

		var menu_quit = new Gtk.MenuItem.with_mnemonic(_("_Quit"));
		menu_quit.activate.connect(() => {Gtk.main_quit();});
		context_menu.append(menu_quit);

		context_menu.show_all();
	}

	public void menu_about_clicked()
	{
		var about = new Gtk.AboutDialog();
		about.set_version("0.1.0");
		about.set_program_name("MicTray");
		about.set_comments("Microphone control application");
		about.set_copyright("Dmitry Kosenkov");
		about.run();
		about.hide();
	}

	public void menu_mixer_clicked()
	{
		Posix.system(config.mixer + " &");
	}

	public void menu_settings_clicked()
	{
		var window = new SettingsWindow();
		window.show_all();
	}

	public void update()
	{
		this.set_tooltip_text(pulse.muted ? "muted" : (pulse.volume.to_string()+"%"));

		if (pulse.muted)
		{
			this.set_from_icon_name("microphone-sensitivity-muted");
		}
		else if(pulse.volume>=0 && pulse.volume <= 33)
		{
			this.set_from_icon_name("microphone-sensitivity-low");
		}
		else if(pulse.volume>33 && pulse.volume <= 66)
		{
			this.set_from_icon_name("microphone-sensitivity-medium");
		}
		else if(pulse.volume>66)
		{
			this.set_from_icon_name("microphone-sensitivity-high");
		}
	}
}