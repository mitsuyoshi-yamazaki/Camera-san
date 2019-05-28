require "util"  -- I don't know what it does

DEBUG = false

SETTINGS = {}

SETTINGS.name = {}
SETTINGS.name.shrink_button = "shrink_button"
SETTINGS.name.fullscreen_button = "fullscreen_button"

SETTINGS.minimap_size = {}
SETTINGS.minimap_size.default = 296
SETTINGS.minimap_size.expanded = 1200

SETTINGS.zoom_level = {}
SETTINGS.zoom_level.default = 0.25
SETTINGS.zoom_level.expanded = 0.5


-- Events --


script.on_event(defines.events.on_gui_click, function(event)

  -- Fullscreen button --
  if event.element.name == SETTINGS.name.fullscreen_button then
    local player = game.players[event.player_index]
    toggle_fullscreen(player, event.element)
				return

		elseif event.element.name == SETTINGS.name.shrink_button then
    local player = game.players[event.player_index]
    toggle_shrink(player, event.element)
    return
  end

  -- Player buttons --
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

function create_camera_element(player)
  local root_element = player.gui.left

  local camera_frame = root_element.add {type = "frame", name = "camera_frame", direction = "vertical"}
		camera_frame.style.minimal_width = SETTINGS.minimap_size.default

		-- Add System Buttons
		local button_flow = camera_frame.add {type = "flow", name = "button_flow", direction = "horizontal"}
		local button_size = 32

		local shrink_button = button_flow.add {type = "button", name = SETTINGS.name.shrink_button, caption = "Shrink"}
			--shrink_button.style.width = button_size
			shrink_button.style.height = button_size

		local fullscreen_button = button_flow.add {type = "button", name = SETTINGS.name.fullscreen_button, caption = "Fullscreen"}
  --fullscreen_button.style.width = button_size
  fullscreen_button.style.height = button_size


		-- Add Minimap
  local camera_element = camera_frame.add {type = "camera", name = "camera", position = player.position, surface_index = player.surface.index, zoom = SETTINGS.zoom_level.default}
  camera_element.style.minimal_width = 280
  camera_element.style.minimal_height = 280
  camera_element.style.top_padding = 0

  camera_element.style.horizontally_stretchable = true
  camera_element.style.vertically_stretchable = true


  set_target_for(player, player)

  --local title_label = camera_element.add{type = "label", name = "title_label", caption = player.name}
  --title_label.style.top_padding = 0
	 --title_label.style.left_padding = 8

  return camera_element
end

function get_camera_frame_for(player)
		return player.gui.left.camera_frame
end

function get_player_button_flow_for(player)
		return get_camera_frame_for(player).player_button_flow
end

function has_player_button_for(player)
  local button_name = get_button_name(player)
		return get_camera_frame_for(player)[button_name] ~= nil
end

function remove_player_buttons()
  local player_button_names = {}
  for index,player in pairs(game.players) do
    player_button_names[index] = get_button_name(player)
  end

  for _,player in pairs(game.players) do
    local camera_frame = get_camera_frame_for(player)

    for _,child_element in pairs(camera_frame.children) do
      if has_value(player_button_names, child_element.name) then
        child_element.destroy() -- Needs 'reverse' ?
      end
    end
  end
end

function add_player_button(player)
  local camera_frame = get_camera_frame_for(player)

  for _,target in pairs(game.players) do
    local button_name = get_button_name(target)

    local has_character = target.connected
    local has_target_button = has_player_button_for(target)

    if has_character and (has_target_button == false) then
      -- add button
      local button = camera_frame.add{type = "button", name = button_name, caption = target.name}
      button.style.top_padding = 0
      button.style.left_padding = 8

    elseif (has_character == false) and has_target_button then
      -- remove button
      camera_frame[button_name].destroy()
    else
      -- do nothing
    end
  end
end

function update_camera_element()
  for _,player in pairs(game.players) do
    if player.connected then
      if get_camera_frame_for(player) == nil then
        create_camera_element(player)
      end
  
      add_player_button(player)
  
      local camera_element = get_camera_frame_for(player).camera
      local target = get_target_for(player)
  
      camera_element.position = target.position
      camera_element.surface_index = target.surface.index  
    end
  end
end

function toggle_fullscreen(player, button)
		local camera_frame = get_camera_frame_for(player)
		local camera_element = camera_frame.camera

  if camera_frame.style.minimal_width <= SETTINGS.minimap_size.default then
				-- Expand
				button.caption = "Exit"

    camera_frame.style.minimal_width = SETTINGS.minimap_size.expanded
    camera_frame.style.minimal_height = SETTINGS.minimap_size.expanded * 0.6

				camera_element.zoom = SETTINGS.zoom_level.expanded
  else 
				-- Collapse
				button.caption = "Fullscreen"

    camera_frame.style.minimal_width = SETTINGS.minimap_size.default
				camera_frame.style.minimal_height = SETTINGS.minimap_size.default
				
				camera_element.zoom = SETTINGS.zoom_level.default
  end
end

function toggle_shrink(player, button)
		local camera_frame = get_camera_frame_for(player)
		local camera_element = camera_frame.camera

  if camera_element.visible then
    -- Shrink
				camera_element.visible = false

			else 
    -- Expand
				camera_element.visible = true
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