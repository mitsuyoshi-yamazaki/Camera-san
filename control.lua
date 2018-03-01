require "util"  -- I don't know what it does

script.on_event(defines.events.on_player_created, function(event)
  local player = game.players[event.player_index]
  create_camera_element(player)
  update_player_buttons()
end)

script.on_event(defines.events.on_gui_click, function(event)
  local player = game.players[event.player_index]
  player.print(event.element.name)

  for _,target in pairs(game.players) do
    local button_name = get_button_name(target)
    if event.element.name == button_name then
      local button = event.element
      local player = game.players[button.player_index]
      set_target_for(player, target)
      break
    else
      player.print("nop")
    end
  end
end)

script.on_event(defines.events.on_tick, function(event)
  if game.tick % 1 == 0 then
    update_camera_element()
  end
end)

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
  player.print("Change target from " .. get_target_for(player).name .. " to " .. target.name)
  global[player.name] = target.index
end

function create_camera_element(player)
  local root_element = player.gui.left

  local base_element = root_element.add {type = "frame", name="camera_frame", direction = "vertical"}
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

  set_target_for(player, player)

  --local title_label = camera_element.add{type = "label", name = "title_label", caption = player.name}
  --title_label.style.top_padding = 0
	--title_label.style.left_padding = 8

  return camera_element
end

function update_player_buttons() 
  remove_player_buttons()
  add_player_buttons()
end

function remove_player_buttons()
  local base_element = player.gui.left.camera_frame

  local player_button_names = {}
  for index,player in pairs(game.players) do
    player_button_names[index] = get_button_name(player)
  end

  for _,player in pairs(game.players) do    
    for child_element in base_element.children do
      if has_value(player_button_names, child_element.name) then
        child_element.destroy() -- Needs 'reverse' ?
      end
    end
  end
end

function add_player_buttons()
  local base_element = player.gui.left.camera_frame

  for index,player in pairs(game.players) do
    local button_name = get_button_name(player)
    local button = base_element.add{type = "button", name = button_name, caption = player.name}
    button.style.top_padding = 0
	  button.style.left_padding = 8
  end
end

function update_camera_element()
  for _,player in pairs(game.players) do
    local camera_element = player.gui.left.camera_frame.camera
    local target = get_target_for(player)

    camera_element.position = target.position
    camera_element.surface_index = target.surface.index
  end
end

local function has_value(table, value)
  for _,v in pairs(table) do
      if v == value then
          return true
      end
  end
  return false
end