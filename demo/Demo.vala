using Gtk;
using Liberate;
using WebKit;

public class Demo : Gtk.Application {

	protected Stack stack;
	protected WebView view;
	protected Liberate.Reader reader;
	protected Entry entry;

	protected Box read_box;
	protected Button read_button;
	protected MenuButton read_menu_button;
	protected Button back_button;
	protected Popover popover;
	protected Grid popover_grid;

	protected string theme = "light";

	construct {
		application_id = "com.github.bleakgrey.liberate.demo";
		flags = ApplicationFlags.FLAGS_NONE;
	}

	public static int main (string[] args) {
		var application = new Demo ();
		return application.run (args);
	}

	public override void activate () {
		var window = new Gtk.Window ();

		entry = new Entry ();
		entry.text = "https://medium.com/elementaryos/juno-updates-for-april-2019-73cd51764207";
		entry.placeholder_text = "Enter URL you want to read...";
		entry.hexpand = true;
		entry.activate.connect (() => go ());

		read_button = new Button.with_label ("Read");
		read_button.clicked.connect (() => {
			Liberate.read (view, theme);
			read_button.sensitive = false;
			read_menu_button.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
		});

		var open_reader_button = new ModelButton ();
		open_reader_button.label = "Open in Reader widget";
		open_reader_button.clicked.connect (open_reader);

		popover_grid = new Grid ();
		popover_grid.orientation = Orientation.VERTICAL;
		popover_grid.add (open_reader_button);

		popover_grid.add (new Separator (Orientation.HORIZONTAL));
		build_themes ();
		popover_grid.show_all ();

		popover = new Popover (read_menu_button);
		popover.add (popover_grid);

		read_menu_button = new MenuButton ();
		read_menu_button.popover = popover;

		read_box = new Box (Orientation.HORIZONTAL, 0);
		read_box.get_style_context ().add_class ("linked");
		read_box.pack_start (read_button, true, true);
		read_box.pack_end (read_menu_button, true, true);

		back_button = new Button.with_label ("Back");
		back_button.clicked.connect (() => {
			stack.visible_child_name = "browser";
			reader.destroy ();
			update_header ();
		});

		var header = new HeaderBar ();
		header.show_close_button = true;
		header.custom_title = entry;
		header.pack_start (back_button);
		header.pack_end (read_box);

		view = new WebView ();
		var settings = new WebKit.Settings ();
		settings.set_enable_developer_extras (true);
		view.settings = settings;
		view.bind_property ("estimated-load-progress", entry, "progress-fraction", BindingFlags.SYNC_CREATE);
		view.load_changed.connect (ev => {
			if (ev != LoadEvent.STARTED)
				return;
			
			read_button.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
			read_menu_button.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
			read_button.sensitive = true;
			Liberate.on_readable (view, () => {
				read_button.get_style_context ().add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
				read_menu_button.get_style_context ().add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
			});
		});

		stack = new Stack ();
		stack.hexpand = true;
		stack.vexpand = true;
		stack.transition_type = StackTransitionType.SLIDE_LEFT_RIGHT;
		stack.add_named (view, "browser");

		window.add (stack);
		window.set_titlebar (header);
		window.set_size_request (750, 500);
		window.show_all ();
		update_header ();
		add_window (window);

		go ();
	}

	protected void build_themes () {
		RadioButton? group_owner = null;
		foreach (string item in Liberate.get_themes ()) {
			var radio = new RadioButton.with_label_from_widget (group_owner, item);
			radio.margin = 8;
			if (group_owner == null)
				group_owner = radio;

			radio.toggled.connect (() => {
				theme = item;
				Liberate.apply_theme (view, item);
				popover.popdown ();
			});

			popover_grid.add (radio);
		}
	}

	protected void go () {
		view.load_uri (entry.text);
	}

	protected void update_header () {
		var browsing = stack.visible_child_name == "browser";
		back_button.visible = !browsing;
		read_box.visible = browsing;
	}

	protected void open_reader () {
		reader = new Liberate.Reader.with_url (entry.text, theme);
		reader.show ();
		stack.add_named (reader, "reader");
		stack.visible_child = reader;
		update_header ();
	}

}
