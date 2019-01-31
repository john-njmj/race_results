local localized, CHILDS, CONTENTS = ...

local M = {}
local text
local scroller_collor

print ("### Scroller INIT")

local function load_config(raw)
    -- proccess the config file 
    local config = json.decode(raw)
    scroller_collor = config.scroller_color
end 

function M.unload()
    print "scroller module is unloaded"
end

function M.content_update(name)
    print("scroller module content update", name)
    if name == "config.json" then 
	Load_config(name)
    end
end

function M.content_remove(name)
    print("scroller module content delete", name)
end

function draw_scroller()
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
		scroller_font:write(draw_pos, 0, scroller_text .. scroller_space, scroller_size, scroller_color.r,scroller_color.b,scroller_color.g,scroller_color.a)
      draw_pos = draw_pos + scroller_text_len + scroller_space_len
	until draw_pos > scroller_offset + screen_width
 
 -- move scroller_pos for next frame
   scroller_pos = scroller_pos + scroller_speed
end 


function M.draw()
   if scroller_mode == "SCROLLER" then 
      draw_scroller()
   elseif scroller_mode == "INFO" then 
      scroller_font:write(0, 0, "MY IP", scroller_size, 1,1,0,1)
   end 
end

return M
