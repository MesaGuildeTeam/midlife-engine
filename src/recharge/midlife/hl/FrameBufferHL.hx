package recharge.midlife.hl;

import sdl.GL;

class FrameBufferHL {
  public var fbo:Framebuffer;
  public var rbo:Renderbuffer;

  public var colorTexture:Texture;
  public var normalTexture:Texture;
  public var positionTexture:Texture;
  
  public function new() {
    // Frame Buffer
    fbo = GL.createFramebuffer();
    GL.bindFramebuffer(GL.FRAMEBUFFER, fbo);
    
    // Generate Textures
    colorTexture = GL.createTexture();
    GL.bindTexture(GL.TEXTURE_2D, colorTexture);
    GL.texImage2D(GL.TEXTURE_2D, 0, GL.RGB, 320, 240, 0, GL.RGB, GL.UNSIGNED_BYTE, null);
    GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, GL.NEAREST);
    GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, GL.NEAREST);
    GL.framebufferTexture2D(GL.FRAMEBUFFER, GL.COLOR_ATTACHMENT0, GL.TEXTURE_2D, colorTexture, 0);

    trace("Color Attachment 0:", GL.COLOR_ATTACHMENT0);

    normalTexture = GL.createTexture();
    GL.bindTexture(GL.TEXTURE_2D, normalTexture);
    GL.texImage2D(GL.TEXTURE_2D, 0, GL.RGB16F, 320, 240, 0, GL.RGB, GL.FLOAT, null);
    GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_S, GL.CLAMP_TO_EDGE);
    GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_T, GL.CLAMP_TO_EDGE);
    GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, GL.NEAREST);
    GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, GL.NEAREST);
    GL.framebufferTexture2D(GL.FRAMEBUFFER, 0x8CE1, GL.TEXTURE_2D, normalTexture, 0);

    positionTexture = GL.createTexture();
    GL.bindTexture(GL.TEXTURE_2D, positionTexture);
    GL.texImage2D(GL.TEXTURE_2D, 0, GL.RGB16F, 320, 240, 0, GL.RGB, GL.FLOAT, null);
    GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_S, GL.CLAMP_TO_EDGE);
    GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_T, GL.CLAMP_TO_EDGE);
    GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, GL.NEAREST);
    GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, GL.NEAREST);
    GL.framebufferTexture2D(GL.FRAMEBUFFER, 0x8CE2, GL.TEXTURE_2D, positionTexture, 0);

    // Render Buffer
    rbo = GL.createRenderbuffer();
    GL.bindRenderbuffer(GL.RENDERBUFFER, rbo);
    GL.renderbufferStorage(GL.RENDERBUFFER, GL.DEPTH_COMPONENT16, 320, 240);
    GL.framebufferRenderbuffer(GL.FRAMEBUFFER, GL.DEPTH_ATTACHMENT, GL.RENDERBUFFER, rbo);

    GL.bindFramebuffer(GL.FRAMEBUFFER, cast(0, Framebuffer));
    GL.bindRenderbuffer(GL.RENDERBUFFER, cast(0, Renderbuffer));
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
