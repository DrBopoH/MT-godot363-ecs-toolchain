# This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
# If a copy of the MPL was not distributed with this file, You can obtain one at https://mozilla.org/MPL/2.0/.

class_name NetLink
extends Reference

var peer: NetworkedMultiplayerPeer
var end: Reference


func _init(_peer: NetworkedMultiplayerPeer, _end: Reference) -> void:
	peer = _peer
	end = _end
	peer.connect("peer_connected", end, "joined")
	peer.connect("peer_disconnected", end, "left")
	peer.connect("server_disconnected", end, "left", [NetWire.HOST])
	peer.connect("connection_failed", end, "left", [NetWire.HOST])
	end.connect("refused", peer, "disconnect_peer")


func pump() -> void:
	if peer.get_connection_status() == NetworkedMultiplayerPeer.CONNECTION_DISCONNECTED: return
	peer.poll()
	while peer.get_available_packet_count() > 0:
		var sender: int = peer.get_packet_peer()
		end.received(sender, bytes2var(peer.get_packet()))
	if peer.get_connection_status() != NetworkedMultiplayerPeer.CONNECTION_CONNECTED: return
	end.commit()
	var outbox: Array = end.wire[NetWire.OUTBOX]
	for packet in outbox:
		var bytes: PoolByteArray = var2bytes(packet[NetWire.MESSAGES])
		peer.transfer_mode = NetworkedMultiplayerPeer.TRANSFER_MODE_RELIABLE if packet[NetWire.RELIABLE] else NetworkedMultiplayerPeer.TRANSFER_MODE_UNRELIABLE_ORDERED
		for target in end.targets(packet[NetWire.TARGET]):
			peer.set_target_peer(target)
			peer.put_packet(bytes)
	outbox.clear()
