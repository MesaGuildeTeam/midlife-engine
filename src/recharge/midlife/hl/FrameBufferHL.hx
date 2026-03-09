package recharge.midlife.hl;

import sdl.GL;

class FrameBufferHL {
  public var fbo:Framebuffer;
  public var rbo:Renderbuffer;

  public var texture:Texture;
  
  public function new() {
    fbo = GL.createFramebuffer();
    GL.bindFramebuffer(GL.FRAMEBUFFER, fbo);
    texture = GL.createTexture();
    GL.bindTexture(GL.TEXTURE_2D, texture);

    GL.texImage2D(GL.TEXTURE_2D, 0, GL.RGB, 320, 240, 0, GL.RGB, GL.UNSIGNED_BYTE, null);
    GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, GL.LINEAR);
    GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, GL.LINEAR);

    GL.framebufferTexture2D(GL.FRAMEBUFFER, GL.COLOR_ATTACHMENT0, GL.TEXTURE_2D, texture, 0);

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

  public function getTexture():Texture {
    return texture;
  }
}
