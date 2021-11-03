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
}
