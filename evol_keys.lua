-- evol_keys.lua -- keysyms definitions
-- Copyright (C) 2008 Noé Falzon

-- This program is  free software:  you can redistribute it and/or modify it
-- under  the terms  of the  GNU General Public License  as published by the
-- Free Software Foundation, version 3 of the License.
--
-- This program  is  distributed  in the hope  that it will  be useful,  but
-- WITHOUT  ANY WARRANTY;  without  even the implied  warranty of MERCHANTA-
-- BILITY  or  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public
-- License for more details.
--
-- You should have received a copy of the  GNU General Public License  along
-- with this program. If not, see <http://www.gnu.org/licenses/>.

-- This is a direct translation of SDL's keysym definitions in SDL_keysym.h


-- the keyboard syms have been cleverly chosen to map to acsii
evol.key_unknown = 0
evol.key_first = 0
evol.key_backspace = 8
evol.key_tab = 9
evol.key_clear = 12
evol.key_return = 13
evol.key_pause = 19
evol.key_escape = 27
evol.key_space = 32
evol.key_exclaim = 33
evol.key_quotedbl = 34
evol.key_hash = 35
evol.key_dollar = 36
evol.key_ampersand = 38
evol.key_quote = 39
evol.key_leftparen = 40
evol.key_rightparen = 41
evol.key_asterisk = 42
evol.key_plus = 43
evol.key_comma = 44
evol.key_minus = 45
evol.key_period = 46
evol.key_slash = 47
evol.key_0 = 48
evol.key_1 = 49
evol.key_2 = 50
evol.key_3 = 51
evol.key_4 = 52
evol.key_5 = 53
evol.key_6 = 54
evol.key_7 = 55
evol.key_8 = 56
evol.key_9 = 57
evol.key_colon = 58
evol.key_semicolon = 59
evol.key_less = 60
evol.key_equals = 61
evol.key_greater = 62
evol.key_question = 63
evol.key_at = 64

-- skip uppercase letters

evol.key_leftbracket = 91
evol.key_backslash = 92
evol.key_rightbracket = 93
evol.key_caret = 94
evol.key_underscore = 95
evol.key_backquote = 96
evol.key_a = 97
evol.key_b = 98
evol.key_c = 99
evol.key_d = 100
evol.key_e = 101
evol.key_f = 102
evol.key_g = 103
evol.key_h = 104
evol.key_i = 105
evol.key_j = 106
evol.key_k = 107
evol.key_l = 108
evol.key_m = 109
evol.key_n = 110
evol.key_o = 111
evol.key_p = 112
evol.key_q = 113
evol.key_r = 114
evol.key_s = 115
evol.key_t = 116
evol.key_u = 117
evol.key_v = 118
evol.key_w = 119
evol.key_x = 120
evol.key_y = 121
evol.key_z = 122
evol.key_delete = 127
-- end of ascii mapped keysyms

