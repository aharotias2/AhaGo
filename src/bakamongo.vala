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
    public class Go : Gtk.Application {
        public bool is_debug_enabled { get; set; default = false; }
        private Bakamon.GoWidget? go_widget = null;
        private Bakamon.StopWatch? stop_watch = null;
        private Bakamon.TernSwitcher? tern_switcher = null;
        private Bakamon.GoScoreBoard? score_board = null;
        private Gtk.Stack? stack = null;
        private Gtk.Box? page_1 = null;
        private Gtk.Box? page_2 = null;
        private Gtk.Box? page_3 = null;

        public Go() {
            Object(application_id: "com.github.aharotias2.BakamonGo", flags: ApplicationFlags.FLAGS_NONE);
        }
        
        public override void activate() {
            var window = new Gtk.ApplicationWindow(this);
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
                                go_widget = new Bakamon.GoWidget.with_model_size(MODEL_9) {
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

                                var pass_button = new Gtk.Button.with_label("パス");
                                pass_button.clicked.connect(() => {
                                    go_widget.model.pass();
                                    tern_switcher.tern = go_widget.model.tern;
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
                                right_box.pack_start(pass_button, false, false);
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
        }
    }
    
    public static int main(string[] argv) {
        Random.set_seed((uint32) new DateTime.now_local().to_unix());
        bool is_debug_enabled = false;
        for (int i = 1; i < argv.length; i++) {
            switch (argv[i]) {
              case "-d":
                is_debug_enabled = true;
                break;
            }
        }

        var app = new Go();
        if (is_debug_enabled) {
            app.is_debug_enabled = true;
        }
        return app.run(null);
    }
}