script.on_event(defines.events.on_player_created, function(event)
  local player = game.players[event.player_index]
end)



script.on_event(defines.events.on_tick, function(event)
  if game.tick % 30 == 0 then
    update_camera_element()
  end
end)

function create_camera_element(player)
  player.print("create_camera_element")

  local root_element = player.gui.left
  local camera_element = root_element.add {type = "camera", name="camera_element", position = player.position, surface_index = player.surface.index, zoom = 0.25}
  camera_element.style.top_padding = 0
  camera_element.style.bottom_padding = 0
  camera_element.style.minimal_width = 2000
  --camera_element.style.minimal_height = 270

  return camera_element
end

function update_camera_element()
  for _,player in pairs(game.players) do
    player.print("update_camera_element")

    if player.controller_type ~= defines.controllers.ghost then
      player.print("not ghost")
      return
    end
    player.print("ghost")

    local camera_element = player.gui.left.camera_element
    if camera_element == nil then
      camera_element = create_camera_element(player)
    end
  end
end