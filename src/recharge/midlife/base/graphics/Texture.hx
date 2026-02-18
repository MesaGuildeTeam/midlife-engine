/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package recharge.midlife.base.graphics;

enum TextureSlot {
  Diffuse;
  Diffuse2;
  Specular;
  Normal;
}

#if hl
typedef Texture = recharge.midlife.hl.TextureHL;
#else
typedef Texture = TextureAbstract;
#end
