namespace Bakamon {
    public enum ModelSize {
        MODEL_9,
        MODEL_13,
        MODEL_15,
        MODEL_19;
        
        public int x_length() {
            switch (this) {
              case MODEL_9: return 9;
              default: case MODEL_13: return 13;
              case MODEL_15: return 15;
              case MODEL_19: return 19;
            }
        }
         
        public int y_length() {
            switch (this) {
              case MODEL_9: return 9;
              default: case MODEL_13: return 13;
              case MODEL_15: return 15;
              case MODEL_19: return 19;
            }
        }
        
        public int dot_start_from() {
            switch (this) {
              case MODEL_9: return 4;
              default: case MODEL_13: return 3;
              case MODEL_15: return 3;
              case MODEL_19: return 3;
            }
        }

        public int dot_interval() {
            switch (this) {
              case MODEL_9: return 5;
              default: case MODEL_13: return 3;
              case MODEL_15: return 4;
              case MODEL_19: return 6;
            }
        }
        
        public string to_string() {
            switch (this) {
              case MODEL_9: return "9路盤";
              default: case MODEL_13: return "13路盤";
              case MODEL_15: return "15路盤";
              case MODEL_19: return "19路盤";
            }
        }
    }

    [Flags]
    public enum GoStatus {
        EMPTY,
        BLACK,
        WHITE,
        BLACK_TERRITORY,
        WHITE_TERRITORY,
        EDGE;
        
        public string to_string() {
            switch (this) {
              default: case EMPTY: return "empty";
              case BLACK: return "black";
              case WHITE: return "white";
              case WHITE_TERRITORY: return "white-territory";
              case BLACK_TERRITORY: return "black-territory";
              case EDGE: return "edge";
            }
        }
    }

    public class LabelBuilder : Object {
        private Pango.FontDescription fd;
        private string label_value;
        private string? color_name = null;
        
        private LabelBuilder() {
            fd = new Pango.FontDescription();
        }

        public static LabelBuilder create() {
            return new LabelBuilder();
        }
        
        public LabelBuilder family(string font_family_name) {
            fd.set_family(font_family_name);
            return this;
        }
        
        public LabelBuilder size(int size_value) {
            fd.set_size(size_value * Pango.SCALE);
            return this;
        }
        
        public LabelBuilder weight(Pango.Weight weight_value) {
            fd.set_weight(weight_value);
            return this;
        }
        
        public LabelBuilder style(Pango.Style style_value) {
            fd.set_style(style_value);
            return this;
        }
        
        public LabelBuilder gravity(Pango.Gravity gravity_value) {
            fd.set_gravity(gravity_value);
            return this;
        }
        
        public LabelBuilder label(string label_value) {
            this.label_value = label_value;
            return this;
        }

        public LabelBuilder color(string color_name) {
            this.color_name = color_name;
            return this;
        }
                
        public Gtk.Label build() {
            var attr = new Pango.AttrFontDesc(fd);
            var attr_list = new Pango.AttrList();
            attr_list.insert((owned) attr);
            var label_widget = new Gtk.Label(
                    color_name != null ? @"<span color=\"$(color_name)\">$(label_value)</span>" : label_value) {
                attributes = attr_list,
                use_markup = true
            };
            return label_widget;
        }
        
        public Pango.AttrList attrlist() {
            var attr = new Pango.AttrFontDesc(fd);
            var attr_list = new Pango.AttrList();
            attr_list.insert((owned) attr);
            return attr_list;
        }
    }
    
    public class TitleLogo : Gtk.DrawingArea {
        private const uint8[,] DOTS = {
            { 1, 1, 1, 0, 0, 0, 1, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 1, 0, 0, 1, 0, 0, 0, 1, 0, 0, 1, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 1, 0, 0, 0, 1, 1, 0, 0, 1, 1 },
            { 1, 0, 0, 1, 0, 1, 0, 0, 1, 0, 1, 0, 0, 1, 0, 1, 0, 0, 1, 0, 1, 1, 0, 1, 1, 0, 1, 0, 0, 1, 0, 1, 0, 0, 1, 0, 1, 0, 0, 1, 0, 1, 0, 0, 1, 0, 1, 1 },
            { 1, 0, 0, 1, 0, 1, 0, 0, 1, 0, 1, 0, 1, 0, 0, 1, 0, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 0, 1, 0, 1, 1, 0, 1, 0, 1, 0, 0, 0, 0, 1, 0, 0, 1, 0, 1, 1 },
            { 1, 1, 1, 0, 0, 1, 1, 1, 1, 0, 1, 1, 0, 0, 0, 1, 1, 1, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 0, 1, 0, 1, 1, 1, 1, 0, 1, 0, 1, 1, 0, 1, 0, 0, 1, 0, 1, 0 },
            { 1, 0, 0, 1, 0, 1, 0, 0, 1, 0, 1, 0, 1, 0, 0, 1, 0, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 0, 1, 0, 1, 0, 1, 1, 0, 1, 0, 0, 1, 0, 1, 0, 0, 1, 0, 1, 0 },
            { 1, 0, 0, 1, 0, 1, 0, 0, 1, 0, 1, 0, 0, 1, 0, 1, 0, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 0, 1, 0, 1, 0, 0, 1, 0, 1, 0, 0, 1, 0, 1, 0, 0, 1, 0, 0, 0 },
            { 1, 1, 1, 0, 0, 1, 0, 0, 1, 0, 1, 0, 0, 1, 0, 1, 0, 0, 1, 0, 1, 0, 1, 0, 1, 0, 0, 1, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 1, 0, 0, 0, 1, 1, 0, 0, 1, 1 }
        };
        public int block_width = 8;
        public int block_height = 8;
        public int line_width = 2;
        
        public TitleLogo() {
            width_request = block_width * 48;
            height_request = block_height * 7;
        }
        
        public override bool draw(Cairo.Context cairo) {
            for (int j = 0; j < 7; j++) {
                for (int i = 0; i < 48; i++) {
                    if (DOTS[j, i] == 1) {
                        if (j % 2 == 0 && i % 2 == 0 || j % 2 == 1 && i % 2 == 1) {
                            cairo.set_source_rgb(0.1, 0.1, 0.1);
                        } else {
                            cairo.set_source_rgb(0.8, 0.8, 0.8);
                        }
                        cairo.rectangle(
                            (double) (i * block_width),
                            (double) (j * block_height),
                            (double) block_width,
                            (double) block_height
                        );
                        cairo.fill();
                        cairo.set_source_rgb(0.1, 0.1, 0.1);
                        cairo.set_line_width(line_width);
                        cairo.rectangle(
                            (double) (i * block_width),
                            (double) (j * block_height),
                            (double) block_width,
                            (double) block_height
                        );
                        cairo.stroke();
                    }
                }
            }
            return true;
        }
    }

    public struct HistoryItem {
        public bool is_black;
        public int x;
        public int y;
    }
    
