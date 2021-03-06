-- RESULTS
local localized, CHILDS, CONTENTS = ...

print("RESULTS sub module INIT")
local M = {}
local json = require "json"
local results = {}
local clublogos = {}
local V_pos = scroller_size + 10
--local pic1 = resource.load_image(localized("foto1.jpg"))
--local pic2 = resource.load_image(localized("foto2.jpg"))
local rotate = 0 

local function load_config(raw)
    -- proccess the config file 
    local config = json.decode(raw)
    local idx
    local clublogo = {}
	 clublogos = {} -- (re)init the table with the logos 
    for idx , clublogo in ipairs(config.clublogos) do
      clublogos[clublogo.code] = resource.load_image(localized(clublogo.file.asset_name))
    end 
end 

function init_results ()
   for i,result_file in ipairs(result_files) do
      --if name == result_file then
         results[i] = "Null"
      --end
   end
end

function load_results(my_result_file)
   local my_results = resource.load_file(localized(my_result_file))
   local lines = {}
   for line in my_results:gmatch("[^\n]+") do
      line=trim(line)
      local items={}
      for item in line:gmatch("[^,]+") do
         items[#items+1] = trim(item)
      end
      lines[#lines+1] = items
   end
   return lines
end

function M.unload()
    print("RESULTS sub module is unloaded")
end

function M.content_update(name)
    print("RESULT sub module content update ", name)
    for i,result_file in ipairs(result_files) do
      print("result_file : ",result_file)
      if name == result_file then
         print("found ", result_file , " = ",name)
         results[i] = load_results(name)
      end
    end
    if name == "config.json" then 
		local my_config = resource.load_file(localized(name))
		load_config(my_config)
    end
end

function M.content_remove(name)
    print("RESULT sub module content delete ", name)
    for i,result_file in ipairs(result_files) do
      if name == result_file then
         results[i] = "Null"
      end
    end   
end


function draw_result(lines)
 
   local H_pos = {}
   --start from left until you get to name
   H_pos[1] = 0 --Postion most left on the screen 
   H_pos[2] = H_pos[1] + result_ref_width2 + result_ref_width_sep -- race number 
   H_pos[3] = H_pos[2] + result_ref_width3 + result_ref_width_sep -- Name
   --Start from right until you are at the first race ( = name +1)
   -- use first line as Reference
   items = lines[1]
   H_pos[#items] = screen_width - result_ref_width3 -- Total most right
   for i = #items-1 ,5, -1 do  -- loop over the races 
      H_pos[i]=H_pos[i+1]- result_ref_width3 - result_ref_width_sep
   end
   H_pos[4] = H_pos[5] - result_ref_width4 - result_ref_width_sep - result_size - result_ref_width_sep -- club code 
   max_size_name = H_pos[4] - H_pos[3] 
  
   for i,line in ipairs(lines) do
      -- alternate the opacity 
      if (i % 2) == 0 then 
         a=.9
      else
         a = 1
      end 
      -- when header (i=1) first print the title
      if i == 1 then
            titel_H_pos = (screen_width / 2) - (result_font:width(line[3],result_size * 2) / 2)
            if titel_H_pos < 0 then 
               titel_H_pos = 0
            end
            result_font:write(titel_H_pos,V_pos,line[3],result_size * 2 ,1,1,0,1)
            V_pos = V_pos + (result_size * 2 ) + 10
      end
      -- loop over the items
      for j,item in ipairs(line) do
         -- special action for item 3 Title/Name
         if j == 3 then 
           if i ~= 1 then -- Do not print titel in header line  
            -- name recalculate to size to let it fit. 
            name_size = result_size 
              while result_font:width(item, name_size) > max_size_name do
                  name_size = name_size * 0.9
              end
            result_font:write(H_pos[j],V_pos,item,name_size,1,1,0,a)
           end
         elseif j == 4 then  -- special action for item 4 Club code 
            if clublogos[item] ~= nil then  
               clublogos[item]:draw(H_pos[j],V_pos, H_pos[j] + result_size,V_pos + result_size,a)
	    end 
            result_font:write(H_pos[j] + result_size + result_ref_width_sep,V_pos, item,result_size,1,1,1,a)
         else   
            result_font:write(H_pos[j],V_pos, item,result_size,1,1,1,a)
         end
      end
      V_pos= V_pos + result_size + 5
   end
   V_pos= V_pos + result_size + 5 -- create separation between results
end 

function draw_info_line(info_text,info_v_pos,info_size,info_collor)
   local R
   local G
   local B
   local my_size 
   local ref_width
   if info_collor == "red" then
        R=1
        G=0
        B=0
   elseif info_collor == "green" then
        R=0
        G=1
        B=0
   else
        R=1
        G=1
        B=1
   end
   if info_size == "max" then 
      if screen_height - info_v_pos < 400 then
         my_size = screen_height - info_v_pos
      else
         my_size = 400
      end 
   else 
      my_size = info_size
   end    
   while result_font:width(info_text,my_size) > screen_width do
                  my_size = my_size * 0.95
   end
   result_font:write(0,info_v_pos,info_text,my_size,R,G,B,1)
   info_v_pos = info_v_pos + my_size + 5 -- set vertical position for next line and retrun it
   return info_v_pos 
end


function M.draw()

   if result_mode == "RESULT" then
      if result_logo_a ~= 0 then
         local p_h
         local p_w
         p_h = (screen_width / 2)-(result_logo_w /2)
         p_v = (screen_height /2)-(result_logo_h /2)
         result_logo:draw(p_h ,p_v, p_h + result_logo_w,p_v + result_logo_h,result_logo_a / 100)
      end
      V_pos = scroller_size + 10
      for r,result in ipairs(results) do 
         if result ~= "Null" then 
            draw_result(result)
         end
      end 
   elseif result_mode == "INFO" then
      local error_collor
      --draw_info_line(text,pos,size,collor)
      IV_pos = draw_info_line("System and configuration INFORMATION",scroller_size + 10,45,"white")   
      IV_pos = draw_info_line("Device Serial Nr :" .. sys.get_env "SERIAL",IV_pos,45,"white")   
      --local serial = sys.get_env "SERIAL"
      if  screen_width_config == screen_width then 
         error_collor = "green"
      else 
         error_collor = "red"
      end 
      IV_pos = draw_info_line("Screen width Device / config :" .. screen_width .. " / " .. screen_width_config,IV_pos,45,error_collor)
      IV_pos = draw_info_line("Scroller Offset : " .. scroller_offset,IV_pos,45,"white")
      IV_pos = draw_info_line("Screen config info : " .. screen_error,IV_pos,45,"white")
      IV_pos = draw_info_line("This screen will display :" ,IV_pos,45,"white")
      for i,result_file in ipairs(result_files) do
         IV_pos = draw_info_line("        " .. i .. " - " .. result_file,IV_pos,45,"white")
      end
      IV_pos = draw_info_line("Screen Number / Screen Count",IV_pos,45,"white")
      IV_pos = draw_info_line(screen_number .. "/" .. screen_count,IV_pos,"max","white")
   elseif result_mode == "PIC" then
      gl.translate(540,0,540)
      gl.rotate(rotate, 0, 540,0)
      rotate = rotate + 1
      if rotate == 360 then 
         rotate = 0
      end
      if rotate > 90 and rotate < 270 then 
         pic1:draw(-540,scroller_size, screen_width-540,screen_height)
      else
         pic2:draw(-540,scroller_size, screen_width-540,screen_height)
      end 
   end
end
return M
