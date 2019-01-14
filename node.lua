-- init
gl.setup(NATIVE_WIDTH, NATIVE_HEIGHT)
--local st = util.screen_transform(90)
local loader = require "loader"
local json = require "json"

-- Create defaults for all paramters. 
-- screensetup parameters 
screen_number = 1 
screen_width = WIDTH -- not in ini
screen_height = HEIGHT -- only for loca rference not in screen.ini or config.json

-- scroller parameters and defaults  
scroller_mode = "SCROLLER" -- SCROLLER - INFO
scroller_pos = 0 -- not in screen.ini or config.json used to sync scroller with TCP connection 
scroller_size = 200 
scroller_speed = -10 
scroller_space = " +++ " 
scroller_text = "STE Results" 
scroller_width = WIDTH -- TO BE REMOVED NOT USED 
scroller_offset = 0 -- sum of screen width of screens before this screen
scroller_font = resource.load_font("font.ttf") -- not in screen.ini

-- result parameters and defaults
result_mode ="PIC"   -- RESULT - INFO - PIC
result_size = 40
result_files={"results_sm.csv", "results_sj.csv"}
result_font = resource.load_font("font.ttf") -- not in ini

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

local function load_ini_file(my_parameters)
--   local my_parameters = resource.load_file(my_parameter_file)
   for parameter in my_parameters:gmatch("[^\n]+") do
      decode_parameter_line(parameter)
   end
end

local function load_json_file (raw)
-- when on info-beamer hosted settings are in config.json 
    local config = json.decode(raw)
    update_parameter("scroller_text",config.scroller_text)
    -- ADD HERE ALL OTHER GENERAL PARAMETERS
    -- screen specific seetings 
    local serial = sys.get_env "SERIAL"
    local my_offset = 0 
    for idx = 1, #config.screenlist do
       local device = config.screenlist[idx]
       if device.screen_id ~= serial then
           my_offset = my_offset + device.screenwidth
       else
           -- found the settings for this screen 
           update_parameter("screen_width",device.screenwidth)
           -- LOAD Orientation
           -- LOAD RESULT List
           -- EXT the FOR loop
       end
    end
    update_parameter("scroller_offset",my_offset)
    
end
--local function decode_command(line)
--    scroller_update(line,scroller_space,scroller_size) 
--end

-- ### INIT #### START OF THE MAIN PROGRAM
-- run delfault calculations 
set_result_param(result_size)
scroller_update(scroller_text, scroller_space,scroller_size)

-- load paramteres from SCREEN.ini and/or config.json file , add watch the files to reload on changes
if CONTENTS['SCREEN.ini'] then
    Print "Found SCREEN.ini loading the settings"
    util.file_watch("SCREEN.ini", function(content)
        load_ini_file(content)
    end)
end
if CONTENTS['config.json'] then
    Print "Found config.json loading the settings"
    util.file_watch("config.json", function(content)
        load_json_file(content)
    end)
end
-- Open TCP and UDP connection for Live updates
node.alias "scroller"
node.event("input", decode_parameter_line) -- listen to TCP
node.event("data", decode_parameter_line)  -- listen to UDP



function node.render()
--   st()
   
   for name, module in pairs(loader.modules) do
        module.draw()
   end
 
end
