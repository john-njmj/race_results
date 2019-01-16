-- RESULTS
local localized, CHILDS, CONTENTS = ...

print("RESULTS sub module INIT")
local M = {}
local results = {}
local V_pos = scroller_size + 10
--local pic1 = resource.load_image(localized("foto1.jpg"))
--local pic2 = resource.load_image(localized("foto2.jpg"))
local rotate = 0 

function init_results ()
   for i,result_file in ipairs(result_files) do
      if name == result_file then
         results[i] = "Null"
      end
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
 
   H_pos = {}
   --start from left until you get to name
   H_pos[1] = 0 --Postion most left on the screen 
   H_pos[2] = H_pos[1] + result_ref_width2 + result_ref_width_sep -- race number 
   H_pos[3] = H_pos[2] + result_ref_width3 + result_ref_width_sep -- Name
   --Start from right until you are at the first race ( = name +1)
   -- use first line as Reference
   items = lines[1]
   H_pos[#items] = screen_width - result_ref_width3 - result_ref_width_sep -- Total most right
   for i = #items-1 ,5, -1 do  -- loop over the races 
      H_pos[i]=H_pos[i+1]- result_ref_width2 - result_ref_width_sep
   end
   H_pos[4] = H_pos[5] - result_ref_width3 - result_ref_width_sep -- club code 
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
         else
            result_font:write(H_pos[j],V_pos, item,result_size,1,1,1,a)
         end
      end
      V_pos= V_pos + result_size + 5
   end
   V_pos= V_pos + result_size + 5 -- create separation between results
end 


function M.draw()

   if result_mode == "RESULT" then
      V_pos = scroller_size + 10
      for r,result in ipairs(results) do 
         if result ~= "Null" then 
            draw_result(result)
         end
      end 
   elseif result_mode == "INFO" then
      result_font:write(0,300,"configuration INFO",45,1,1,1,1)
      local serial = sys.get_env "SERIAL"
      result_font:write(0,350,"Device Serial Nr :" .. serial,45,1,1,1,1)
      if  WIDTH == screen_width then 
         result_font:write(0,400,"Device Screen width :" .. WIDTH .. " screen width config : " .. screen_width,45,0,1,0,1)
      else 
         result_font:write(0,400,"Device Screen width :" .. WIDTH .. " screen width config : " .. screen_width,45,1,0,0,1)
      end 
      result_font:write(0,450,"Screen config info : " .. screen_error,45,1,1,1,1) 
      result_font:write(0,500,"This screen will display :" ,45,1,1,1,1)
      for i,result_file in ipairs(result_files) do
         result_font:write(0,500+(i-1 *50),result_file,45,1,1,1,1)
      end
      result_font:write(0,screen_height - 800,"Screen Number / Screen Count",45,1,1,1,1)      
      result_font:write(0,screen_height - 750,screen_number .. "/" .. screen_count,750,1,1,1,1)      
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
