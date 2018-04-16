using PulseAudio;
using Gee;


public class Pulse : Object 
{
	public string? current_source_name = null;
	public int volume;
	public bool muted;

	public Callback change_callback;

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

	public void start()
	{

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

		if (state == Context.State.READY) {
			GLib.info("state READY\n");

			context.set_subscribe_callback(this.subscribeCallback);

			context.subscribe(Context.SubscriptionMask.SOURCE | Context.SubscriptionMask.SERVER);

			this.refreshServerInfo();
		}
	 }

	public HashMap<string,string> getInputList()
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
			if (op.get_state() == PulseAudio.Operation.DONE)
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

	public void increaseVolume()
	{
		context.get_source_info_by_name(this.current_source_name, (ctx, info, eol) => 
		{
			if (eol > 0) return;

			CVolume cvolume = info.volume;

			if (cvolume.avg() + getPreparedVolumeIncrement() > PulseAudio.Volume.NORM)
			{
				cvolume.inc(PulseAudio.Volume.NORM - cvolume.avg());
			}
			else
				cvolume = cvolume.inc(getPreparedVolumeIncrement());

			context.set_source_volume_by_name(this.current_source_name, cvolume);
		});
	}

	public void decreaseVolume()
	{
		context.get_source_info_by_name(this.current_source_name, (ctx, info, eol) => 
		{
			if (eol > 0) return;

			CVolume cvolume = info.volume;

			cvolume = cvolume.dec(getPreparedVolumeIncrement());

			context.set_source_volume_by_name(this.current_source_name, cvolume);
		});		
	}

	private void subscribeCallback(Context ctx, Context.SubscriptionEventType eventType, uint32 idx)
	{
		switch (eventType & Context.SubscriptionEventType.FACILITY_MASK)
		{
			case Context.SubscriptionEventType.SERVER:
			{
				this.refreshServerInfo();
				break;
			}
			case Context.SubscriptionEventType.SOURCE:
			{
				context.get_source_info_by_index(idx, (ctx, info, eol) => 
				{
					if (eol > 0) return;

					if (info.name == this.current_source_name)
						this.refreshSourceInfo();
				});

				break;
			}
		}
	}

	private uint32 getPreparedVolumeIncrement()
	{
		return (uint32)((config.volume_increment * PulseAudio.Volume.NORM) / 100);
	}

	public void refreshServerInfo()
	{
		this.context.get_server_info((ctx, server_info) => 
		{
			bool changed = false;

			if (this.current_source_name == null)
			{
				this.current_source_name = server_info.default_source_name;
				changed = true;
			}

			if (config.use_default_source && this.current_source_name != server_info.default_source_name)
			{
				this.current_source_name = server_info.default_source_name;
				config.source_name = this.current_source_name;
				changed = true;
			}

			if (changed)
			{
				this.refreshSourceInfo();
			}
		});
	}

	public void refreshSourceInfo()
	{
		context.get_source_info_by_name(this.current_source_name, (ctx, info, eol) => 
		{
			if (eol > 0) return;

			this.volume = (int)((info.volume.avg() / (float)PulseAudio.Volume.NORM) * 100);
			this.muted = (bool)info.mute;

			this.change_callback();
		});
	}

}