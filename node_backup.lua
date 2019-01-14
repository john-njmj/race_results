-- init
gl.setup(NATIVE_WIDTH, NATIVE_HEIGHT)
--local st = util.screen_transform(90)
local loader = require "loader"

-- screensetup parameters 
screen_number = 1 -- done
number_of_screens = 1 -- done
screen_width = WIDTH -- not in ini
screen_height = HEIGHT -- not in ini

-- scroller parameters and defaults  
scroller_mode = "SCROLLER" -- SCROLLER - INFO
scroller_pos = 0 -- not in ini added to decode for TCP connection 
scroller_size = 200 -- done
scroller_speed = -10 -- done
scroller_space = " --- " --done
scroller_text = "STE Results" --done
scroller_width = WIDTH --done
scroller_offset = 0 --(screen_number -1) *WIDTH

--scroller_font = resource.load_font("font.ttf")
--scroller_font = resource.load_font("ballplay.ttf")
scroller_font = resource.load_font("Tango.TTF") -- not in ini

-- result parameters and defaults
result_mode ="PIC"   -- RESULT - INFO - PIC
result_size = 40
result_files={"results_sm.csv", "results_sj.csv"}
--result_font = resource.load_font("ariblk.ttf")
--result_font = resource.load_font("ballplay.ttf")
--result_font = resource.load_font("Tango.TTF")
result_font = resource.load_font("ARIALN.TTF") -- not in ini

-- funtions 
local function set_result_param(my_size)
   result_size = my_size
   result_ref_width_sep = result_size 
   result_ref_width2 = result_font:width("99", result_size)
   result_ref_width3 = result_font:width("999", result_size)
end 
local function scroller_update(my_text, my_space, my_size)
   -- set text & spacer and calculate the length
   scroller_text = my_text
   scroller_space = my_space
   scroller_size = my_size
   scroller_text_len = scroller_font:width(scroller_text, scroller_size)
   scroller_space_len = scroller_font:width(scroller_space, scroller_size)
end

local function update_parameter(par_name,par_val)
   print ("Found parameter : ",par_name)
   print ("with Value : ",par_val)
   if par_name == "screen_number" then 
      screen_number = tonumber(par_val)
   elseif par_name == "number_of_screens" then
      number_of_screens = tonumber(par_val)
   elseif par_name == "scroller_mode" then 
      scroller_mode = par_val
   elseif par_name == "scroller_size" then
      scroller_update(scroller_text, scroller_space, tonumber(par_val))
   elseif par_name == "scroller_speed" then
      scroller_speed = tonumber(par_val)
   elseif par_name == "scroller_space" then
      scroller_update(scroller_text, par_val, scroller_size)
   elseif par_name == "scroller_text" then
      scroller_update(par_val, scroller_space, scroller_size)
   elseif par_name == "scroller_width" then
      scroller_width = tonumber(par_val)
   elseif par_name == "scroller_offset" then
      scroller_offset = tonumber(par_val)
   elseif par_name == "scroller_pos" then
      scroller_pos = tonumber(par_val)
   elseif par_name == "result_mode" then 
      result_mode = par_val
   elseif par_name == "result_size" then    
      set_result_param(tonumber(par_val))
   else
      print ("unknown PARAMETER :", par_name)
   end
end 

function trim(s)
   return (s:gsub("^%s*(.-)%s*$", "%1"))
end

local function decode_parameter_line(my_parameter)
   my_parameter=trim(my_parameter)
   if string.sub(my_parameter, 1, 1) ~= "#" then
      local items={}
      for item in my_parameter:gmatch("[^=]+") do
         items[#items+1] = trim(item)
      end
      if #items == 2 then 
         update_parameter(items[1],items[2])
      else 
         print ("Wrong formatted parameter : ",my_parameter)
      end
   else -- comment line 
      print ("Comment line : ",my_parameter)
   end
end

local function load_parameter_file(my_parameters)
--   local my_parameters = resource.load_file(my_parameter_file)
   for parameter in my_parameters:gmatch("[^\n]+") do
      decode_parameter_line(parameter)
   end
end

--local function decode_command(line)
--    scroller_update(line,scroller_space,scroller_size) 
--end

-- init
-- run delfault calculations 
set_result_param(result_size)
scroller_update(scroller_text, scroller_space,scroller_size)

-- load paramteres from ini file , watch file for changes and reload
util.file_watch("SCREEN.ini", function(content)
    load_parameter_file(content)
end)

-- load_parameter_file("SCREEN.ini")



node.alias "scroller"

node.event("input", decode_parameter_line) -- listen to TCP
node.event("data", decode_parameter_line)  -- listen to UDP


function node.render()
--   st()
   
   for name, module in pairs(loader.modules) do
        module.draw()
   end
 
end
