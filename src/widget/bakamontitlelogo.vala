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
}