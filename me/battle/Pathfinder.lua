Pathfinder = {}
Pathfinder.__index = Pathfinder

--- Returns a path from the given pixel position to the other pixel position.
---
---
--- @param from_x number x pixel coordinate
--- @param from_y number y pixel coordinate
--- @param to_x number x pixel coordinate
--- @param to_y number y pixel coordinate
---
--- @return table<number, BattleTile>|nil the path from the given pixel position to the other pixel position. Nil if no path is possible.
function Pathfinder.get_path(from_x, from_y, to_x, to_y)

  assert(Battle:in_world_bounds(from_x, from_y), "The from pixel position is not within the world bounds.: " .. from_x .. " " .. from_y)
  assert(Battle:in_world_bounds(to_x, to_y), "The to pixel position is not within the world bounds.: " .. to_x .. " " .. to_y)

  -- todo: use a-star instead of this simple pathfinder

  local from_tile = Battle:get_tile(from_x, from_y)
  local to_tile = Battle:get_tile(to_x, to_y)

  -- for now a straight line
  --- @type table<number, BattleTile>
  local path = {}
  local delta_x = to_tile.x_in_pixel - from_tile.x_in_pixel
  local delta_y = to_tile.y_in_pixel - from_tile.y_in_pixel

  local current_tile = from_tile

  while current_tile ~= to_tile do

    if delta_x > 0 then
      current_tile = current_tile.neighbors["right"]
      delta_x = delta_x - Battle.tiles_size_in_pixels
    elseif delta_x < 0 then
      current_tile = current_tile.neighbors["left"]
      delta_x = delta_x + Battle.tiles_size_in_pixels
    end

    if current_tile == nil then return nil end

    if delta_y > 0 then
      current_tile = current_tile.neighbors["bottom"]
      delta_y = delta_y - Battle.tiles_size_in_pixels
    elseif delta_y < 0 then
      current_tile = current_tile.neighbors["top"]
      delta_y = delta_y + Battle.tiles_size_in_pixels
    end

    if current_tile == nil then return nil end

    path[#path + 1] = current_tile

  end

  return path
end