    public class GoModel : Object {
        public bool is_debug_enabled { get; set; default = false; }
        public signal int debug_is_surrounded_by(int y, int x);
        public signal int ball_dropped(int y, int x);
        public signal void game_over(GoStatus winner);
        public signal void end_with_a_draw();
        public ModelSize size { get; set; }
        public int black_score {
            get {
                int black_score_value = 0;
                for (int j = 0; j < size.y_length(); j++) {
                    for (int i = 0; i < size.x_length(); i++) {
                        if (territory_status[j, i] == BLACK_TERRITORY) {
                            black_score_value++;
                        }
                    }
                }
                return black_score_value;
            }
        }
        public int white_score {
            get {
                int white_score_value = 0;
                for (int j = 0; j < size.y_length(); j++) {
                    for (int i = 0; i < size.x_length(); i++) {
                        if (territory_status[j, i] == WHITE_TERRITORY) {
                            white_score_value++;
                        }
                    }
                }
                return white_score_value;
            }
        }
        public int black_pows { get; private set; default = 0; }
        public int white_pows { get; private set; default = 0; }
        private GoStatus[,] status;
        private GoStatus[,] territory_status;
        private int put_count = 0;
        private List<HistoryItem?>? history;
        private DateTime start_datetime;
        
        public GoModel(ModelSize size) {
            history = new List<HistoryItem?>();
            start_datetime = new DateTime.now_local();
            this.size = size;
            status = new GoStatus[size.y_length(), size.x_length()];
            territory_status = new GoStatus[size.y_length(), size.x_length()];
            for (int y = 0; y < size.y_length(); y++) {
                for (int x = 0; x < size.x_length(); x++) {
                    status[y, x] = EMPTY;
                    territory_status[y, x] = EMPTY;
                }
            }
        }

        public Json.Node get_history() {
            Json.Object json = new Json.Object();
            json.set_string_member("盤面", size.to_string());
            json.set_string_member("開始時刻", start_datetime.format_iso8601());
            json.set_string_member("終了時刻", new DateTime.now_local().format_iso8601());
            json.set_int_member("黒星", black_score - white_pows);
            json.set_int_member("白星", white_score - black_pows);
            if ((black_score - white_pows) > (white_score - black_pows)) {
                json.set_string_member("勝敗", "黒の勝ち");
            } else if ((black_score - white_pows) < (white_score - black_pows)) {
                json.set_string_member("勝敗", "白の勝ち");
            } else {
                json.set_string_member("勝敗", "引き分け");
            }
            Json.Array arr = new Json.Array();
            foreach (var item in history) {
                Json.Array item_array = new Json.Array();
                item_array.add_string_element(item.is_black ? "黒" : "白");
                item_array.add_int_element(item.x);
                item_array.add_int_element(item.y);
                arr.add_array_element(item_array);
            }
            json.set_array_member("棋譜", arr);
            Json.Node root_node = new Json.Node(OBJECT);
            root_node.init_object(json);
            return root_node;
        }
        
        public GoStatus get_status(int y, int x) {
            return status[y, x];
        }

        public GoStatus get_territory_status(int y, int x) {
            return territory_status[y, x];
        }
        
        public async bool put_black(int y, int x) {
            if (yield can_put_v2(BLACK, y, x)) {
                status[y, x] = BLACK;
                history.append({true, x, y});
                territory_status[y, x] = BLACK;
                put_count++;
                black_pows += yield drop_balls(y, x);
                if (put_count > 2) {
                    yield check_territory();
                }
                return true;
            } else {
                return false;
            }
        }

        public async bool put_white(int y, int x) {
            if (yield can_put_v2(WHITE, y, x)) {
                status[y, x] = WHITE;
                history.append({false, x, y});
                territory_status[y, x] = WHITE;
                put_count++;
                white_pows += yield drop_balls(y, x);
                if (put_count > 2) {
                    yield check_territory();
                }
                return true;
            } else {
                return false;
            }
        }

        private async bool can_put_v2(GoStatus go, int y, int x) {
            if (status[y, x] != EMPTY) {
                return false;
            } else {
                status[y, x] = go;
                GoStatus opposite = go == GoStatus.BLACK ? GoStatus.WHITE : GoStatus.BLACK;
                bool[,] checker = new bool[size.y_length(), size.x_length()];
                bool result_1 = false, result_2 = false, result_3 = false, result_4 = false, result_5 = false;
                result_1 = (yield is_surrounded_by(go, y, x, checker)) == GoStatus.EMPTY;
                if (y > 0) {
                    result_2 = (yield is_surrounded_by(opposite, y - 1, x, checker)) == go;
                }
                if (x > 0) {
                    result_3 = (yield is_surrounded_by(opposite, y, x - 1, checker)) == go;
                }
                if (y < size.y_length() - 1) {
                    result_4 = (yield is_surrounded_by(opposite, y + 1, x, checker)) == go;
                }
                if (x < size.x_length() - 1) {
                    result_5 = (yield is_surrounded_by(opposite, y, x + 1, checker)) == go;
                }
                bool can_get = result_2 || result_3 || result_4 || result_5;
                bool is_surrounded_by_empty = result_1;
                if (is_surrounded_by_empty || can_get) {
                    status[y, x] = EMPTY;
                    return true;
                } else {
                    status[y, x] = EMPTY;
                    return false;
                }
            }
        }

        private async int drop_balls(int y, int x) {
            GoStatus orig_status = status[y, x];
            GoStatus target_status = orig_status == BLACK ? GoStatus.WHITE : GoStatus.BLACK;
            GoStatus territory = orig_status == BLACK ? GoStatus.BLACK_TERRITORY : GoStatus.WHITE_TERRITORY;
            int drop_count = 0;
            
            if (y > 0 && status[y - 1, x] == target_status) {
                bool[,]? checker_top = new bool[size.y_length(), size.x_length()];
                if (orig_status == yield is_surrounded_by(target_status, y - 1, x, checker_top)) {
                    drop_count += yield drop_balls_sub(checker_top, territory);
                }
            }
            
            if (x > 0 && status[y, x - 1] == target_status) {
                bool[,]? checker_left = new bool[size.y_length(), size.x_length()];
                if (orig_status == yield is_surrounded_by(target_status, y, x - 1, checker_left)) {
                    drop_count += yield drop_balls_sub(checker_left, territory);
                }
            }
            
            if (y < size.y_length() - 1 && status[y + 1, x] == target_status) {
                bool[,]? checker_bottom = new bool[size.y_length(), size.x_length()];
                if (orig_status == yield is_surrounded_by(target_status, y + 1, x, checker_bottom)) {
                    drop_count += yield drop_balls_sub(checker_bottom, territory);
                }
            }
            
            if (x < size.x_length() + 1 && status[y, x + 1] == target_status) {
                bool[,]? checker_right = new bool[size.y_length(), size.x_length()];
                if (orig_status == yield is_surrounded_by(target_status, y, x + 1, checker_right)) {
                    drop_count += yield drop_balls_sub(checker_right, territory);
                }
            }
            return drop_count;
        }        

