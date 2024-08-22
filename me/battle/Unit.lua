--- @class Unit
--- @field x number
--- @field y number
--- @field current_frame number
--- @field current_max_frame number
--- @field current_animation string
--- @field facing string
--- @field mode string
--- @field tile_atlas_image love.graphics.Image
--- @field steps_to_do_x number
--- @field steps_to_do_y number
--- @field tile_i_am_on BattleTile
--- @field path table<number, string>
Unit = {}
Unit.__index = Unit

--- Creates a new unit at the given pixel position.
--- @param x number
--- @param y number
--- @return Unit the new unit
function Unit.new(x, y)
  local self = {
    x = x,
    y = y,
    current_frame = 1,
    current_animation = "big_swing_bottom",
    facing = "right",
    mode = "idle",
    tile_atlas_image = Battle.unit_atlases.unit,
    steps_to_do_x = 0,
    steps_to_do_y = 0,
    tile_i_am_on = nil,
    path = {}
  }

  -- todo: register unit in chunk here, try to set me on a free tile
  local my_chunk = Battle:get_chunk_at_pixel(x, y)
  table.insert(my_chunk.units, self)
  self.tile_i_am_on = my_chunk:get_tile(x, y)
  assert(self.tile_i_am_on)
  assert(self.tile_i_am_on.unit_opt == nil)
  self.tile_i_am_on.unit_opt = self

  setmetatable(self, Unit)
  return self
end

--- Draws the unit to the screen based on the current frame and animation.
function Unit:draw()
  local bc = BattleCamera
  local animation_row = SpriteGeneratorFrameAtlasQuad[self.current_animation]
  local quad = animation_row.frames_as_quads[self.current_frame]
  local texture_based_x_correction = animation_row.texture_based_x_correction
  local texture_based_y_correction = animation_row.texture_based_y_correction
  local draw_x = (self.x - texture_based_x_correction)
  local draw_y = (self.y - texture_based_y_correction)
  local view_x = (draw_x - bc.x) * bc.zoom
  local view_y = (draw_y - bc.y) * bc.zoom
  love.graphics.draw(
    self.tile_atlas_image, quad, view_x, view_y, 0, bc.zoom, bc.zoom)

  -- todo: this does not need to be always drawn ...
  -- draw rect at real position
  love.graphics.setColor(1, 0, 0)
  love.graphics.rectangle(
    "line",
    (self.x - bc.x) * bc.zoom,
    (self.y - bc.y) * bc.zoom,
    32 * bc.zoom,
    32 * bc.zoom
  )
  love.graphics.setColor(1, 1, 1)
end

--- @region Unit:update()
local step_size = 3 -- used in Unit:update
--- This function updates the unit. This means do steps, fight and also change the frame.
--- This is called every 0.1 seconds; all 3 frames;
function Unit:update()

  -- update the frame; no matter what animation is played
  do
    -- The first frame is the idle animation.
    if self.mode == "idle" then
      self.current_frame = 1
    else
      local max_frame = SpriteGeneratorFrameAtlasQuad[self.current_animation].frames
      self.current_frame = self.current_frame + 1
      if self.current_frame > max_frame then self.current_frame = 1 end
    end
  end

  -- A unit can only fight if it stands still. The most important action is
  -- to walk a unit to its destination tile. All other actions are secondary to movement.
  -- This ensures a simple basis for all other algorithms.
  local there_are_steps_to_do = self.steps_to_do_x ~= 0 or self.steps_to_do_y ~= 0
  -- todo: i need to disable this for now, since the pathfinder fucks up...
  --assert(
  --  not (self.steps_to_do_x ~= 0 and self.steps_to_do_y ~= 0),
  --  "The unit is not allowed to move in two directions at the same time."
  -- )

  -- NOTE: The first frame is the idle animation.
  -- if the step size is 32 then update the animation to walking IF it is not already walking
  -- if we update the animation reset the current_frame to 1
  -- then walk a step
  -- if we reach the target ( 0 steps to do) then we look into the path-array and check if it is 0
  -- if so we set the animation to idle
  if there_are_steps_to_do then
    self:walk()
  else
    -- if there are not steps to do, do all the other logic

    -- check if i need to set my mode to idle if i was previously moving
    -- this is the case if i have no steps to do and no path to go
    -- and my mode is move
    do
      if #self.path == 0 and self.mode == "move" then self.mode = "idle" end
    end

    -- check here if a unit is attacked, soo if it is, it can pause the path
    -- and fight the enemy; this block needs to be before the pathfinding block
    do

    end


    -- do i need to go my path? This block checks if the unit
    -- needs to go to the next tile on its path
    do
      if #self.path ~= 0 then
        local next_tile = self.path[1]
        local next_tile_x = next_tile.x_in_pixel
        local next_tile_y = next_tile.y_in_pixel
        local current_tile_x = self.tile_i_am_on.x_in_pixel
        local current_tile_y = self.tile_i_am_on.y_in_pixel
        local possible_steps_to_do_x = next_tile_x - self.x
        local possible_steps_to_do_y = next_tile_y - self.y

        if next_tile_x > current_tile_x then
          self.current_animation = "right_walk"
          self.facing = "right"
        elseif next_tile_x < current_tile_x then
          self.current_animation = "left_walk"
          self.facing = "left"
        elseif next_tile_y > current_tile_y then
          self.current_animation = "bottom_walk"
          self.facing = "bottom"
        elseif next_tile_y < current_tile_y then
          self.current_animation = "top_walk"
          self.facing = "top"
        end

        -- try to move to the next tile
        local crash_if_not_possible = false
        if not self:try_move_to_tile_and_set_steps(self.facing, crash_if_not_possible) then
          -- if we cannot move to the next tile, we need to recalculate the path
          self.path = Pathfinder.get_path(self.x, self.y, next_tile_x, next_tile_y)
          if self.path == nil then
            -- we cannot reach the next tile
            self.path = {}
          end
        else
          -- we could move to the next tile
          table.remove(self.path, 1)
          self.steps_to_do_x = possible_steps_to_do_x
          self.steps_to_do_y = possible_steps_to_do_y
          self:walk()
        end
      end
    end

    -- do i look for enemies?
    do

    end

    -- do i fight
    do

    end

    -- do i work
    do

    end

    :: continue ::

  end -- if there_are_steps_to_do

