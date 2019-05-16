using Gtk;
using GLib;
using WebKit;

public class Liberate.Reader: Grid {

	protected WebKit.WebView view;
	protected WebKit.Settings settings;
	protected WebKit.UserContentManager content;
	
	public signal void progress (double fraction, bool ready);
	public string theme {get; set; default = "light";}
	public string url {get; set;}
	public bool is_debug {get; set; default = false;}

 	protected const string[] reader_deps = {
 		"theme-light.css",
 		"theme-solarized.css",
 		"theme-moonlight.css",
 		"Readability-readerable.js",
 		"Readability.js",
 		"patcher.js"
 	};

	construct {
		halign = Align.FILL;
		valign = Align.FILL;
		
		notify["url"].connect (() => {
			create_view ();
			debug ("Navigating to %s", url);
			view.load_uri (url);
		});
	}

	public Reader () {}
	
	public Reader.with_url (string url) {
		this.url = url;
	}

	protected void create_view () {
		if (view != null) {
			debug ("Destroying old view");
			view.destroy ();
			settings = null;
			content = null;
		}
		
		settings = new WebKit.Settings ();
		settings.enable_smooth_scrolling = true;
		settings.enable_javascript = false;
		settings.enable_developer_extras = is_debug;

		settings.javascript_can_access_clipboard = false;
		settings.javascript_can_open_windows_automatically = false;
		settings.enable_java = false;
		settings.enable_media_stream = false;
		settings.enable_mediasource = false;
		settings.enable_plugins = false;
		settings.enable_html5_database = false;
		settings.enable_html5_local_storage = false;
		settings.enable_webaudio = false;
		settings.enable_webgl = false;

		content = new UserContentManager ();
		content.register_script_message_handler ("bridge");

		view = new WebView.with_user_content_manager (content);
		view.expand = true;
		view.settings = settings;
		attach (view, 0, 0);
		view.visible = false;

		view.notify["estimated-load-progress"].connect (on_progress);
		notify["theme"].connect (() => {
			apply_theme (theme);
		});
		
		content.script_message_received.connect (result => {
			unowned JS.GlobalContext ctx = result.get_global_context ();
			unowned JS.Value js_str_value = result.get_value ();
			JS.Value? err = null;
			JS.String js_str = js_str_value.to_string_copy (ctx, out err);
			
			if (err == null)
				on_message (to_vala_string (js_str));
			else
				warning ("Caught JS error on receiving bridge message");
		});
		view.load_changed.connect (on_patch_request);
	}

	protected void inject (string[] resources) {
		foreach (string name in resources) {
			var res = GLib.resources_lookup_data (RESOURCES_PATH + name, ResourceLookupFlags.NONE);
			var source = (string)res.get_data ();
			if (".css" in name) {
				var stylesheet = new UserStyleSheet (source,
					UserContentInjectedFrames.TOP_FRAME,
					UserStyleLevel.USER, null, null);

				content.add_style_sheet (stylesheet);
			}
			else
			{
				// var script = new UserScript (source,
				// 	UserContentInjectedFrames.TOP_FRAME,
				// 	UserScriptInjectionTime.START, null, null);
				view.run_javascript (source, null);
			}
		}
	}

	protected inline string to_vala_string (global::JS.String js) {
		size_t len = js.get_maximum_utf8_cstring_size ();
		uint8[] str = new uint8[len];
		js.get_utf8_cstring (str);
		return (string) str;
	}

	protected bool on_message (string text) {
		debug ("Bridge message: %s", text);
		
		if (text == "done") {
			progress (1, false);
			view.load_changed.disconnect (on_patch_request);
		}
		return true;
	}

	protected void on_progress () {
		progress (view.estimated_load_progress, view.is_loading);
	}

	protected void apply_theme (string name) {
		//var js = settings.get_enable_javascript ();
		//settings.set_enable_javascript (true);
		view.run_javascript ("var reader_theme=\""+name+"\"; theme(\""+name+"\");", null);
		//settings.set_enable_javascript (js);
	}

	protected void on_patch_request (LoadEvent ev) {
		if (ev != LoadEvent.FINISHED)
			return;

		debug ("Page load complete");
		settings.set_enable_javascript (true);
		inject (reader_deps);
		apply_theme (theme);
		view.visible = true;
	}

}
