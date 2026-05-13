package recharge.midlife.base.graphics;

import recharge.midlife.base.graphics.Mesh;

class TextMesh extends Mesh {
  static inline var CHAR_WIDTH:Float = 1 / 13;
  static inline var CHAR_HEIGHT:Float = 1 / 7;

  public function new(text:String) {
    for (i in 0...text.length) {
      var char:Int = text.charCodeAt(i);

      if (char == 32) { // Space
        continue;
      }

      if (char >= 97) { // Lowercase Letters
        char -= 97 - 26;
      } else if (char >= 65) { // Uppercase Letters
        char -= 65;
      } else if (char >= 48) { // Numbers
        char -= 48 - 52;
      } 

      var uvY:Int = Std.int(char / 13);
      var uvX:Int = char % 13;

      addQuad(new Vertex(vec3(i, 0, 0),
        vec2(uvX * CHAR_WIDTH, (uvY + 1) * CHAR_HEIGHT)),
        new Vertex(vec3(i + 1, 0, 0),
          vec2((uvX + 1) * CHAR_WIDTH, (uvY + 1) * CHAR_HEIGHT)),
        new Vertex(vec3(i + 1, 1, 0),
          vec2((uvX + 1) * CHAR_WIDTH, uvY * CHAR_HEIGHT)),
        new Vertex(vec3(i, 1, 0), vec2(uvX * CHAR_WIDTH, uvY * CHAR_HEIGHT)));
    }
  }
}