        private async int drop_balls_sub(bool[,] checker, GoStatus whos_territory) {
            int drop_count = 0;
            for (int j = 0; j < size.y_length(); j++) {
                for (int i = 0; i < size.x_length(); i++) {
                    if (checker[j, i]) {
                        status[j, i] = EMPTY;
                        drop_count++;
                        territory_status[j, i] = whos_territory;
                        int time_interval = ball_dropped(j, i);
                        Timeout.add(time_interval, drop_balls_sub.callback);
                        yield;
                    }
                }
            }
            return drop_count;
        }
        
        private async void check_territory() {
            for (int j = 0; j < size.y_length(); j++) {
                for (int i = 0; i < size.x_length(); i++) {
                    if (territory_status[j, i] == EMPTY) {
                        bool[,] checker = new bool[size.y_length(), size.x_length()];
                        var go = yield is_surrounded_by(EMPTY, j, i, checker);
                        if (go == BLACK || go == WHITE) {
                            var territory = go == GoStatus.BLACK ? GoStatus.BLACK_TERRITORY
                                    : (go == GoStatus.WHITE ? GoStatus.WHITE_TERRITORY
                                    : GoStatus.EMPTY);
                            for (int k = 0; k < size.y_length(); k++) {
                                for (int l = 0; l < size.x_length(); l++) {
                                    if (checker[k, l]) {
                                        territory_status[k, l] = territory;
                                    }
                                }
                            }
                        } else if (go == EMPTY) {
                            while (territory_status[j, i] == EMPTY) {
                                i++;
                            }
                        }
                    }
                }
            }
            for (int j = 0; j < size.y_length(); j++) {
                for (int i = 0; i < size.x_length(); i++) {
                    if (territory_status[j, i] == EMPTY) {
                        return;
                    }
                }
            }
            int black_score_value = black_score - white_pows;
            int white_score_value = white_score - black_pows;
            if (black_score_value > white_score_value) {
                game_over(BLACK);
            } else if (white_score_value > black_score_value) {
                game_over(WHITE);
            } else {
                end_with_a_draw();
            }
        }
        
        private async GoStatus is_surrounded_by(GoStatus go, int y, int x, bool[,] checker) {
            if (checker[y, x]) {
                return EDGE;
            }
            checker[y, x] = true;
            GoStatus top_status, left_status, bottom_status, right_status;
            if (is_debug_enabled) {
                int time_interval = debug_is_surrounded_by(y, x);
                Timeout.add(time_interval, is_surrounded_by.callback);
                yield;
            }
            
            if (y == 0) {
                top_status = EDGE;
            } else {
                top_status = status[y - 1, x];
                if (top_status == go) {
                    top_status = yield is_surrounded_by(go, y - 1, x, checker);
                }
            }
            
            if (x == 0) {
                left_status = EDGE;
            } else {
                left_status = status[y, x - 1];
                if (left_status == go) {
                    left_status = yield is_surrounded_by(go, y, x - 1, checker);
                }
            }
            
            if (y == size.y_length() - 1) {
                bottom_status = EDGE;
            } else {
                bottom_status = status[y + 1, x];
                if (bottom_status == go) {
                    bottom_status = yield is_surrounded_by(go, y + 1, x, checker);
                }
            }
            
            if (x == size.x_length() - 1) {
                right_status = EDGE;
            } else {
                right_status = status[y, x + 1];
                if (right_status == go) {
                    right_status = yield is_surrounded_by(go, y, x + 1, checker);
                }
            }
            
            GoStatus status = top_status | left_status | bottom_status | right_status;
            if (BLACK in status && WHITE in status) {
                status = EMPTY;
            } else if (EMPTY in status) {
                status = EMPTY;
            } else if (BLACK in status) {
                status = BLACK;
            } else if (WHITE in status) {
                status = WHITE;
            }

            return status;
        }
    }

    public struct DPoint {
        public double x;
        public double y;
    }

    public class BallDrawer : Object {
        private double radius;
        private DPoint center;
        private DPoint light_offset;
        private DPoint shadow_offset;
        private DPoint lighting_point;
        private GoStatus status;
        private Gdk.RGBA base_color;
        
        public void set_color(GoStatus status) {
            this.status = status;
            if (status == BLACK) {
                base_color = { 0.17, 0.17, 0.17, 1.0 };
            } else {
                base_color = { 0.7, 0.7, 0.7, 1.0 };;
            }
        }
              
        public void move_to(DPoint center) {
            this.center = center;
        }
        
        public void set_radius(double radius) {
            this.radius = radius;
        }
        
        public void light_from(DPoint p) {
            lighting_point = p;
        }
        
        public void draw(Cairo.Context cairo) {
            cairo.set_line_width(0.0);
            
            double a = lighting_point.x - center.x;
            double b = lighting_point.y - center.y;
            double c = Math.sqrt(a * a + b * b);
            double d = radius / c;

            shadow_offset.x = center.x - a * d * 0.3;
            shadow_offset.y = center.y - b * d * 0.3;

            var shadow_pattern = new Cairo.Pattern.radial(
                    shadow_offset.x, shadow_offset.y, 0, shadow_offset.x, shadow_offset.y, radius * 1.3);
            shadow_pattern.add_color_stop_rgba(radius * 1.0, 0.0, 0.0, 0.0, 0.0);
            shadow_pattern.add_color_stop_rgba(0, 0.0, 0.0, 0.0, 0.9);
            cairo.set_source(shadow_pattern);
            cairo.arc(shadow_offset.x + 5, shadow_offset.y + 5, radius * 2.0, 0.0, Math.PI * 2.0);
            cairo.fill();
            
            var pattern = new Cairo.Pattern.radial(center.x + 3, center.y - 3, 0, center.x + 3, center.y - 3, radius);
            pattern.add_color_stop_rgb(radius, base_color.red, base_color.green, base_color.blue);
            pattern.add_color_stop_rgb(0, base_color.red + 0.1, base_color.green + 0.1, base_color.blue + 0.1);
            cairo.set_source(pattern);
            cairo.arc(center.x, center.y, radius, 0.0, Math.PI * 2.0);
            cairo.fill();

            light_offset.x = center.x + a * d * 0.2;
            light_offset.y = center.y + b * d * 0.2;
            
            var light_pattern = new Cairo.Pattern.radial(
                    light_offset.x, light_offset.y, 0, light_offset.x, light_offset.y, radius * 0.95);
            light_pattern.add_color_stop_rgba(radius * 1.2, 1.0, 1.0, 1.0, 0.0);
            light_pattern.add_color_stop_rgba(0, 1.0, 1.0, 1.0, 0.3);
            cairo.set_source(light_pattern);
            cairo.arc(center.x, center.y, radius * 0.95, 0.0, Math.PI * 2.0);
            cairo.fill();

            light_offset.x = center.x + a * d * 0.3;
            light_offset.y = center.y + b * d * 0.3;

            var light_pattern2 = new Cairo.Pattern.radial(
                    light_offset.x, light_offset.y, 0, light_offset.x, light_offset.y, radius * 0.4);
            light_pattern2.add_color_stop_rgba(radius * 0.5, 1.0, 1.0, 1.0, 0.0);
            light_pattern2.add_color_stop_rgba(0.1, 1.0, 1.0, 1.0, 0.8);
            cairo.set_source(light_pattern2);
            cairo.arc(center.x, center.y, radius * 0.9, 0.0, Math.PI * 2.0);
            cairo.fill();
        }
    }
    
