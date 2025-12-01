extends Node2D

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
	$"CanvasLayer/AI Screen".text = ""
	var ai_font = $"CanvasLayer/AI Screen".get_theme_font("font")
	var problem = ""
	var solution = ""
	var list_num = randi_range(1,1)
	if list_num == 1:
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
			while ai_font.get_string_size(line).x + 120 < $"CanvasLayer/AI Screen".size.x:
				line = line.insert(randi_range(3,len(line)-3), " ")
			$"CanvasLayer/AI Screen".text += line + "\n"
		$"CanvasLayer/AI Screen".text = $"CanvasLayer/AI Screen".text.left(-1)
		print("Occurances: " + str(occurances))
		#Allow +/- 1 to be correct

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_button_start_ai_pressed() -> void:
	$CanvasLayer/ButtonStartAI.visible = false
	generate_problem()
