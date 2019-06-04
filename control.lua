require "util"  -- I don't know what it does
require "mod-gui" -- this? https://github.com/wube/factorio-data/blob/556fd3f5de22fc768468a071dae51af7c4f601d5/core/lualib/mod-gui.lua

DEBUG = false
CAMERA_TOGGLE_BUTTON = "camera_toggle"


-- Events --

script.on_event(defines.events.on_gui_click, function(event)
  local player = game.players[event.player_index]

  for _,target in pairs(game.players) do
    local button_name = get_button_name(target)
    if event.element.name == button_name then
      local button = event.element
      local player = game.players[button.player_index]
      set_target_for(player, target)
      break
    end
  end
  local element_name = event.element.name
		if element_name == CAMERA_TOGGLE_BUTTON then
				local camera_frame = get_root_element_for(player).camera_frame
			 camera_frame.visible = not camera_frame.visible
  end
end)

script.on_event(defines.events.on_tick, function(event)
  if game.tick % 1 == 0 then
				malicious_vicious_migration()
    update_camera_element()
  end
end)


-- Functions --


function get_button_name(player)
  return "button_" .. player.name
end

function get_target_for(player)
  local index = global[player.name]
  if index == nil then
    return player
  end

  return game.players[index]
end

function set_target_for(player, target)
  print_to(player, "Change target from " .. get_target_for(player).name .. " to " .. target.name)
  global[player.name] = target.index
end

function get_root_element_for(player)
		return mod_gui.get_frame_flow(player)
end

function create_toggle_button(player)
  mod_gui.get_frame_flow(player).add({
    type = "button",
    name = CAMERA_TOGGLE_BUTTON,
    caption = "Camera"
  })
end

function create_camera_element(player)
  local root_element = get_root_element_for(player)

  local base_element = root_element.add {type = "frame", name="camera_frame", direction = "vertical"}
  base_element.style.top_padding = 8
	 base_element.style.left_padding = 8
	 base_element.style.right_padding = 8
  base_element.style.bottom_padding = 8
  base_element.style.maximal_width = 296

  local camera_element = base_element.add {type = "camera", name="camera", position = player.position, surface_index = player.surface.index, zoom = 0.25}
  camera_element.style.minimal_width = 280
  camera_element.style.minimal_height = 280

  set_target_for(player, player)

  return camera_element
end

function remove_player_buttons()
  local player_button_names = {}
  for index,player in pairs(game.players) do
    player_button_names[index] = get_button_name(player)
  end

  for _,player in pairs(game.players) do
    local base_element = get_root_element_for(player).camera_frame

    for _,child_element in pairs(base_element.children) do
      if has_value(player_button_names, child_element.name) then
        child_element.destroy() -- Needs 'reverse' ?
      end
    end
  end
end

function add_player_button(player)
  local base_element = get_root_element_for(player).camera_frame

  for _,target in pairs(game.players) do
    local button_name = get_button_name(target)

    local has_character = target.connected
    local has_target_button = base_element[button_name] ~= nil

    if has_character and (has_target_button == false) then
      -- add button
      local button = base_element.add{type = "button", name = button_name, caption = target.name}
      button.style.top_padding = 0
      button.style.left_padding = 8

    elseif (has_character == false) and has_target_button then
      -- remove button
      base_element[button_name].destroy()
    else
      -- do nothing
    end
  end
end

function update_camera_element()
  for _,player in pairs(game.players) do
				if player.connected then
        if get_root_element_for(player).camera_frame == nil then
          create_camera_element(player)
								end
								
								if mod_gui.get_frame_flow(player)[CAMERA_TOGGLE_BUTTON] == nil then
										create_toggle_button(player)
								end

        add_player_button(player)

        local camera_element = get_root_element_for(player).camera_frame.camera
        local target = get_target_for(player)

        camera_element.position = target.position
        camera_element.surface_index = target.surface.index
    end
  end
end

function malicious_vicious_migration()
		-- This function removes GUI elements created by Camera-san v1.1.4 or prior
		for _,player in pairs(game.players) do
				if player.gui.left.camera_frame ~= nil then
						player.gui.left.camera_frame.destroy()
						print_to(player, "player.gui.left.camera_frame.destroy()")
				end
		end
end

-- Utilities --


function has_value(table, value)
  for _,v in pairs(table) do
      if v == value then
          return true
      end
  end
  return false
end

function print_to(player, message)
  if DEBUG then
    player.print(serpent.block(message))
  end
end
