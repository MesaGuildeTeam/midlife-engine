package recharge.midlife.js;

import js.html.webgl.GL2;
import js.html.webgl.Framebuffer;
import js.html.webgl.Renderbuffer;
import js.html.webgl.Texture;

class FrameBufferJS {
  public var fbo:Framebuffer;
  public var rbo:Renderbuffer;

  public var colorTexture:Texture;
  public var normalTexture:Texture;
  public var positionTexture:Texture;
  public var specularTexture:Texture;

  var dimensions:Vec2;

  static var GL:GL2;

  public function new(gl:GL2) {
    GL = gl;

    // Frame Buffer
    fbo = GL.createFramebuffer();
    GL.bindFramebuffer(GL2.FRAMEBUFFER, fbo);

    final width = 320;
    final height = 240;

    dimensions = vec2(width, height);

    // Generate Textures
    colorTexture = GL.createTexture();
    GL.bindTexture(GL2.TEXTURE_2D, colorTexture);
    GL.texImage2D(GL2.TEXTURE_2D, 0, GL2.RGBA16F, width, height, 0, GL2.RGBA,
      GL2.FLOAT, null);
    GL.texParameteri(GL2.TEXTURE_2D, GL2.TEXTURE_MIN_FILTER, GL2.NEAREST);
    GL.texParameteri(GL2.TEXTURE_2D, GL2.TEXTURE_MAG_FILTER, GL2.NEAREST);
    GL.framebufferTexture2D(GL2.FRAMEBUFFER, GL2.COLOR_ATTACHMENT0,
      GL2.TEXTURE_2D, colorTexture, 0);

    trace("Color Attachment 0:", GL2.COLOR_ATTACHMENT0);

    normalTexture = GL.createTexture();
    GL.bindTexture(GL2.TEXTURE_2D, normalTexture);
    GL.texImage2D(GL2.TEXTURE_2D, 0, GL2.RGBA16F, width, height, 0, GL2.RGBA,
      GL2.FLOAT, null);
    GL.texParameteri(GL2.TEXTURE_2D, GL2.TEXTURE_WRAP_S, GL2.CLAMP_TO_EDGE);
    GL.texParameteri(GL2.TEXTURE_2D, GL2.TEXTURE_WRAP_T, GL2.CLAMP_TO_EDGE);
    GL.texParameteri(GL2.TEXTURE_2D, GL2.TEXTURE_MIN_FILTER, GL2.NEAREST);
    GL.texParameteri(GL2.TEXTURE_2D, GL2.TEXTURE_MAG_FILTER, GL2.NEAREST);
    GL.framebufferTexture2D(GL2.FRAMEBUFFER, 0x8CE1, GL2.TEXTURE_2D,
      normalTexture, 0);

    positionTexture = GL.createTexture();
    GL.bindTexture(GL2.TEXTURE_2D, positionTexture);
    GL.texImage2D(GL2.TEXTURE_2D, 0, GL2.RGBA16F, width, height, 0, GL2.RGBA,
      GL2.FLOAT, null);
    GL.texParameteri(GL2.TEXTURE_2D, GL2.TEXTURE_WRAP_S, GL2.CLAMP_TO_EDGE);
    GL.texParameteri(GL2.TEXTURE_2D, GL2.TEXTURE_WRAP_T, GL2.CLAMP_TO_EDGE);
    GL.texParameteri(GL2.TEXTURE_2D, GL2.TEXTURE_MIN_FILTER, GL2.NEAREST);
    GL.texParameteri(GL2.TEXTURE_2D, GL2.TEXTURE_MAG_FILTER, GL2.NEAREST);
    GL.framebufferTexture2D(GL2.FRAMEBUFFER, 0x8CE2, GL2.TEXTURE_2D,
      positionTexture, 0);

    specularTexture = GL.createTexture();
    GL.bindTexture(GL2.TEXTURE_2D, specularTexture);
    GL.texImage2D(GL2.TEXTURE_2D, 0, GL2.RGBA16F, width, height, 0, GL2.RGBA,
      GL2.FLOAT, null);
    GL.texParameteri(GL2.TEXTURE_2D, GL2.TEXTURE_WRAP_S, GL2.CLAMP_TO_EDGE);
    GL.texParameteri(GL2.TEXTURE_2D, GL2.TEXTURE_WRAP_T, GL2.CLAMP_TO_EDGE);
    GL.texParameteri(GL2.TEXTURE_2D, GL2.TEXTURE_MIN_FILTER, GL2.NEAREST);
    GL.texParameteri(GL2.TEXTURE_2D, GL2.TEXTURE_MAG_FILTER, GL2.NEAREST);
    GL.framebufferTexture2D(GL2.FRAMEBUFFER, 0x8CE3, GL2.TEXTURE_2D,
      specularTexture, 0);

    // Render Buffer
    rbo = GL.createRenderbuffer();
    GL.bindRenderbuffer(GL2.RENDERBUFFER, rbo);
    GL.renderbufferStorage(GL2.RENDERBUFFER, GL2.DEPTH_COMPONENT16, width,
      height);
    GL.framebufferRenderbuffer(GL2.FRAMEBUFFER, GL2.DEPTH_ATTACHMENT,
      GL2.RENDERBUFFER, rbo);

    GL.bindFramebuffer(GL2.FRAMEBUFFER, null);
    GL.bindRenderbuffer(GL2.RENDERBUFFER, null);
  }

