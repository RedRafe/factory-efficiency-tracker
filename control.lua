local handler = require '__core__.lualib.event_handler'

---@class ScriptLib
---@field add_commands? fun()
---@field add_remote_interface? fun()
---@field on_init? fun()
---@field on_load? fun()
---@field on_configuration_changed? fun(d: ConfigurationChangedData)
---@field events? table<defines.events, fun(d: EventData)>
---@field on_nth_tick? table<integer, fun(d: NthTickEventData)>

FET_UPDATE_INTERVAL = 127

handler.add_libraries {
  require 'scripts.tracker',
  require 'scripts.stats',
}
