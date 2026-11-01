extends Node2D

var textures: Array[Texture2D] = [
load("res://assets/Random Objects and Textures 1/Table 2.png"),
load("res://assets/Random Objects and Textures 1/Table 3.png"),
load("res://assets/Random Objects and Textures 1/Table 4.png")]

func _ready():
	%Sprite2D.texture = textures[(randf()*3)]
