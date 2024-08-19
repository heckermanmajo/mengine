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
require("battle/SpriteGeneratorFrameAtlasQuad")
require("battle/Unit")
require("battle/Battle")
require("battle/BattleTile")
require("battle/BattleChunk")
require("battle/BattleCamera")

local ScreenWidth
local ScreenHeight

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

  --print(#Battle:get_chunk_at_pixel(2,2).units)
  --os.exit()
end



function love.update(dt)

  Unit.static.frame_progression = Unit.static.frame_progression + dt

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
end

function love.keypressed(key)
  if key == "escape" then love.event.quit() end
end

-- mouse wheel zoom
function love.wheelmoved(x, y)
  print(y, "y")
  BattleCamera:apply_zoom(ScreenWidth, ScreenHeight, y)
end
