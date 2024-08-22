--- @class Faction
Faction = {}
Faction.__index = Faction


--- Creates a new faction.
--- @param name string the name of the faction
--- @param color table<number, number> the color of the faction
--- @return Faction the new faction
function Faction.new(name, color)
  local self = {
    name = name,
    color = color
  }
  setmetatable(self, Faction)
  return self
end