namespace Bakamon {
    public class GoScoreBoard : Gtk.Box {
        public int black_score {
            get {
                return black_score_value;
            }
            set {
                black_score_value = value;
                black_score_label.label = @"黒：<span color=\"red\">$(black_score_value)</span>点";
            }
        }
        public int white_score {
            get {
                return white_score_value;
            }
            set {
                white_score_value = value;
                white_score_label.label = @"白：<span color=\"blue\">$(white_score_value)</span>点";
            }
        }
        public int black_pows {
            get {
                return black_pows_value;
            }
            set {
                black_pows_value = value;
                black_pows_widget.pows_count = black_pows_value;
            }
        }
        public int white_pows {
            get {
                return white_pows_value;
            }
            set {
                white_pows_value = value;
                white_pows_widget.pows_count = white_pows_value;
            }
        }
        private int black_score_value;
        private int white_score_value;
        private int black_pows_value;
        private int white_pows_value;
        private Gtk.Label black_score_label;
        private Gtk.Label white_score_label;
        private GoPowsWidget black_pows_widget;
        private GoPowsWidget white_pows_widget;

        public GoScoreBoard() {
            Object(
                orientation: Gtk.Orientation.VERTICAL,
                spacing: 4
            );
        }
        
        construct {
            var attrlist_big = LabelBuilder.create().weight(BOLD).family("Serif").size(16).attrlist();
            var attrlist_small = LabelBuilder.create().weight(BOLD).family("Serif").size(12).attrlist();
            black_score_label = new Gtk.Label("黒：<span color=\"red\">0</span>点") {
                    attributes = attrlist_big, halign = START, use_markup = true };
            var black_pows_frame = new Gtk.Frame(null);
            {
                var black_pows_label = new Gtk.Label("黒の捕虜") { attributes = attrlist_small };
                black_pows_widget = new GoPowsWidget(WHITE);
                black_pows_frame.add(black_pows_widget);
                black_pows_frame.label_widget = black_pows_label;
            }
            white_score_label = new Gtk.Label("白：<span color=\"blue\">0</span>点") {
                    attributes = attrlist_big, halign = START, use_markup = true };
            var white_pows_frame = new Gtk.Frame(null);
            {
                var white_pows_label = new Gtk.Label("白の捕虜") { attributes = attrlist_small };
                white_pows_widget = new GoPowsWidget(BLACK);
                white_pows_frame.add(white_pows_widget);
                white_pows_frame.label_widget = white_pows_label;
            }
            pack_start(black_score_label, false, false);
            pack_start(black_pows_frame, false, false);
            pack_start(white_score_label, false, false);
            pack_start(white_pows_frame, false, false);
        }
        
        public void reset() {
            black_score = 0;
            black_pows = 0;
            white_score = 0;
            white_pows = 0;
        }
    }
}
