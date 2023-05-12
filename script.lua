print("-- model reloaded --")

math.randomseed(world.getTime())

local function get_model_by_path(list, root)
	if root == nil then
		root = models:getChildren()
	else
		root = root:getChildren()
	end

	local resolving = list[1]
	table.remove(list, 1)

	for _, v in pairs(root) do
		if v:getName() == resolving then
			if #list < 1 then
				return v
			else
				return get_model_by_path(list, v)
			end
		end
	end
	error("Invalid model path!", 2)
end

local on_new_player = {}
local players
events.TICK:register(function()
	if host:isHost() then
		if players == nil then
			players = world.getPlayers()
			for _, event in ipairs(on_new_player) do
				event()
			end
		else
			for k, _ in pairs(world.getPlayers()) do
				if players[k] == nil then
					for _, event in ipairs(on_new_player) do
						event()
					end
					break
				end
			end
		end
	end
end, "update_new_players")

local default_page = action_wheel:newPage('Root')
action_wheel:setPage(default_page)
function action_wheel.rightClick()
	action_wheel:setPage(default_page)
end


--hide vanilla model
vanilla_model.PLAYER:setVisible(false)

--hide vanilla cape model
vanilla_model.CAPE:setVisible(false)

--hide vanilla elytra model
vanilla_model.ELYTRA:setVisible(false)


nameplate.ALL:setText("♥ Octelly")
nameplate.ENTITY:setPos(0, 0.3, 0)

