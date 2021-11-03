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
}