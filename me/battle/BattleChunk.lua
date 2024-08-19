--- @class BattleChunk A chunk in the rts battle map; used for optimization and some gameplay(ai, ownership-mechanics).
--- @field tiles table<number, BattleTile>
--- @field tiles_as_lookup_table table<number, table<number, BattleTile>>
--- @field units table<number, Unit>
--- @field canvas love.graphics.Canvas
--- @field absolute_position table<number, number>
--- @field pixel_size_per_chunk number
BattleChunk = {}
BattleChunk.__index = BattleChunk

--- Creates a new BattleChunk.
---
--- if you want to load a chunk from a save game, use the load_from_save_game_data function
--- @see BattleChunk.load_from_save_game_data
---
--- @return BattleChunk the new BattleChunk
function BattleChunk.new(x_num, y_num)

  local pixel_size_per_chunk = Battle.tiles_size_in_pixels * Battle.chunk_size_in_tiles
  local absolute_position_x = x_num * pixel_size_per_chunk
  local absolute_position_y = y_num * pixel_size_per_chunk

  local self = {
    tiles = {},
    tiles_as_lookup_table = {},
    units = {}, -- units; is updated in the update loop, since the source of truth are the tiles
    visual_objects = {}, -- f.e. flowers
    effects = {}, -- f.e. fire
    non_movable_objects = {}, -- f.e. trees
    absolute_position = { x = absolute_position_x, y = absolute_position_y },
    pixel_size_per_chunk = pixel_size_per_chunk,
    canvas = love.graphics.newCanvas(pixel_size_per_chunk, pixel_size_per_chunk)
  }

  -- Populate the tiles table with BattleTile objects.
  do
    for x_num = 0, Battle.chunk_size_in_tiles-1 do
      for y_num = 0, Battle.chunk_size_in_tiles-1 do
        print("CREATE TILE: x_num: " .. x_num .. " y_num: " .. y_num)
        self.tiles[#self.tiles + 1] = BattleTile.new(
          x_num * Battle.tiles_size_in_pixels + absolute_position_x,
          y_num * Battle.tiles_size_in_pixels + absolute_position_y
        )
        if self.tiles_as_lookup_table[x_num] == nil then self.tiles_as_lookup_table[x_num] = {} end
        assert(self.tiles[#self.tiles])
        self.tiles_as_lookup_table[x_num][y_num] = self.tiles[#self.tiles]
      end
    end
  end

  setmetatable(self, BattleChunk)

  self:render_canvas()

  return self
end

--- Renders the not often updated elements of the chunk to the chunk canvas.
---
--- PERFORMANCE CRITICAL CODE.
---
--- @return nil
function BattleChunk:render_canvas()
  -- only units and effects are not rendered to the canvas
  -- since they are rendered on top of the canvas in the draw function
  -- because they are updated more frequently, so that it makes sense to render them on top

  -- we can also delay the canvas render action if the chunk is not in the viewport
  love.graphics.setCanvas(self.canvas)
  do
    love.graphics.clear(1, 1, 1, 1)
    love.graphics.setColor(1, 1, 1)

    local gras = Battle.tiles.gras
    for x = 0, self.pixel_size_per_chunk, Battle.tiles_size_in_pixels do
      for y = 0, self.pixel_size_per_chunk, Battle.tiles_size_in_pixels do
        love.graphics.draw(gras, x, y)
      end
    end
    -- draw each tile with a random color rect
    --[[for x_num = 0, Battle.chunk_size_in_tiles do
      for y_num = 0, Battle.chunk_size_in_tiles do
        love.graphics.setColor(math.random(), math.random(), math.random())
        love.graphics.rectangle(
          "fill",
          x_num * Battle.tiles_size_in_pixels,
          y_num * Battle.tiles_size_in_pixels,
          Battle.tiles_size_in_pixels,
          Battle.tiles_size_in_pixels
        )
      end
    end
    ]]

  end
  love.graphics.setCanvas()
end

--- Draws the chunk on the screen.
--- THIS IS PERFORMANCE CRITICAL CODE, so we dont create functions for each unit and visual object.
--- BUT DO THE RENDER LOGIC FOR THEM IN THIS FUNCTION AS WELL -> hope of faster jit compilation
--- @see BattleChunk:render_canvas uses a canvas to render the elements of the chunk that are not updated frequently
--- @return nil
function BattleChunk:draw()
  -- draw the canvas
  -- also draw all units
  -- draw all visual objects (fire, f.e.)
  -- also draw all projectiles

  -- draw my canvas
  love.graphics.draw(
    self.canvas,
    (self.absolute_position.x - BattleCamera.x) * BattleCamera.zoom,
    (self.absolute_position.y - BattleCamera.y) * BattleCamera.zoom,
    0,
    BattleCamera.zoom,
    BattleCamera.zoom
  )

  -- for now draw a rect and apply the camera
  love.graphics.setColor(0.5, 0.5, 0)
  love.graphics.rectangle(
    "line",
    (self.absolute_position.x - BattleCamera.x) * BattleCamera.zoom,
    (self.absolute_position.y - BattleCamera.y) * BattleCamera.zoom,
    self.pixel_size_per_chunk * BattleCamera.zoom,
    self.pixel_size_per_chunk * BattleCamera.zoom
  )
  love.graphics.setColor(1, 1, 1)
end

--- Returns the tile at the given pixel position.
--- CAN ERROR: Crashes if the tile does not exist.
--- @param x number x pixel coordinate
--- @param y number y pixel coordinate
--- @return BattleTile the tile at the given pixel position
function BattleChunk:get_tile(x, y)
  local x_num = math.floor((x - self.absolute_position.x) / Battle.tiles_size_in_pixels)
  local y_num = math.floor((y - self.absolute_position.y) / Battle.tiles_size_in_pixels)
  return self.tiles_as_lookup_table[x_num][y_num]
end

--- Loads the chunk from the save game data; sets its properties from the save game data.
---
--- If there is a problem with the save game data, this function logs this error and
--- returns a string with the error message.
---
--- @param save_game_data table<string, any> the save game data
--- @return nil|string nil if the chunk was loaded successfully, a string with the error message otherwise
function BattleChunk:load_from_save_game_data(save_game_data)
  -- load the entities
  -- load the tiles
  error("not implemented")
end


--- Updates this chunk: all units in it, all visual objects in it, all effects in it.
--- Is called by battle all 0.1 seconds, which means 10 times per second; since the
--- game runs at 30 fps, we have 3 frames to split the update logic.
function BattleChunk:update(dt)
  print("update chunk")
  for _, unit in pairs(self.units) do
    unit:update()
  end
end