    public class GoWidget : Gtk.DrawingArea {
        public signal void tern_changed(GoStatus tern);
        public signal void require_showing_message(string message);
        public signal void game_over(GoStatus winner);
        public signal void end_with_a_draw();
        public bool is_debug_enabled {
            get {
                return is_debug_enabled_value;
            }
            set {
                is_debug_enabled_value = value;
                model.is_debug_enabled = is_debug_enabled_value;
            }
        }
        public bool is_territory_visible {
            get;
            set;
            default = false;
        }
        public GoModel model { get; private set; }
        private double padding_top = 22.0;
        private double padding_left = 22.0;
        private double padding_right = 22.0;
        private double padding_bottom = 22.0;
        private double cell_width = 40.0;
        private double cell_height = 40.0;
        private double line_width = 2.0;
        private double dot_radius = 4.0;
        private double ball_radius = 18.0;
        private double hover_circle_radius = 18.0;
        private Cairo.Rectangle area_rect;
        private DPoint[,] cross_points;
        private DPoint cursor_point;
        private Gdk.Point hover_position;
        private Gdk.RGBA board_color = { 0.7, 0.65, 0.4, 1.0 };
        private Gdk.RGBA board_highlight_color = { 0.9, 0.85, 0.6, 1.0 };
        private Gdk.RGBA line_color = { 0.1, 0.1, 0.1, 1.0 }; 
        private Gdk.RGBA hover_color = { 0.9, 0.9, 0.2, 0.5 };
        private const double @2TIMES_PI = Math.PI * 2.0;
        private GoStatus tern;
        private BallDrawer white_ball_drawer;
        private BallDrawer black_ball_drawer;
        private List<Gdk.Point?> debug_list;
        private List<Gdk.Point?> debug_list_dropped;
        private bool is_debug_enabled_value = false;
        private bool paused = false;
        
        public GoWidget() {
            model = new GoModel(ModelSize.MODEL_15);
            init();
        }

        public GoWidget.with_model_size(ModelSize size) {
            model = new GoModel(size);
            init();
        }
        
        public void bind_model(GoModel new_model) {
            model = new_model;
            init();
        }
        
        private void init() {
            tern = BLACK;
            
            model.debug_is_surrounded_by.connect((y, x) => {
                Gdk.Point p = { x, y };
                debug_list.append(p);
                queue_draw();
                return 7;
            });
            
            model.ball_dropped.connect((y, x) => {
                Gdk.Point q = { x, y };
                debug_list_dropped.append(q);
                queue_draw();
                return 50;
            });
            
            model.game_over.connect((winner) => {
                game_over(winner);
            });

            model.end_with_a_draw.connect(() => {
                end_with_a_draw();
            });
            
            add_events(
                Gdk.EventMask.BUTTON_PRESS_MASK |
                Gdk.EventMask.POINTER_MOTION_MASK |
                Gdk.EventMask.KEY_PRESS_MASK |
                Gdk.EventMask.LEAVE_NOTIFY_MASK
            );

            debug_list = new List<Gdk.Point>();
            debug_list_dropped = new List<Gdk.Point>();
            cross_points = new DPoint[model.size.y_length(), model.size.x_length()];

            for (int j = 0; j < model.size.y_length(); j++) {
                for (int i = 0; i < model.size.x_length(); i++) {
                    double x;
                    double y;
                    if (j == 0) {
                        y = padding_top;
                    } else {
                        y = cross_points[j - 1, 0].y + line_width + cell_height;
                    }
                    if (i == 0) {
                        x = padding_left;
                    } else {
                        x = cross_points[0, i - 1].x + line_width + cell_width;
                    }
                    cross_points[j, i] = { x, y };
                }
            }

            area_rect = Cairo.Rectangle() {
                x = 0,
                y = 0,
                width = cross_points[model.size.y_length() - 1, model.size.x_length() - 1].x + line_width + padding_right,
                height = cross_points[model.size.y_length() - 1, model.size.x_length() - 1].y + line_width + padding_bottom,
            };

            set_size_request((int) area_rect.width, (int) area_rect.height);
            
            cursor_point = { -1.0, -1.0 };
            hover_position = { -1, -1 };
            
            black_ball_drawer = new BallDrawer();
            black_ball_drawer.set_color(BLACK);
            black_ball_drawer.set_radius(ball_radius);
            white_ball_drawer = new BallDrawer();
            white_ball_drawer.set_color(WHITE);
            white_ball_drawer.set_radius(ball_radius);
        }

        public void reset_debug() {
            debug_list = new List<Gdk.Point>();
            debug_list_dropped = new List<Gdk.Point>();
            queue_draw();
        }

