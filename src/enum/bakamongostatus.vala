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
