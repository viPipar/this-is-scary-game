extends CanvasLayer

# --- 1. THE "TEMPLATE PICKER" (This appears in Inspector) ---
enum Template { FATHER, MOTHER, ELDER_BROTHER, LITTLE_BROTHER, SISTER, NARRATOR }

@export_group("Dialogue Content")
@export_multiline var dialog_text: String = "Enter text here..."
@export var character_template: Template = Template.FATHER
@export var auto_start: bool = true

@export_group("Settings")
@export var typing_speed: float = 0.05

# --- 2. ASSET REFERENCES (Preloaded for ease of use) ---
# Adjust paths if your folder structure changes. 
# Based on your screenshot, assuming this script is in the same folder as assets.
const AUDIO_FATHER = preload("res://component/assets/dialogue_engine/father_blip.wav")
const AUDIO_MOTHER = preload("res://component/assets/dialogue_engine/mother_blip.wav")
const AUDIO_ELDER = preload("res://component/assets/dialogue_engine/elder_brother_blip.wav")
const AUDIO_LITTLE = preload("res://component/assets/dialogue_engine/little_brother.wav") # Note: filename in screenshot lacked _blip?
const AUDIO_NARRATOR = preload("res://component/assets/dialogue_engine/narrator_blip.wav")

# --- 3. NODE REFERENCES ---
# We need to know where everything is to toggle them on/off
@onready var sys_char = $DialogueSystem
@onready var sys_narr = $DialogueSystem_Narrator

@onready var char_label = $DialogueSystem/Panel/RichTextLabel
@onready var char_audio = $DialogueSystem/AudioStreamPlayer
@onready var char_sprites = {
	Template.FATHER: $DialogueSystem/Panel/Father,
	Template.MOTHER: $DialogueSystem/Panel/Mother,
	Template.ELDER_BROTHER: $"DialogueSystem/Panel/Elder Brother",
	Template.LITTLE_BROTHER: $"DialogueSystem/Panel/Little Brother",
	Template.SISTER: $DialogueSystem/Panel/Sister
}

@onready var narr_label = $DialogueSystem_Narrator/Panel/RichTextLabel
@onready var narr_audio = $DialogueSystem_Narrator/AudioStreamPlayer

# --- INTERNAL VARIABLES ---
var active_label: RichTextLabel
var active_audio: AudioStreamPlayer
var default_audio_stream: AudioStream
var current_speed: float = 0.05
var tag_regex = RegEx.new()

func _ready():
	tag_regex.compile("<(?<key>\\w+):(?<val>[^>]+)>")
	
	# 1. Apply the Template Logic
	apply_template()
	
	# 2. Start
	if auto_start:
		show_message(dialog_text)

func apply_template():
	# Reset everything to hidden first
	sys_char.visible = false
	sys_narr.visible = false
	
	# Hide all character sprites
	for key in char_sprites:
		char_sprites[key].visible = false

	# LOGIC: Switch based on selection
	match character_template:
		Template.NARRATOR:
			# --- NARRATOR MODE ---
			sys_narr.visible = true
			active_label = narr_label
			active_audio = narr_audio
			default_audio_stream = AUDIO_NARRATOR
			
		_: 
			# --- CHARACTER MODE (Default) ---
			sys_char.visible = true
			active_label = char_label
			active_audio = char_audio
			
			# Activate the specific sprite
			if character_template in char_sprites:
				char_sprites[character_template].visible = true
			
			# Assign specific audio
			match character_template:
				Template.FATHER: default_audio_stream = AUDIO_FATHER
				Template.MOTHER: default_audio_stream = AUDIO_MOTHER
				Template.ELDER_BROTHER: default_audio_stream = AUDIO_ELDER
				Template.LITTLE_BROTHER: default_audio_stream = AUDIO_LITTLE
				# Add Sister audio here if you have it
				_: default_audio_stream = AUDIO_FATHER # Fallback

	# Set the audio stream to the player
	if active_audio and default_audio_stream:
		active_audio.stream = default_audio_stream

func show_message(raw_text: String):
	if not active_label: return
	
	var parsed = parse_tags(raw_text)
	var clean_text = parsed["text"]
	var events = parsed["events"]
	
	active_label.text = clean_text 
	active_label.visible_characters = 0 
	current_speed = typing_speed
	
	# Reset audio
	if active_audio and default_audio_stream:
		active_audio.stream = default_audio_stream
	
	# Typing Loop
	for i in range(clean_text.length()):
		if i in events:
			await execute_events(events[i])
			
		active_label.visible_characters = i + 1
		
		# Play Sound (only if not space)
		if clean_text[i] != " ":
			active_audio.pitch_scale = randf_range(0.9, 1.1)
			active_audio.play()	
			
		await get_tree().create_timer(current_speed).timeout

# --- PARSING (Standard) ---
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

# --- EVENTS ---
func execute_events(event_list: Array):
	for e in event_list:
		match e["key"]:
			"speed":
				current_speed = e["val"].to_float()
			"delay":
				await get_tree().create_timer(e["val"].to_float()).timeout
			"volume":
				active_audio.volume_db = linear_to_db(e["val"].to_float())
			"pitch":
				active_audio.pitch_scale = e["val"].to_float()
			"audio":
				if e["val"] == "reset":
					active_audio.stream = default_audio_stream
				else:
					var new_sample = load(e["val"])
					if new_sample: active_audio.stream = new_sample
