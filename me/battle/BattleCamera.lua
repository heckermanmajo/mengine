 --- @class ZoomLevel ENUM; allows to change render modes based on the zoom level.
---
--- the smaller the zoom level, the more detailed the rendering
---
--- @field public Mini number
--- @field public VerySmall number
--- @field public Small number
--- @field public Default number
--- @field public Big number
ZoomLevel = {
  Mini = "Mini",
  VerySmall = "VerySmall",
  Small = "Small",
  Default = "Default",
  Big = "Big",
  VeryBig = "VeryBig"
}

--- @class BattleCamera Singleton; Manages the camera in the battle; also contains teh cam state.
--- @field public zoom number The zoom level of the camera.
--- @field public x number The x position of the camera.
--- @field public y number The y position of the camera.
--- @field public zoom_level ZoomLevel The zoom level of the camera.
---
--- @field private zoom_factor number
--- @field private wasd_move_speed number
--- @field private mouse_middle_drag_speed number
--- @field private drag_padding number
--- @field private recenter_padding number
BattleCamera = {
  zoom = 1,
  x = 0,
  y = 0,
  zoom_level = ZoomLevel.Default,
  zoom_factor = 1,
  wasd_move_speed = 300,
  mouse_middle_drag_speed = 1,
  drag_padding = 10,
  recenter_padding = 10,
  last_mouse_x = 0,
  last_mouse_y = 0
}

--- Initializes the BattleCamera.
--- @param x number The x position of the camera at the start of the battle.
--- @param y number The y position of the camera at the start of the battle.
--- @return nil
function BattleCamera:init(x, y)
  self.x = x
  self.y = y
  self.last_mouse_x, self.last_mouse_y = love.mouse.getPosition()
end

function BattleCamera:draw_debug_infos(x, y)
  love.graphics.print("x: " .. self.x, x, y)
  love.graphics.print("y: " .. self.y, x, y + 20)
  love.graphics.print("zoom: " .. self.zoom, x, y + 40)
  love.graphics.print("zoom_factor: " .. self.zoom_factor, x, y + 60)
  -- print the zoom level
  love.graphics.print("zoom_level: " .. self.zoom_level, x, y + 80)

end

function BattleCamera:apply_zoom(screen_width, screen_height, direction)
  local MIN_ZOOM = 0.3
  local MAX_ZOOM = 6.0
  assert(direction == 1 or direction == -1, "direction must be 1 or -1")
  local zoom_delta = 0.1 * direction
  local old_zoom = self.zoom
  self.zoom = self.zoom + zoom_delta
  if self.zoom < MIN_ZOOM then self.zoom = MIN_ZOOM end
  if self.zoom > MAX_ZOOM then self.zoom = MAX_ZOOM end
  local new_zoom = self.zoom
  local screen_center = {
    x = screen_width / 2,
    y = screen_height / 2
  }
  local world_center_before = {
    x = (screen_center.x - self.x) / old_zoom + self.x,
    y = (screen_center.y - self.y) / old_zoom + self.y
  }
  local world_center_after = {
    x = (screen_center.x - self.x) / new_zoom + self.x,
    y = (screen_center.y - self.y) / new_zoom + self.y
  }
  self.x = self.x - (world_center_after.x - world_center_before.x)
  self.y = self.y - (world_center_after.y - world_center_before.y)
  self.zoom_factor = math.floor(self.zoom * 10)
  if self.zoom_factor <= 2 then self.zoom_factor = 32
  elseif self.zoom_factor <= 4 then self.zoom_factor = 16
  elseif self.zoom_factor <= 9 then self.zoom_factor = 8
  elseif self.zoom_factor == 10 then self.zoom_factor = 4
  elseif self.zoom_factor <= 19 then self.zoom_factor = 2
  elseif self.zoom_factor <= 40 then self.zoom_factor = 0.5
  elseif self.zoom_factor > 40 then self.zoom_factor = 0.1 end

  -- update the zoom level
  if self.zoom <= 0.6 then self.zoom_level = ZoomLevel.VeryBig
  elseif self.zoom <= 0.9 then self.zoom_level = ZoomLevel.Big
  elseif self.zoom <= 1.2 then self.zoom_level = ZoomLevel.Default
  elseif self.zoom <= 1.5 then self.zoom_level = ZoomLevel.Small
  elseif self.zoom <= 2.0 then self.zoom_level = ZoomLevel.VerySmall
  else self.zoom_level = ZoomLevel.Mini end

  self:recenter_camera_target_on_map(
    Battle.world_size_in_pixels,
    Battle.world_size_in_pixels,
    screen_width,
    screen_height
  )

  --[[-- zoom in towards the mouse position
  local mouse_x, mouse_y = love.mouse.getPosition()
  local old_world_mouse_x = (mouse_x / old_zoom) + self.x - (screen_width / 2 / old_zoom)
  local old_world_mouse_y = (mouse_y / old_zoom) + self.y - (screen_height / 2 / old_zoom)
  local new_world_mouse_x = (mouse_x / new_zoom) + self.x - (screen_width / 2 / new_zoom)
  local new_world_mouse_y = (mouse_y / new_zoom) + self.y - (screen_height / 2 / new_zoom)
  self.x = self.x - (new_world_mouse_x - old_world_mouse_x)
  self.y = self.y - (new_world_mouse_y - old_world_mouse_y)]]

end

