--- @class BattleTile
--- @field x_in_pixel number
--- @field y_in_pixel number
--- @field unit_opt Unit|nil
--- @field visual_object_opt VisualObject|nil
--- @field effect_opt Projectile|nil
--- @field non_movable_object_opt NonMovableObject|nil
--- @field neighbors table<number, BattleTile>
BattleTile = {}
BattleTile.__index = BattleTile

function BattleTile.new(x_in_pixel, y_in_pixel)
  local self = {
    x_in_pixel = x_in_pixel,
    y_in_pixel = y_in_pixel,
    unit_opt = nil,
    visual_object_opt = nil,
    effect_opt = nil,
    movable_terrain = true,
    non_movable_object_opt = nil,
    neighbors = {}
  }
  setmetatable(self, BattleTile)
  return self
end

--- We set all the neighbors of the tile, this way we can easily access them.
--- @return nil
function BattleTile:set_neighbor_tiles()

  local B = Battle

  print ("set_neighbor_tiles for tile: " .. self.x_in_pixel .. " " .. self.y_in_pixel)

  local half_size = B.tiles_size_in_pixels / 2
  local one_and_half_size = B.tiles_size_in_pixels + half_size

  self.neighbors["left"] = B:get_tile(self.x_in_pixel - half_size, self.y_in_pixel)
  self.neighbors["right"] = B:get_tile(self.x_in_pixel + one_and_half_size, self.y_in_pixel)
  self.neighbors["top"] = B:get_tile(self.x_in_pixel, self.y_in_pixel - half_size)
  self.neighbors["bottom"] = B:get_tile(self.x_in_pixel, self.y_in_pixel + one_and_half_size)
  self.neighbors["top_left"] = B:get_tile(self.x_in_pixel - half_size, self.y_in_pixel - half_size)
  self.neighbors["top_right"] = B:get_tile(self.x_in_pixel + one_and_half_size, self.y_in_pixel - half_size)
  self.neighbors["bottom_left"] = B:get_tile(self.x_in_pixel - half_size, self.y_in_pixel + one_and_half_size)
  self.neighbors["bottom_right"] = B:get_tile(self.x_in_pixel + one_and_half_size, self.y_in_pixel + one_and_half_size)

end

--- Returns true if the tile is free to be moved on.
--- @return boolean true if the tile is free to be moved on, false otherwise
function BattleTile:i_am_free_to_be_moved_on()
  return self.unit_opt == nil and self.non_movable_object_opt == nil and self.movable_terrain
end