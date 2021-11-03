/*
 * This file is part of Bakamon-Go.
 *
 *     Bakamon-Go is free software: you can redistribute it and/or modify
 *     it under the terms of the GNU General Public License as published by
 *     the Free Software Foundation, either version 3 of the License, or
 *     (at your option) any later version.
 *
 *     Bakamon-Go is distributed in the hope that it will be useful,
 *     but WITHOUT ANY WARRANTY; without even the implied warranty of
 *     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *     GNU General Public License for more details.
 *
 *     You should have received a copy of the GNU General Public License
 *     along with Bakamon-Go.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Copyright 2021 Takayuki Tanaka
 */

namespace Bakamon {
    public class GoModel : Object {
        public bool is_debug_enabled { get; set; default = false; }
        public signal int debug_is_surrounded_by(int y, int x);
        public signal int ball_dropped(int y, int x);
        public signal void game_over(GoStatus winner);
        public signal void end_with_a_draw();
        public signal void tern_changed(GoTern tern);
        public GoTern tern { get; set; default = BLACK; }
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

        public void change_tern() {
            if (tern == BLACK) {
                tern = WHITE;
            } else {
                tern = BLACK;
            }
        }
        
        public void pass() {
            if (history.last().data.is_passed) {
                finish_game();
            } else {
                history.append({tern == BLACK, true, -1, -1});
                change_tern();
            }
        }
        
        public Json.Node get_history() {
            Json.Object json = new Json.Object();
            json.set_string_member("盤面", size.to_string());
            json.set_string_member("開始時刻", start_datetime.format(DATETIME_FORMAT_ISO8601));
            json.set_string_member("終了時刻", new DateTime.now_local().format(DATETIME_FORMAT_ISO8601));
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
                if (item.is_passed) {
                    item_array.add_string_element("パス");
                } else {
                    item_array.add_int_element(item.x);
                    item_array.add_int_element(item.y);
                }
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

        public async bool put(int y, int x) {
            if (tern == BLACK) {
                return yield put_black(y, x);
            } else {
                return yield put_white(y, x);
            }
        }
                
        public async bool put_black(int y, int x) {
            if (yield can_put_v2(BLACK, y, x)) {
                status[y, x] = BLACK;
                history.append({true, false, x, y});
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
                history.append({false, false, x, y});
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
            finish_game();
        }

        private void finish_game() {
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
}
