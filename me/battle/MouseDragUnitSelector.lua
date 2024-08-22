
--- @class MouseDragUnitSelector
--- This class is used to select units with the mouse.
---
--- @field private current_drag_is_active boolean If the current drag is active; the user is dragging the mouse.
--- @field private drag_start_x number The x position of the start of the drag.
--- @field private drag_start_y number The y position of the start of the drag.
--- @field private current_drag_end_x number The x position of the end of the drag.
--- @field private current_drag_end_y number The y position of the end of the drag.
MouseDragUnitSelector = {
  current_drag_is_active = false,
  drag_start_x = 0,
  drag_start_y = 0,
  current_drag_end_x = 0,
  current_drag_end_y = 0,
}

--- This function is used to create a drag selection with the mouse and
--- then select all units in this selection.
--- Create a unit selection Event.
--- It is called in the update function of the battle.
--- @return nil
function MouseDragUnitSelector:update_drag_and_select_units_if_release()

  if love.mouse.isDown(1) then
    if not self.current_drag_is_active then
      self.drag_start_x, self.drag_start_y = love.mouse.getPosition()
      self.current_drag_is_active = true
    end
    self.current_drag_end_x, self.current_drag_end_y = love.mouse.getPosition()
  else
    if self.current_drag_is_active then
      self.current_drag_is_active = false
      local real_x1, real_y1 = BattleCamera:screen_to_world(self.drag_start_x, self.drag_start_y)
      local real_x2, real_y2 = BattleCamera:screen_to_world(self.current_drag_end_x, self.current_drag_end_y)
      local units = Battle:get_units_in_rectangle(real_x1, real_y1, real_x2, real_y2)
      Battle:handle_unit_selection(units)
    end
  end

end

--- This function is used to draw the mouse drag selection.
--- It is called in the draw function of the battle.
--- @return nil
function MouseDragUnitSelector:draw_mouse_drag_selection()
  if self.current_drag_is_active then
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle(
      "line",
      self.drag_start_x,
      self.drag_start_y,
      self.current_drag_end_x - self.drag_start_x,
      self.current_drag_end_y - self.drag_start_y
    )
  end
end