        public override bool draw(Cairo.Context cairo) {
            if (cursor_point.y >= 0 && cursor_point.x >= 0) {
                Cairo.Pattern pattern_bg = new Cairo.Pattern.radial(cursor_point.x, cursor_point.y, 0,
                        cursor_point.x, cursor_point.y, cell_width * 10.0);
                pattern_bg.add_color_stop_rgb(area_rect.width * 10.0, board_color.red, board_color.green, board_color.blue);
                pattern_bg.add_color_stop_rgb(0.0, board_highlight_color.red, board_highlight_color.green, board_highlight_color.blue);
                cairo.set_source(pattern_bg);
            } else {
                cairo.set_source_rgb(board_color.red, board_color.green, board_color.blue);
            }

            cairo.set_line_width(0.0);

            cairo.rectangle(area_rect.x, area_rect.y, area_rect.width - area_rect.x, area_rect.height - area_rect.y);
            cairo.fill();

            cairo.set_source_rgb(line_color.red, line_color.green, line_color.blue);
            cairo.set_line_width(line_width);
            
            for (int j = 0; j < model.size.y_length(); j++) {
                double start_x = cross_points[j, 0].x - line_width / 2.0;
                double start_y = cross_points[j, 0].y;
                double end_x = cross_points[j, model.size.x_length() - 1].x + line_width / 2.0;
                double end_y = cross_points[j, model.size.x_length() - 1].y;
                cairo.move_to(start_x, start_y);
                cairo.line_to(end_x, end_y);
                cairo.stroke();
            }

            for (int i = 0; i < model.size.x_length(); i++) {
                cairo.move_to(cross_points[0, i].x, cross_points[0, i].y);
                cairo.line_to(cross_points[model.size.y_length() - 1, i].x, cross_points[model.size.y_length() - 1, i].y);
                cairo.stroke();
            }

            for (int j = model.size.dot_start_from(); j < model.size.y_length() - 1; j += model.size.dot_interval()) {
                for (int i = model.size.dot_start_from(); i < model.size.x_length() - 1; i += model.size.dot_interval()) {
                    cairo.arc(cross_points[j, i].x, cross_points[j, i].y, dot_radius, 0.0, 2TIMES_PI);
                    cairo.fill();
                }
            }
            
            cairo.set_source_rgb(0.1, 0.1, 0.1);
            cairo.set_line_width(line_width);
            
            for (int j = 0; j < model.size.y_length(); j++) {
                for (int i = 0; i < model.size.x_length(); i++) {
                    switch (model.get_status(j, i)) {
                      case WHITE:
                        white_ball_drawer.move_to(cross_points[j, i]);
                        white_ball_drawer.light_from(cursor_point);
                        white_ball_drawer.draw(cairo);
                        break;
                      case BLACK:
                        black_ball_drawer.move_to(cross_points[j, i]);
                        black_ball_drawer.light_from(cursor_point);
                        black_ball_drawer.draw(cairo);
                        break;
                      default:
                      case EMPTY:
                        break;
                    }
                }
            }
            
            if (hover_position.x >= 0 && hover_position.y >= 0) {
                Cairo.Pattern hover_pattern = new Cairo.Pattern.radial(cursor_point.x, cursor_point.y, 0,
                        cursor_point.x, cursor_point.y, hover_circle_radius);
                hover_pattern.add_color_stop_rgb(
                    hover_circle_radius, board_color.red, board_color.green, board_color.blue
                );
                hover_pattern.add_color_stop_rgb(
                    0, hover_color.red, hover_color.green, hover_color.blue
                );
                cairo.set_source(hover_pattern);
                cairo.set_source_rgba(
                    hover_color.red,
                    hover_color.green,
                    hover_color.blue,
                    hover_color.alpha
                );
                cairo.arc(
                    cross_points[hover_position.y, hover_position.x].x,
                    cross_points[hover_position.y, hover_position.x].y,
                    hover_circle_radius,
                    0.0,
                    2TIMES_PI
                );
                cairo.fill();
            }
            
            if (is_debug_enabled) {
                for (int i = 0; i < debug_list.length(); i++) {
                    Gdk.Point p = debug_list.nth_data(i);
                    cairo.set_source_rgba(1.0, 0.5, 0.0, 0.3);
                    cairo.arc(cross_points[p.y, p.x].x, cross_points[p.y, p.x].y, 10.0, 0.0, Math.PI * 2.0);
                    cairo.fill();
                }

                for (int i = 0; i < debug_list_dropped.length(); i++) {
                    Gdk.Point p = debug_list_dropped.nth_data(i);
                    cairo.set_source_rgba(1.0, 0.0, 1.0, 0.3);
                    cairo.arc(cross_points[p.y, p.x].x, cross_points[p.y, p.x].y, 10.0, 0.0, Math.PI * 2.0);
                    cairo.fill();
                }
            }

            if (is_territory_visible) {
                cairo.set_line_width(2.0);
                for (int j = 0; j < model.size.y_length(); j++) {
                    for (int i = 0; i < model.size.x_length(); i++) {
                        var terr = model.get_territory_status(j, i);
                        if (terr == GoStatus.BLACK_TERRITORY || terr == GoStatus.WHITE_TERRITORY) {
                            if (terr == GoStatus.BLACK_TERRITORY) {
                                cairo.set_source_rgba(1.0, 0.0, 0.0, 0.6);
                            } else {
                                cairo.set_source_rgba(0.0, 0.0, 1.0, 0.6);
                            }
                            cairo.rectangle(
                                cross_points[j, i].x - 10,
                                cross_points[j, i].y - 10,
                                20,
                                20
                            );
                            cairo.stroke();
                        } else if (terr == GoStatus.EMPTY) {
                            cairo.set_source_rgba(0.8, 0.8, 0.1, 0.6);
                            cairo.move_to(cross_points[j, i].x - 10, cross_points[j, i].y - 10);
                            cairo.line_to(cross_points[j, i].x + 10, cross_points[j, i].y + 10);
                            cairo.stroke();
                            cairo.move_to(cross_points[j, i].x - 10, cross_points[j, i].y + 10);
                            cairo.line_to(cross_points[j, i].x + 10, cross_points[j, i].y - 10);
                            cairo.stroke();
                        }
                    }
                }
            }
            return true;
        }

        public override bool button_press_event(Gdk.EventButton event) {
            if (paused) {
                return false;
            }
            
            if (hover_position.y < 0 || hover_position.x < 0) {
                return false;
            }
            
            if (tern == BLACK) {
                model.put_black.begin(hover_position.y, hover_position.x, (obj, res) => {
                    bool result = model.put_black.end(res);
                    if (result) {
                        tern = WHITE;
                        tern_changed(tern);
                    }
                    paused = false;
                    set_hover_position();
                    queue_draw();
                });
            } else {
                model.put_white.begin(hover_position.y, hover_position.x, (obj, res) => {
                    bool result = model.put_white.end(res);
                    if (result) {
                        tern = BLACK;
                        tern_changed(tern);
                    }
                    paused = false;
                    set_hover_position();
                    queue_draw();
                });
            }

            hover_position.x = -1;
            hover_position.y = -1;
            paused = true;
            queue_draw();
            return false;
        }

        public override bool button_release_event(Gdk.EventButton event) {
            return false;
        }

        public override bool leave_notify_event(Gdk.EventCrossing event) {
            cursor_point.x = -1.0;
            cursor_point.y = -1.0;
            hover_position.x = -1;
            hover_position.y = -1;
            queue_draw();
            return false;
        }

        public override bool motion_notify_event(Gdk.EventMotion event) {
            cursor_point.x = event.x;
            cursor_point.y = event.y;
            if (paused) {
                hover_position.x = -1;
                hover_position.y = -1;
            } else {
                set_hover_position();
            }
            queue_draw();
            return false;
        }
        
        private void set_hover_position() {
            hover_position.y = -1;
            hover_position.x = -1;
            for (int j = 0; j < model.size.y_length(); j++) {
                if (cross_points[j, 0].y - cell_width / 2 <= cursor_point.y
                        && cursor_point.y < cross_points[j, 0].y + cell_width / 2) {
                    hover_position.y = j;
                }
            }
            for (int i = 0; i < model.size.x_length(); i++) {
                if (cross_points[0, i].x - cell_width / 2 <= cursor_point.x
                        && cursor_point.x < cross_points[0, i].x + cell_width / 2) {
                    hover_position.x = i;
                }
            }
        }
    }
    
    public class TernSwitcher : Gtk.DrawingArea {
        public int width = 130;
        public int height = 50;
        public int radius = 16;
        public Gdk.RGBA selection_bg_color = { 0.9, 0.6, 0.4, 1.0 };
        public Gdk.RGBA normal_bg_color = { 3.0, 3.0, 3.0, 1.0 };
        public int spacing = 2;
        public DPoint cursor;
        private DPoint black_ball_position;
        private DPoint white_ball_position;
        private double ball_radius = 16.0;
        private double highlight_radius = 150;
        private int selection_offset = 0;
        private GoStatus tern_value = BLACK;
        public GoStatus tern {
            get {
                return tern_value;
            }
            set {
                if (tern_value != value && tern_value in GoStatus.BLACK + GoStatus.WHITE) {
                    tern_value = value;
                    if (tern_value == BLACK) {
                        Timeout.add(20, () => {
                            if (tern_value == BLACK && selection_offset > 0) {
                                selection_offset -= 10;
                                this.queue_draw();
                                return true;
                            } else {
                                return false;
                            }
                        });
                    } else {
                        Timeout.add(20, () => {
                            if (tern_value == WHITE && selection_offset < width + spacing - 10) {
                                selection_offset += 10;
                                this.queue_draw();
                                return true;
                            } else {
                                return false;
                            }
                        });
                    }
                }
            }
        }
        
