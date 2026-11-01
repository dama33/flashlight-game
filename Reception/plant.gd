extends Node2D

var textures: Array[Texture2D] = [load("res://assets/Random Objects and Textures 1/Plant 1.png"),
load("res://assets/Random Objects and Textures 1/Plant 2.png"),
load("res://assets/Random Objects and Textures 1/Plant 3.png"),
load("res://assets/Random Objects and Textures 1/Plant 4.png")]

func _ready():
	%Sprite2D.texture = textures[(randf()*4)]