--- @param dt number
--- @param world_width_in_pixel number
--- @param world_height_in_pixels number
--- @param screen_width number
--- @param screen_height number
--- @param use_wasd boolean
--- @param use_arrow_keys boolean
function BattleCamera:apply_camera_movement(
  dt,
  world_width_in_pixel,
  world_height_in_pixels,
  screen_width,
  screen_height,
  use_wasd,
  use_arrow_keys
)

  --[[

    { // move_camera_with_wasd_block
      var speed = zoom_factor * wasd_move_speed * dt;
      if (use_wasd) {
        if (Raylib.IsKeyDown(KeyboardKey.D)) cam.Target.X += speed;
        if (Raylib.IsKeyDown(KeyboardKey.A)) cam.Target.X -= speed;
        if (Raylib.IsKeyDown(KeyboardKey.W)) cam.Target.Y -= speed;
        if (Raylib.IsKeyDown(KeyboardKey.S)) cam.Target.Y += speed;
      }
      if (use_arrow_keys) {
        if (Raylib.IsKeyDown(KeyboardKey.Right)) cam.Target.X += speed;
        if (Raylib.IsKeyDown(KeyboardKey.Left)) cam.Target.X -= speed;
        if (Raylib.IsKeyDown(KeyboardKey.Up)) cam.Target.Y -= speed;
        if (Raylib.IsKeyDown(KeyboardKey.Down)) cam.Target.Y += speed;
      }
    }
  ]]

  -- move_camera_with_wasd_block
  do
    local speed = self.zoom_factor * self.wasd_move_speed * dt
    if use_wasd then
      if love.keyboard.isDown("d") then self.x = self.x + speed end
      if love.keyboard.isDown("a") then self.x = self.x - speed end
      if love.keyboard.isDown("w") then self.y = self.y - speed end
      if love.keyboard.isDown("s") then self.y = self.y + speed end
    end
    if use_arrow_keys then
      if love.keyboard.isDown("right") then self.x = self.x + speed end
      if love.keyboard.isDown("left") then self.x = self.x - speed end
      if love.keyboard.isDown("up") then self.y = self.y - speed end
      if love.keyboard.isDown("down") then self.y = self.y + speed end
    end
  end

  local padding = 1000
  if self.x > world_width_in_pixel - screen_width / self.zoom + padding then
    self.x = world_width_in_pixel - screen_width / self.zoom + padding
  end
  if self.y > world_height_in_pixels - screen_height / self.zoom + padding then
    self.y = world_height_in_pixels - screen_height / self.zoom + padding
  end
  if self.x < -padding then self.x = -padding end
  if self.y < -padding then self.y = -padding end


  if true then return end -- TODO: remove this line
  --[[
      { // move_world_with_mouse_middle_drag
      if (Raylib.IsMouseButtonDown(MouseButton.Middle)) {
        var mouseDelta = Raylib.GetMouseDelta();
        cam.Target.X +=
          mouseDelta.X * dt * mouse_middle_drag_speed * cam.Zoom;
        cam.Target.Y +=
          mouseDelta.Y * dt * mouse_middle_drag_speed + cam.Zoom;
        if (cam.Target.X < -drag_padding) cam.Target.X = -drag_padding;
        if (cam.Target.Y < -drag_padding) cam.Target.Y = -drag_padding;
      }
    }
  ]]

  -- move_world_with_mouse_middle_drag
  do
    if love.mouse.isDown(2) then
      local mouse_x, mouse_y = love.mouse.getPosition()
      local mouse_delta_x = mouse_x - self.last_mouse_x
      local mouse_delta_y = mouse_y - self.last_mouse_y
      self.x = self.x + mouse_delta_x * dt * self.mouse_middle_drag_speed * self.zoom
      self.y = self.y + mouse_delta_y * dt * self.mouse_middle_drag_speed * self.zoom
      if self.x < -self.drag_padding then self.x = -self.drag_padding end
      if self.y < -self.drag_padding then self.y = -self.drag_padding end
      self.last_mouse_x, self.last_mouse_y = mouse_x, mouse_y
    end
  end

end


function BattleCamera:recenter_camera_target_on_map(world_width_in_pixel, world_height_in_pixels, screen_width, screen_height)
  if self.x > world_width_in_pixel - screen_width / self.zoom + self.recenter_padding then
    self.x = world_width_in_pixel - screen_width / self.zoom + self.recenter_padding
  end
  if self.y > world_height_in_pixels - screen_height / self.zoom + self.recenter_padding then
    self.y = world_height_in_pixels - screen_height / self.zoom + self.recenter_padding
  end
  if self.x < -self.recenter_padding then self.x = -self.recenter_padding end
  if self.y < -self.recenter_padding then self.y = -self.recenter_padding end
end

--- Checks if a position is within the viewport considering the zoom, camera movement, and padding.
--- @param x number The x position.
--- @param y number The y position.lua language server

--- @param screen_width number The width of the screen.
--- @param screen_height number The height of the screen.
--- @param padding number The padding around the viewport.
--- @return boolean Whether the position is within the viewport.
function BattleCamera:position_in_viewport(x, y, screen_width, screen_height, padding)
  -- apply zoom and camera movement
  x = (x - self.x) * self.zoom
  y = (y - self.y) * self.zoom
  padding = padding * self.zoom

  -- check if position is within the viewport considering the padding
  return (
    x >= -padding
      and x <= screen_width + padding
      and y >= -padding
      and y <= screen_height + padding
  )
end