  public function resize(width:Int, height:Int) {
    dimensions = vec2(width, height);

    // Bind the framebuffer to make changes
    GL.bindFramebuffer(GL2.FRAMEBUFFER, fbo);

    // Resize color texture
    GL.bindTexture(GL2.TEXTURE_2D, colorTexture);
    GL.texImage2D(GL2.TEXTURE_2D, 0, GL2.RGBA16F, width, height, 0, GL2.RGBA,
      GL2.FLOAT, null);

    // Resize normal texture
    GL.bindTexture(GL2.TEXTURE_2D, normalTexture);
    GL.texImage2D(GL2.TEXTURE_2D, 0, GL2.RGBA16F, width, height, 0, GL2.RGBA,
      GL2.FLOAT, null);

    // Resize position texture
    GL.bindTexture(GL2.TEXTURE_2D, positionTexture);
    GL.texImage2D(GL2.TEXTURE_2D, 0, GL2.RGBA16F, width, height, 0, GL2.RGBA,
      GL2.FLOAT, null);

    // Resize specular texture
    GL.bindTexture(GL2.TEXTURE_2D, specularTexture);
    GL.texImage2D(GL2.TEXTURE_2D, 0, GL2.RGBA16F, width, height, 0, GL2.RGBA,
      GL2.FLOAT, null);

    // Resize renderbuffer
    GL.bindRenderbuffer(GL2.RENDERBUFFER, rbo);
    GL.renderbufferStorage(GL2.RENDERBUFFER, GL2.DEPTH_COMPONENT16, width,
      height);

    // Unbind everything
    GL.bindFramebuffer(GL2.FRAMEBUFFER, null);
    GL.bindRenderbuffer(GL2.RENDERBUFFER, null);
    GL.bindTexture(GL2.TEXTURE_2D, null);
  }

  public function getDimensions():Vec2 {
    return dimensions;
  }

  public function bind() {
    GL.bindFramebuffer(GL2.FRAMEBUFFER, fbo);
    GL.bindRenderbuffer(GL2.RENDERBUFFER, rbo);
  }

  public function unbind() {
    GL.bindFramebuffer(GL2.FRAMEBUFFER, null);
    GL.bindRenderbuffer(GL2.RENDERBUFFER, null);
  }

  public function delete() {
    GL.deleteFramebuffer(fbo);
  }
}
