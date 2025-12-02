extends Node2D

var problem = ""
var solution = ""
var problem_type = "element"
var special_available = false
var failed_question = false

var elements = ["hydrogen", "helium", "lithium", "beryllium", "boron", "carbon", "nitrogen", "oxygen", "fluorine", "neon", "iridium"]
var angles = ["right", "obtuse", "acute", "reflex", "straight", "full"]
var planet_distances = {
	"mercury": 0.39,
	"venus": 0.72,
	"earth": 1.00,
	"mars": 1.52,
	"jupiter": 5.20,
	"saturn": 9.58,
	"uranus": 19.20,
	"neptune": 30.10
}

func generate_problem():
	$"CanvasLayer/GamePanel/AI Screen".clear()
	var ai_font = $"CanvasLayer/GamePanel/AI Screen".get_theme_font("font")
	var list_num = randi_range(1,2)
	if list_num == 1:
		problem_type = "element"
		var element = elements.pick_random()
		problem = "How many examples of " + element + " are present?"
		print(problem)
		var occurances = 0
		for i in range (9):
			var line = ""
			for j in range(7):
				var pick = elements.pick_random()
				if pick == element:
					occurances += 1
				line += pick
			while ai_font.get_string_size(line).x + 120 < $"CanvasLayer/GamePanel/AI Screen".size.x:
				line = line.insert(randi_range(3,len(line)-3), " ")
			$"CanvasLayer/GamePanel/AI Screen".text += line + "\n"
		$"CanvasLayer/GamePanel/AI Screen".text = $"CanvasLayer/GamePanel/AI Screen".text.left(-1)
		print("Occurances: " + str(occurances))
		solution = occurances
	elif list_num == 2:
		problem_type = "planets"
		var probe_distance = snapped(randf_range(0.3, 30), 0.01)
		print(probe_distance)
		problem = "Sensors malfunctioning. Enter nearest planet to probe."
		var closest_planet = "mercury"
		var distance = 50
		for planet in planet_distances:
			if abs(planet_distances[planet] - probe_distance) < distance:
				closest_planet = planet
				distance = abs(planet_distances[planet] - probe_distance)
		print(closest_planet)
		solution = closest_planet
		var probe_line = randi_range(0,8)
		var probe_position = randi_range(0,3)
		for i in range (9):
			var line = ""
			for j in range(4):
				var planet_choice = planet_distances.keys().pick_random()
				var pick =  planet_choice + " " + str(planet_distances[planet_choice])
				if probe_line == i and probe_position == j:
					pick = "probe " + str(probe_distance)
				line += pick 
			while ai_font.get_string_size(line).x + 120 < $"CanvasLayer/GamePanel/AI Screen".size.x:
				line = line.insert(randi_range(3,len(line)-3), " ")
			$"CanvasLayer/GamePanel/AI Screen".text += line + "\n"
		$"CanvasLayer/GamePanel/AI Screen".text = $"CanvasLayer/GamePanel/AI Screen".text.left(-1)
	$CanvasLayer/GamePanel/TextSubmission.placeholder_text = problem
			
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if SpaceApi.connected:
		$CanvasLayer/GamePanel.visible = true
		if special_available:
			$CanvasLayer/GamePanel/ButtonConsume.disabled = false
			$CanvasLayer/GamePanel/ButtonEMP.disabled = false
			$CanvasLayer/GamePanel/ButtonStartAI.disabled = true
		else:
			$CanvasLayer/GamePanel/ButtonConsume.disabled = true
			$CanvasLayer/GamePanel/ButtonEMP.disabled = true
			if not failed_question:
				$CanvasLayer/GamePanel/Label.text = "The AI has a query for you..."
				$CanvasLayer/GamePanel/ButtonStartAI.disabled = false
		$CanvasLayer/ConnectPanel.visible = false
	else:
		$CanvasLayer/ConnectPanel.visible = true
		$CanvasLayer/GamePanel.visible = false

func _on_button_start_ai_pressed() -> void:
	$CanvasLayer/GamePanel/ButtonStartAI.visible = false
	$CanvasLayer/GamePanel/TextSubmission.visible = true
	$CanvasLayer/GamePanel/Label.text = "The AI wishes to know..."
	generate_problem()


func check_answer() -> void:
	if problem_type == "element":
		if !(int($CanvasLayer/GamePanel/TextSubmission.text) > solution + 1) and !(int($CanvasLayer/GamePanel/TextSubmission.text) < solution - 1):
			failed_question = false
		else:
			failed_question = true
	elif problem_type == "planets":
		if $CanvasLayer/GamePanel/TextSubmission.text == solution:
			failed_question = false
		else:
			failed_question = true
	if failed_question:
		$CanvasLayer/GamePanel/Label.text = "The AI is angry and upset"
		$CanvasLayer/GamePanel/ButtonStartAI.disabled = true
	else:
		$CanvasLayer/GamePanel/Label.text = "This pleases the AI"
		special_available = true
	$CanvasLayer/GamePanel/ButtonStartAI.visible = true
	$"CanvasLayer/GamePanel/AI Screen".clear()
	$CanvasLayer/GamePanel/TextSubmission.clear()
	$CanvasLayer/GamePanel/TextSubmission.visible = false
	$TimerQuestionFinished.start()


func _on_text_submission_text_changed() -> void:
	if len($CanvasLayer/GamePanel/TextSubmission.text) > 1 and $CanvasLayer/GamePanel/TextSubmission.text[-1] == "\n":
		$CanvasLayer/GamePanel/TextSubmission.text = $CanvasLayer/GamePanel/TextSubmission.text.trim_suffix("\n")
		check_answer()


func _on_button_connect_pressed() -> void:
	SpaceApi.host = $CanvasLayer/ConnectPanel/TextServerIP.text
	SpaceApi.server_connect(SpaceApi.host, SpaceApi.role, SpaceApi.team)

func _on_button_shields_up_pressed() -> void:
	SpaceApi.add_shield()


func _on_button_consume_pressed() -> void:
	SpaceApi.consume_shield()
	special_available = false


func _on_button_emp_pressed() -> void:
	SpaceApi.emp()
	special_available = false


func _on_timer_question_finished_timeout() -> void:
	$CanvasLayer/GamePanel/Label.text = "The AI is bored..."
	failed_question = false
	$CanvasLayer/GamePanel/ButtonStartAI.disabled = false
