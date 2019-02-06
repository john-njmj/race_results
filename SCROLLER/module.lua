local localized, CHILDS, CONTENTS = ...

local M = {}
local texts ={}
local scroller_len 
local text
local scroller_collor
local json = require "json"
local last_time = sys.now()


print ("### Scroller INIT")
local scroller_speed = - 10 -- default scroller_speed
local scroller_font = resource.load_font(localized("font.ttf")) -- default font 

local function load_config(raw)
    -- proccess the config file 
    local config = json.decode(raw)
    local idx
	-- 
	scroller_speed = config.scroller_speed
	if CONTENTS[localized(config.scroller_font.asset_name)] then
           scroller_font = resource.load_font(localized(config.scroller_font.asset_name))
        else 
         print ("Scroller_font not found : ",config.scroller_font.asset_name)
        end 
	
	
	-- init and reload texts table - table wil contain alterante a text and a separator item 
	texts = {}
	scroller_len = 0
	for idx , text_line in ipairs(config.scroller_text_list) do
		texts[((idx*2)-1)] ={}
		texts[((idx*2)-1)].t_active = text_line.t_active
		texts[((idx*2)-1)].t_color = text_line.t_color
		texts[((idx*2)-1)].b_image = resource.create_colored_texture(text_line.b_color.r, text_line.b_color.g, text_line.b_color.b, text_line.b_color.a)
		texts[((idx*2)-1)].s_text = text_line.s_text
		texts[((idx*2)-1)].t_width = scroller_font:width(text_line.s_text,scroller_size)
		scroller_len = scroller_len + texts[((idx*2)-1)].t_width
		texts[(idx*2)] ={}
		texts[(idx*2)].t_active = text_line.t_active
		texts[(idx*2)].t_color = text_line.t_color
		texts[(idx*2)].b_image = resource.create_colored_texture(text_line.b_color.r, text_line.b_color.g, text_line.b_color.b, text_line.b_color.a)
		texts[(idx*2)].s_text = config.scroller_space 
		texts[(idx*2)].t_width = scroller_font:width(config.scroller_space,scroller_size)
		scroller_len = scroller_len + texts[(idx*2)].t_width
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
   last_time = curent_time
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
	   for idx , text_line in ipairs(texts) do
		--loop over texts
		textend = textstart + text_line.t_width
		if (textstart < screen_offset and textend > screen_offset) or (textstart >= screen_offset and textstart <= screen_offset +screen_width) then
		   --draw background
		   scroller_font:write(textstart, 0, text_line.s_text, scroller_size, text_line.t_color.r,text_line.t_color.g,text_line.t_color.b,text_line.t_color.a)
		end				
		textstart = textend
		-- breack if textstart is off screen 
	   end
	until textend > scroller_offset + screen_width
--OLD code 		
--	--check if text will be on screen for current position 
--   offscreen_pos_left =  0 - scroller_text_len - scroller_space_len
--   --reset to most left position  
--   while scroller_pos > offscreen_pos_left do
--      scroller_pos = scroller_pos - scroller_text_len - scroller_space_len
--  end
--   -- correct calculation, while always ends a fulltext to far to the left
--   scroller_pos = scroller_pos + scroller_text_len + scroller_space_len
--   -- write text and repeat writing until we are a the end of the screen  
--   draw_pos = scroller_pos 
--   while draw_pos < scroller_offset - scroller_text_len - scroller_space_len do
--      draw_pos = draw_pos + scroller_text_len + scroller_space_len
--   end
--   draw_pos = draw_pos - scroller_offset
--	repeat
--	  scroller_font:write(draw_pos, 0, scroller_text .. scroller_space, scroller_size, text_color.r,text_color.g,text_color.b,text_color.a)
--      draw_pos = draw_pos + scroller_text_len + scroller_space_len
--	until draw_pos > scroller_offset + screen_width
 
 
end 


function M.draw()
   if scroller_mode == "SCROLLER" then 
      draw_scroller()
   elseif scroller_mode == "INFO" then 
      scroller_font:write(0, 0, "MY IP", scroller_size, 1,1,0,1)
   end 
end

return M
