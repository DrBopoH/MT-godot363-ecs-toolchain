extends Spatial

const Position = preload("position.gd")
const Proxy = preload("proxy.gd")
const Translator = preload("translator.gd")
const DirectTranslator = preload("direct_translator.gd")

var scheduler: Scheduler = Scheduler.new()


func _ready() -> void:
	scheduler.open(Translator, DirectTranslator.new(), [])
	scheduler.spawn([Position.new(Vector3(0, 0, -5)), Proxy.new($craft)])

func _physics_process(delta: float) -> void: scheduler.physic(delta)

func _process(delta: float) -> void: scheduler.render(delta)
