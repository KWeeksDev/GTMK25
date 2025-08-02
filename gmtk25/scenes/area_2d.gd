extends Area2D

var allow_drawing = false
var is_drawing = false
var raw_points: PackedVector2Array = []
var threshold = 30.0

const SAMPLE_SIZE = 32
const TEMPLATE_SIZE = Vector2(300,300)

var target_template: String = ""

# Track if the shape target template
signal shape_matched(match:bool)

var templates = {
	"triangle": preload("res://templates/triangle_templates.tres"),
	"circle": preload("res://templates/circle_templates.tres"),
	"square": preload("res://templates/square_templates.tres"),
	"spiral": preload("res://templates/spiral_templates.tres"),
	"line" : preload("res://templates/line_templates.tres")
}

func _input(event):
	if allow_drawing:
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT:
				is_drawing = event.pressed
				if !is_drawing:
					#pass
					process_shape()
				else:
					raw_points.clear()
		elif event is InputEventMouseMotion and is_drawing:
			raw_points.append(to_local(event.position))
			queue_redraw()
		elif event is InputEventKey and event.pressed:
			if event.keycode == KEY_N:
				var new_resource = TemplateResource.new()
				new_resource.data.append(normalize(resample(raw_points, SAMPLE_SIZE)))
				ResourceSaver.save(new_resource, "res://templates/new.tres")
			elif event.keycode == KEY_S:
				save_template("square")
			elif event.keycode == KEY_C:
				save_template("circle")
			elif event.keycode == KEY_L:
				save_template("line")
			elif event.keycode == KEY_T:
				save_template("triangle")
			elif event.keycode == KEY_P:
				save_template("spiral")
			elif event.keycode == KEY_0:
				for name in templates.keys():
					templates[name].data.clear()
					ResourceSaver.save(templates[name])

func _draw():
	if raw_points.size() > 1:
		draw_polyline(raw_points, Color.RED, 2)
		
func save_template(name):
	var new_resource = templates[name]
	var normaled = normalize(resample(raw_points, SAMPLE_SIZE))
	new_resource.data.append(normaled)
	ResourceSaver.save(new_resource, "res://templates/"+name+"_templates.tres")

func get_centroid(points: PackedVector2Array) -> Vector2:
	if points.is_empty():
		return Vector2.ZERO
	
	var total = Vector2.ZERO
	for p in points:
		total += p
	return total / points.size()

func process_shape():
	var processed = normalize(resample(raw_points, SAMPLE_SIZE))
	var best_score = INF
	var best_match = ""
	
	# Check all templates if no specific is supplied
	if target_template == "":
		for name in templates.keys():
			for template in templates[name].data:
				var s = score(template, processed)
				if s < best_score:
					best_score = s
					best_match = name
	else:
		if templates.has(target_template):
			for template in templates[target_template].data:
				var s = score(template, processed)
				if s < best_score:
					best_score = s
					best_match = target_template
			
	if best_score < threshold:
		print("Matched: ", best_match, " with a score of ", best_score)
		emit_signal("shape_matched",true)
	else:
		print("No Match. Best was: ", best_match, " (", best_score, ")")
		emit_signal("shape_matched",false)

func resample(points: PackedVector2Array, n: int) -> PackedVector2Array:
	# Early out for speed
	if points.size() < 2:
		return points.duplicate()
	
	var new_points: PackedVector2Array = [points[0]]
	
	var total_length = 0.0
	for i in range(1, points.size()):
		total_length += points[i].distance_to(points[i-1])
		
	var interval = total_length / (n - 1)
	var d = 0.0
	
	for i in range(1, points.size()):
		var pt1 = points[i - 1]
		var pt2 = points[i]
		var dist = pt1.distance_to(pt2)
	
		if (dist + d) >= interval:
			var t = (interval - d) / dist
			var new_point = pt1.lerp(pt2, t)
			new_points.append(new_point)
			points.insert(i, new_point)
			d = 0.0
		else:
			d += dist
	
	while new_points.size() < n:
		new_points.append(points[-1])
	
	return new_points

func normalize(points: PackedVector2Array) -> PackedVector2Array:
	# Translate the origin
	var centroid = Vector2.ZERO
	
	for p in points:
		centroid += p
	centroid /= points.size()
	
	for i in points.size():
		points[i] -= centroid
	
	# Scale Uniformly
	var min_x = INF
	var min_y = INF
	var max_x = -INF
	var max_y = -INF
	
	for p in points:
		min_x = min(min_x, p.x)
		min_y = min(min_y, p.y)
		max_x = max(max_x, p.x)
		max_y = max(max_y, p.y)
	
	var size = Vector2(max_x - min_x, max_y - min_y)
	if size.x < 1: size.x = 1
	if size.y < 1: size.y = 1
	
	#var scale = TEMPLATE_SIZE / size
	var scale = min(TEMPLATE_SIZE.x / size.x, TEMPLATE_SIZE.y / size.y)
	
	for i in points.size():
		points[i] *= scale
	
	return points

# Point to point Euclidean distance for scoring
func score(template: PackedVector2Array, candidate: PackedVector2Array) -> float:
	if candidate.size() < 1:
		return INF
	var sum = 0.0
	
	for i in template.size():
		sum += template[i].distance_to(candidate[i])
		
	return sum / template.size()
