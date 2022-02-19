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
        public StopWatch stop_watch_black { get; private set; }
        public StopWatch stop_watch_white { get; private set; }
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
            
            var black_score_box = new Gtk.Box(HORIZONTAL, 0);
            {
                black_score_label = new Gtk.Label("黒：<span color=\"red\">0</span>点") {
                        attributes = attrlist_big, halign = START, use_markup = true };
                black_score_label.halign = START;
                
                stop_watch_black = new StopWatch() {
                    halign = END
                };

                black_score_box.pack_start(black_score_label, true, false);
                black_score_box.pack_end(stop_watch_black, true, false);
            }
            
            var black_pows_frame = new Gtk.Frame(null);
            {
                var black_pows_label = new Gtk.Label("黒の捕虜") { attributes = attrlist_small };
                black_pows_widget = new GoPowsWidget(WHITE);
                black_pows_frame.add(black_pows_widget);
                black_pows_frame.label_widget = black_pows_label;
            }
            
            var white_score_box = new Gtk.Box(HORIZONTAL, 0);
            {
                white_score_label = new Gtk.Label("白：<span color=\"blue\">0</span>点") {
                        attributes = attrlist_big, halign = START, use_markup = true };
                
                stop_watch_white = new StopWatch() {
                    halign = END
                };
                
                white_score_box.pack_start(white_score_label, true, false);
                white_score_box.pack_end(stop_watch_white, true, false);
            }
            
            var white_pows_frame = new Gtk.Frame(null);
            {
                var white_pows_label = new Gtk.Label("白の捕虜") { attributes = attrlist_small };
                white_pows_widget = new GoPowsWidget(BLACK);
                white_pows_frame.add(white_pows_widget);
                white_pows_frame.label_widget = white_pows_label;
            }
            pack_start(black_score_box, false, false);
            pack_start(black_pows_frame, false, false);
            pack_start(white_score_box, false, false);
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
