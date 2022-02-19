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
    public class StopWatch : Gtk.Box {
        public signal void started();
        public signal void end_count_down();
        
        public int start_from = 0;
        public bool is_counting_down = false;
                
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
            label_1 = Aha.LabelBuilder.create()
                    .size(14).weight(BOLD).style(ITALIC).family("Sans")
                    .label("0:00").build();
            label_1.valign = END;
            label_2 = Aha.LabelBuilder.create()
                    .size(10).weight(BOLD).style(ITALIC).family("Sans")
                    .label(".00").build();
            label_2.valign = END;
            
            pack_start(label_1, false, false);
            pack_start(label_2, false, false);
            valign = END;
        }
        
        public async void run() {
            time = start_from;
            update_time();
            count++;
            int count_save = count;
            is_running = true;
            is_paused = false;
            Idle.add(run.callback);
            yield;
            started();
            while (count_save == count && is_running && time > 0) {
                if (!is_paused) {
                    time -= 10;
                    update_time();
                }
                Timeout.add(10, run.callback);
                yield;
            }
        }
        
        public void stop() {
            is_running = false;
        }
        
        public void stop_signal() {
            is_running = false;
            Idle.add(() => {
                end_count_down();
                return false;
            });
        }
        
        public void pause() {
            is_paused = true;
        }
        
        public void unpause() {
            is_paused = false;
        }
        
        private void update_time() {
            int hour = time / 1000 / 60 / 60;
            int minute = time / 1000 / 60 % 60;
            int second = time / 1000 % 60;
            int millisecond = time % 1000;
            if (hour == 0) {
                label_1.label = "%02d:%02d".printf(minute, second);
                label_2.label = ".%02d".printf(millisecond / 10);
            } else {
                label_1.label = "%d:%02d:%02d".printf(hour, minute, second);
                label_2.label = ".%02d".printf(millisecond / 10);
            }
        }
    }
}
