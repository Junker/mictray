using PulseAudio;
using Gee;

public class Pulse : Object
{
	public string? current_source_name = null;
	public string? current_source_description = null;
	public int volume;
	public int old_volume;
	public bool muted;
	public bool old_muted;
	public bool first_change = true;

	public Callback change_callback;
	public Callback source_change_callback;

	private PulseAudio.Context context;
	private PulseAudio.Context.Flags cflags;
	private PulseAudio.GLibMainLoop loop;

	construct
	{
		this.loop = new PulseAudio.GLibMainLoop();

		this.context = new PulseAudio.Context(loop.get_api(), null);
		this.cflags = Context.Flags.NOFAIL;
		this.context.set_state_callback(this.cstate_cb);

		if (this.context.connect(null, this.cflags, null) < 0)
		{
			print("pa_context_connect() failed: %s\n", PulseAudio.strerror(context.errno()));
			Process.exit(Posix.EXIT_FAILURE);
		}
	}

	public void cstate_cb(Context context)
	{
		Context.State state = context.get_state();

		if (state == Context.State.UNCONNECTED) { GLib.info("state UNCONNECTED\n"); }
		if (state == Context.State.CONNECTING) { GLib.info("state CONNECTING\n"); }
		if (state == Context.State.AUTHORIZING) { GLib.info("state AUTHORIZING,\n"); }
		if (state == Context.State.SETTING_NAME) { GLib.info("state SETTING_NAME\n"); }
		if (state == Context.State.READY) { GLib.info("state READY\n"); }
		if (state == Context.State.FAILED) { GLib.info("state FAILED,\n"); }
		if (state == Context.State.TERMINATED) { GLib.info("state TERMINATED\n"); }

		if (state == Context.State.READY)
		{
			GLib.info("state READY\n");

			context.set_subscribe_callback(this.subscribe_cb);

			context.subscribe(Context.SubscriptionMask.SOURCE | Context.SubscriptionMask.SERVER);

			this.refresh_server_info();
			this.refresh_source_info();
		}
	 }

	public HashMap<string,string> get_input_list()
	{
		PulseAudio.Operation op = null;

		var list = new HashMap<string, string>();

		op = context.get_source_info_list((ctx, info, eol) =>
		{
			if (eol > 0) return;

			GLib.info(info.name+"\n");

			list.set(info.name, info.description);
		});

		for (;;)
		{
			if (op.get_state() == PulseAudio.Operation.State.DONE)
			{
				return list;
			}

			Gtk.main_iteration();
		}
	}

	public void mute()
	{
		context.set_source_mute_by_name(this.current_source_name, true);
	}

	public void unmute()
	{
		context.set_source_mute_by_name(this.current_source_name, false);
	}

	public void toggle_mute()
	{
			if (this.muted)
				this.unmute();
			else
				this.mute();
	}

	public void increase_volume()
	{
		context.get_source_info_by_name(this.current_source_name, (ctx, info, eol) =>
		{
			if (eol > 0) return;

			CVolume cvolume = info.volume;

			if (cvolume.avg() + get_prepared_volume_increment() > PulseAudio.Volume.NORM)
			{
				cvolume.inc(PulseAudio.Volume.NORM - cvolume.avg());
			}
			else
				cvolume = cvolume.inc(get_prepared_volume_increment());

			context.set_source_volume_by_name(this.current_source_name, cvolume);
		});
	}

	public void decrease_volume()
	{
		context.get_source_info_by_name(this.current_source_name, (ctx, info, eol) =>
		{
			if (eol > 0) return;

			CVolume cvolume = info.volume;

			cvolume = cvolume.dec(get_prepared_volume_increment());

			context.set_source_volume_by_name(this.current_source_name, cvolume);
		});
	}

	private void subscribe_cb(Context ctx, Context.SubscriptionEventType eventType, uint32 idx)
	{
		switch (eventType & Context.SubscriptionEventType.FACILITY_MASK)
		{
			case Context.SubscriptionEventType.SERVER:
			{
				this.refresh_server_info();
				break;
			}
			case Context.SubscriptionEventType.SOURCE:
			{
				context.get_source_info_by_index(idx, (ctx, info, eol) =>
				{
					if (eol > 0) return;

					if (info == null) return;

					if (info.name == this.current_source_name)
						this.refresh_source_info();
				});

				break;
			}
		}
	}

	private uint32 get_prepared_volume_increment()
	{
		return (uint32)((config.volume_increment * PulseAudio.Volume.NORM) / 100);
	}

	public void refresh_server_info()
	{
		this.context.get_server_info((ctx, server_info) =>
		{
			if (this.current_source_name == null)
			{
				this.current_source_name = server_info.default_source_name;
				this.refresh_source_info();
			}

			if (config.use_default_source && this.current_source_name != server_info.default_source_name)
			{
				this.current_source_name = server_info.default_source_name;
				config.source_name = this.current_source_name;
				this.refresh_source_info();
			}
		});
	}

	public void refresh_source_info()
	{
		context.get_source_info_by_name(this.current_source_name, (ctx, info, eol) =>
		{
			if (eol > 0) return;

			if (eol < 0 || info == null)
			{
				this.current_source_name = null;
				this.refresh_server_info();

				return;
			}

			this.old_volume = this.volume;
			this.volume = (int)((info.volume.avg() / (float)PulseAudio.Volume.NORM) * 100);
			this.old_muted = this.muted;
			this.muted = (bool)info.mute;

			this.change_callback();

			string? old_source_description = this.current_source_description;
			this.current_source_description = info.description;

			if (old_source_description != null && old_source_description != this.current_source_description)
			{
				this.source_change_callback();
			}

			this.first_change = false;
		});

	}
}