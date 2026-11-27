extends Spatial

var scheduler: Scheduler = Scheduler.new()


func _ready() -> void:
	scheduler.open(Movement, LinearMovement.new(), [])
	scheduler.open(Following, AnchorFollow.new(), [])
	scheduler.open(Aging, Expiry.new(), [])
	scheduler.open(Embodiment, Instancer.new(), [Root.new(self)])
	scheduler.open(Translator, DirectTranslator.new(), [])
	var anchor: int = scheduler.spawn([
		Position.new(Vector3(-2, 0, -6)),
		Velocity.new(Vector3(1, 0, 0)),
		Lifetime.new(3.0),
		Scene.new(preload("anchor.tscn"))
	])
	scheduler.spawn([
		Position.new(Vector3(-2, -1.5, -6)),
		Target.new(anchor),
		Offset.new(Vector3(0, -1.5, 0)),
		Scene.new(preload("body.tscn"))
	])

func _physics_process(delta: float) -> void: scheduler.physic(delta)

func _process(delta: float) -> void: scheduler.render(delta)
