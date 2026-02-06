extends CanvasLayer
@onready var label = $Panel/RichTextLabel
@onready var audio = $AudioStreamPlayer

# GANTI INI COY
var dialog_text = "You will slip."

# Default settings
var default_speed: float = 0.3
var current_speed: float = 0.3
var default_audio_sample: AudioStream = null # You can set a default in the inspector

# Regex to find your tags like <speed:0.1>
var tag_regex = RegEx.new()

func _ready():
	# Compile regex to match pattern <key:value>
	tag_regex.compile("<(?<key>\\w+):(?<val>[^>]+)>")
	
	# Store the default audio sample if one is assigned
	if audio.stream:
		default_audio_sample = audio.stream
	
	# TEST: Run it immediately
	show_message(dialog_text)

func show_message(raw_text: String):
	# 1. Parse the text into a clean string and a list of "events"
	var parsed = parse_tags(raw_text)
	var clean_text = parsed["text"]
	var events = parsed["events"]
	
	# 2. Setup Label
	label.text = clean_text # Set the full text (without tags)
	label.visible_characters = 0 # Hide everything
	current_speed = default_speed # Reset speed
	
	# Reset audio to default
	if default_audio_sample:
		audio.stream = default_audio_sample
	
	# 3. Start Typing Loop
	for i in range(clean_text.length()):
		
		# A. Check if there is an event at this specific index
		if i in events:
			await execute_events(events[i])
			
		# B. Reveal the character
		label.visible_characters = i + 1
		
		# C. Play Sound (Skip spaces)
		if clean_text[i] != " ":
			audio.pitch_scale = randf_range(0.9, 1.1) # Small pitch variation
			audio.play()	
			
		# D. Wait based on current speed
		await get_tree().create_timer(current_speed).timeout

# --- PARSING LOGIC ---
func parse_tags(raw_text: String) -> Dictionary:
	var clean_text = ""
	var events = {} # Format: { index: [ {key: "speed", val: "0.1"}, ... ] }
	
	var cursor = 0
	
	# Find all matches in the string
	var matches = tag_regex.search_all(raw_text)
	
	# If no tags, return raw text
	if matches.is_empty():
		return {"text": raw_text, "events": {}}
		
	var last_end = 0
	
	for m in matches:
		# Add the text BEFORE this tag to our clean string
		var text_before = raw_text.substr(last_end, m.get_start() - last_end)
		clean_text += text_before
		
		# Calculate where in the CLEAN text this tag "happens"
		var current_index = clean_text.length()
		
		# Extract tag data
		var key = m.get_string("key")
		var val = m.get_string("val")
		
		# Store event
		if not events.has(current_index):
			events[current_index] = []
		events[current_index].append({"key": key, "val": val})
		
		last_end = m.get_end()
		
	# Add any remaining text after the last tag
	clean_text += raw_text.substr(last_end)
	
	return {"text": clean_text, "events": events}

# --- EVENT HANDLER ---
func execute_events(event_list: Array):
	for e in event_list:
		match e["key"]:
			"speed":
				current_speed = e["val"].to_float()
			"delay":
				await get_tree().create_timer(e["val"].to_float()).timeout
			"volume":
				# Convert linear 0-1 to Decibels
				audio.volume_db = linear_to_db(e["val"].to_float())
			"pitch":
				audio.pitch_scale = e["val"].to_float()
			"audio":
				# Switch audio sample
				if e["val"] == "reset":
					# Reset to default
					if default_audio_sample:
						audio.stream = default_audio_sample
				else:
					# Load new audio file
					var new_sample = load(e["val"])
					if new_sample and new_sample is AudioStream:
						audio.stream = new_sample
					else:
						push_warning("Failed to load audio: " + e["val"])
