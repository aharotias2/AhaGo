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
                base_color = { 0.1, 0.1, 0.1, 1.0 };
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
            shadow_pattern.add_color_stop_rgba(radius * 1.2, 0.0, 0.0, 0.0, 0.0);
            shadow_pattern.add_color_stop_rgba(0.0, 0.0, 0.0, 0.0, 0.9);
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
                    light_offset.x, light_offset.y, 0, light_offset.x, light_offset.y, radius * 0.65);
            light_pattern2.add_color_stop_rgba(radius * 0.6, 1.0, 1.0, 1.0, 0.0);
            light_pattern2.add_color_stop_rgba(0.0, 1.0, 1.0, 1.0, 0.7);
            cairo.set_source(light_pattern2);
            //cairo.arc(center.x, center.y, radius * 0.5, 0.0, Math.PI * 2.0);
            cairo.arc(light_offset.x, light_offset.y, radius * 0.7, 0.0, Math.PI * 2.0);
            cairo.fill();
        }
    }
}
