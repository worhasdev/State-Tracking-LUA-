--[[ StateMachine.lua - finite state machine with enter/exit/update hooks
     Author: Bhavish Krish Purgaus | License: MIT ]]
local SM = {}; SM.__index = SM

function SM.new(states, initial)
  local self = setmetatable({states = states, current = nil}, SM)
  if initial then self:Set(initial) end
  return self
end

function SM:Set(name, ...)
  assert(self.states[name], "Unknown state: " .. tostring(name))
  if name == self.current then return end
  local old = self.states[self.current]
  if old and old.exit then old.exit(self, name) end
  local prev = self.current; self.current = name
  local new = self.states[name]
  if new.enter then new.enter(self, prev, ...) end
end

function SM:Update(dt)
  local s = self.states[self.current]
  if s and s.update then s.update(self, dt) end
end

function SM:Is(name) return self.current == name end

return SM
