extends Node

const GAME = "GAME"
const LOBBY = "LOBBY"
const LOCALHOST_BROADCAST_INTERVAL = 0.5
const LOCALHOST_PORT = 31401
const MENU = "MENU"
const SETTINGS = "SETTINGS"
const SETTINGS_FILE_PATH = "user://settings.json"

var LOBBY_SERVER_ROOT: String = "http://192.81.135.83/" if OS.has_feature("standalone") else "http://localhost:3000/"
