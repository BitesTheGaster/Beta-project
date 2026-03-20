class_name MainMenu
extends CanvasLayer
## Main menu

signal world_entered()

enum Menu {
	MAIN,
	HOST,
	JOIN,
	SETTINGS_MAIN,
	SETTINGS_AUDIO,
	SETTINGS_GRAFICS,
	SETTINGS_CONROLS,
}

var current_menu: Menu = Menu.MAIN

@onready var status_label: Label = %StatusLabel
@onready var host_button: Button = %HostButton
@onready var join_button: Button = %JoinButton
@onready var ip_edit: LineEdit = %IPEdit
@onready var port_edit: LineEdit = %PortEdit
@onready var back_button: Button = %BackButton
@onready var quit_button: Button = %QuitButton


func _update_menu():
	if current_menu == Menu.MAIN:
		host_button.show()
		join_button.show()
		ip_edit.hide()
		port_edit.hide()
		back_button.hide()
		quit_button.show()
	elif current_menu == Menu.HOST:
		host_button.show()
		join_button.hide()
		ip_edit.hide()
		port_edit.show()
		back_button.show()
		quit_button.hide()
	elif current_menu == Menu.JOIN:
		host_button.hide()
		join_button.show()
		ip_edit.show()
		port_edit.show()
		back_button.show()
		quit_button.hide()


func _on_host_button_pressed() -> void:
	if current_menu == Menu.HOST:
		var port = int(port_edit.text) if port_edit.text.is_valid_int() else 7777
		var error = NetworkManager.host_game(port)
		
		if error != OK:
			status_label.text = "Failed to host!"
			return
		world_entered.emit()
		return
	
	current_menu = Menu.HOST
	_update_menu()


func _on_join_button_pressed() -> void:
	if current_menu == Menu.JOIN:
		var ip = ip_edit.text if ip_edit.text != "" else "localhost"
		var port = int(port_edit.text) if port_edit.text.is_valid_int() else 7777
		var error = NetworkManager.join_game(ip, port)
		
		if error != OK:
			status_label.text = "Failed to join!"
			return
		world_entered.emit()
		return
	
	current_menu = Menu.JOIN
	_update_menu()


func _on_back_button_pressed() -> void:
	current_menu = Menu.MAIN
	_update_menu()


func _on_quit_button_pressed() -> void:
	get_tree().quit()
