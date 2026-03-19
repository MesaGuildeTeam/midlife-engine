---
trigger: manual
---

language: "haxe"
dependencies:
  hints:
    - "Use the versions specified in haxelib.json"
    - "Use can use the github urls for to find documentation, or you can look in .haxelib for installed libraries"
  utest: "https://github.com/haxe-utest/utest"
  hlsdl: "https://github.com/HaxeFoundation/hashlink/tree/master/libs/sdl"
  format: "https://github.com/HaxeFoundation/format"
  vector-math: "https://github.com/haxiomic/vector-math"
codeStyle:
  hints:
    - "you can also look at hxformat.json for formatting rules, but I still specify the important ones here"
  indentation: 2
  lineLength: 80
