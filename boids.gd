extends Node2D

# Member variables
const BOID_COUNT = 500
const SPEED_MIN = 20
const SPEED_MAX = 50

var boids = []
var shape

# Inner classes
class Boid:
	var pos = Vector2()
	var speed = 1.0
	var body = RID()

func _draw():
	var t = preload("res://boid.png")
	var tofs = -t.get_size()*0.5
	for b in boids:
		draw_texture(t, b.pos + tofs)

func _process(delta):
	var width = get_viewport_rect().size.x*2.0
	var mat = Matrix32()
	for b in boids:
		b.pos.x -= b.speed*delta
		if (b.pos.x < -30):
			b.pos.x += width
		mat.o = b.pos
		
		Physics2DServer.body_set_state(b.body, Physics2DServer.BODY_STATE_TRANSFORM, mat)
	
	update()


func _ready():
	shape = Physics2DServer.shape_create(Physics2DServer.SHAPE_CIRCLE)
	Physics2DServer.shape_set_data(shape, 8) # Radius
	
	for i in range(BOID_COUNT):
		var b = Boid.new()
		b.speed = rand_range(SPEED_MIN, SPEED_MAX)
		b.body = Physics2DServer.body_create(Physics2DServer.BODY_MODE_KINEMATIC)
		Physics2DServer.body_set_space(b.body, get_world_2d().get_space())
		Physics2DServer.body_add_shape(b.body, shape)
		
		b.pos = Vector2(get_viewport_rect().size * Vector2(randf()*2.0, randf())) # Twice as long
		b.pos.x += get_viewport_rect().size.x # Start outside
		var mat = Matrix32()
		mat.o = b.pos
		Physics2DServer.body_set_state(b.body, Physics2DServer.BODY_STATE_TRANSFORM, mat)
		
		boids.append(b)
	
	set_process(true)


func _exit_tree():
	for b in boids:
		Physics2DServer.free_rid(b.body)
	
	Physics2DServer.free_rid(shape)
	boids.clear()