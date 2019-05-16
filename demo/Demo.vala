using Gtk;
using Liberate;

public class Demo : Gtk.Application {

	protected Liberate.Reader reader;
	protected Entry entry;

	construct {
		application_id = "com.github.bleakgrey.liberate.demo";
		flags = ApplicationFlags.FLAGS_NONE;
	}
	
	public override void activate () {
		var window = new Gtk.Window ();
		
		entry = new Entry ();
		entry.text = "https://medium.com/elementaryos/juno-updates-for-april-2019-73cd51764207";
		entry.hexpand = true;
		entry.secondary_icon_name = "system-search-symbolic";
		entry.icon_press.connect (() => go ());
		
		var theme_button = new Button.with_label ("Toggle theme");
		
		var header = new HeaderBar ();
		header.show_close_button = true;
		header.custom_title = entry;
		header.pack_end (theme_button);
		
		reader = new Liberate.Reader ();
		reader.is_debug = true;
		reader.progress.connect ((fraction, is_loading) => {
			if (is_loading)
				entry.set_progress_fraction (fraction);
			else
				entry.set_progress_fraction (0);
		});
		
		theme_button.clicked.connect (() => {
			switch (reader.theme) {
				case "light":
					reader.theme = "solarized";
					break;
				case "solarized":
					reader.theme = "moonlight";
					break;
				case "moonlight":
					reader.theme = "light";
					break;
			}
		});
		
		window.add (reader);
		window.set_titlebar (header);
		window.set_size_request (800, 550);
		window.show_all ();
		add_window (window);
		
		go ();
	}

	protected void go () {
		reader.url = entry.text;
	}

	public static int main (string[] args) {
		var application = new Demo ();
		return application.run (args);
	}

}
