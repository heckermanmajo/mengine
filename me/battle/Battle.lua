require("CONFIG")

--- @class Battle Contains all the state of the rts battle, except for BattleCamera
---
--- Battle manages its own resources like textures and sounds, this way we dont mix up the resources
--- for camp and menu with the battle ones. A little bit of redundancy is no problem.
---
--- @see BattleCamera
---
--- @field chunks table<number, BattleChunk> A list of all the chunks in the battle.
--- @field chunks_on_lookup_table table<number, table<number, BattleChunk>> A lookup table for the chunks on the num-x and num-y coordinates.
--- @field chunk_size_in_tiles number The size of a chunk in tiles.
--- @field tiles_size_in_pixels number The size of a tile in pixels.
--- @field world_size_in_pixels number The size of the world in pixels. The world is a square.
--- @field world_size_in_chunks number The size of the world in chunks. The world is a square.
--- @field tiles table<string, love.graphics.Image> A list of all the tiles in the battle.
Battle = {
  chunk_size_in_tiles = 0,
  tiles_size_in_pixels = 0,
  world_size_in_pixels = 0,
  world_size_in_chunks = 0,
  chunks = {},
  chunks_on_lookup_table = {},
  tiles = {
    gras = nil,
  },
}
Battle.__index = Battle

--- Loads all the resources for the battle; THis function should be called once at the start of the game.
--- Does NOT need to be called at the start of the battle.
function Battle:load_resources()
  self.tiles = {
    gras = love.graphics.newImage("assets/tiles/gras_debug.png"),
  }
  self.unit_atlases = {
    unit = love.graphics.newImage("assets/unit/unit.png"),
  }
end

