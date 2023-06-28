extends Node2D

@export var tank: Tank
@export var ui: UI

func _ready():
	if !tank.collected.is_connected(ui._on_collected):
		tank.collected.connect(ui._on_collected)
	if !tank.reload_progress.is_connected(ui._on_reload_progress):
		tank.reload_progress.connect(ui._on_reload_progress)
