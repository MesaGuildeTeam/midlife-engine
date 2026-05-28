package recharge.midlife.hl;

import sdl.GL;

class FrameBufferHL {
  public var fbo:Framebuffer;
  public var rbo:Renderbuffer;

  public var colorTexture:Texture;
  public var normalTexture:Texture;
  public var positionTexture:Texture;
  public var specularTexture:Texture;

  var dimensions:Vec2;

  public function new() {
    // Frame Buffer
    fbo = GL.createFramebuffer();
    GL.bindFramebuffer(GL.FRAMEBUFFER, fbo);

    final width = 320;
    final height = 240;

    dimensions = vec2(width, height);

    // Generate Textures
    colorTexture = GL.createTexture();
    GL.bindTexture(GL.TEXTURE_2D, colorTexture);
    GL.texImage2D(GL.TEXTURE_2D, 0, GL.RGB16F, width, height, 0, GL.RGB,
      GL.FLOAT, null);
    GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, GL.NEAREST);
    GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, GL.NEAREST);
    GL.framebufferTexture2D(GL.FRAMEBUFFER, GL.COLOR_ATTACHMENT0,
      GL.TEXTURE_2D, colorTexture, 0);

    trace("Color Attachment 0:", GL.COLOR_ATTACHMENT0);

    normalTexture = GL.createTexture();
    GL.bindTexture(GL.TEXTURE_2D, normalTexture);
    GL.texImage2D(GL.TEXTURE_2D, 0, GL.RGB16F, width, height, 0, GL.RGB,
      GL.FLOAT, null);
    GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_S, GL.CLAMP_TO_EDGE);
    GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_T, GL.CLAMP_TO_EDGE);
    GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, GL.NEAREST);
    GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, GL.NEAREST);
    GL.framebufferTexture2D(GL.FRAMEBUFFER, 0x8CE1, GL.TEXTURE_2D,
      normalTexture, 0);

    positionTexture = GL.createTexture();
    GL.bindTexture(GL.TEXTURE_2D, positionTexture);
    GL.texImage2D(GL.TEXTURE_2D, 0, GL.RGB16F, width, height, 0, GL.RGB,
      GL.FLOAT, null);
    GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_S, GL.CLAMP_TO_EDGE);
    GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_T, GL.CLAMP_TO_EDGE);
    GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, GL.NEAREST);
    GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, GL.NEAREST);
    GL.framebufferTexture2D(GL.FRAMEBUFFER, 0x8CE2, GL.TEXTURE_2D,
      positionTexture, 0);

    specularTexture = GL.createTexture();
    GL.bindTexture(GL.TEXTURE_2D, specularTexture);
    GL.texImage2D(GL.TEXTURE_2D, 0, GL.RGB16F, width, height, 0, GL.RGB,
      GL.FLOAT, null);
    GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_S, GL.CLAMP_TO_EDGE);
    GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_T, GL.CLAMP_TO_EDGE);
    GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, GL.NEAREST);
    GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, GL.NEAREST);
    GL.framebufferTexture2D(GL.FRAMEBUFFER, 0x8CE3, GL.TEXTURE_2D,
      specularTexture, 0);

    // Render Buffer
    rbo = GL.createRenderbuffer();
    GL.bindRenderbuffer(GL.RENDERBUFFER, rbo);
    GL.renderbufferStorage(GL.RENDERBUFFER, GL.DEPTH_COMPONENT16, width,
      height);
    GL.framebufferRenderbuffer(GL.FRAMEBUFFER, GL.DEPTH_ATTACHMENT,
      GL.RENDERBUFFER, rbo);

    GL.bindFramebuffer(GL.FRAMEBUFFER, cast(0, Framebuffer));
    GL.bindRenderbuffer(GL.RENDERBUFFER, cast(0, Renderbuffer));
  }

  public function resize(width:Int, height:Int) {
    dimensions = vec2(width, height);

    // Bind the framebuffer to make changes
    GL.bindFramebuffer(GL.FRAMEBUFFER, fbo);

    // Resize color texture
    GL.bindTexture(GL.TEXTURE_2D, colorTexture);
    GL.texImage2D(GL.TEXTURE_2D, 0, GL.RGB16F, width, height, 0, GL.RGB,
      GL.FLOAT, null);

    // Resize normal texture
    GL.bindTexture(GL.TEXTURE_2D, normalTexture);
    GL.texImage2D(GL.TEXTURE_2D, 0, GL.RGB16F, width, height, 0, GL.RGB,
      GL.FLOAT, null);

    // Resize position texture
    GL.bindTexture(GL.TEXTURE_2D, positionTexture);
    GL.texImage2D(GL.TEXTURE_2D, 0, GL.RGB16F, width, height, 0, GL.RGB,
      GL.FLOAT, null);

    // Resize specular texture
    GL.bindTexture(GL.TEXTURE_2D, specularTexture);
    GL.texImage2D(GL.TEXTURE_2D, 0, GL.RGB16F, width, height, 0, GL.RGB,
      GL.FLOAT, null);

    // Resize renderbuffer
    GL.bindRenderbuffer(GL.RENDERBUFFER, rbo);
    GL.renderbufferStorage(GL.RENDERBUFFER, GL.DEPTH_COMPONENT16, width,
      height);

    // Unbind everything
    GL.bindFramebuffer(GL.FRAMEBUFFER, cast(0, Framebuffer));
    GL.bindRenderbuffer(GL.RENDERBUFFER, cast(0, Renderbuffer));
    GL.bindTexture(GL.TEXTURE_2D, cast(0, Texture));
  }

  public function getDimensions():Vec2 {
    return dimensions;
  }

  public function bind() {
    GL.bindFramebuffer(GL.FRAMEBUFFER, fbo);
    GL.bindRenderbuffer(GL.RENDERBUFFER, rbo);
  }

  public function unbind() {
    GL.bindFramebuffer(GL.FRAMEBUFFER, cast(0, Framebuffer));
    GL.bindRenderbuffer(GL.RENDERBUFFER, cast(0, Renderbuffer));
  }

  public function delete() {
    GL.deleteFramebuffer(fbo);
  }
}
