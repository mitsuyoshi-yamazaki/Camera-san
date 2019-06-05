require "util"  -- I don't know what it does
require "mod-gui" -- this? https://github.com/wube/factorio-data/blob/556fd3f5de22fc768468a071dae51af7c4f601d5/core/lualib/mod-gui.lua

SETTINGS = {}
SETTINGS.DEBUG = true

SETTINGS.ELEMENT_NAMES = {}
SETTINGS.ELEMENT_NAMES.CAMERA_TOGGLE_BUTTON = "camera_toggle_button"
SETTINGS.ELEMENT_NAMES.CAMERA_FRAME = "camera_frame"
SETTINGS.ELEMENT_NAMES.SHRINKED_FRAME = "shrinked_frame"


-- Events --

script.on_event(defines.events.on_gui_click, function(event)
  local player = game.players[event.player_index]

		local element_name = event.element.name
		if element_name == SETTINGS.ELEMENT_NAMES.CAMERA_TOGGLE_BUTTON then
			toggle_gui(player)
			return
  end

  for _,target in pairs(game.players) do
    local button_name = get_button_name(target)
    if event.element.name == button_name then
      local button = event.element
      local player = game.players[button.player_index]
      set_target_for(player, target)
      return
    end
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

function create_camera_element(player)
  local root_element = get_root_element_for(player)

		local padding = 8
		local camera_size = 280

		--
  local camera_frame = root_element.add {type = "frame", name=SETTINGS.ELEMENT_NAMES.CAMERA_FRAME, direction = "vertical"}
  camera_frame.style.top_padding = padding
	 camera_frame.style.left_padding = padding
	 camera_frame.style.right_padding = padding
  camera_frame.style.bottom_padding = padding
		camera_frame.style.minimal_width = camera_size + padding * 3
		
		local toggle_button_props = {
    type = "button",
    name = SETTINGS.ELEMENT_NAMES.CAMERA_TOGGLE_BUTTON,
    caption = "Camera"
  }

  local camera_element = camera_frame.add {type = "camera", name="camera", position = player.position, surface_index = player.surface.index, zoom = 0.25}
  camera_element.style.minimal_width = camera_size
  camera_element.style.minimal_height = camera_size

		camera_element.add(toggle_button_props)

  set_target_for(player, player)

		--
  local shrinked_frame = root_element.add {type = "frame", name=SETTINGS.ELEMENT_NAMES.SHRINKED_FRAME, direction = "horizontal"}
  shrinked_frame.style.top_padding = padding
	 shrinked_frame.style.left_padding = padding
	 shrinked_frame.style.right_padding = padding
  shrinked_frame.style.bottom_padding = padding
		shrinked_frame.visible = not camera_frame.visible

		shrinked_frame.add(toggle_button_props)
	end

function remove_player_buttons()
  local player_button_names = {}
  for index,player in pairs(game.players) do
    player_button_names[index] = get_button_name(player)
  end

  for _,player in pairs(game.players) do
    local base_element = get_root_element_for(player)[SETTINGS.ELEMENT_NAMES.CAMERA_FRAME]

    for _,child_element in pairs(base_element.children) do
      if has_value(player_button_names, child_element.name) then
        child_element.destroy() -- Needs 'reverse' ?
      end
    end
  end
end

function add_player_button(player)
  local base_element = get_root_element_for(player)[SETTINGS.ELEMENT_NAMES.CAMERA_FRAME]

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
								local root_element = get_root_element_for(player)
        if root_element[SETTINGS.ELEMENT_NAMES.CAMERA_FRAME] == nil then
          create_camera_element(player)
								end

        add_player_button(player)

        local camera_element = root_element[SETTINGS.ELEMENT_NAMES.CAMERA_FRAME].camera
        local target = get_target_for(player)

        camera_element.position = target.position
        camera_element.surface_index = target.surface.index
    end
  end
end

function toggle_gui(player)
				local root_element = get_root_element_for(player)
				local camera_frame = root_element[SETTINGS.ELEMENT_NAMES.CAMERA_FRAME]
				local shrinked_frame = root_element[SETTINGS.ELEMENT_NAMES.SHRINKED_FRAME]

				camera_frame.visible = not camera_frame.visible
				shrinked_frame.visible = not camera_frame.visible

				print_to(player, camera_frame.visible)
end

function malicious_vicious_migration()
		-- This function removes GUI elements created by Camera-san v1.1.4 or prior
		-- How can we appropriately do this?
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
  if SETTINGS.DEBUG then
    player.print(serpent.block(message))
  end
end
