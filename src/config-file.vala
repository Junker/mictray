public class ConfigFile
{
	public KeyFile file;
	public string filename;

	public bool use_default_source = true;
	public string source_name;
	public int volume_increment = 3;
	public string mixer ="pavucontrol";
	public bool show_notifications = true;

	public ConfigFile()
	{
		this.file = new KeyFile();

		this.filename = GLib.Path.build_filename(GLib.Environment.get_home_dir(), ".config", GETTEXT_PACKAGE, "mictray.conf");
	}

	public bool load()
	{
		try
		{
			this.file.load_from_file(this.filename, KeyFileFlags.NONE);

			this.use_default_source = this.file.get_boolean("Options", "use_default_source");
			this.source_name = this.file.get_string("Options", "source_name");
			this.mixer = this.file.get_string("Options", "mixer");
			this.volume_increment = this.file.get_integer("Options", "volume_increment");
			this.show_notifications = this.file.get_boolean("Options", "show_notifications");
		}
		catch(KeyFileError err)
		{
			return false;
		}
		catch(FileError err)
		{
			return false;
		}

		return true;
	}

	public bool save()
	{
		try
		{
			var config_dir = GLib.Path.get_dirname(this.filename);
			Posix.mkdir(config_dir, 0755);

			this.file.set_boolean("Options", "use_default_source", this.use_default_source);
			this.file.set_string("Options", "source_name", this.source_name);
			this.file.set_string("Options", "mixer", this.mixer);
			this.file.set_integer("Options", "volume_increment", this.volume_increment);
			this.file.set_boolean("Options", "show_notifications", this.show_notifications);

			return this.file.save_to_file(this.filename);
		}
		catch(KeyFileError err)
		{
			return false;
		}
		catch(FileError err)
		{
			return false;
		}
	}
}