        public TernSwitcher() {
            black_ball_position.x = width / 2;
            black_ball_position.y = height / 2;
            white_ball_position.x = width + spacing + width / 2;
            white_ball_position.y = height / 2;
            add_events(Gdk.EventMask.LEAVE_NOTIFY_MASK + Gdk.EventMask.POINTER_MOTION_MASK);
            width_request = width * 2 + spacing;
            height_request = height;
            queue_draw();
        }
        
        public override bool draw(Cairo.Context cairo) {
            cairo.set_source_rgba(0.0, 0.0, 0.0, 0.5);
            cairo.arc(radius + 2, radius + 2, radius + 2, Math.PI * 1.0, Math.PI * 1.5);
            cairo.arc(width * 2 + spacing - radius - 2, radius + 2, radius + 2, Math.PI * 1.5, Math.PI * 2.0);
            cairo.arc(width * 2 + spacing - radius - 2, height - radius - 2, radius + 2, Math.PI * 0.0, Math.PI * 0.5);
            cairo.arc(radius + 2, height - radius - 2, radius + 2, Math.PI * 0.5, Math.PI * 1.0);
            cairo.fill();
            
            if (cursor.x >= 0.0 && cursor.y >= 0.0) {
                var pat = new Cairo.Pattern.radial(cursor.x, cursor.y, 0.0, cursor.x, cursor.y, highlight_radius);
                pat.add_color_stop_rgb(highlight_radius, selection_bg_color.red, selection_bg_color.green, selection_bg_color.blue);
                pat.add_color_stop_rgb(0.0, selection_bg_color.red * 1.5, selection_bg_color.green * 1.5, selection_bg_color.blue * 1.5);
                cairo.set_source(pat);
            } else {
                cairo.set_source_rgb(selection_bg_color.red, selection_bg_color.green, selection_bg_color.blue);
            }

            double offset_radius = selection_offset + radius + 2;
            cairo.arc(offset_radius, radius + 2, radius, Math.PI * 1.0, Math.PI * 1.5);
            cairo.arc(selection_offset + width - radius - 2, radius + 2, radius, Math.PI * 1.5, Math.PI * 2.0);
            cairo.arc(selection_offset + width - radius - 2, height - radius - 2, radius, Math.PI * 0.0, Math.PI * 0.5);
            cairo.arc(offset_radius, height - radius - 2, radius, Math.PI * 0.5, Math.PI * 1.0);
            cairo.fill();
            
            cairo.set_source_rgba(0.2, 0.2, 0.2, 1.0);
            cairo.arc(black_ball_position.x, black_ball_position.y, ball_radius, 0.0, Math.PI * 2.0);
            cairo.fill();
            
            cairo.set_source_rgba(0.9, 0.9, 0.9, 1.0);
            cairo.arc(white_ball_position.x, white_ball_position.y, ball_radius, 0.0, Math.PI * 2.0);
            cairo.fill();
            
            return true;
        }
        
        public override bool leave_notify_event(Gdk.EventCrossing event) {
            cursor.x = -1;
            cursor.y = -1;
            queue_draw();
            return true;
        }
        
        public override bool motion_notify_event(Gdk.EventMotion event) {
            cursor.x = event.x;
            cursor.y = event.y;
            queue_draw();
            return true;
        }
    }

    public class StopWatch : Gtk.Box {
        public signal void started();
        
        private Gtk.Label label_1;
        private Gtk.Label label_2;
        private bool is_running = false;
        private bool is_paused = false;
        private int time = 0;
        private int count = 0;

        public StopWatch() {
            Object(
                orientation: Gtk.Orientation.HORIZONTAL
            );
        }
                
        construct {
            label_1 = Bakamon.LabelBuilder.create()
                    .size(16).weight(BOLD).style(ITALIC).family("Sans")
                    .label("0:00").build();
            label_1.valign = END;
            label_2 = Bakamon.LabelBuilder.create()
                    .size(10).weight(BOLD).style(ITALIC).family("Sans")
                    .label(".00").build();
            label_2.valign = END;
            
            pack_start(label_1, false, false);
            pack_start(label_2, false, false);
            valign = END;
        }
        
        public async void run() {
            count++;
            int count_save = count;
            is_running = true;
            is_paused = false;
            time = 0;
            started();
            int hour_span = 60 * 60 * 10;
            while (count_save == count && is_running) {
                if (!is_paused) {
                    time += 1;
                    if (time < hour_span) {
                        label_1.label = "%02d:%02d".printf(
                            time / 100 / 60,
                            time / 100 % 60
                        );
                        label_2.label = ".%02d".printf(
                            time % 100
                        );
                    } else {
                        label_1.label = "%d:%02d:%02d".printf(
                            time / 100 / 60 / 60,
                            time / 100 / 60 % 60,
                            time / 100 % 60
                        );
                        label_2.label = ".%02d".printf(
                            time % 100
                        );
                    }
                }
                Timeout.add(10, run.callback);
                yield;
            }
        }
        
        public void stop() {
            is_running = false;
        }
        
        public void pause() {
            is_paused = true;
        }
        
        public void unpause() {
            is_paused = false;
        }
    }
    
    public class MiniGoWidget : Gtk.DrawingArea {
        private Gdk.RGBA board_color = { 0.7, 0.65, 0.4, 1.0 };
        private ModelSize size;
        private int padding = 5;
        private int board_width = 200;
        private int cell_width = 10;
        private int line_width = 1;
        private GoStatus[,] mini_model;
        
        private void set_size(ModelSize size) {
            this.size = size;
            line_width = 1;
            cell_width = board_width / (size.x_length() + 1);
            padding = (board_width - cell_width * (size.x_length() - 1)) / 2;
            mini_model = new GoStatus[size.y_length(), size.x_length()];
            for (int j = 0; j < size.y_length(); j++) {
                for (int i = 0; i < size.x_length(); i++) {
                    int random_value = Random.int_range(0, 30);
                    switch (random_value) {
                      case 1:
                        mini_model[j, i] = BLACK;
                        break;
                      case 2:
                        mini_model[j, i] = WHITE;
                        break;
                      case 3:
                        mini_model[j, i] = EMPTY;
                        break;
                    }
                }
            }
        }
        
        public MiniGoWidget(ModelSize size) {
            set_size(size);
            width_request = board_width;
            height_request = board_width;
        }
        