-- IMPOSTOR {{{
if false then
	local impostor_walking = false
	
	--@param r number 1-100
	--@param g number 1-100
	--@param b number 1-100
	--@return vectors.Vector3
	local function rgb100(r,g,b)
		return vec(r,g,b):scale(1/100)
	end
	
	
	local impostor_colors = {
		red    = rgb100( 77.6,  6.7,  6.7),
		blue   = rgb100(  7.5, 18.0, 82.4),
		green  = rgb100(  6.7, 50.2, 17.6),
		pink   = rgb100( 93.3, 32.9, 73.3),
		orange = rgb100( 94.1, 49.0,  5.1),
		yellow = rgb100( 96.5, 96.5, 34.1),
		black  = rgb100( 24.7, 27.8, 30.6),
		white  = rgb100( 84.3, 88.2, 94.5),
		purple = rgb100( 42.0, 18.4, 73.7),
		brown  = rgb100( 44.3, 28.6, 11.8),
		cyan   = rgb100( 22.0, 88.6, 86.7),
		lime   = rgb100( 31.4, 94.1, 22.4),
		maroon = rgb100( 42.0, 16.9, 23.5),
		rose   = rgb100( 92.5, 75.3, 82.7),
		banana = rgb100(100.0, 99.6, 74.5),
		gray   = rgb100( 51.4, 59.2, 65.5),
		tan    = rgb100( 57.3, 52.9, 46.3),
		coral  = rgb100( 92.5, 45.9, 47.1)
	}
	
	local impostor_color_pages = {}
	for k,v in pairs(impostor_colors) do
		if #impostor_color_pages == 0 then
			table.insert(impostor_color_pages, action_wheel:newPage("impostor_colors_1"))
		elseif #impostor_color_pages == 1 and impostor_color_pages[1]:getAction(7) ~= nil then
	
			table.insert(impostor_color_pages, action_wheel:newPage("impostor_colors_"..tostring(#impostor_color_pages+1)))
			local next = impostor_color_pages[1]:newAction()
			next:setTitle("next")
			next:onLeftClick(function()
				action_wheel:setPage(impostor_color_pages[2])
			end)
			local prev = impostor_color_pages[2]:newAction()
			prev:setTitle("prev")
			prev:onLeftClick(function()
				action_wheel:setPage(impostor_color_pages[1])
			end)
	
		elseif impostor_color_pages[#impostor_color_pages]:getAction(7) ~= nil then
			table.insert(impostor_color_pages, action_wheel:newPage("impostor_colors_"..tostring(#impostor_color_pages+1)))
			local next = impostor_color_pages[#impostor_color_pages-1]:newAction()
			next:setTitle("next")
			next:onLeftClick(function()
				action_wheel:setPage(impostor_color_pages[#impostor_color_pages])
			end)
			local prev = impostor_color_pages[#impostor_color_pages]:newAction()
			prev:setTitle("prev")
			prev:onLeftClick(function()
				action_wheel:setPage(impostor_color_pages[#impostor_color_pages-1])
			end)
		end
	
		local action = impostor_color_pages[#impostor_color_pages]:newAction()
	
		for _, texture in ipairs(textures:getTextures()) do
			if texture:getName() == "impostor."..k then
				local width, height = texture:getDimensions():unpack()
				action:setTexture(texture, 0, 0, width, height, 0.1)
				break
			end
		end
		action:setColor(v)
	
		function action.leftClick()
			models.impostor.root.colorable:setColor(v)
		end
	end
	
	local impostor_page_action = default_page:newAction()
	function impostor_page_action.leftClick()
		action_wheel:setPage(impostor_color_pages[1])
	end
	
	
	
	
	
	events.ENTITY_INIT:register(function()
		models.impostor.root.colorable:setColor(77.6/100, 6.7/100, 6.7/100)
		models.impostor:setParentType("WORLD")
		models.impostor:setPos(player:getPos():add(1, 0.07, 0):scale(16))
		animations.impostor.walking:setSpeed(0.7)
	end)
	
	events.RENDER:register(function(delta)
		local delta_table = models.impostor:getPos():scale(1/16) - player:getPos():add(0, 0.07, 0)
		local delta_vec = vec(delta_table[1], delta_table[2], delta_table[3])
		if delta_vec:length() < 1 then
			impostor_walking = false
			animations.impostor.walking:stop()
		elseif delta_vec:length() > 2 then
			impostor_walking = true
			animations.impostor.walking:play()
		end
		if impostor_walking then
			models.impostor:setPos(models.impostor:getPos():add(delta_vec:normalize():scale(-0.1):scale(delta)))
			local abs_deg
			local relative_deg = math.deg(math.atan(math.abs(delta_vec.z/delta_vec.x)))
			if delta_vec.z >0 then
				if delta_vec.x > 0 then
					-- 1st quadrant
					abs_deg = relative_deg
				else
					-- 2nd quadrant
					abs_deg = 180 - relative_deg
				end
			else
				if delta_vec.x < 0 then
					-- 3rd quadrant
					abs_deg = 180 + relative_deg
				else
					-- 4th quadrant
					abs_deg = 360 - relative_deg
				end
			end
			abs_deg = ((abs_deg + 90) % 360) - 180
			models.impostor:setRot(0, 180-abs_deg)
	
		elseif delta_vec.y ~= 0 then
			local x, y, z = models.impostor:getPos():unpack()
			models.impostor:setPos(x, y+delta_vec:normalize():scale(-0.3):scale(delta).y, z)
		end
	
		if world.getBlockState(models.impostor:getPos():scale(1/16)):getID() ~= "minecraft:air" then
			local newpos = models.impostor:getPos()
			newpos.y = player:getPos():add(0, 0.07, 0):scale(16).y
			models.impostor:setPos(newpos)
			while world.getBlockState(models.impostor:getPos():scale(1/16)):getID() ~= "minecraft:air" do
				models.impostor:setPos(models.impostor:getPos():add(0,16,0))
			end
		end
	
		if not impostor_walking then
			local playerRot = player:getRot()
			local playerX = math.map(-playerRot.x, -90, 90, -20, 30)
			local playerY = 180 - (playerRot.y % 360)
			models.impostor:setRot(playerX, playerY, 0)
		end
	end)
else
	models.impostor:setVisible(false)
end
-- }}}

local wet = 0
if host:isHost() then
	local drying_delta = 0
	local drying_min = 60
	local drying_max = 120
	events.TICK:register(function()
		--print()
		--print(world.getBlockState(player:getPos():add(0, 1.9, 0)))  -- completely submerged
		--print(world.getBlockState(player:getPos():add(0, 1.6, 0)))  -- head under water
		--print(world.getBlockState(player:getPos():add(0, 1.3, 0)))  -- is wet
		--print(world.getBlockState(player:getPos():add(0, 1, 0)))    -- block above
		--print(world.getBlockState(player:getPos():add(0, 0.3, 0)))  -- wet feet
		--print(world.getBlockState(player:getPos()))                 -- player pos

		local old_wet = wet

		for i = 0.3, 2, 0.1 do
			i = math.floor(i*10+0.5)/10
			if wet <= i and world.getBlockState(player:getPos():add(0, i, 0)):getID() == "minecraft:water" then
				wet = i
			end
		end

		if drying_delta >= drying_min + math.floor(math.random()*(drying_min-drying_max)) then
			drying_delta = 0
			wet = (wet*10-1)/10
		end

		if wet <  0.3 then wet          = 0 end
		if wet == 0   then drying_delta = 0 else
			                 drying_delta = drying_delta + 1 end

		if wet ~= old_wet then
			pings.set_wet(wet)
		end
	end)
end
function pings.set_wet(new_wet)
	wet = new_wet
	print(wet)
end


local eyelids = get_model_by_path({'model','root','Head',"Eyelids"})
if host:isHost() then
	local eyelids_delta = 0
	local blink_interval_min = 60
	local blink_interval_max = 120
	local blink_length = 3
	events.TICK:register(function()
		if eyelids:getVisible() and eyelids_delta >= blink_length then
			eyelids_delta = 0
			pings.show_eyelids(false)
		elseif eyelids_delta >= blink_interval_min + math.floor(math.random()*(blink_interval_max-blink_interval_min)) then
			eyelids_delta = 0
			pings.show_eyelids(true)
		end
		eyelids_delta = eyelids_delta + 1
	end)
end
function pings.show_eyelids(bool)
		eyelids:setVisible(bool)
end


local ears = require "ears" (models.model.root.Head.Ears.Left, models.model.root.Head.Ears.Right)
ears.config = {
    default_angle = 0,
    sneak_angle = 0,
}
local getVelocity = require "velocity"

events.TICK:register(function()
    local _, _, rot_vel, head_vel = getVelocity()
    ears.tick(rot_vel, head_vel)
end, "ears_by_dragekk-tick")
events.RENDER:register(ears.render)



local meow_action = default_page:newAction()
meow_action:item("minecraft:cod")
meow_action:title("Meow! :3")
meow_action:onLeftClick(function()
	pings.meow_action()
end)
function pings.meow_action()
	sounds:playSound("minecraft:entity.cat.ambient", player:getPos(), 1, 1, false)
end

local halo_model = get_model_by_path({'model','root','Halo'})
local halo_toggle = default_page:newAction()
halo_toggle:setItem("minecraft:iron_nugget")
halo_toggle:setToggleItem("minecraft:gold_nugget")
halo_toggle:setTitle("Halo OFF")
halo_toggle:setToggleTitle("Halo ON")
halo_toggle:onToggle(function(bool, _)
	pings.halo_toggle(bool)
end)
animations.model.halo_float:play()
animations.model.halo_rotate:play()
local halo_particle_delta = 0
events.TICK:register(function()
	if halo_model:getVisible() then
		if halo_particle_delta > (15+math.floor(math.random()*60)) then
			particles:newParticle("minecraft:instant_effect", player:getPos():add(math.random()*0.4-0.2, 2.2, math.random()*0.4-0.2), 0, 0, 0)
			-- /particle minecraft:end_rod ~ ~2.3 ~ 0.2 0 0.2 0 1
			halo_particle_delta = 0
		else
			halo_particle_delta = halo_particle_delta + 1
		end
	end
end)
events.RENDER:register(function(delta)
	halo_model:setRot(0, player:getBodyYaw(delta))
end)
function pings.halo_toggle(state)
	if halo_model:getVisible() ~= state then
		halo_model:setVisible(state)
		local pitch = 1.2
		if state == false then pitch = 0.8 end
		sounds:playSound("minecraft:block.note_block.chime", player:getPos(), 1, pitch, false)
	end
end
halo_toggle:setToggled(halo_model:getVisible())

table.insert(on_new_player, function()
	if host:isHost() then
		if players == nil then
			players = world.getPlayers()
			pings.halo_toggle(halo_toggle:isToggled())
		else
			for k, _ in pairs(world.getPlayers()) do
				if players[k] == nil then
					pings.halo_toggle(halo_toggle:isToggled())
					break
				end
			end
		end
	end
end)

local tail_frame = 0

local tail_anim_length = 300
local tail_joint_offset = 0.7
local tail_anim_intensity = 13
local tail = {}
tail[1] = get_model_by_path({'model','root','Body','Tail'})
tail[2] = get_model_by_path({'Part2'}, tail[1])
tail[3] = get_model_by_path({'Part3'}, tail[2])
tail[4] = get_model_by_path({'Part4'}, tail[3])
--local tail_offsets = {-19.14 + 45, 15, -8, -14.77}
local tail_offsets = {-90 + 45, 10, -8, -9}
events.RENDER:register(function(delta, render_mode)
	tail_frame = tail_frame + (1 + player:getVelocity():length()*10)*delta

	if tail_frame > tail_anim_length then tail_frame = tail_frame - tail_anim_length end
	
	local anim_point = (tail_frame / tail_anim_length)
	for i, tail_part in ipairs(tail) do
		tail_part:setRot(math.sin(2 * math.pi * (anim_point + tail_joint_offset*i/#tail)) * (tail_anim_intensity + player:getVelocity():length()*5) +
			tail_offsets[i] -
			math.max(math.min(player:getVelocity():length()*60, 0), -25)*(#tail/i/#tail), 0, 0)
	end
end)
