--- @param entity LuaEntity
local function get_recipe_time(entity)
  if not entity then return false end
  local r = (entity.type == "furnace") and entity.previous_recipe or entity.get_recipe()
  return r and r.energy or false
end

local function box(selection_box, b)
  local lt = selection_box.left_top
  local rb = selection_box.right_bottom
  return {
    left_top = { 
      x = (lt.x or lt[1]) + b,
      y = (lt.y or lt[2]) + b
    },
    right_bottom = {
      x = (rb.x or rb[1]) - b,
      y = (rb.y or rb[2]) - b
    }
  }
end

local function setup()
  global.enabled = false --[[as bool|number]]
end

-- global.enabled acts strange, it could be 'boolean' or 'number' (true, false, tick)
-- When it transitions from 'true' to 'false', it becomes 'tick' until a full cycle is exausted,
-- then it becomes false untile turned on again.
-- Compressing its behaviour to 1 var at 'on_toggle' simplifies the conditions to be checkd at 'on_tick'
--- @param player_index uint
--- @param prototype_name string
--- @param name defines.events.on_lua_shortcut
--- @param tick uint
local function on_toggle(event)
  if (event.input_name or event.prototype_name) ~= 'fet_shortcut' then return end

  if global.enabled == true then global.enabled = event.tick
  else global.enabled = true end

  for _, player in pairs(game.players) do
    player.set_shortcut_toggled('fet_shortcut', global.enabled == true)
  end
end

--- @param unit FETUnit
--- @param tick uint
local function update_stats(unit, tick)
  local entity = unit.entity
  if not unit.recipe_time then
    unit.recipe_time = get_recipe_time(entity)
  end
  local time = unit.recipe_time
  if not time then return end -- no recipe set

  local count = entity.products_finished or 0
  local ratio = (time * 60 * count) / (tick - unit.tick) / (1 + entity.productivity_bonus) / entity.crafting_speed
  ratio = math.min(ratio, 1)
  ratio = math.max(ratio, 0)
  unit.ratio = ratio

  -- init render
  if not unit.render_ID then
    local sb = box(entity.selection_box, 0.1)
    unit.render_ID = rendering.draw_text({
      text = tostring(math.floor(ratio * 100)),
      color = { r = 0, g = 0, b = 0, a = 0.3 },
      target = entity.position,
      surface = entity.surface,
      visible = false,
    })
  end
end

--- @param r_ID uint (LuaReendering->ID)
local function update_render(r_ID, p)
  if not r_ID or not p then return end
  rendering.set_visible(r_ID, true)
  rendering.set_text(r_ID, tostring(math.floor(p * 100))) 
  rendering.set_color(r_ID, { r = 1 - p, g = p, b = 0, a = 1 })
end

--- @param r_ID uint (LuaReendering->ID)
local function remove_render(r_ID)
  if not r_ID then return end
  rendering.set_visible(r_ID, false)
end

--- @param name defines.events.on_tick
--- @param tick uint
local function on_tick(event)
  if not global.enabled then return end

  local tick = event.tick
  if global.enabled ~= true and tick - global.enabled > FET_UPDATE_INTERVAL then
    global.enabled = false
    return
  end

  local bucket_index = tick % FET_UPDATE_INTERVAL
  local bucket = global.schedule[bucket_index]
  if not bucket then return end

  if global.enabled == true then
    for _, unit in pairs(bucket) do
      update_stats(unit, tick)
      update_render(unit.render_ID, unit.ratio)
    end
  else
    for _, unit in pairs(bucket) do
      remove_render(unit.render_ID)
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