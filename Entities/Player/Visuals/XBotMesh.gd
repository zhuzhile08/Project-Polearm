extends Node3D
class_name XBotMesh


@onready var surface := $Alpha_Surface_007 as MeshInstance3D
@onready var joints := $Alpha_Joints_007 as MeshInstance3D


func acceptSkeleton(skeleton : Skeleton3D) -> void:
	surface.skeleton = skeleton.get_path()
	joints.skeleton = skeleton.get_path()
