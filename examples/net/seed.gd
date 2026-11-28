# This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
# If a copy of the MPL was not distributed with this file, You can obtain one at https://mozilla.org/MPL/2.0/.

extends Spatial

const PILOT = preload("res://addons/MT-godot363-ecs-toolchain/content/blueprints/pilot.blueprint")
const BINDINGS = preload("res://addons/MT-godot363-ecs-toolchain/content/settings/bindings.blueprint")
const INTENTS: Dictionary = {"forward": 0, "back": 1, "left": 2, "right": 3, "fire": 4, "aim": 5, "look": 6, "up": 7, "down": 8}
const PORT: int = 19777

var scheduler: Scheduler = Scheduler.new()
var wire: Array = [[], []]
var link: NetLink
var inputs: IntentInputs
var pilots: Dictionary = {}



class Dress:
	extends Functor
	const CRATE = preload("res://addons/MT-godot363-ecs-toolchain/examples/dispenser/crate.tscn")
	func needs() -> Array: return [NetId]
	func enter(entity: int) -> void: requests.appearing.append([entity, Scene.new(CRATE)])



func _ready() -> void:
	var fields: NetFields = NetFields.new([Position])
	var peer: NetworkedMultiplayerENet = NetworkedMultiplayerENet.new()
	if "--server" in OS.get_cmdline_args():
		peer.create_server(PORT, 8)
		set_process_unhandled_input(false)
		scheduler.open(Intention, Latch.new(), [])
		scheduler.open(Conversion, DirectionFromIntents.new(), [Directions.new([3, 2, 7, 8, 0, 1])])
		scheduler.open(Thrust, DirectThrust.new(), [])
		scheduler.open(Movement, LinearMovement.new(), [])
		scheduler.open(NetSend, NetSnapshotSend.new(), [NetWire.new(wire), NetIssued.new(1), fields])
		var host: NetHost = NetHost.new(scheduler, wire, NetTicket.new())
		host.connect("admitted", self, "admitted")
		host.connect("departed", self, "departed")
		link = NetLink.new(peer, host)
	else:
		peer.create_client("127.0.0.1", PORT)
		var guest: NetGuest = NetGuest.new(wire, "player")
		scheduler.open(NetReceive, NetSnapshotReceive.new(), [NetWire.new(wire), NetIndex.new({}), fields])
		scheduler.open(Dress, Dress.new(), [])
		scheduler.open(Embodiment, Instancer.new(), [Root.new(self)])
		scheduler.open(Translator, DirectTranslator.new(), [])
		inputs = IntentInputs.new(guest, INTENTS, BINDINGS, "user://settings/bindings.blueprint")
		link = NetLink.new(peer, guest)

func admitted(peer: int, _player: String) -> void:
	var values: Array = []
	for carrier in PILOT: values.append(carrier)
	values+= [Controlled.new(peer), NetId.new(0), Position.new(Vector3(pilots.size()*2 - 3, 0, -5))]
	pilots[peer] = scheduler.composer.spawn(values)

func departed(peer: int) -> void:
	scheduler.composer.kill(pilots[peer])
	pilots.erase(peer)


func _unhandled_input(event: InputEvent) -> void: inputs.capture(event)

func _physics_process(delta: float) -> void:
	link.pump()
	scheduler.update(delta)
