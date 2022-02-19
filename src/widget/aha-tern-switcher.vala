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
    public class TernSwitcher : Gtk.DrawingArea {
        public int width = 80;
        public int height = 40;
        public int radius = 18;
        public Gdk.RGBA selection_bg_color = { 0.9, 0.6, 0.4, 1.0 };
        public Gdk.RGBA normal_bg_color = { 3.0, 3.0, 3.0, 1.0 };
        public int spacing = 2;
        public DPoint cursor;
        private DPoint black_ball_position;
        private DPoint white_ball_position;
        private double ball_radius = 10.0;
        private double highlight_radius = 150;
        private int selection_offset = 0;
        private GoTern tern_value = BLACK;
        public GoTern tern {
            get {
                return tern_value;
            }
            set {
                if (tern_value != value) {
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
}