end

--- Walks the unit one step in the direction of the steps_to_do_x and steps_to_do_y.
---
--- @return nil
function Unit:walk()
  -- if there are steps to do and we are not in move mode, set the mode to move
  if self.mode ~= "move" then
    self.mode = "move"
    self.current_animation = self.facing .. "_walk"
    self.current_frame = 1
  end

  if self.steps_to_do_x ~= 0 then

    if math.abs(self.steps_to_do_x) < step_size then
      self.x = self.x + self.steps_to_do_x
      self.steps_to_do_x = 0
    end

    if self.steps_to_do_x > 0 then
      -- We are moving to the right

      self.x = self.x + step_size
      self.steps_to_do_x = self.steps_to_do_x - step_size
    else
      -- We are moving to the left
      self.x = self.x - step_size
      self.steps_to_do_x = self.steps_to_do_x + step_size
    end
  end

  if self.steps_to_do_y ~= 0 then

    if math.abs(self.steps_to_do_y) < step_size then
      self.y = self.y + self.steps_to_do_y
      self.steps_to_do_y = 0
    end

    if self.steps_to_do_y > 0 then
      -- We are moving down
      self.y = self.y + step_size
      self.steps_to_do_y = self.steps_to_do_y - step_size
    else
      -- We are moving up
      self.y = self.y - step_size
      self.steps_to_do_y = self.steps_to_do_y + step_size
    end
  end
end

--- Tries to move the unit to the given tile and sets the steps to do.
--- If the tile is not free, the function returns false.
--- If the tile does not exist, the function returns false.
--- If crash_if_not_possible is set to true, the function crashes if the tile is not free or does not exist.
---
--- CAN ERROR: Crashes if the tile does not exist or is not free if crash_if_not_possible is set to true.
---
--- @param direction string "top", "bottom", "left", "right"
--- @param crash_if_not_possible boolean
---
--- @return boolean true if the unit could move to the tile, false otherwise
function Unit:try_move_to_tile_and_set_steps(direction, crash_if_not_possible)

  -- the unit need to be on a tile
  assert(self.x % 32 == 0, "The x position must be dividable by 32.")
  assert(self.y % 32 == 0, "The y position must be dividable by 32.")

  local tile

  if direction == "top" then tile = self.tile_i_am_on.neighbors["top"]
  elseif direction == "bottom" then tile = self.tile_i_am_on.neighbors["bottom"]
  elseif direction == "left" then tile = self.tile_i_am_on.neighbors["left"]
  elseif direction == "right" then tile = self.tile_i_am_on.neighbors["right"]
  else error("Unknown direction: " .. direction) end

  if tile == nil then
    if crash_if_not_possible then
      error("cannot move here: Tile does not exist.")
    else
      return false
    end
  end

  if not tile:i_am_free_to_be_moved_on() then
    if crash_if_not_possible then
      error("cannot move here: Tile is not free.")
    else
      return false
    end
  end

  -- set the steps to do; This steps will be done in the move function
  if direction == "top" then self.steps_to_do_y = -32
  elseif direction == "bottom" then self.steps_to_do_y = 32
  elseif direction == "left" then self.steps_to_do_x = -32
  elseif direction == "right" then self.steps_to_do_x = 32 end

  -- change the tile the unit is on; also update the tiles unit_opt field
  -- we dont need to update the units table in the chunks class, since the tile is the only and
  -- real source of truth; The chunk updates the units table itself.
  self.tile_i_am_on.unit_opt = nil
  self.tile_i_am_on = tile
  tile.unit_opt = self

  return true

end


function Unit:draw_path()
  for i, tile in ipairs(self.path) do
    love.graphics.setColor(0, 1, 0)
    love.graphics.rectangle(
      "line",
      (tile.x_in_pixel - BattleCamera.x) * BattleCamera.zoom,
      (tile.y_in_pixel - BattleCamera.y) * BattleCamera.zoom,
      32 * BattleCamera.zoom,
      32 * BattleCamera.zoom
    )
    -- another line so we can see it better
    love.graphics.rectangle(
      "line",
      (tile.x_in_pixel - BattleCamera.x) * BattleCamera.zoom + 1,
      (tile.y_in_pixel - BattleCamera.y) * BattleCamera.zoom + 1,
      32 * BattleCamera.zoom - 2,
      32 * BattleCamera.zoom - 2
    )
    love.graphics.setColor(1, 1, 1)
  end
end