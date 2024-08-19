--- @class UnitFrameRow
--- @field start_y number
--- @field size_in_pixel number
--- @field frames number
--- @field frames_as_quads table<number, love.graphics.Quad>
--- @field texture_based_x_correction number
--- @field texture_based_y_correction number

-- we know the height and the width of these tilesets
local width_of_frame_atlas = 1152
local height_of_frame_atlas = 3712
local start_y = 0
--- Create the next frame row based on the given size and frames and
--- the upvalue in which the start_y is stored of all the previous rows.
--- @param size number
--- @param frames number
--- @return UnitFrameRow
local function next_frame_row(size, frames, texture_based_x_correction, texture_based_y_correction,
                              do_not_generate_quads)
  local row = {
    start_y = start_y,
    size_in_pixel = size,
    frames = frames,
    frames_as_quads = {},
    texture_based_x_correction = texture_based_x_correction or 0,
    texture_based_y_correction = texture_based_y_correction or 0
  }
  if not do_not_generate_quads then
    local start_x_of_quad = 0
    for i = 0, frames - 1 do
      start_x_of_quad = i * size
      table.insert(
        row.frames_as_quads,
        love.graphics.newQuad(start_x_of_quad, start_y, size, size, width_of_frame_atlas, height_of_frame_atlas)
      )
    end
  end
  start_y = start_y + size
  return row
end
--- This table contains all needed quads to create the unit animations from the
--- Sprite generator tool.
--- LINK:  https://sanderfrenken.github.io/Universal-LPC-Spritesheet-Character-Generator/#?body=Humanlike_white
--- @type table<string, UnitFrameRow>
SpriteGeneratorFrameAtlasQuad = {
  top_cast = next_frame_row(64, 7, 16, 32),
  left_cast = next_frame_row(64, 7, 16, 32),
  bottom_cast = next_frame_row(64, 7, 16, 32),
  right_cast = next_frame_row(64, 7, 16, 32),

  top_lance = next_frame_row(64, 8, 16, 32),
  left_lance = next_frame_row(64, 8, 16, 32),
  bottom_lance = next_frame_row(64, 8, 16, 32),
  right_lance = next_frame_row(64, 8, 16, 32),

  top_walk = next_frame_row(64, 9, 16, 32),
  left_walk = next_frame_row(64, 9, 16, 32),
  bottom_walk = next_frame_row(64, 9, 16, 32),
  right_walk = next_frame_row(64, 9, 16, 32),

  top_slap = next_frame_row(64, 6, 16, 32),
  left_slap = next_frame_row(64, 6, 16, 32),
  bottom_slap = next_frame_row(64, 6, 16, 32),
  right_slap = next_frame_row(64, 6, 16, 32),

  top_bow = next_frame_row(64, 13, 16, 32),
  left_bow = next_frame_row(64, 13, 16, 32),
  bottom_bow = next_frame_row(64, 13, 16, 32),
  right_bow = next_frame_row(64, 13, 16, 32),

  die = next_frame_row(64, 6, 16, 32),

  __ignore__ = next_frame_row(64 * 25, 1, 16, 32+64,true),

  big_swing_top = next_frame_row(64 * 3, 6, 16+64, 32+64),
  big_swing_left = next_frame_row(64 * 3, 6, 16+64, 32+64),
  big_swing_bottom = next_frame_row(64 * 3, 6, 16+64, 32+64),
  big_swing_right = next_frame_row(64 * 3, 6, 16+64, 32+64),
}
