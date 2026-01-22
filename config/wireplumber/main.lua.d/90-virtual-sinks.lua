table.insert(alsa_monitor.rules, {
	matches = {},
	apply_properties = {
		["node.description"] = "Desktop Audio",
		["node.name"] = "sink_desktop",
		["factory.name"] = "support.null-audio-sink",
		["media.class"] = "Audio/Sink",
		["audio.position"] = "FL,FR",
	},
})

table.insert(alsa_monitor.rules, {
	matches = {},
	apply_properties = {
		["node.description"] = "Music",
		["node.name"] = "sink_music",
		["factory.name"] = "support.null-audio-sink",
		["media.class"] = "Audio/Sink",
		["audio.position"] = "FL,FR",
	},
})

table.insert(alsa_monitor.rules, {
	matches = {},
	apply_properties = {
		["node.description"] = "Virtual Mic",
		["node.name"] = "sink_virtual_mic",
		["factory.name"] = "support.null-audio-sink",
		["media.class"] = "Audio/Sink",
		["audio.position"] = "FL,FR",
	},
})
