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
    [Flags]
    public enum GoStatus {
        EMPTY,
        BLACK,
        WHITE,
        BLACK_TERRITORY,
        WHITE_TERRITORY,
        EDGE;
        
        public string to_string() {
            switch (this) {
              default: case EMPTY: return "empty";
              case BLACK: return "black";
              case WHITE: return "white";
              case WHITE_TERRITORY: return "white-territory";
              case BLACK_TERRITORY: return "black-territory";
              case EDGE: return "edge";
            }
        }
    }
}
