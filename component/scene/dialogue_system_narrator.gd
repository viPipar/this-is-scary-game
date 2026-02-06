extends CanvasLayer

# --- INSPECTOR SETTINGS (Edit these in the Godot Inspector) ---

@export_group("Content")
@export_multiline var dialog_text: String = "You will slip."
@export_enum("None", "Father", "Mother", "Elder Brother", "Little Brother", "Sister") var speaker: int = 0

@export_group("Audio")
@export var custom_voice_sound: AudioStream

@export_group("Settings")
@export var typing_speed: float = 0.05
@export var auto_start: bool = true

# --- NODES & INTERNAL VARIABLES ---
@onready var label = $Panel/RichTextLabel
@onready var audio = $AudioStreamPlayer

# Mapping the Dropdown Enum (0, 1, 2...) to your actual Nodes
# Note: "Elder Brother" and "Little Brother" need quotes because of the space in the name
@onready var speaker_sprites = {
	1: $Panel/Father,
	2: $Panel/Mother,
	3: $"Panel/Elder Brother", 
	4: $"Panel/Little Brother",
	5: $Panel/Sister
}

var current_speed: float = 0.3
var default_audio_sample: AudioStream = null 
var tag_regex = RegEx.new()

func _ready():
	# 1. Compile regex
	tag_regex.compile("<(?<key>\\w+):(?<val>[^>]+)>")
	
	# 2. Setup Audio
	# If a custom sound was dropped in the Inspector, use it.
	if custom_voice_sound:
		default_audio_sample = custom_voice_sound
		audio.stream = custom_voice_sound
	# Otherwise, keep whatever is on the AudioPlayer node
	elif audio.stream:
		default_audio_sample = audio.stream
		
	# 3. Setup Speed
	current_speed = typing_speed
	
	# 4. Setup Visuals (Show the correct character)
	update_speaker_visuals()
	
	# 5. Run
	if auto_start:
		show_message(dialog_text)

func update_speaker_visuals():
	# Loop through all possible speaker nodes and hide them
	for key in speaker_sprites:
		if speaker_sprites[key]:
			speaker_sprites[key].visible = false
			
	# Show only the one selected in the Inspector (if not "None")
	if speaker in speaker_sprites:
		speaker_sprites[speaker].visible = true

func show_message(raw_text: String):
	# 1. Parse the text into a clean string and a list of "events"
	var parsed = parse_tags(raw_text)
	var clean_text = parsed["text"]
	var events = parsed["events"]
	
	# 2. Setup Label
	label.text = clean_text 
	label.visible_characters = 0 
	
	# Reset settings to defaults for this run
	current_speed = typing_speed 
	if default_audio_sample:
		audio.stream = default_audio_sample
	
	# 3. Start Typing Loop
	for i in range(clean_text.length()):
		
		# A. Check for events
		if i in events:
			await execute_events(events[i])
			
		# B. Reveal the character
		label.visible_characters = i + 1
		
		# C. Play Sound (Skip spaces)
		if clean_text[i] != " ":
			audio.pitch_scale = randf_range(0.9, 1.1) 
			audio.play()	
			
		# D. Wait based on current speed
		await get_tree().create_timer(current_speed).timeout

# --- PARSING LOGIC (Unchanged) ---
func parse_tags(raw_text: String) -> Dictionary:
	var clean_text = ""
	var events = {} 
	var cursor = 0
	var matches = tag_regex.search_all(raw_text)
	
	if matches.is_empty():
		return {"text": raw_text, "events": {}}
		
	var last_end = 0
	
	for m in matches:
		var text_before = raw_text.substr(last_end, m.get_start() - last_end)
		clean_text += text_before
		var current_index = clean_text.length()
		var key = m.get_string("key")
		var val = m.get_string("val")
		
		if not events.has(current_index):
			events[current_index] = []
		events[current_index].append({"key": key, "val": val})
		last_end = m.get_end()
		
	clean_text += raw_text.substr(last_end)
	return {"text": clean_text, "events": events}

# --- EVENT HANDLER (Unchanged) ---
func execute_events(event_list: Array):
	for e in event_list:
		match e["key"]:
			"speed":
				current_speed = e["val"].to_float()
			"delay":
				await get_tree().create_timer(e["val"].to_float()).timeout
			"volume":
				audio.volume_db = linear_to_db(e["val"].to_float())
			"pitch":
				audio.pitch_scale = e["val"].to_float()
			"audio":
				if e["val"] == "reset":
					if default_audio_sample:
						audio.stream = default_audio_sample
				else:
					var new_sample = load(e["val"])
					if new_sample and new_sample is AudioStream:
						audio.stream = new_sample
					else:
						push_warning("Failed to load audio: " + e["val"])
