local localized, CHILDS, CONTENTS = ...

local M = {}
local texts ={}
local scroller_len 
local text
local scroller_collor
local json = require "json"
local last_time = sys.now()


print ("### Scroller INIT")

local function load_config(raw)
    -- proccess the config file 
    local config = json.decode(raw)
    local idx
	local new_sep = {}
	local new_text = {}
	-- init and remoad texts table - table wil contain alterante a text and a separator item 
	texts = {}
	scroller_len = 0
	for idx = 1 , #config.scroller_text_list do
		new_text=config.scroller_text_list[idx]
		new_text.t_width = font.width(new_text.s_text,scroller_size)
		new_text.b_image = resource.create_colored_texture(new_text.b_color.r, new_text.b_color.g, new_text.b_color.b, new_text.b_color.a)
		-- separator has same parameters as text -> copy and update text and width
		new_sep = new_text
		new_sep.s_text = config.scroller_space
		new_sep.t_width = font.width(new_sep.s_text,scroller_size)
		texts[(idx*2)-1] = new_text
		texts[(idx*2)] = new_sep
		scroller_len = scroller_len + new_text.width + new_sep.width
	end 
    text_color = config.scroller_text_list[1].t_color
end 

function M.unload()
    print "###scroller module is unloaded"
end

function M.content_update(name)
    print("###scroller module content update", name)
    if name == "config.json" then 
	local my_config = resource.load_file(localized(name))
	load_config(my_config)
    end
end

function M.content_remove(name)
    print("scroller module content delete", name)
end

function draw_scroller()
   -- move scroller_pos to next postion 
   local curent_time = sys.now()
   scroller_pos = scroller_pos + ((curent_time-last_time) * scroller_speed)
   last_time : current_time
   -- rest the postion if we are at a full lengt away from 0
   if math.abs(scroller_pos) > scroller_len then
	scroller_pos = 0
   end 
   -- start at the most left position 
   if scroller_pos <= 0 then 
	textstart = scroller_pos 
   else 
	textstart = scroller_pos - scroller_len
   end  
   -- keep loping over the texts until textend is offscreen
	repeat
	   --loop over texts
		textend = scroller_offset + screen_width +1 -- temp to get out off loop
		-- update textend
		-- if on screen draw text and background 
		-- update textstart (for next run)
	   -- loop
	until textend > scroller_offset + screen_width
		
	--check if text will be on screen for current position 
   offscreen_pos_left =  0 - scroller_text_len - scroller_space_len
   --reset to most left position  
   while scroller_pos > offscreen_pos_left do
      scroller_pos = scroller_pos - scroller_text_len - scroller_space_len
   end
   -- correct calculation, while always ends a fulltext to far to the left
   scroller_pos = scroller_pos + scroller_text_len + scroller_space_len
   -- write text and repeat writing until we are a the end of the screen  
   draw_pos = scroller_pos 
   while draw_pos < scroller_offset - scroller_text_len - scroller_space_len do
      draw_pos = draw_pos + scroller_text_len + scroller_space_len
   end
   draw_pos = draw_pos - scroller_offset
	repeat
	  scroller_font:write(draw_pos, 0, scroller_text .. scroller_space, scroller_size, text_color.r,text_color.g,text_color.b,text_color.a)
      draw_pos = draw_pos + scroller_text_len + scroller_space_len
	until draw_pos > scroller_offset + screen_width
 
 
end 


function M.draw()
   if scroller_mode == "SCROLLER" then 
      draw_scroller()
   elseif scroller_mode == "INFO" then 
      scroller_font:write(0, 0, "MY IP", scroller_size, 1,1,0,1)
   end 
end

return M