-- international keyboard syms
evol.key_world_0 = 160 -- 0xa0
evol.key_world_1 = 161
evol.key_world_2 = 162
evol.key_world_3 = 163
evol.key_world_4 = 164
evol.key_world_5 = 165
evol.key_world_6 = 166
evol.key_world_7 = 167
evol.key_world_8 = 168
evol.key_world_9 = 169
evol.key_world_10 = 170
evol.key_world_11 = 171
evol.key_world_12 = 172
evol.key_world_13 = 173
evol.key_world_14 = 174
evol.key_world_15 = 175
evol.key_world_16 = 176
evol.key_world_17 = 177
evol.key_world_18 = 178
evol.key_world_19 = 179
evol.key_world_20 = 180
evol.key_world_21 = 181
evol.key_world_22 = 182
evol.key_world_23 = 183
evol.key_world_24 = 184
evol.key_world_25 = 185
evol.key_world_26 = 186
evol.key_world_27 = 187
evol.key_world_28 = 188
evol.key_world_29 = 189
evol.key_world_30 = 190
evol.key_world_31 = 191
evol.key_world_32 = 192
evol.key_world_33 = 193
evol.key_world_34 = 194
evol.key_world_35 = 195
evol.key_world_36 = 196
evol.key_world_37 = 197
evol.key_world_38 = 198
evol.key_world_39 = 199
evol.key_world_40 = 200
evol.key_world_41 = 201
evol.key_world_42 = 202
evol.key_world_43 = 203
evol.key_world_44 = 204
evol.key_world_45 = 205
evol.key_world_46 = 206
evol.key_world_47 = 207
evol.key_world_48 = 208
evol.key_world_49 = 209
evol.key_world_50 = 210
evol.key_world_51 = 211
evol.key_world_52 = 212
evol.key_world_53 = 213
evol.key_world_54 = 214
evol.key_world_55 = 215
evol.key_world_56 = 216
evol.key_world_57 = 217
evol.key_world_58 = 218
evol.key_world_59 = 219
evol.key_world_60 = 220
evol.key_world_61 = 221
evol.key_world_62 = 222
evol.key_world_63 = 223
evol.key_world_64 = 224
evol.key_world_65 = 225
evol.key_world_66 = 226
evol.key_world_67 = 227
evol.key_world_68 = 228
evol.key_world_69 = 229
evol.key_world_70 = 230
evol.key_world_71 = 231
evol.key_world_72 = 232
evol.key_world_73 = 233
evol.key_world_74 = 234
evol.key_world_75 = 235
evol.key_world_76 = 236
evol.key_world_77 = 237
evol.key_world_78 = 238
evol.key_world_79 = 239
evol.key_world_80 = 240
evol.key_world_81 = 241
evol.key_world_82 = 242
evol.key_world_83 = 243
evol.key_world_84 = 244
evol.key_world_85 = 245
evol.key_world_86 = 246
evol.key_world_87 = 247
evol.key_world_88 = 248
evol.key_world_89 = 249
evol.key_world_90 = 250
evol.key_world_91 = 251
evol.key_world_92 = 252
evol.key_world_93 = 253
evol.key_world_94 = 254
evol.key_world_95 = 255 -- 0xff

-- numeric keypad
evol.key_kp0 = 256
evol.key_kp1 = 257
evol.key_kp2 = 258
evol.key_kp3 = 259
evol.key_kp4 = 260
evol.key_kp5 = 261
evol.key_kp6 = 262
evol.key_kp7 = 263
evol.key_kp8 = 264
evol.key_kp9 = 265
evol.key_kp_period = 266
evol.key_kp_divide = 267
evol.key_kp_multiply = 268
evol.key_kp_minus = 269
evol.key_kp_plus = 270
evol.key_kp_enter = 271
evol.key_kp_equals = 272

-- arrows + home/end pad
evol.key_up = 273
evol.key_down = 274
evol.key_right = 275
evol.key_left = 276
evol.key_insert = 277
evol.key_home = 278
evol.key_end = 279
evol.key_pageup = 280
evol.key_pagedown = 281

-- function keys
evol.key_f1 = 282
evol.key_f2 = 283
evol.key_f3 = 284
evol.key_f4 = 285
evol.key_f5 = 286
evol.key_f6 = 287
evol.key_f7 = 288
evol.key_f8 = 289
evol.key_f9 = 290
evol.key_f10 = 291
evol.key_f11 = 292
evol.key_f12 = 293
evol.key_f13 = 294
evol.key_f14 = 295
evol.key_f15 = 296

-- key state modifier keys
evol.key_numlock = 300
evol.key_capslock = 301
evol.key_scrollock = 302
evol.key_rshift = 303
evol.key_lshift = 304
evol.key_rctrl = 305
evol.key_lctrl = 306
evol.key_ralt = 307
evol.key_lalt = 308
evol.key_rmeta = 309
evol.key_lmeta = 310
evol.key_lsuper = 311
evol.key_rsuper = 312
evol.key_mode = 313
evol.key_compose = 314

-- miscellaneous function keys
evol.key_help = 315
evol.key_print = 316
evol.key_sysreq = 317
evol.key_break = 318
evol.key_menu = 319
evol.key_power = 320 -- power macintosh power key
evol.key_euro = 321 -- some european keyboards
evol.key_undo = 322 -- atari keyboard has undo