        public override bool draw(Cairo.Context cairo) {
            cairo.set_source_rgb(board_color.red, board_color.green, board_color.blue);
            cairo.rectangle(0.0, 0.0, board_width, board_width);
            cairo.fill();
            cairo.set_source_rgb(0.1, 0.1, 0.1);
            cairo.set_line_width(1.0);
            for (int j = 0; j < size.y_length(); j++) {
                cairo.move_to((double) padding, (double) (padding + j * cell_width));
                cairo.line_to((double) (board_width - padding), (double) (padding + j * cell_width));
                cairo.stroke();
            }
            for (int i = 0; i < size.x_length(); i++) {
                cairo.move_to((double) (padding + i * cell_width), (double) padding);
                cairo.line_to((double) (padding + i * cell_width), (double) (board_width - padding));
                cairo.stroke();
            }
            for (int j = 0; j < size.y_length(); j++) {
                for (int i = 0; i < size.x_length(); i++) {
                    if (mini_model[j, i] == BLACK) {
                        cairo.set_source_rgb(0.1, 0.1, 0.1);
                    } else if (mini_model[j, i] == WHITE) {
                        cairo.set_source_rgb(0.95, 0.95, 0.95);
                    } else {
                        continue;
                    }
                    cairo.arc(padding + i * cell_width, padding + j * cell_width, cell_width / 2, 0.0, Math.PI * 2.0);
                    cairo.fill();
                }
            }
            return true;
        }
    }
    
    public class GoPowsWidget : Gtk.DrawingArea {
        private int width = 264;
        
        public int pows_count {
            get {
                return pows_count_value;
            }
            set {
                pows_count_value = value;
                height_request = (pows_count / 8 + (pows_count % 8 > 0 ? 1 : 0)) * (width / 8);
                queue_draw();
            }
        }
        
        private int pows_count_value = 0;
        private GoStatus status;
        private BallDrawer drawer;
        
        public GoPowsWidget(GoStatus status) requires(status == BLACK || status == WHITE) {
            this.status = status;
            drawer = new BallDrawer();
            drawer.set_color(status);
        }
        
