using Gtk;
using Liberate;
using WebKit;

public class Demo : Gtk.Application {

	protected Stack stack;
	protected WebView view;
	protected Liberate.Reader reader;
	protected Entry entry;
	
	protected Button read_button;
	protected Button theme_button;
	protected Button back_button;

	construct {
		application_id = "com.github.bleakgrey.liberate.demo";
		flags = ApplicationFlags.FLAGS_NONE;
	}
	
	public override void activate () {
		var window = new Gtk.Window ();
		
		entry = new Entry ();
		entry.text = "https://medium.com/elementaryos/juno-updates-for-april-2019-73cd51764207";
		entry.placeholder_text = "Enter URL you want to read...";
		entry.hexpand = true;
		entry.secondary_icon_name = "go-next-symbolic";
		entry.icon_press.connect (() => go ());
		
		read_button = new Button.with_label ("Read");
		read_button.clicked.connect (() => {
			Liberate.read (view);
			read_button.sensitive = false;
		});
		
		theme_button = new Button.with_label ("Toggle theme");
		back_button = new Button.with_label ("Back");
		
		var header = new HeaderBar ();
		header.show_close_button = true;
		header.custom_title = entry;
		header.pack_start (back_button);
		header.pack_end (theme_button);
		header.pack_end (read_button);
		
		view = new WebView ();
		view.bind_property ("estimated-load-progress", entry, "progress-fraction", BindingFlags.SYNC_CREATE);
		Liberate.on_readable.begin (view, () => {
			read_button.get_style_context ().add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
		});
		
		stack = new Stack ();
		stack.hexpand = true;
		stack.vexpand = true;
		stack.add_named (view, "browser");
		
		// reader = new Liberate.Reader ();
		// reader.is_debug = true;
		// reader.progress.connect ((fraction, is_loading) => {
		// 	if (is_loading)
		// 		entry.set_progress_fraction (fraction);
		// 	else
		// 		entry.set_progress_fraction (0);
		// });
		
		// theme_button.clicked.connect (() => {
		// 	switch (reader.theme) {
		// 		case "light":
		// 			reader.theme = "solarized";
		// 			break;
		// 		case "solarized":
		// 			reader.theme = "moonlight";
		// 			break;
		// 		case "moonlight":
		// 			reader.theme = "light";
		// 			break;
		// 	}
		// });
		
		window.add (stack);
		window.set_titlebar (header);
		window.set_size_request (750, 500);
		window.show_all ();
		update_header ();
		add_window (window);
		
		go ();
	}

	protected void go () {
		view.load_uri (entry.text);
		read_button.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
		read_button.sensitive = true;
	}
	
	protected void update_header () {
		var browsing = stack.visible_child_name == "browser";
		back_button.visible = !browsing;
		theme_button.visible = !browsing;
		read_button.visible = browsing;
	}

	public static int main (string[] args) {
		var application = new Demo ();
		return application.run (args);
	}

}
