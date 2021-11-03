namespace Bakamon {
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
