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
    public enum ModelSize {
        MODEL_9,
        MODEL_13,
        MODEL_15,
        MODEL_19;
        
        public int x_length() {
            switch (this) {
              case MODEL_9: return 9;
              default: case MODEL_13: return 13;
              case MODEL_15: return 15;
              case MODEL_19: return 19;
            }
        }
         
        public int y_length() {
            switch (this) {
              case MODEL_9: return 9;
              default: case MODEL_13: return 13;
              case MODEL_15: return 15;
              case MODEL_19: return 19;
            }
        }
        
        public int dot_start_from() {
            switch (this) {
              case MODEL_9: return 4;
              default: case MODEL_13: return 3;
              case MODEL_15: return 3;
              case MODEL_19: return 3;
            }
        }

        public int dot_interval() {
            switch (this) {
              case MODEL_9: return 5;
              default: case MODEL_13: return 3;
              case MODEL_15: return 4;
              case MODEL_19: return 6;
            }
        }
        
        public string to_string() {
            switch (this) {
              case MODEL_9: return "9路盤";
              default: case MODEL_13: return "13路盤";
              case MODEL_15: return "15路盤";
              case MODEL_19: return "19路盤";
            }
        }
    }
}