--- Initializes the battle singleton; this function should be called once the battle starts.
--- @param chunk_size_in_tiles number The size of a chunk in tiles.
--- @param tiles_size_in_pixels number The size of a tile in pixels.
--- @param world_size_in_chunks number The size of the world in pixels. The world is a square.
--- @return nil
function Battle.init(
  chunk_size_in_tiles,
  tiles_size_in_pixels,
  world_size_in_chunks
)

  Battle.world_size_in_chunks = world_size_in_chunks
  -- this is needed since we split up the logic in 6 frames, updates everything all 0.2 seconds
  assert((world_size_in_chunks * world_size_in_chunks) % 6 == 0, "The world size must be dividable by 6.")
  Battle.chunk_size_in_tiles = chunk_size_in_tiles
  Battle.tiles_size_in_pixels = tiles_size_in_pixels
  Battle.world_size_in_pixels = Battle.chunk_size_in_tiles * Battle.tiles_size_in_pixels * Battle.world_size_in_chunks

  --region Create_Chunks
  do
    Battle.chunks = {}
    for x_num = 0, world_size_in_chunks - 1 do
      for y_num = 0, world_size_in_chunks - 1 do
        print("CREATE CHUNK: x_num: " .. x_num .. " y_num: " .. y_num)
        Battle.chunks[#Battle.chunks + 1] = BattleChunk.new(x_num, y_num)
        if Battle.chunks_on_lookup_table[x_num] == nil then Battle.chunks_on_lookup_table[x_num] = {} end
        Battle.chunks_on_lookup_table[x_num][y_num] = Battle.chunks[#Battle.chunks]
      end
    end
  end

  -- now we set all the neighbours of the tiles
  for _, chunk in ipairs(Battle.chunks) do
    for _, tile in ipairs(chunk.tiles) do
      tile:set_neighbor_tiles()
    end
  end

  --endregion

  BattleCamera:init(0, 0) -- later we can set this to the start-chunk of the player

end

--- Checks if the given pixel position is within the world bounds.
--- @param x number x pixel coordinate
--- @param y number y pixel coordinate
--- @return boolean true if the pixel position is within the world bounds, false otherwise
function Battle:in_world_bounds(x, y)
  return (
    x >= 0
      and x < self.world_size_in_pixels
      and y >= 0
      and y < self.world_size_in_pixels)
end

--- Sanitizes the given x pixel coordinate to be within the world bounds.
--- @param x number x pixel coordinate
--- @return number sanitized x pixel coordinate that is definitely within the world bounds
function Battle:sanitize_x(x)
  if x < 0 then return 0 end
  if x >= self.world_size_in_pixels then return self.world_size_in_pixels - 1 end
  return x
end

--- Sanitizes the given y pixel coordinate to be within the world bounds.
--- @param y number y pixel coordinate
--- @return number sanitized y pixel coordinate that is definitely within the world bounds
function Battle:sanitize_y(y)
  if y < 0 then return 0 end
  if y >= self.world_size_in_pixels then return self.world_size_in_pixels - 1 end
  return y
end

--- Returns the chunk at the given pixel position.
---
--- CAN ERROR: Crashes if the chunk does not exist.
---
--- @param x number x pixel coordinate
--- @param y number y pixel coordinate
--- @return BattleChunk the chunk at the given pixel position
function Battle:get_chunk_at_pixel(x, y)
  assert(Battle:in_world_bounds(x, y), "The pixel position is not within the world bounds.")
  local x_num = math.floor(x / (self.chunk_size_in_tiles * self.tiles_size_in_pixels))
  local y_num = math.floor(y / (self.chunk_size_in_tiles * self.tiles_size_in_pixels))
  return self.chunks_on_lookup_table[x_num][y_num]
end

--- Draws the battle
---
--- PERFORMANCE CRITICAL CODE.
---
--- @param dt number
--- @return nil
function Battle.draw(dt)

  local screen_width = love.graphics.getWidth()
  local screen_height = love.graphics.getHeight()

  for index = 1, #Battle.chunks do
    local chunk = Battle.chunks[index]
    local padding = 500
    local in_view = BattleCamera:position_in_viewport(
      chunk.absolute_position.x,
      chunk.absolute_position.y,
      screen_width,
      screen_height,
      padding
    )
    if in_view then
      chunk:draw(Battle, BattleCamera)
    end
  end

  do
    if CONFIG.debug then
      love.graphics.print("FPS: " .. love.timer.getFPS(), 10, 10)
      BattleCamera:draw_debug_infos(10, 30)
    end
  end

end


--- This function checks that the state of the battle singleton is correct.
--- It crashes if the state is not correct.
--- Each class should have a check function that we can run in debug mode.
---
--- CAN ERROR: Crashes if the state is not correct.
--- @return nil
function Battle.check() end

--- Returns the tile at the given pixel position.
--- CAN ERROR: Crashes if the tile does not exist.
--- @param x number x pixel coordinate
--- @param y number y pixel coordinate
--- @return BattleTile the tile at the given pixel position
function Battle:get_tile(x, y, crash_if_not_exist)
  if not self:in_world_bounds(x, y) then
    if crash_if_not_exist then
      assert(false, "The pixel position is not within the world bounds: " .. x .. " " .. y)
    end
    return nil
  end
  local chunk = self:get_chunk_at_pixel(x, y)
  assert(chunk, "The chunk does not exist.: " .. x .. " " .. y)
  local tile = chunk:get_tile(x, y)
  return tile
end

local update_frame_counter = 0
--- Updates the battle by calling all the battle systems.
--- PERFORMANCE CRITICAL CODE.
--- @param dt number
--- @return nil
function Battle:update(dt)

  --- @region Update 1/3 of the chunks per frame; All chunks are updated every 0.1 seconds.
  --- Units and stuff are split up by their location in the chunk.
  --- Therefore their update logic is split up by the chunks.
  do
    local chunks_to_update_this_step = #Battle.chunks / 3
    local start_index = update_frame_counter * chunks_to_update_this_step
    local end_index = start_index + chunks_to_update_this_step
    for index = start_index+1, end_index do
      local chunk = Battle.chunks[index]
      chunk:update(dt)
      print("UPDATE CHUNK: " .. chunk.absolute_position.x .. " " .. chunk.absolute_position.y)
    end
    update_frame_counter = update_frame_counter + 1
    if update_frame_counter == 3 then update_frame_counter = 0 end
  end
  --- @endregion

end

--- @class Projectile
Projectile = {}
Projectile.__index = Projectile

--- @class NonMovableObject
NonMovableObject = {}
NonMovableObject.__index = NonMovableObject

--- @class VisualObject
VisualObject = {}
VisualObject.__index = VisualObject

--- @class Effect
Effect = {}
Effect.__index = Effect