        public override bool draw(Cairo.Context cairo) {
            int num_in_row = 10;
            int cell_width = width / num_in_row;
            int radius = cell_width / 2 - 1;
            drawer.set_radius(radius);
            for (int i = 0; i < pows_count_value; i++) {
                var p = DPoint() {
                    x = (double) ((i % num_in_row) * cell_width + radius),
                    y = (double) ((i / num_in_row) * cell_width + radius)
                };
                drawer.move_to(p);
                drawer.draw(cairo);
            }
            return true;
        }
    }
    
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

int main(string[] argv) {
    Random.set_seed((uint32) new DateTime.now_local().to_unix());
    bool is_debug_enabled = false;
    Bakamon.ModelSize model_size = MODEL_13;
    
    for (int i = 1; i < argv.length; i++) {
        switch (argv[i]) {
          case "-d":
            is_debug_enabled = true;
            break;
        }
    }
    
    var app = new Gtk.Application("com.github.aharotias2.BakamonGo", FLAGS_NONE);
    app.activate.connect(() => {
        Bakamon.GoWidget? go_widget = null;
        Bakamon.StopWatch? stop_watch = null;
        Bakamon.TernSwitcher? tern_switcher = null;
        Bakamon.GoScoreBoard? score_board = null;
        Gtk.Stack? stack = null;
        Gtk.Box? page_1 = null;
        Gtk.Box? page_2 = null;
        Gtk.Box? page_3 = null;
        var window = new Gtk.ApplicationWindow(app);
        {
            var body_box = new Gtk.Box(HORIZONTAL, 2);
            {
                stack = new Gtk.Stack();
                {
                    page_1 = new Gtk.Box(VERTICAL, 20);
                    {
                        var logo_overlay = new Gtk.Overlay();
                        {
                            var big_logo = new Gtk.Image.from_resource("/images/go-logo.png");

                            var title_logo = new Bakamon.TitleLogo() { valign = CENTER };
                            
                            logo_overlay.add(big_logo);
                            logo_overlay.add_overlay(title_logo);
                            logo_overlay.width_request = title_logo.width_request;
                            logo_overlay.height_request = big_logo.height_request;
                        }
                        
                        var greeting = new Gtk.Label("始めますか？");

                        var button_box = new Gtk.ButtonBox(VERTICAL);
                        {
                            var button_1 = new Gtk.Button.with_label("一人でプレイする");
                            button_1.clicked.connect(() => {
                                stack.visible_child_name = "page-2";
                            });

                            button_box.pack_start(button_1, false, false);
                        }

                        page_1.pack_start(logo_overlay, false, false);
                        page_1.pack_start(greeting, false, false);
                        page_1.pack_start(button_box, false, false);
                        page_1.halign = CENTER;
                        page_1.valign = CENTER;
                    }

                    page_2 = new Gtk.Box(VERTICAL, 2);
                    {
                        var message_label = new Gtk.Label("盤面の大きさを選んでください");
                        var mini_board_grid = new Gtk.Grid();
                        var mini_board_9 = new Bakamon.MiniGoWidget(MODEL_9) { margin = 5 };
                        var mini_board_13 = new Bakamon.MiniGoWidget(MODEL_13) { margin = 5 };
                        var mini_board_15 = new Bakamon.MiniGoWidget(MODEL_15) { margin = 5 };
                        var mini_board_19 = new Bakamon.MiniGoWidget(MODEL_19) { margin = 5 };
                        var radio_model_9 = new Gtk.RadioButton.with_label(null, "9路盤 (9x9)") { active = true, halign = CENTER };
                        var radio_model_13 = new Gtk.RadioButton.with_label_from_widget(radio_model_9, "13路盤 (13x13)") { halign = CENTER };
                        var radio_model_15 = new Gtk.RadioButton.with_label_from_widget(radio_model_9, "15路盤 (15x15)") { halign = CENTER };
                        var radio_model_19 = new Gtk.RadioButton.with_label_from_widget(radio_model_9, "19路盤 (19x19)") { halign = CENTER };
                        mini_board_grid.attach(mini_board_9, 0, 0);
                        mini_board_grid.attach(radio_model_9, 0, 1);
                        mini_board_grid.attach(mini_board_13, 1, 0);
                        mini_board_grid.attach(radio_model_13, 1, 1);
                        mini_board_grid.attach(mini_board_15, 0, 2);
                        mini_board_grid.attach(radio_model_15, 0, 3);
                        mini_board_grid.attach(mini_board_19, 1, 2);
                        mini_board_grid.attach(radio_model_19, 1, 3);
                        mini_board_grid.valign = CENTER;
                        mini_board_grid.halign = CENTER;

                        var button_box = new Gtk.ButtonBox(HORIZONTAL);
                        {
                            var ok_button = new Gtk.Button.with_label("決定");
                            ok_button.clicked.connect(() => {
                                Bakamon.ModelSize size;
                                if (radio_model_9.active) {
                                    size = Bakamon.ModelSize.MODEL_9;
                                } else if (radio_model_13.active) {
                                    size = Bakamon.ModelSize.MODEL_13;
                                } else if (radio_model_15.active) {
                                    size = Bakamon.ModelSize.MODEL_15;
                                } else if (radio_model_19.active) {
                                    size = Bakamon.ModelSize.MODEL_19;
                                } else {
                                    return;
                                }
                                go_widget.bind_model(new Bakamon.GoModel(size));
                                stack.visible_child_name = "page-3";
                                window.resize(1, 1);
                                Idle.add(() => {
                                    stop_watch.run.begin();
                                    return false;
                                });
                            });
                            ok_button.hexpand = false;
                            ok_button.halign = CENTER;

                            var cancel_button = new Gtk.Button.with_label("戻る");
                            cancel_button.clicked.connect(() => {
                                stack.transition_type = SLIDE_RIGHT;
                                Idle.add(() => {
                                    stack.visible_child_name = "page-1";
                                    stack.transition_type = SLIDE_LEFT;
                                    return false;
                                });
                            });
                            
                            button_box.pack_start(cancel_button);
                            button_box.pack_start(ok_button);
                            button_box.layout_style = SPREAD;
                        }
                        
                        page_2.pack_start(message_label, false, false);
                        page_2.pack_start(mini_board_grid, false, false);
                        page_2.pack_start(button_box, false, false);
                        page_2.margin = 10;
                    }

                    page_3 = new Gtk.Box(HORIZONTAL, 2);
                    {
                        var left_box = new Gtk.Box(VERTICAL, 2);
                        {
                            go_widget = new Bakamon.GoWidget.with_model_size(model_size) {
                                is_debug_enabled = is_debug_enabled
                            };
                            {
                                go_widget.tern_changed.connect((tern) => {
                                    score_board.black_score = go_widget.model.black_score;
                                    score_board.white_score = go_widget.model.white_score;
                                    score_board.black_pows = go_widget.model.black_pows;
                                    score_board.white_pows = go_widget.model.white_pows;
                                    score_board.queue_draw();
                                    tern_switcher.tern = tern;
                                });

                                go_widget.require_showing_message.connect((message) => {
                                    var dialog = new Gtk.MessageDialog(window, MODAL, INFO, OK, message);
                                    dialog.run();
                                    dialog.close();
                                });

                                go_widget.game_over.connect((winner) => {
                                    string message;
                                    int black_score = go_widget.model.black_score - go_widget.model.white_pows;
                                    int white_score = go_widget.model.white_score - go_widget.model.black_pows;
                                    if (winner == BLACK) {
                                        message = @"黒の勝ち (黒$(black_score)点、白$(white_score)点)";
                                    } else {
                                        message = @"白の勝ち (白$(white_score)点、黒$(black_score)点)";
                                    }
                                    stop_watch.stop();
                                    go_widget.sensitive = false;
                                    go_widget.require_showing_message(message);
                                });

                                go_widget.end_with_a_draw.connect(() => {
                                    stop_watch.stop();
                                    go_widget.sensitive = false;
                                    go_widget.require_showing_message(@"引き分け (両者$(go_widget.model.black_score)点)");
                                });

                                go_widget.sensitive = false;
                            }

                            left_box.pack_start(go_widget, false, false);
                            left_box.margin = 2;
                        }

                        var right_box = new Gtk.Box(VERTICAL, 2);
                        {
                            tern_switcher = new Bakamon.TernSwitcher();
                            {
                                tern_switcher.halign = CENTER;
                                tern_switcher.tern = BLACK;
                            }

                            stop_watch = new Bakamon.StopWatch();
                            {
                                stop_watch.halign = END;
                                stop_watch.started.connect(() => {
                                    go_widget.sensitive = true;
                                });
                            }

                            score_board = new Bakamon.GoScoreBoard();
                            
                            var toggle_showing_territories = new Gtk.ToggleButton.with_label("陣地を表示する");
                            toggle_showing_territories.toggled.connect(() => {
                                if (toggle_showing_territories.active) {
                                    go_widget.is_territory_visible = true;
                                } else {
                                    go_widget.is_territory_visible = false;
                                }
                                go_widget.queue_draw();
                            });
                            
                            var return_button = new Gtk.Button.with_label("終了する");
                            return_button.clicked.connect(() => {
                                stack.transition_type = SLIDE_RIGHT;
                                go_widget.sensitive = false;
                                score_board.reset();
                                stop_watch.stop();
                                Idle.add(() => {
                                    stack.visible_child_name = "page-1";
                                    stack.transition_type = SLIDE_LEFT;
                                    return false;
                                });
                            });

                            var write_button = new Gtk.Button.with_label("棋譜を出力する");
                            write_button.clicked.connect(() => {
                                var dialog = new Gtk.FileChooserDialog(
                                    "保存する", window, SAVE, "キャンセル", Gtk.ResponseType.CANCEL, "保存する", Gtk.ResponseType.ACCEPT
                                );
                                dialog.set_filename("新規.json");
                                int res = dialog.run();
                                if (res == Gtk.ResponseType.ACCEPT) {
                                    try {
                                        var filename = dialog.get_filename();
                                        File file = File.new_for_path(filename);
                                        DataOutputStream? st = null;
                                        if (file.query_exists()) {
                                            st = new DataOutputStream(file.replace(null, true, NONE));
                                        } else {
                                            st = new DataOutputStream(file.create(NONE));
                                        }
                                        if (st != null) {
                                            Json.Node history_json = go_widget.model.get_history();
                                            st.put_string(Json.to_string(history_json, false));
                                        }
                                    } catch (Error e) {
                                        printerr("ERROR: cannot save file!\n");
                                    }
                                }
                                dialog.close();
                            });
                            
                            right_box.pack_start(tern_switcher, false, false);
                            right_box.pack_start(stop_watch, false, false);
                            right_box.pack_start(score_board, false, false);
                            right_box.pack_start(toggle_showing_territories, false, false);
                            right_box.pack_end(return_button, false, false);
                            right_box.pack_end(write_button, false, false);
                            right_box.margin = 5;
                            right_box.height_request = left_box.height_request;
                        }

                        page_3.pack_start(left_box, false, false);
                        page_3.pack_start(right_box, false, false);
                    }

                    stack.add_named(page_1, "page-1");
                    stack.add_named(page_2, "page-2");
                    stack.add_named(page_3, "page-3");
                    stack.visible_child_name = "page-1";
                    stack.transition_type = SLIDE_LEFT;
                }
                
                body_box.pack_start(stack, false, false);
            }
            
            window.add(body_box);
            window.key_press_event.connect((event) => {
                if (event.keyval == Gdk.Key.r) {
                    if (go_widget.is_debug_enabled) {
                        go_widget.reset_debug();
                    }
                } else if (event.keyval == Gdk.Key.d) {
                    go_widget.is_debug_enabled = !go_widget.is_debug_enabled;
                } else if (event.keyval == Gdk.Key.t) {
                    go_widget.is_territory_visible = !go_widget.is_territory_visible;
                }
                return false;
            });
        }
        
        window.show_all();
    });
    return app.run(null);
}
