### Factory Efficiency Tracker

The uptime tracking and visualization mod for Factorio allows players to monitor the uptime and downtime ratios of their assembling machines. This real-time tracking is accomplished through the use of colorful overlays which provide a clear visual representation of the stats for each machine. With this tool, engineers can easily identify and address any issues with their manufacturing process, resulting in improved productivity and efficiency.

---

### Main features
*Factory Efficiency Tracker (FET)* tells you what you didn't know. Rate tools ([Rate Calculator](https://mods.factorio.com/mod/RateCalculator), [Max Rate Calculator](https://mods.factorio.com/mod/MaxRateCalculator)) and bottleneck tools ([Bottleneck Lite](https://mods.factorio.com/mod/BottleneckLite), [Bottleneck](https://mods.factorio.com/mod/Bottleneck), [Assembly Analyst](https://mods.factorio.com/mod/assemblyanalyst)) are great tools to help you design better factories and I love to use them too.

But sometimes, the expected behavior can be far from reality and the design doesn't work as it's supposed to do. **FET** keeps track of each `assembler` & every `furnace` in your factory, from when it gets build 'till its last breath, and reports what's the actual work output of your machine, in terms of efficiency and uptime ratio over its lifetime (not only the present), as a percent of the expected value. Here are some examples:

![AntiElitz's 100 RG build](https://github.com/RedRafe/factory-efficiency-tracker/blob/main/archive/100_belts.png?raw=true)
> Gears, belts & inserter assemblers working <50% of the time


![AntiElitz's 100 yellow science](https://github.com/RedRafe/factory-efficiency-tracker/blob/main/archive/100_yellow.png?raw=true)
> Science assemblers & Blue chips not working 100% of the time actually

![Nefrum's Any pipes](https://github.com/RedRafe/factory-efficiency-tracker/blob/main/archive/any_gears.png?raw=true)
> GCs assemblers on 70% of their max working capacity, furnace & pipes output limited

![Nefrum's Any mixed](https://github.com/RedRafe/factory-efficiency-tracker/blob/main/archive/any_mixed.png?raw=true)
> Chem plants, furnaces and GCs starved on input resources

*Disclaimer: the above pictures are just meant to show the mod's functionality, as a preview of the expected behavior*

---

### Additional info

- The efficiency trackers can be toggled `ON` / `OFF` by simply pressing the shortcut icon on your shortcut bar.
- To reset all the production stats, use the command `/fet-reset` (achievement-friendly). It will reset all the machines' stats as if they were just built
- *not retroactive* - due to API limitations, it's impossible to retrieve the built time of the machines. It's completely safe to add this mod mid-save, but it will only keep track of the production stats from its initialization moving forward
- Performance: should be quite optimized. The UPS drain goes from `0.005` of a small save to `1.0-1.2` at gigabase size (source: [AntiElitz's 100% save](https://www.speedrun.com/factorio/runs/me0v792z) after completion). Obviously the higher the # of entities, the # the number of stats drawn at runtime. 
- When turned `OFF`, no stats are computed. When turned `ON`, the updates are distributed over multiple ticks to keep it as efficient as possible.

---

### Known bugs & compatibility
As a QoL mod, this should be compatible with any other mods. Please feel free to report any issue on the mod portal page, on GitHub, or over on my Discord.
