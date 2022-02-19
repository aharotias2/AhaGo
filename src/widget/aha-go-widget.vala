/*
 * This file is part of Aha-Go.
 *
 *     Aha-Go is free software: you can redistribute it and/or modify
 *     it under the terms of the GNU General Public License as published by
 *     the Free Software Foundation, either version 3 of the License, or
 *     (at your option) any later version.
 *
 *     Aha-Go is distributed in the hope that it will be useful,
 *     but WITHOUT ANY WARRANTY; without even the implied warranty of
 *     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *     GNU General Public License for more details.
 *
 *     You should have received a copy of the GNU General Public License
 *     along with Aha-Go.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Copyright 2021 Takayuki Tanaka
 */

namespace Aha {
    public class GoWidget : Gtk.DrawingArea {
        public signal void tern_changed(GoTern tern);
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

            model.tern_changed.connect((tern) => {
                tern_changed(tern);
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

            cairo.set_source_rgba(line_color.red, line_color.green, line_color.blue, line_color.alpha);
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
            
            model.put.begin(hover_position.y, hover_position.x, (obj, res) => {
                bool result = model.put.end(res);
                if (result) {
                    model.change_tern();
                    model.tern_changed(model.tern);
                }
                paused = false;
                set_hover_position();
                queue_draw();
            });

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
}
