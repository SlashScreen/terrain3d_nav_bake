@tool
extends EditorPlugin


var baker_plugin:NavBakerPlugin
var unpacker_plugin:UnpackerPlugin


func _enter_tree():
	baker_plugin = NavBakerPlugin.new()
	add_inspector_plugin(baker_plugin)
	unpacker_plugin = UnpackerPlugin.new()
	add_inspector_plugin(unpacker_plugin)


func _exit_tree():
	remove_inspector_plugin(baker_plugin)
	remove_inspector_plugin(unpacker_plugin)
