class_name ValidationResult
extends RefCounted


var is_valid: bool
var reason: String
var correction: Dictionary


func _init(valid: bool, reason: String = "", correction: Dictionary = {}):
	is_valid = valid
	self.reason = reason
	self.correction = correction


static func ok() -> ValidationResult:
	return ValidationResult.new(true)


static func invalid(reason: String) -> ValidationResult:
	return ValidationResult.new(false, reason)
