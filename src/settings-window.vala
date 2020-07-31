using Gtk;
using Gee;

public class SettingsWindow : Window
{
	private ComboBoxText input_combo;
	private CheckButton input_checkbox;
	private CheckButton notify_checkbox;
	private SpinButton spin_button;

	construct
	{
		this.title = _("Settings");
		this.window_position = WindowPosition.CENTER;

		this.set_border_width(10);

		var vbox = new Box(Gtk.Orientation.VERTICAL, 5);

		input_checkbox = new CheckButton.with_label("Use default PulseAudio input");
		input_checkbox.toggled.connect(() => {
			input_combo.set_state_flags(input_checkbox.get_active() ? StateFlags.INSENSITIVE : StateFlags.NORMAL, true);
		});

		input_checkbox.set_active(config.use_default_source);
		vbox.pack_start(input_checkbox, false, false, 5);

		var hbox1 = new Box(Gtk.Orientation.HORIZONTAL, 2);
		input_combo = new ComboBoxText();
		input_combo.set_state_flags(input_checkbox.get_active() ? StateFlags.INSENSITIVE : StateFlags.NORMAL, true);

		hbox1.pack_start(new Label("Input:"), false, false, 5);
		hbox1.pack_end(input_combo, false, false, 5);
		vbox.pack_start(hbox1, false, false, 5);

		var hbox3 = new Box(Gtk.Orientation.HORIZONTAL, 2);
		spin_button = new SpinButton.with_range(1, 99, 1);
		spin_button.set_value(config.volume_increment);

		hbox3.pack_start(new Label("Volume increment"), false, false, 5);
		hbox3.pack_end(spin_button, false, false, 5);
		vbox.pack_start(hbox3, false, false, 5);

		notify_checkbox = new CheckButton.with_label("Show notifications");
		notify_checkbox.set_active(config.show_notifications);
		vbox.pack_start(notify_checkbox, false, false, 5);

		var hbox6 = new Box(Gtk.Orientation.HORIZONTAL, 2);
		var btn_cancel = new Button.with_label("Cancel");

		btn_cancel.clicked.connect(() => {this.destroy();});;

		var btn_ok = new Button.with_label("Save");
		btn_ok.clicked.connect(() => {this.save_settings();});

		hbox6.pack_start(btn_cancel, false, false, 5);
		hbox6.pack_end(btn_ok, false, false, 5);
		vbox.pack_start(hbox6,false, false, 10);


		this.add(vbox);

		load_sources();
	}

	public void save_settings()
	{
		pulse.current_source_name = this.input_combo.get_active_id();

		config.source_name = pulse.current_source_name;
		config.use_default_source = this.input_checkbox.get_active();

		pulse.refresh_server_info();
		pulse.refresh_source_info();

		config.volume_increment = this.spin_button.get_value_as_int();

		config.show_notifications = this.notify_checkbox.get_active();


		config.save();

		this.destroy();
	}

	private void load_sources()
	{

		HashMap<string, string> list = pulse.get_input_list();

		var i = 0;

		foreach (var entry in list.entries)
		{
			input_combo.append(entry.key, entry.value);

			if (entry.key == pulse.current_source_name)
			{
				input_combo.set_active(i);
			}

			i++;
		}
	}

}