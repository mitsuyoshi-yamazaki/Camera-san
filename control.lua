script.on_event(defines.events.on_player_created, function(event)
  local player = game.players[event.player_index]
  create_camera_element(player)
end)



script.on_event(defines.events.on_tick, function(event)
  if game.tick % 1 == 0 then
    update_camera_element()
  end
end)

function create_camera_element(player)
  local root_element = player.gui.left

  local base_element = root_element.add {type = "frame", name="camera_base"}
  base_element.style.top_padding = 8
	base_element.style.left_padding = 8
	base_element.style.right_padding = 8
  base_element.style.bottom_padding = 8
  base_element.style.title_top_padding = 0
  base_element.style.title_right_padding = 0
  base_element.style.title_bottom_padding = 2
  base_element.style.title_left_padding = 0
  base_element.style.maximal_width = 296

  local camera_element = base_element.add {type = "camera", name="camera", position = player.position, surface_index = player.surface.index, zoom = 0.25}
  camera_element.style.minimal_width = 280
  camera_element.style.minimal_height = 280

  local title_label = camera_element.add{type = "label", name = "title_label", caption = player.name}
  title_label.style.top_padding = 0
	title_label.style.left_padding = 8

  return camera_element
end

function update_camera_element()
  for _,player in pairs(game.players) do
    local camera_element = player.gui.left.camera_base.camera

    camera_element.position = player.position
    camera_element.surface_index = player.surface.index
  end
end