extends Node2D

# --- 1. SETTINGS ---
enum Template { FATHER, MOTHER, ELDER_BROTHER, LITTLE_BROTHER, SISTER, NARRATOR }

@export_group("Dialogue Content")
@export_multiline var dialog_text: String = "Enter text here..."
@export var character_template: Template = Template.FATHER
@export var auto_start: bool = true

@export_group("Internal Settings")
@export var typing_speed: float = 0.05

# --- 2. ASSETS (Matched to your screenshot) ---
const AUDIO_FATHER = preload("res://component/assets/dialogue_engine/father_blip.wav")
const AUDIO_MOTHER = preload("res://component/assets/dialogue_engine/mother_blip.wav")
const AUDIO_ELDER = preload("res://component/assets/dialogue_engine/elder_brother_blip.wav")
const AUDIO_LITTLE = preload("res://component/assets/dialogue_engine/little_brother.wav") 
const AUDIO_NARRATOR = preload("res://component/assets/dialogue_engine/narrator_blip.wav")

# --- 3. NODE REFERENCES ---
# These paths must match your Scene Tree EXACTLY
@onready var sys_char = $DialogueSystem
@onready var sys_narr = $DialogueSystem_Narrator

# Note: We use get_node() for paths with spaces to be safe, though $"..." works too.
@onready var char_label = $DialogueSystem/Panel/RichTextLabel
@onready var char_audio = $DialogueSystem/AudioStreamPlayer

# Dictionary mapping Templates to Nodes
@onready var char_sprites = {
	Template.FATHER: $DialogueSystem/Panel/Father,
	Template.MOTHER: $DialogueSystem/Panel/Mother,
	Template.ELDER_BROTHER: $"DialogueSystem/Panel/Elder Brother",
	Template.LITTLE_BROTHER: $"DialogueSystem/Panel/Little Brother",
	Template.SISTER: $DialogueSystem/Panel/Sister
}

@onready var narr_label = $DialogueSystem_Narrator/Panel/RichTextLabel
@onready var narr_audio = $DialogueSystem_Narrator/AudioStreamPlayer

var active_label: RichTextLabel
var active_audio: AudioStreamPlayer
var default_audio_stream: AudioStream
var current_speed: float = 0.05
var tag_regex = RegEx.new()

func _ready():
	# DEBUG: This will tell you exactly which node is missing if it crashes
	if not sys_char: push_error("ERROR: Could not find node 'DialogueSystem'")
	if not sys_narr: push_error("ERROR: Could not find node 'DialogueSystem_Narrator'")
	
	tag_regex.compile("<(?<key>\\w+):(?<val>[^>]+)>")
	
	apply_template()
	
	if auto_start:
		show_message(dialog_text)

func apply_template():
	# 1. Reset Visibility
	if sys_char: sys_char.visible = false
	if sys_narr: sys_narr.visible = false
	
	# Hide all sprites safely
	for key in char_sprites:
		var sprite = char_sprites[key]
		if sprite:
			sprite.visible = false
		else:
			print("Warning: Sprite node not found for key: ", key)

	# 2. Activate Selected Mode
	match character_template:
		Template.NARRATOR:
			if sys_narr: sys_narr.visible = true
			active_label = narr_label
			active_audio = narr_audio
			default_audio_stream = AUDIO_NARRATOR
			
		_: 
			# Character Mode
			if sys_char: sys_char.visible = true
			active_label = char_label
			active_audio = char_audio
			
			# Show specific character image
			var selected_sprite = char_sprites.get(character_template)
			if selected_sprite:
				selected_sprite.visible = true
			
			# Pick Audio
			match character_template:
				Template.FATHER: default_audio_stream = AUDIO_FATHER
				Template.MOTHER: default_audio_stream = AUDIO_MOTHER
				Template.ELDER_BROTHER: default_audio_stream = AUDIO_ELDER
				Template.LITTLE_BROTHER: default_audio_stream = AUDIO_LITTLE
				_: default_audio_stream = AUDIO_FATHER 

	# Apply audio stream
	if active_audio and default_audio_stream:
		active_audio.stream = default_audio_stream

func show_message(raw_text: String):
	if not active_label: 
		push_warning("No active label found. Cannot show message.")
		return
	
	var parsed = parse_tags(raw_text)
	var clean_text = parsed["text"]
	var events = parsed["events"]
	
	active_label.text = clean_text 
	active_label.visible_characters = 0 
	current_speed = typing_speed
	
	if active_audio and default_audio_stream:
		active_audio.stream = default_audio_stream
	
	for i in range(clean_text.length()):
		if i in events:
			await execute_events(events[i])
			
		active_label.visible_characters = i + 1
		
		if clean_text[i] != " ":
			# Random pitch for variation
			if active_audio:
				active_audio.pitch_scale = randf_range(0.9, 1.1)
				active_audio.play()	
			
		await get_tree().create_timer(current_speed).timeout

# --- PARSING & EVENTS (Unchanged) ---
func parse_tags(raw_text: String) -> Dictionary:
	var clean_text = ""
	var events = {} 
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

func execute_events(event_list: Array):
	for e in event_list:
		match e["key"]:
			"speed": current_speed = e["val"].to_float()
			"delay": await get_tree().create_timer(e["val"].to_float()).timeout
			"volume": if active_audio: active_audio.volume_db = linear_to_db(e["val"].to_float())
			"pitch": if active_audio: active_audio.pitch_scale = e["val"].to_float()
			"audio":
				if active_audio:
					if e["val"] == "reset":
						active_audio.stream = default_audio_stream
					else:
						var new_sample = load(e["val"])
						if new_sample: active_audio.stream = new_sample
