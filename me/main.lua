--[[
Wie machen wir das mit den threads?
-> wir müssen alle Daten über den channel senden, das kann kosten.
-> code struktur ist wichtig.
-> zoom level erlaubt uns weniger zu zeichnen
-> tile based combat
-> love ist das einzige env wo man nur an das game und die logik denkt


LUA LANGUAGE SERVER:
MAYBE: https://luals.github.io/


]]


local todos = {
  " Use Astar to navigte the unit",
  " Add unit fighting with animation",
  " Add place objects mode",
  " collide with objects",
  " if debug_pathfinding is enabled, draw the path as dots on top of the tiles",
  " Add unit working with animation",
}

require("battle/SpriteGeneratorFrameAtlasQuad")
require("battle/Unit")
require("battle/Battle")
require("battle/BattleTile")
require("battle/BattleChunk")
require("battle/BattleCamera")
require("battle/Pathfinder")

local ScreenWidth
local ScreenHeight

--- @type Unit
local unit

function love.load()

  ScreenWidth = love.graphics.getWidth()
  ScreenHeight = love.graphics.getHeight()

  Battle:load_resources()

  do
    local chunk_size_in_tiles = 3
    local tiles_size_in_pixels = 32
    local world_size_chunks = 6
    Battle.init(chunk_size_in_tiles, tiles_size_in_pixels, world_size_chunks)
  end

  unit = Unit.new(32, 32)
  --unit.path = Pathfinder.get_path(32, 32, 32, 200)

  --print(#Battle:get_chunk_at_pixel(2,2).units)
  --os.exit()
end

local todo_font = love.graphics.newFont(40)
local default_font = love.graphics.newFont(12)
--- This function draws a todo-list on front of a black screen.
--- The list is shown if the F1 key is pressed.
---
function todo()

  local start = 100
  -- get mouse key 4
  if love.mouse.isDown(4) then
    --if love.keyboard.isDown("f1") then
    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("TODO:", 10, 10)

    -- increase the font size
    love.graphics.setFont(todo_font)

    for i, todo in ipairs(todos) do
      love.graphics.print(todo, 10, start + i * 40)
    end

    -- reset the font size
    love.graphics.setFont(default_font)

  end

end

function love.update(dt)

  if #unit.path == 0 then
    unit.path = Pathfinder.get_path(unit.x, unit.y, math.random(32, 500), math.random(32, 500))
  end

  Battle:update(dt)
  --unit:update_frame()

  BattleCamera:apply_camera_movement(
    dt,
    Battle.world_size_in_pixels,
    Battle.world_size_in_pixels,
    love.graphics.getWidth(),
    love.graphics.getHeight(),
    true,
    true
  )

end

function love.draw()
  love.graphics.print("Hello World!", 400, 300)
  -- get fps
  Battle.draw(dt)

  unit:draw()

  todo()
end

function love.keypressed(key)
  if key == "escape" then love.event.quit() end
end

-- mouse wheel zoom
function love.wheelmoved(x, y)
  print(y, "y")
  BattleCamera:apply_zoom(ScreenWidth, ScreenHeight, y)
end
