# This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
# If a copy of the MPL was not distributed with this file, You can obtain one at https://mozilla.org/MPL/2.0/.

class_name HMACTicket
extends NetTicket

var secret: PoolByteArray
var match_id: String


func _init(_secret: String, _match_id: String) -> void:
	secret = _secret.to_utf8()
	match_id = _match_id


func verify(token: String) -> String:
	var parts: PoolStringArray = token.split(".")
	if parts.size() != 2 or parts[1] != signature(parts[0]): return ""
	var claims = parse_json(Marshalls.base64_to_utf8(parts[0]))
	if typeof(claims) != TYPE_DICTIONARY or claims.get("match") != match_id: return ""
	if claims.get("exp", 0) <= OS.get_unix_time(): return ""
	return str(claims.get("player", ""))

func signature(payload: String) -> String:
	var context: HMACContext = HMACContext.new()
	context.start(HashingContext.HASH_SHA256, secret)
	context.update(payload.to_utf8())
	return Marshalls.raw_to_base64(context.finish())
