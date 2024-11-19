local math_min = math.min
local math_max = math.max
local math_floor = math.floor
local draw_text = rendering.draw_text

--- @param entity LuaEntity
local function get_recipe_time(entity)
  if not (entity and entity.valid) then
    return false
  end

  local r = false
  if entity.type == 'furnace' then
    local r = entity.previous_recipe
  else
    r =  entity.get_recipe()
  end
  return r and r.valid and r.energy or false
end

local function setup()
  storage.enabled = false --[[as bool|number]]
end

-- storage.enabled acts strange, it could be 'boolean' or 'number' (true, false, tick)
-- When it transitions from 'true' to 'false', it becomes 'tick' until a full cycle is exhausted,
-- then it becomes false until turned on again.
-- Compressing its behavior to 1 var at 'on_toggle' simplifies the conditions to be checked at 'on_tick'
--- @param player_index uint
--- @param prototype_name string
--- @param name defines.events.on_lua_shortcut
--- @param tick uint
local function on_toggle(event)
  if (event.input_name or event.prototype_name) ~= 'fet_shortcut' then return end

  if storage.enabled == true then storage.enabled = event.tick
  else storage.enabled = true end

  for _, player in pairs(game.players) do
    player.set_shortcut_toggled('fet_shortcut', storage.enabled == true)
  end
end

--- @param unit FETUnit
--- @param tick uint
local function update_stats(unit, tick)
  local entity = unit.entity
  if not (entity and entity.valid) then
    return
  end
  if not unit.recipe_time then
    unit.recipe_time = get_recipe_time(entity)
  end
  local time = unit.recipe_time
  if not time then return end -- no recipe set

  local count = entity.products_finished or 0
  local ratio = (time * 60 * count) / (tick - unit.tick) / (1 + entity.productivity_bonus) / entity.crafting_speed
  ratio = math_min(ratio, 1)
  ratio = math_max(ratio, 0)
  unit.ratio = ratio

  -- init render
  if not unit.render then
    unit.render = draw_text({
      text = tostring(math_floor(ratio * 100)),
      color = { r = 0, g = 0, b = 0, a = 0.3 },
      target = entity.position,
      surface = entity.surface,
      visible = false,
    })
  end
end

--- @param render LuaRenderObject
local function update_render(render, p)
  if not (render and render.valid) or not p then return end
  render.visible = true
  render.text = tostring(math_floor(p * 100))
  render.color = { r = 1 - p, g = p, b = 0, a = 1 }
end

--- @param render LuaRenderObject
local function remove_render(render)
  if not (render and render.valid) then return end
  render.visible = false
end

--- @param name defines.events.on_tick
--- @param tick uint
local function on_tick(event)
  if not storage.enabled then return end

  local tick = event.tick
  if storage.enabled ~= true and tick - storage.enabled > FET_UPDATE_INTERVAL then
    storage.enabled = false
    return
  end

  local bucket_index = tick % FET_UPDATE_INTERVAL
  local bucket = storage.schedule[bucket_index]
  if not bucket then return end

  if storage.enabled == true then
    for id, unit in pairs(bucket) do
      if unit.entity and unit.entity.valid then
        update_stats(unit, tick)
        update_render(unit.render, unit.ratio)
      else
        bucket[id] = nil
      end
    end
  else
    for _, unit in pairs(bucket) do
      remove_render(unit.render)
    end
  end
end

--=================================================================================================

---@type ScriptLib
local Stats = {}

Stats.events = {
  [defines.events.on_lua_shortcut] = on_toggle,
  [defines.events.on_tick] = on_tick
}

return Stats