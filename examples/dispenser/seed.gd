extends Spatial

var scheduler: Scheduler = Scheduler.new()


func _ready() -> void:
	scheduler.open(Translator, DirectTranslator.new(), [])
	scheduler.open(Embodiment, Instancer.new(), [Root.new(self)])
	scheduler.open(Aging, Expiry.new(), [])
	scheduler.open(Emission, Periodic.new(), [
		Interval.new(1.0),
		Countdown.new(0.0),
		Template.new([Position.new(Vector3(0, 0, -5)), Scene.new(preload("crate.tscn")), Lifetime.new(0.8)])
	])

func _physics_process(delta: float) -> void: scheduler.physic(delta)

func _process(delta: float) -> void: scheduler.render(delta)
