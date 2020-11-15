extends Node

const GAME = "GAME"
const LOBBY = "LOBBY"
const MENU = "MENU"

var LOBBY_SERVER_ROOT: String = "http://192.81.135.83/" if OS.has_feature("standalone") else "http://localhost:3000/"
