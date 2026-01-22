return {
  rose        = {
    0xfff6c4c4,
    0xffe79a9a,
    0xffa86464,
  },
  coral       = {
    0xfff4b894,
    0xffe0926d,
    0xffa35f3b,
  },
  amber       = {
    0xffefd391,
    0xffd9b56a,
    0xff9b7a3f,
  },
  cyan        = {
    0xff9ddcdc,
    0xff6ab9b9,
    0xff3e7f7f,
  },
  teal        = {
    0xff94d8b8,
    0xff64bfa0,
    0xff3c7b66,
  },
  azure       = {
    0xffa4c8f5,
    0xff6fa8f0,
    0xff466b9d,
  },
  indigo      = {
    0xffb3b5e6,
    0xff8487d8,
    0xff51549b,
  },
  moss        = {
    0xffb7d6a0,
    0xff8ab57a,
    0xff58774d,
  },
  olive       = {
    0xffd1c98c,
    0xffaaa162,
    0xff6e673b,
  },
  emerald     = {
    0xff9ce0b3,
    0xff6ec896,
    0xff3d825b,
  },
  sage        = {
    0xffc4d5c2,
    0xff99b19a,
    0xff667865,
  },
  mauve       = {
    0xffcdb2dc,
    0xffa982c3,
    0xff6f5590,
  },
  plum        = {
    0xffdeb3d1,
    0xffbd84ad,
    0xff7e5676,
  },
  iris        = {
    0xffb2b1e1,
    0xff8886c7,
    0xff59589a,
  },

  black       = 0xff000000,
  white       = 0xffffffff,

  soft_50     = 0xfff9f5f5,
  soft_100    = 0xffe7e2de,
  soft_200    = 0xffcfcac7,
  soft_300    = 0xffb7b3b0,
  soft_400    = 0xff9f9c99,
  soft_500    = 0xff878583,
  soft_600    = 0xff6f6d6c,
  soft_700    = 0xff575655,
  soft_800    = 0xff3f3f3e,
  soft_900    = 0xff272727,
  soft_950    = 0xff0f1010,

  transparent = 0x00000000,

  with_alpha  = function(color, alpha)
    if alpha > 1.0 or alpha < 0.0 then return color end
    return (color & 0x00ffffff) | (math.floor(alpha * 255.0) << 24)
  end,
}
