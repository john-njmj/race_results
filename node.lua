-- init
gl.setup(NATIVE_WIDTH, NATIVE_HEIGHT)
local screen_rotation_function -- place holder for rotation function
local loader = require "loader"
local json = require "json"

-- Create defaults for all paramters. 
-- screensetup parameters 
screen_number = 1 
screen_count  = 1 -- only used to display the number of screens on the info screen 
screen_width_config = NATIVE_WIDTH -- not in ini  - config.json : Only used to check config parameter, as other screens need to know the correct WIDTH of this screen   
screen_width = NATIVE_WIDTH -- place holder , set in node.render  - only for local reference not in screen.ini or config.json  
screen_height = NATIVE_HEIGHT -- place holder , set in node.render - only for local reference not in screen.ini or config.json
screen_oriantation = 0 
screen_error = "No error" -- To display config errors in info mode 

-- scroller parameters and defaults  
scroller_mode = "SCROLLER" -- SCROLLER - INFO
scroller_pos = 0 -- not in screen.ini or config.json used to sync scroller with TCP connection 
scroller_size = 200 
-- scroller_speed = -10 
scroller_space = " +++ " 
scroller_text = "STE Results" 
-- remove scroller_width = WIDTH -- Only used to check config parameter, as other screens need to know the correct WIDTH of this screen   
scroller_offset = 0 -- sum of screen width of screens before this screen
scroller_font = resource.load_font("font.ttf") -- not in screen.ini

-- result parameters and defaults
result_mode ="RESULT"   -- RESULT - INFO - PIC
result_size = 40
result_ref_width_sep  = 15
result_files={}
result_font = resource.load_font("font.ttf") -- not in ini

-- funtions 
local function set_screen_rotation(my_rotation)
   gl.setup(NATIVE_WIDTH, NATIVE_HEIGHT)
   screen_oriantation = my_rotation
   screen_rotation_function = util.screen_transform(my_rotation)
   -- recoalculate width and height
   if my_rotation == 0 or my_rotation == 180 then 
      screen_width = NATIVE_WIDTH 
      screen_height = NATIVE_HEIGHT 
   else -- portrate swap height and width
      screen_height = NATIVE_WIDTH 
      screen_width = NATIVE_HEIGHT 
   end      
end 

local function set_result_param(my_size , my_sep_size)
   result_size = my_size
   result_ref_width_sep = my_sep_size
   result_ref_width2 = result_font:width("99", result_size)
   result_ref_width3 = result_font:width("999", result_size)
   result_ref_width4 = result_font:width("9999", result_size)
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
   print ("Parameter : ",par_name," Value : ",par_val)
   if par_name == "screen_number" then 
      screen_number = tonumber(par_val)
   elseif par_name == "scroller_mode" then 
      scroller_mode = par_val
   elseif par_name == "scroller_size" then
      scroller_update(scroller_text, scroller_space, tonumber(par_val))
   --elseif par_name == "scroller_speed" then
   --   scroller_speed = tonumber(par_val)
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
      set_result_param(tonumber(par_val),result_ref_width_sep)
   elseif par_name == "result_sep" then    
      set_result_param(result_size,tonumber(par_val))
   elseif par_name == "scroller_font" then
      if CONTENTS[par_val] then
         scroller_font = resource.load_font(par_val)
      else 
         print ("Scroller_font not found : ",par_val)
      end 
   elseif par_name == "result_font" then    
      if CONTENTS[par_val] then
         result_font = resource.load_font(par_val)
         set_result_param(result_size,result_ref_width_sep)
      else 
         print ("result_font not found : ",par_val)
      end 
   elseif par_name == "result_logo" then
      result_logo = resource.load_image(par_val.asset_name)
      local result_log_scale = screen_width * 0.8 / par_val.metadata.width
      result_logo_w = par_val.metadata.width * result_log_scale
      result_logo_h = par_val.metadata.height * result_log_scale
   elseif par_name == "result_logo_a" then    
      result_logo_a=tonumber(par_val)
   elseif par_name == "screen_width_config" then
         screen_width_config = tonumber(par_val)
   elseif par_name == "screen_count" then
         screen_count = tonumber(par_val)
   elseif par_name == "screen_oriantation" then 
       set_screen_rotation(par_val)
   elseif par_name == "result_files" then       
      result_files ={} 
      for idx1 = 1, #par_val do
         local my_file = par_val[idx1]
          result_files[idx1]=my_file.filename    
      end     
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
--    update_parameter("scroller_text",config.scroller_text)
--    update_parameter("scroller_space",config.scroller_space)
    update_parameter("scroller_mode", config.scroller_mode)
    update_parameter("scroller_size", config.scroller_size)
--    update_parameter("scroller_speed", config.scroller_speed) 
    update_parameter("result_mode",  config.result_mode)
    update_parameter("result_size", config.result_size)
    update_parameter("result_sep", config.result_sep)
    update_parameter("scroller_font",config.scroller_font.asset_name)
    update_parameter("result_font",config.result_font.asset_name)
    update_parameter("result_logo",config.result_logo)
    update_parameter("result_logo_a",config.result_logo_a)
   
   
    -- screen specific seetings 
    update_parameter("screen_count",#config.screenlist)
    local serial = sys.get_env "SERIAL"
    local my_offset = 0
    local found_my_screen = 0
    local idx
    for idx = 1, #config.screenlist do
       local device = config.screenlist[idx]
       if device.screen_id ~= serial then
         if found_my_screen == 0 then   
            my_offset = my_offset + device.screenwidth
         end 
       else
           if found_my_screen == 0 then 
               -- found the settings for this screen
              update_parameter("screen_number",idx)
              update_parameter("screen_oriantation",device.screenoriantation)
              update_parameter("screen_width_config",device.screenwidth)
              -- LOAD RESULT List
              update_parameter("result_files",device.resultfiles)
              -- set found my screen, we only want to load the first definition for this screen 
              found_my_screen = 1
           else
              screen_error = "Screen Defined more than once"
           end
       end
    end
   if found_my_screen == 0 then
      screen_error = "This screen is not defined in the setup"
   end      
   update_parameter("scroller_offset",my_offset)
    
end
--local function decode_command(line)
--    scroller_update(line,scroller_space,scroller_size) 
--end

-- ### INIT #### START OF THE MAIN PROGRAM
-- run delfault calculations 
set_screen_rotation(screen_oriantation)
set_result_param(result_size,result_ref_width_sep)
scroller_update(scroller_text, scroller_space,scroller_size)

-- load paramteres from SCREEN.ini and/or config.json file , add watch the files to reload on changes
if CONTENTS['SCREEN.ini'] then
    print "Found SCREEN.ini loading the settings"
    util.file_watch("SCREEN.ini", function(content)
        load_ini_file(content)
    end)
end
if CONTENTS['config.json'] then
    print "Found config.json loading the settings"
    util.file_watch("config.json", function(content)
        load_json_file(content)
    end)
end
-- Open TCP and UDP connection for Live updates
node.alias "scroller"
--node.event("input", decode_parameter_line) -- listen to TCP
--node.event("data", decode_parameter_line)  -- listen to UDP



function node.render()
   screen_rotation_function()   
   for name, module in pairs(loader.modules) do
        module.draw()
   end
 
end
