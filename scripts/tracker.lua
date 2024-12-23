local function setup()
  storage.schedule = storage.schedule or {}
end

--- @param entity/created_entity LuaEntity
--- @param tick uint
local function on_built(event)
  local entity = event.entity or event.created_entity
  if not (entity and entity.valid) then
    return
  end

  local _t = entity.type
  if _t ~= 'assembling-machine' and _t ~= 'furnace' then
    return
  end

  local ID = entity.unit_number
  local bucket_index = ID % FET_UPDATE_INTERVAL
  if not storage.schedule[bucket_index] then
    storage.schedule[bucket_index] = {}
  end
  local bucket = storage.schedule[bucket_index]
  if not bucket[ID] then
    entity.products_finished = 0
    bucket[ID] = {
      entity = entity,
      tick = event.tick,
      recipe_time = false,
      render = false,
      ratio = 0
    }
  end
end

--- @param entity/created_entity LuaEntity
local function on_destroyed(event)
  local entity = event.entity
  if not (entity and entity.valid) then
    return
  end

  local _t = entity.type
  if _t ~= 'assembling-machine' and _t ~= 'furnace' then
    return
  end

  local ID = entity.unit_number
  local bucket_index = ID % FET_UPDATE_INTERVAL
  local bucket = storage.schedule[bucket_index] or {}
  local unit = bucket[ID]
  if not unit then
    return
  end
  if unit.render and unit.render.valid then
    unit.render.destroy()
  end
  bucket[ID] = nil
end

local function on_init()
  setup()

  for index, surface in pairs(game.surfaces) do
    local entities = surface.find_entities_filtered { type = { 'assembling-machine', 'furnace' } }
    for _, entity in pairs(entities) do
      if entity and entity.valid then
        on_built({ tick = game.tick, entity = entity })
      end
    end
  end
end

local function on_reset()
  commands.add_command('fet-reset', { 'command-help.fet-reset' }, function()
    game.print('Resetting all entities production stats')
    storage.schedule = {}
    rendering.clear('factory-efficiency-tracker')
    on_init()
  end)
end

-- =================================================================================================

---@type ScriptLib
local Tracker = {}

Tracker.on_init = on_init
Tracker.on_configuration_changed = setup

Tracker.add_commands = on_reset

Tracker.events = {
  -- on built
  [defines.events.on_built_entity]       = on_built,
  [defines.events.on_robot_built_entity] = on_built,
  [defines.events.on_entity_cloned]      = on_built,
  [defines.events.script_raised_built]   = on_built,
  [defines.events.script_raised_revive]  = on_built,
  [defines.events.on_space_platform_built_entity] = on_built,
  -- on destroyed
  [defines.events.on_player_mined_entity] = on_destroyed,
  [defines.events.on_robot_mined_entity]  = on_destroyed,
  [defines.events.on_entity_died]         = on_destroyed,
  [defines.events.script_raised_destroy]  = on_destroyed,
  [defines.events.on_space_platform_mined_entity] = on_destroyed,
}

return Tracker
