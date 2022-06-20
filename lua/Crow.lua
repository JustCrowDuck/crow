menu.next_line()
menu.next_line()

for i=1,10 do
	client.log("See the console")
end



local title_text = [[
╔═══╗          ╔╗
║╔═╗║          ║║
║║─╚╬═╦══╦╗╔╗╔╗║║╔╗╔╦══╗
║║─╔╣╔╣╔╗║╚╝╚╝║║║║║║║╔╗║
║╚═╝║║║╚╝╠╗╔╗╔╬╣╚╣╚╝║╔╗║
╚═══╩╝╚══╝╚╝╚╝╚╩═╩══╩╝╚╝
]]


for i=1,3 do
	console.execute("clear")
end

print(title_text)

print([[

---------------------Crow.lua---------------------
author:         Crow
QQ:             2715930853
QQ group:       926086108

version:        1.0.5
last update:    2020/6/19
Public config:  kaldKcytsgE2

Log - V1.0.2
Remove kill say and hit sound (some bugs in these two modules)

Log - V1.0.3
Fix hitlog

Log - V1.0.4
Fix slow-walking

Log - V1.0.5
Add Full-Random AA (Just Make A Shit lol)
Fix Pitch 0 on land
]])






local ffi = require("ffi")

Crow_lua_loading = true
client.add_callback("unload", function ()
    Crow_lua_loading = false
end)

-- ffi def begin
ffi.cdef[[
    typedef int(__fastcall* clantag_t)(const char*, const char*);
    typedef void(__thiscall* find_or_load_model_t)(void*, const char*);
    typedef void (__thiscall* draw_beams_t)(void*, void*);
    typedef void*(__thiscall* create_beam_points_t)(void*, struct beam_info_t&);
    typedef uintptr_t (__thiscall* GetClientEntity_4242425_t)(void*, int);
    typedef void (__cdecl* chat_printf)(void*, int, int, const char*, ...);
    typedef void*(__thiscall* c_entity_list_get_client_entity_t)(void*, int);
    typedef unsigned long DWORD, *PDWORD, *LPDWORD;  


    typedef struct
    {
        float x;
        float y;
        float z;
    } Vector_t;


    typedef struct
    {
        char        pad0[0x60]; // 0x00
        void*       pEntity; // 0x60
        void*       pActiveWeapon; // 0x64
        void*       pLastActiveWeapon; // 0x68
        float        flLastUpdateTime; // 0x6C
        int            iLastUpdateFrame; // 0x70
        float        flLastUpdateIncrement; // 0x74
        float        flEyeYaw; // 0x78
        float        flEyePitch; // 0x7C
        float        flGoalFeetYaw; // 0x80
        float        flLastFeetYaw; // 0x84
        float        flMoveYaw; // 0x88
        float        flLastMoveYaw; // 0x8C // changes when moving/jumping/hitting ground
        float        flLeanAmount; // 0x90
        char        pad1[0x4]; // 0x94
        float        flFeetCycle; // 0x98 0 to 1
        float        flMoveWeight; // 0x9C 0 to 1
        float        flMoveWeightSmoothed; // 0xA0
        float        flDuckAmount; // 0xA4
        float        flHitGroundCycle; // 0xA8
        float        flRecrouchWeight; // 0xAC
        Vector_t    vecOrigin; // 0xB0
        Vector_t    vecLastOrigin;// 0xBC
        Vector_t    vecVelocity; // 0xC8
        Vector_t    vecVelocityNormalized; // 0xD4
        Vector_t    vecVelocityNormalizedNonZero; // 0xE0
        float        flVelocityLenght2D; // 0xEC
        float        flJumpFallVelocity; // 0xF0
        float        flSpeedNormalized; // 0xF4 // clamped velocity from 0 to 1
        float        flRunningSpeed; // 0xF8
        float        flDuckingSpeed; // 0xFC
        float        flDurationMoving; // 0x100
        float        flDurationStill; // 0x104
        bool        bOnGround; // 0x108
        bool        bHitGroundAnimation; // 0x109
        char        pad2[0x2]; // 0x10A
        float        flNextLowerBodyYawUpdateTime; // 0x10C
        float        flDurationInAir; // 0x110
        float        flLeftGroundHeight; // 0x114
        float        flHitGroundWeight; // 0x118 // from 0 to 1, is 1 when standing
        float        flWalkToRunTransition; // 0x11C // from 0 to 1, doesnt change when walking or crouching, only running
        char        pad3[0x4]; // 0x120
        float        flAffectedFraction; // 0x124 // affected while jumping and running, or when just jumping, 0 to 1
        char        pad4[0x208]; // 0x128
        float        flMinBodyYaw; // 0x330
        float        flMaxBodyYaw; // 0x334
        float        flMinPitch; //0x338
        float        flMaxPitch; // 0x33C
        int            iAnimsetVersion; // 0x340
    } CCSGOPlayerAnimationState_534535_t;

    struct pose_params_t {
        char pad[8];
        float 	m_flStart;
        float 	m_flEnd;
        float 	m_flState;
    };


    short GetKeyState(int);
    short GetAsyncKeyState(int);
]]
-- ffi def end



-- click listen begin
client.add_callback("on_paint", function()
	E_Click = ffi.C.GetKeyState(69)
end)

local function CursorHold(Key_Value)
    flag = ffi.C.GetAsyncKeyState(Key_Value)
    return flag ~= 0
end
-- click listen end



-- hook begin
local set_clantag = ffi.cast("clantag_t", utils.find_signature("engine.dll", "53 56 57 8B DA 8B F9 FF 15"))
local entity_list_ptr = ffi.cast("void***", utils.create_interface("client.dll", "VClientEntityList003"))
local get_client_entity_fn = ffi.cast("GetClientEntity_4242425_t", entity_list_ptr[0][3])
-- hook end



-- variable begin
local aa_mode_list = {
    [0] = "Jitter",
    [1] = "Spin",
    [2] = "Random",
    [3] = "Full Random",
}


local desync_type_list = {
    [0] = "None",
    [1] = "Static",
    [2] = "Jitter",
    [3] = "Flick",
}


local pitch_list = {
    "Up",
    "None",
    "Down",
}


local mask_names_list = {
    'None',
    'Dallas',
    'Battle Mask',
    'Evil Clown',
    'Anaglyph',
    'Boar',
    'Bunny',
    'Bunny Gold',
    'Chains',
    'Chicken',
    'Devil Plastic',
    'Hoxton',
    'Pumpkin',
    'Samurai',
    'Sheep Bloody',
    'Sheep Gold',
    'Sheep Model',
    'Skull',
    'Template',
    'Wolf',
    'Doll',
}


local clantag = {
    "------crow.pub-",
    "-----crow.pub--",
    "----crow.pub---",
    "---crow.pub----",
    "--crow.pub-----",
    "-crow.pub------",
    "crow.pub------c",
    "row.pub------cr",
    "ow.pub------cro",
    "w.pub------crow",
    ".pub------crow.",
    "pub------crow.p",
    "ub------crow.pu",
    "b------crow.pub",
}


local nothing = {
    "",
}
-- variable end



-- Chat print begin
local FindHudElement = function(name)
    local pThis = ffi.cast(ffi.typeof("DWORD**"), utils.find_signature("client.dll", "B9 ? ? ? ? 68 ? ? ? ? E8 ? ? ? ? 89 46 24") + 1)[0]

    local find_hud_element = ffi.cast(ffi.typeof("DWORD(__thiscall*)(void*, const char*)"), utils.find_signature("client.dll", "55 8B EC 53 8B 5D 08 56 57 8B F9 33 F6 39 77 28"))

    return find_hud_element(pThis, name)
end
    
local g_ChatElement = FindHudElement("CHudChat")
    
local CHudChat_vtbl = ffi.cast(ffi.typeof("void***"), g_ChatElement)

local chat_print = {
    print = ffi.cast("chat_printf", CHudChat_vtbl[0][27]), vtbl = CHudChat_vtbl
}
-- Chat print end





-- Ui begin
menu.add_check_box("AntiAim") -- OK
menu.add_combo_box("MODE", aa_mode_list) -- OK
menu.add_combo_box("pitch", pitch_list) -- OK
menu.add_slider_int("AA limit 1", 1, 180) -- OK
menu.add_slider_int("AA limit 2", 1, 180) -- OK
menu.add_combo_box("Desync type", desync_type_list) -- OK
menu.add_slider_int("Desync range", 0, 60) -- OK
menu.add_check_box("Custom Slow-Walk") -- OK
menu.add_slider_int("Custom Slow-Walk Speed", 1, 120) -- OK
menu.add_check_box("legit aa on E") -- OK

menu.add_check_box("Static Legs in air") -- OK

menu.add_check_box("JumpScout") -- OK
menu.add_slider_int("Normal Hitchance", 0, 100) -- OK
menu.add_slider_int("DT Hitchance", 0, 100) -- OK
menu.add_slider_int("Air Hitchance", 0, 100) -- OK

menu.add_slider_int("Pitch 0 tick", 0, 100) -- OK

menu.add_check_box("Clantag") -- OK

menu.add_check_box("Watermark") -- OK
menu.add_check_box("Indicators") -- OK
menu.add_check_box("Keybinds") -- OK
menu.add_slider_int("Key binds position X", 0, engine.get_screen_width()) -- OK
menu.add_slider_int("Key binds position Y", 0, engine.get_screen_height()) -- OK

menu.add_check_box("Enable hitlog") -- OK

menu.add_check_box("Health UI") -- OK

menu.add_combo_box("Mask Changer", mask_names_list) -- OK

-- menu.add_check_box("Killsay") -- OK
-- menu.add_check_box("Hitsound") -- OK
-- Ui end




-- Anti-Aim begin
local yaw = 0

local function anti_aim(cmd)
    local tick_bit = {
        [0] = 1,
        [1] = -1,
    }

    local yaw_value = 0
    local tick = globals.get_tickcount() % 2
    if menu.get_int("MODE") == 0 then
        yaw_value = math.floor((menu.get_int("AA limit 1") + menu.get_int("AA limit 2")) / 2)
        if menu.get_int("Desync type") == 0 then
            yaw_value = math.floor(yaw_value / 2)
            menu.set_int("anti_aim.yaw_modifier", 0)
            yaw = yaw_value * tick_bit[tick]
            menu.set_int("anti_aim.yaw_offset", yaw)
        else
            menu.set_int("anti_aim.yaw_offset", 0)
            menu.set_int("anti_aim.yaw_modifier", 1)
            menu.set_int("anti_aim.yaw_modifier_range", yaw_value)
        end

    elseif menu.get_int("MODE") == 1 then
        menu.set_int("anti_aim.desync_type", 0)
        menu.set_int("anti_aim.desync_range", 0)
        menu.set_int("anti_aim.desync_range_inverted", 0)
        menu.set_int("anti_aim.yaw_modifier", 0)
        menu.set_int("anti_aim.yaw_modifier_range", 0)
        yaw_value = math.random(menu.get_int("AA limit 1"), menu.get_int("AA limit 2"))
        menu.set_int("anti_aim.yaw_offset", yaw)
        yaw = yaw + yaw_value
        if (yaw > 180) then
            yaw = -180
        end

    elseif menu.get_int("MODE") == 2 then
        yaw_value = math.random(menu.get_int("AA limit 1"),menu.get_int("AA limit 2"))
        if menu.get_int("Desync type") == 0 then
            yaw_value = math.floor(yaw_value / 2)
            menu.set_int("anti_aim.yaw_modifier", 0)
            yaw = yaw_value * tick_bit[tick]
            menu.set_int("anti_aim.yaw_offset", yaw)
        else
            menu.set_int("anti_aim.yaw_offset", 0)
            menu.set_int("anti_aim.yaw_modifier", 1)
            menu.set_int("anti_aim.yaw_modifier_range", yaw_value)
        end
    elseif menu.get_int("MODE") == 3 then 
        menu.set_int("anti_aim.yaw_offset", math.random(-180, 180))
        menu.set_int("anti_aim.pitch" , math.random(-1, 1))
    end

    menu.set_int("anti_aim.desync_type", menu.get_int("Desync type"))
    if not (menu.get_int("Desync type") == 0) or not (menu.get_int("MODE") == 1) then
        menu.set_int("anti_aim.desync_range", menu.get_int("Desync range"))
        menu.set_int("anti_aim.desync_range_inverted", menu.get_int("Desync range"))
    end

end

client.add_callback("create_move", function (cmd)
    if not Crow_lua_loading then return end
    if (E_Click ~= 0) and menu.get_bool("legit aa on E") then return end
    if not menu.get_bool("AntiAim") then menu.set_int("anti_aim.yaw_offset", 0) return end
    anti_aim(cmd)
end)
-- Anti-Aim end



-- Slow walk begin
local bit = require("bit")
local function slowwalk(cmd)
    Forward_Flag = bit.band(cmd.buttons, 8) == 8
    Back_Flag = bit.band(cmd.buttons, 16) == 16
    Left_Flag = bit.band(cmd.buttons, 512) == 512
    Right_Flag = bit.band(cmd.buttons, 1024) == 1024

    Movement_Straight = 0
    Movement_Side = 0

    if Forward_Flag then
        Movement_Straight = Movement_Straight + menu.get_int("Custom Slow-Walk Speed")
    end

    if Back_Flag then
        Movement_Straight = Movement_Straight - menu.get_int("Custom Slow-Walk Speed")
    end

    if Left_Flag then
        Movement_Side = Movement_Side - menu.get_int("Custom Slow-Walk Speed")
    end

    if Right_Flag then
        Movement_Side = Movement_Side + menu.get_int("Custom Slow-Walk Speed")
    end


    cmd.forwardmove = Movement_Straight
    cmd.sidemove = Movement_Side
end
client.add_callback("create_move",function (cmd)
    if not Crow_lua_loading then return end
    if not menu.get_bool("Custom Slow-Walk") or not CursorHold(160) then
        return
    end
    if not entitylist.get_local_player() then
        return
    end
    slowwalk(cmd)
end)
-- Slow walk end



-- Legit aa begin
client.add_callback("create_move",function ()
    if not Crow_lua_loading or not (E_Click ~= 0) then return end
    if menu.get_bool("legit aa on E") then
        menu.set_int("anti_aim.pitch" , 0)
        menu.set_int("anti_aim.yaw_offset" , 180)
        menu.set_int("anti_aim.desync_range" , 60)
        menu.set_int("anti_aim.desync_range_inverted" , 60)
        menu.set_int("anti_aim.desync_type" , 1)
    end
end)
-- Legit aa end




-- Static Legs in air begin
local ffi_helpers = {
    get_entity_address = function(ent_index)
        local addr = get_client_entity_fn(entity_list_ptr, ent_index)
        return addr
    end
}

local offset_value = 0x9960
local shared_onground

client.add_callback("on_paint", function()
    if not Crow_lua_loading or not menu.get_bool("Static Legs in air") then return end
    local localplayer = entitylist.get_local_player()
    if not localplayer then return end

    local bOnGround = bit.band(localplayer:get_prop_float("CBasePlayer", "m_fFlags"), bit.lshift(1,0)) ~= 0
    if not bOnGround then
        ffi.cast("CCSGOPlayerAnimationState_534535_t**", ffi_helpers.get_entity_address(localplayer:get_index()) + offset_value)[0].flDurationInAir = 99
        ffi.cast("CCSGOPlayerAnimationState_534535_t**", ffi_helpers.get_entity_address(localplayer:get_index()) + offset_value)[0].flHitGroundCycle = 0
        ffi.cast("CCSGOPlayerAnimationState_534535_t**", ffi_helpers.get_entity_address(localplayer:get_index()) + offset_value)[0].bHitGroundAnimation = false
    end

    shared_onground = bOnGround
end)

client.add_callback("on_paint", function()
    local localplayer = entitylist.get_local_player()
    if not localplayer then return end

    local bOnGround = bit.band(localplayer:get_prop_float("CBasePlayer", "m_fFlags"), bit.lshift(1,0)) ~= 0
    if bOnGround and not shared_onground then
        ffi.cast("CCSGOPlayerAnimationState_534535_t**", ffi_helpers.get_entity_address(localplayer:get_index()) + offset_value)[0].flDurationInAir = 0.5
    end -- ACT_CSGO_LAND_LIGHT
end)
-- Static Legs in air end




-- Jumpscout begin
local function jumpscout()
    if not Crow_lua_loading then return end
    local inAir = entitylist.get_local_player():get_prop_int("CBasePlayer", "m_fFlags") == 256
    local normalhitchance =menu.get_int("Normal Hitchance")
    local dthitchance = menu.get_int("DT Hitchance")
    local airhitchance = menu.get_int("Air Hitchance")
   
     if(menu.get_bool("JumpScout")) then
        if inAir then
           menu.set_int(string.format("rage.weapon[3].hit_chance"), airhitchance)
           menu.set_int(string.format("rage.weapon[3].double_tap_hit_chance"), airhitchance)
      else
           menu.set_int(string.format("rage.weapon[3].hit_chance"), normalhitchance)
           menu.set_int(string.format("rage.weapon[3].double_tap_hit_chance"), dthitchance)
          end
      end     
  end
  
  client.add_callback("create_move",jumpscout)
-- Jumpscout end



-- Pitch 0 on land begin
local ground_tick = 1
local end_tick = 0
local state

local function pitch0()
    local inAir = entitylist.get_local_player():get_prop_int("CBasePlayer", "m_vecVelocity[2]") ~= 0
    local curtick = globals.get_tickcount()
    if inAir == true then
        ground_tick = 0
        end_tick = curtick + menu.get_int("Pitch 0 tick")
        state = "in air"
    else
        ground_tick = ground_tick + 1
        state = "on land"
    end
    if ground_tick > 1 and end_tick > curtick then
        menu.set_int("anti_aim.pitch", 0)
    else
        if E_Click ~= 0 then return end
        menu.set_int("anti_aim.pitch", menu.get_int("pitch") - 1)
    end
end

client.add_callback("create_move", function ()
    if not Crow_lua_loading then return end
    if not entitylist.get_local_player() or menu.get_int("MODE") == 3 then
        return
    end
    pitch0()
end)
-- Pitch 0 on land end








-- Clantag begin
local old_time = 0
client.add_callback("create_move", function()
    if Crow_lua_loading then
        if menu.get_bool("Clantag") then
            local curtime = math.floor(globals.get_curtime()*5)
            if old_time ~= math.floor(globals.get_curtime()*5) then
                set_clantag(clantag[curtime % #clantag+1], clantag[curtime % #clantag+1])
            end
            old_time = curtime
        else
            local curtime = math.floor(globals.get_curtime()*5)
            if old_time ~= math.floor(globals.get_curtime()*5) then
                set_clantag(nothing[curtime % #nothing+1], nothing[curtime % #nothing+1])
            end
            old_time = curtime
        end
   end
end)

client.add_callback("unload", function ()
    set_clantag(nothing[0],nothing[#nothing])
end)
-- Clantag end




-- Watermark begin
local font = render.create_font("Verdana", 12, 500, false, true, false)
client.add_callback("on_paint", function()
    if not Crow_lua_loading then return end
    if menu.get_bool("Watermark") then
        local screen_width = engine.get_screen_width()
        local username = globals.get_username()
        local ping = tostring(globals.get_ping())
        local tickrate = math.floor(1.0 / globals.get_intervalpertick())
		local get_time = os.date("%X", os.time())
        --
        local text
        if engine.is_connected() then
            text = tostring(" crow.pub | " .. username .. " | 延迟: " .. ping .. "毫秒 | " .. tickrate .. "tick | "..get_time.. " ")
        else
            text = tostring(" crow.pub | " .. username .. " | " ..get_time.. " ")
        end
        --
        local width = render.get_text_width(font, text)
        --
        local line_color = color.new(125, 125, 255)
        local text_color = color.new(255, 255, 255)
        local bg_color = color.new(20, 20, 20, 100)
        --
        local x = screen_width - 10 - width - 4
        local y = 10
        local w = width + 5
        --
        render.draw_rect_filled(x, y - 1, w, 2, line_color)
        render.draw_rect_filled(x, y + 1, w, 18, bg_color)
        render.draw_text(font, x + 2.5, y + 3, text_color, text)
    end
end)
-- Watermark end











-- Indicators begin
local font = render.create_font( "Verdana", 25, 562, true, true, false )
local color0 = color.new(132, 195, 16)
local color1 = color.new(16, 125, 255)
local color2 = color.new(255, 255, 255)
local x, y = engine.get_screen_width() / 115 , engine.get_screen_height() / 1.60

local function indicators()
    if not Crow_lua_loading then return end
    local is_ingame = engine.is_in_game()
    local dt = menu.get_key_bind_state( "rage.double_tap_key" )
    local fd = menu.get_key_bind_state( "anti_aim.fake_duck_key" )
    local fdmg = menu.get_key_bind_state( "rage.force_damage_key" )
    local hs = menu.get_key_bind_state( "rage.hide_shots_key" )
    local ap = menu.get_key_bind_state( "misc.automatic_peek_key" )
	local f = menu.get_bool("anti_aim.enable_fake_lag")

    if is_ingame then
        local lp = entitylist.get_local_player()
        local lp_health  = lp:get_health()
        if lp_health > 0 then

            if dt then
                space1 = 25
                render.draw_text( font, x, y, color2, "DT" )
            else
                space1 = 0
            end
            if hs then 
                space2 = 25
                render.draw_text( font, x, y + space1, color0, "HS" )
            else
                space2 = 0
            end
            if fdmg then
                space3 = 25
                render.draw_text( font, x, y + space1 + space2, color2, "DMG" )
            else
                space3 = 0
            end
            if fd then
                space4 = 25
                render.draw_text( font, x, y + space1 + space2 + space3, color2, "FAKE-DUCK" )
            else
                space4 = 0
            end
            if ap then
                space5 = 25
                render.draw_text( font, x, y + space1 + space2 + space3 + space4, color2, "AUTO-PEEK" )
            else
                space5 = 0
			if f then
                space6 = 25
                render.draw_text( font, x, y + space1 + space2 + space3 + space4 + space5, color0, "FL" )
				space6 = 0
			    end
			end
    	end
    end
end

client.add_callback("on_paint", function ()
    if not Crow_lua_loading then return end
    if not engine.is_in_game() or not menu.get_bool("Indicators") then return end
    indicators()
end)
-- Indicators end











-- Keybinds begin
local font = render.create_font("Verdana", 12, 500, false, true, false)
local types = {"always", "holding", "toggled"}

local get_state, get_mode = menu.get_key_bind_state, menu.get_key_bind_mode
local screen_x, screen_y = engine.get_screen_width(), engine.get_screen_height()
local count = 0

local function add_bind(name, bind_name, x, y)
    if get_state(bind_name) then
        render.draw_text(font, x, y + 22 + (15 * count), color.new(255, 255, 255), name)     
        text_width = render.get_text_width(font, "[" .. types[get_mode(bind_name) + 1] .. "]")
      
        render.draw_text(font, x + 151 - text_width - 5, y + 23 + (15 * count), color.new(255, 255, 255), "[" .. types[get_mode(bind_name) + 1] .. "]")     
        count = count + 1   
    end
end

local function keybind_list()
    local pos_x = menu.get_int("Key binds position X")
    local pos_y = menu.get_int("Key binds position Y")
 
    render.draw_rect_filled(pos_x, pos_y - 3, 150, 2, color.new(125, 125, 255))
    render.draw_rect_filled(pos_x, pos_y - 1, 150, 18, color.new(20, 20, 20, 100))
    render.draw_text(font, pos_x + 55, pos_y + 2, color.new(255, 255, 255), "keybinds")
    count = 0
 
    add_bind(" 不抬头", "rage.hide_shots_key", pos_x + 1, pos_y - 2)
    add_bind(" 边缘跳", "misc.edge_jump_key", pos_x + 1, pos_y - 2)
    add_bind(" 双发", "rage.double_tap_key", pos_x + 1, pos_y - 2)
    add_bind(" 假走", "misc.slow_walk_key", pos_x + 1, pos_y - 2)
    add_bind(" 伤害覆盖", "rage.force_damage_key", pos_x + 1, pos_y - 2)
    add_bind(" 切换假身方向", "anti_aim.invert_desync_key", pos_x + 1, pos_y - 2)
    add_bind(" 假蹲", "anti_aim.fake_duck_key", pos_x + 1, pos_y - 2)
    add_bind(" 自动peek", "misc.automatic_peek_key", pos_x + 1, pos_y - 2)
    add_bind(" 第三人称", "misc.third_person_key", pos_x + 1, pos_y - 2)
end

client.add_callback("on_paint", function ()
    if not Crow_lua_loading then return end
    if not menu.get_bool("Keybinds") then
        return
    end

    if not engine.is_in_game() then
        return
    end
    keybind_list()
end)
-- keybinds end









-- Hitlog begin
local gpinf = engine.get_player_info
local shot_num = tonumber(file.read(os.getenv("APPDATA") .. "\\Legendware\\Crow\\data\\shot_num"))

if not shot_num then shot_num = 0 end

local function write_shot_num()
  file.write(os.getenv("APPDATA") .. "//Legendware//Crow//data//shot_num", tostring(shot_num))
  client.log("Crow's hitlog: 目前已经开了 " .. shot_num .. " 枪了")
  chat_print.print(chat_print.vtbl, 0, 0, " \x0C[Crow's hitlog]  \x08目前已经开了 \x07" .. shot_num .. " \x08枪了")
end



client.add_callback("on_shot", function (shot_info)
    if not Crow_lua_loading or not menu.get_bool("Enable hitlog") then return end
    local results       = shot_info.result
    local target        = shot_info.target_index
    local targetname    = gpinf(target).name
    local serverdamage  = shot_info.server_damage
    local clientdamage  = shot_info.client_damage
    local serverhitbox  = shot_info.server_hitbox
    local clienthitbox  = shot_info.client_hitbox
    local hitchance     = shot_info.hitchance
    local backtrack     = shot_info.backtrack_ticks
    local safe          = tostring(shot_info.safe)
  
   shot_num = shot_num + 1
   if results == "Hit" then
    chat_print.print(chat_print.vtbl, 0, 0, "[\x06LW\x08] \x08第\x03" .. shot_num .. "\x08枪 蒙中了 \x03" .. targetname .. "\x08 造成了: \x07" .. serverdamage .. "\x08 部位 \x10" .. serverhitbox .. "\x08 | 命中率: \x09" .. hitchance .. "\x08 | 预计伤害: \x07" .. clientdamage .. "\x08 | 预计部位: \x10" .. clienthitbox .. "\x08 | 回溯: \x0C" .. backtrack .. "\x08 | 安全点: \x03" .. safe)
    
    elseif results == "Spread" then
        chat_print.print(chat_print.vtbl, 0, 0, "[\x02LW\x08] \x08第\x03" .. shot_num .. "\x08枪 空枪 \x03" .. targetname .. "\x08 原因: \x02扩散\x08 | 命中率: \x09" .. hitchance .. "\x08 | 预计伤害: \x07" .. clientdamage .. "\x08 | 实际伤害: \x07" .. serverdamage .. "\x08 | 预计部位: \x10" .. clienthitbox .. "\x08 | 实际部位: \x10" .. serverhitbox .. "\x08 | 回溯: \x0C" .. backtrack .. "\x08 | 安全点: \x03" .. safe)
    
    elseif results == "Resolver" then
        chat_print.print(chat_print.vtbl, 0, 0, "[\x02LW\x08] \x08第\x03" .. shot_num .. "\x08枪 空枪 \x03" .. targetname .. "\x08 原因: \x02解析\x08 | 命中率: \x09" .. hitchance .. "\x08 | 预计伤害: \x07" .. clientdamage .. "\x08 | 实际伤害:: \x07" .. serverdamage .. "\x08 | 预计部位: \x10" .. clienthitbox .. "\x08 | 实际部位: \x10" .. serverhitbox .. "\x08 | 回溯: \x0C" .. backtrack .. "\x08 | 安全点: \x03" .. safe)
    
    else
        chat_print.print(chat_print.vtbl, 0, 0, "[\x02LW\x08] \x08第\x03" .. shot_num .. "\x08枪 空枪 \x03" .. targetname .. "\x08 原因: \x02死亡\x08 | 命中率: \x09" .. hitchance .. "\x08 | 预计伤害: \x07" .. clientdamage .. "\x08 | 实际伤害:: \x07" .. serverdamage .. "\x08 | 预计部位: \x10" .. clienthitbox .. "\x08 | 实际部位: \x10" .. serverhitbox .. "\x08 | 回溯: \x0C" .. backtrack .. "\x08 | 安全点: \x03" .. safe)
    end
  
    if shot_num % 10 == 0 then write_shot_num() end

end)
client.add_callback("unload", write_shot_num)
-- Hitlog end








-- HP ui befin
local gris = render.create_image(file.read(os.getenv("APPDATA") .. "\\Legendware\\Crow\\img\\HP.png" ))

local function draw_line(p1, p2, o1, o2)
    render.draw_line(p1, p2,    o1, o2, color.new(180, 190, 200, 200 ))
    render.draw_line(p1, p2+1,  o1, o2+1, color.new(180, 190, 200, 200 ))
    render.draw_line(p1, p2+2,  o1, o2+2, color.new(180, 190, 200, 200))
    render.draw_line(p1, p2+2.4,o1, o2+2.4, color.new(180, 190, 200, 200))
    render.draw_line(p1, p2,  o1, o2, color.new(180, 190, 200, 200 ))
end

function hp_line_draw()
    render.draw_image(0, 0, 722, 126, gris)
    local local_player = entitylist.get_local_player()
    if (local_player ~= nil) then
        local hp = local_player:get_prop_int("CBasePlayer", "m_iHealth")
        local hp_true = local_player:get_prop_int("CBasePlayer", "m_iHealth")

        if not engine.is_connected() then
            return end
    
        local t = globals.get_frametime() * (10 + math.abs(local_player:get_prop_int("CBasePlayer", "m_iHealth") - hp) * 1.3);

        if hp > local_player:get_prop_int("CBasePlayer", "m_iHealth") then
            hp = math.max(hp - t, local_player:get_prop_int("CBasePlayer", "m_iHealth"))
        elseif hp < local_player:get_prop_int("CBasePlayer", "m_iHealth") then
            hp = math.min(hp + t, local_player:get_prop_int("CBasePlayer", "m_iHealth"))
        end
        
        if (hp > 0) then
            
        end
        if hp == 100 then
            render.draw_circle_filled(712, 58, 5, 4, color.new(180, 190, 200,255))
        end
        if hp > 90 then
            local o_x = (712 - 666) * (1 - ((hp - 90) / 10))
            local o_y = (58 - 47) * (1 - ((hp - 90) / 10))
            render.draw_circle_filled(666, 47, 5, 4, color.new(180, 190, 200,255))
            render.draw_circle_filled(394, 52, 5, 4, color.new(180, 190, 200,255))
            render.draw_circle_filled(358, 41, 5, 4, color.new(180, 190, 200,255))
            render.draw_circle_filled(232, 48, 5, 4, color.new(180, 190, 200,255))
            render.draw_circle_filled(160, 64, 5, 4, color.new(180, 190, 200,255))
            render.draw_circle_filled(131, 51, 5, 4, color.new(180, 190, 200,255))
            render.draw_circle_filled(116, 65, 5, 4, color.new(180, 190, 200,255))
            draw_line(666, 47, 712 - o_x, 58 - o_y)
            draw_line(394, 52, 666, 47)
            draw_line(358, 41, 394, 52)
            draw_line(232, 48, 358, 41)
            draw_line(160, 64, 232, 48)
            draw_line(131, 51, 160, 64)
            draw_line(116, 65, 131, 51)
        elseif (hp > 50) then
            local o_x = (666 - 394) * (1 - (hp - 50) / 40)
            local o_y = (47 - 52) * (1 - (hp - 50) / 40)
            render.draw_circle_filled(394, 52, 5, 4, color.new(180, 190, 200,255))
            render.draw_circle_filled(358, 41, 5, 4, color.new(180, 190, 200,255))
            render.draw_circle_filled(232, 48, 5, 4, color.new(180, 190, 200,255))
            render.draw_circle_filled(160, 64, 5, 4, color.new(180, 190, 200,255))
            render.draw_circle_filled(131, 51, 5, 4, color.new(180, 190, 200,255))
            render.draw_circle_filled(116, 65, 5, 4, color.new(180, 190, 200,255))
            draw_line(394, 52, 666 - o_x, 47 - o_y)

            draw_line(358, 41, 394, 52)
            draw_line(232, 48, 358, 41)
            draw_line(160, 64, 232, 48)
            draw_line(131, 51, 160, 64)
            draw_line(116, 65, 131, 51)
        elseif (hp > 40) then
            local o_x = (394 - 358) * ((hp - 50) / -10)
            local o_y = (52 - 41) * ((hp - 50) / -10)
            render.draw_circle_filled(358, 41, 5, 4, color.new(180, 190, 200,255))
            render.draw_circle_filled(232, 48, 5, 4, color.new(180, 190, 200,255))
            render.draw_circle_filled(160, 64, 5, 4, color.new(180, 190, 200,255))
            render.draw_circle_filled(131, 51, 5, 4, color.new(180, 190, 200,255))
            render.draw_circle_filled(116, 65, 5, 4, color.new(180, 190, 200,255))
            draw_line(358, 41, 394 - o_x, 52 - o_y)

            draw_line(232, 48, 358, 41)
            draw_line(160, 64, 232, 48)
            draw_line(131, 51, 160, 64)
            draw_line(116, 65, 131, 51)
        elseif (hp > 20) then
            local o_x = (358 - 232) * ((hp - 40) / -20)
            local o_y = (41 - 48) * ((hp - 40) / -20)
            render.draw_circle_filled(232, 48, 5, 4, color.new(180, 190, 200,255))
            render.draw_circle_filled(160, 64, 5, 4, color.new(180, 190, 200,255))
            render.draw_circle_filled(131, 51, 5, 4, color.new(180, 190, 200,255))
            render.draw_circle_filled(116, 65, 5, 4, color.new(180, 190, 200,255))
            draw_line(232, 48, 358 - o_x, 41 - o_y)

            draw_line(160, 64, 232, 48)
            draw_line(131, 51, 160, 64)
            draw_line(116, 65, 131, 51)
        elseif (hp > 10) then
            local o_x = (232 - 160) * ((hp - 20) / -10)
            local o_y = (48 - 64) * ((hp - 20) / -10)
            render.draw_circle_filled(160, 64, 5, 4, color.new(180, 190, 200,255))
            render.draw_circle_filled(131, 51, 5, 4, color.new(180, 190, 200,255))
            render.draw_circle_filled(116, 65, 5, 4, color.new(180, 190, 200,255))
            draw_line(160, 64, 232 - o_x, 48 - o_y)

            draw_line(131, 51, 160, 64)
            draw_line(116, 65, 131, 51)
        elseif (hp > 5) then
            local o_x = (160 - 131) * ((hp - 10) / -5)
            local o_y = (64 - 51) * ((hp - 10) / -5)
            render.draw_circle_filled(131, 51, 5, 4, color.new(180, 190, 200,255))
            render.draw_circle_filled(116, 65, 5, 4, color.new(180, 190, 200,255))
            draw_line(131, 51, 160 - o_x, 64 - o_y)

            draw_line(116, 65, 131, 51)
        else
            if (hp > 0) then
                local o_x = (131 - 116) * ((hp - 5) / -5)
                local o_y = (51 - 65) * ((hp - 5) / -5)
                render.draw_circle_filled(116, 65, 5, 4, color.new(180, 190, 200,255))
                
                draw_line(116, 65, 131 - o_x, 51 - o_y)
            end
        end
    end
end
client.add_callback( "on_paint", function()
    if not Crow_lua_loading then return end

    if not engine.is_in_game() then
        return
    end

    if menu.get_bool( "Health UI" ) then
        hp_line_draw()
    end
end )
-- HP ui end










-- Maskchanger begin
local __thiscall = function(func, this)
    return function(...) return func(this, ...) end
end
local interface_ptr = ffi.typeof("void***")
local vtable_bind = function(module, interface, index, typedef)
    local addr = ffi.cast("void***", utils.create_interface(module, interface)) or error(interface .. " was not found")
    return __thiscall(ffi.cast(typedef, addr[0][index]), addr)
end
local vtable_entry = function(instance, i, ct)
    return ffi.cast(ct, ffi.cast(interface_ptr, instance)[0][i])
end
local vtable_thunk = function(i, ct)
    local t = ffi.typeof(ct)
    return function(instance, ...)
        return vtable_entry(instance, i, t)(instance, ...)
    end
end

local get_class_name = vtable_thunk(143, "const char*(__thiscall*)(void*)")
local set_model_index = vtable_thunk(75, "void(__thiscall*)(void*,int)")

local get_client_entity_from_handle = vtable_bind("client.dll", "VClientEntityList003", 4, "void*(__thiscall*)(void*,void*)")
local get_model_index = vtable_bind("engine.dll", "VModelInfoClient004", 2, "int(__thiscall*)(void*, const char*)")

local rawientitylist = utils.create_interface('client.dll', 'VClientEntityList003') or error('VClientEntityList003 was not found', 2)

local ientitylist = ffi.cast(interface_ptr, rawientitylist) or error('rawientitylist is nil', 2)
local get_client_entity = ffi.cast('void*(__thiscall*)(void*, int)', ientitylist[0][3]) or error('get_client_entity was not found', 2)

local client_string_table_container = ffi.cast(interface_ptr, utils.create_interface('engine.dll', 'VEngineClientStringTable001')) or error('VEngineClientStringTable001 was not found', 2)
local find_table = vtable_thunk(3, 'void*(__thiscall*)(void*, const char*)')

local model_info = ffi.cast(interface_ptr, utils.create_interface('engine.dll', 'VModelInfoClient004')) or error('VModelInfoClient004 was not found', 2)

ffi.cdef [[
    typedef void(__thiscall* find_or_load_model_t)(void*, const char*);
]]

local add_string = vtable_thunk(8, "int*(__thiscall*)(void*, bool, const char*, int length, const void* userdata)")
local find_or_load_model = ffi.cast("find_or_load_model_t", model_info[0][43]) -- vtable thunk crashes (?)

local function _precache(szModelName)
    if szModelName == "" then return end -- don't precache empty strings (crash)
    if szModelName == nil then return end
    szModelName = string.gsub(szModelName, [[\]], [[/]])

    local m_pModelPrecacheTable = find_table(client_string_table_container, "modelprecache")
    if m_pModelPrecacheTable ~= nil then
        find_or_load_model(model_info, szModelName)
        add_string(m_pModelPrecacheTable, false, szModelName, -1, nil)
    end
end



local models = {
    '',
    'models/player/holiday/facemasks/facemask_dallas.mdl',
    'models/player/holiday/facemasks/facemask_battlemask.mdl',
    'models/player/holiday/facemasks/evil_clown.mdl',
    'models/player/holiday/facemasks/facemask_anaglyph.mdl',
    'models/player/holiday/facemasks/facemask_boar.mdl',
    'models/player/holiday/facemasks/facemask_bunny.mdl',
    'models/player/holiday/facemasks/facemask_bunny_gold.mdl',
    'models/player/holiday/facemasks/facemask_chains.mdl',
    'models/player/holiday/facemasks/facemask_chicken.mdl',
    'models/player/holiday/facemasks/facemask_devil_plastic.mdl',
    'models/player/holiday/facemasks/facemask_hoxton.mdl',
    'models/player/holiday/facemasks/facemask_pumpkin.mdl',
    'models/player/holiday/facemasks/facemask_samurai.mdl',
    'models/player/holiday/facemasks/facemask_sheep_bloody.mdl',
    'models/player/holiday/facemasks/facemask_sheep_gold.mdl',
    'models/player/holiday/facemasks/facemask_sheep_model.mdl',
    'models/player/holiday/facemasks/facemask_skull.mdl',
    'models/player/holiday/facemasks/facemask_template.mdl',
    'models/player/holiday/facemasks/facemask_wolf.mdl',
    'models/player/holiday/facemasks/porcelain_doll.mdl',
}

local last_model = 0

local model_index = -1
local enabled = false

local function precache(modelPath)
    if modelPath == "" then return -1 end -- don't crash.
    local local_model_index = get_model_index(modelPath)
    if local_model_index == -1 then
        _precache(modelPath)
    end
    return get_model_index(modelPath)
end

local function on_paint()
    if not Crow_lua_loading then return end
    if not engine.is_in_game() then
        last_model = 0
        return
    end
    if last_model ~= menu.get_int("Mask Changer") then
        last_model = menu.get_int("Mask Changer")
        if last_model == 0 then
            enabled = false
        else
            enabled = true
            model_index = precache(models[last_model + 1])
        end
    end
end

client.add_callback("on_paint", on_paint)

local function get_player_address(lp)
    return get_client_entity(ientitylist, lp:get_index())
end

function player:addMask()
    self:set_prop_int("CCSPlayer", "m_iAddonBits", bit.bor(self:get_prop_int("CCSPlayer", "m_iAddonBits"), bit.bor(0x10000, 0x00800)))
end


client.add_callback("create_move", function (cmd)
    if not Crow_lua_loading then return end
    if not engine.is_connected() or not engine.is_in_game() then return end
    local lp = entitylist.get_local_player()
    lp:addMask()

    if model_index == -1 then return precache(models[last_model + 1]) end

    local local_player = lp
    if enabled then
        local lp_addr = ffi.cast("intptr_t*", get_player_address(local_player))
        local m_AddonModelsHead = ffi.cast("intptr_t*", lp_addr + 0x462F) -- E8 ? ? ? ? A1 ? ? ? ? 8B CE 8B 40 10
        local i, next_model = m_AddonModelsHead[0], -1

        while i ~= -1 do
            next_model = ffi.cast("intptr_t*", lp_addr + 0x462C)[0] + 0x18 * i -- this is the pModel (CAddonModel) afaik
            i = ffi.cast("intptr_t*", next_model + 0x14)[0]
            local m_pEnt = ffi.cast("intptr_t**", next_model)[0] -- CHandle<C_BaseAnimating> m_hEnt -> Get()
            local m_iAddon = ffi.cast("intptr_t*", next_model + 0x4)[0]
            if tonumber(m_iAddon) == 16 then -- face mask addon bits knife = 10
                local entity = get_client_entity_from_handle(m_pEnt)
                set_model_index(entity, model_index)
            end
        end
    end
end )

client.add_callback('unload', function ()
    if not engine.is_connected() or not engine.is_in_game() then return end
    enabled = false
    local lp = entitylist.get_local_player()
    lp:set_prop_int("CCSPlayer", "m_iAddonBits", 1024)
end)
-- Maskchanger end


-- -- Killsay begin
-- events.register_event("player_death", function(event)
--     if not Crow_lua_loading and not menu.get_bool("Killsay") then return end
--     local attacker = event:get_int("attacker")
--     local attacker_to_player = engine.get_player_for_user_id(attacker)
--     local local_index = engine.get_local_player_index()

--     if attacker_to_player == local_index then
--         console.execute("say crow.pub | free cfg & free cheat");
--     end
	
-- end)
-- -- Killsay end



-- -- Hitsound begin
-- events.register_event("player_hurt", function(event)
--     if not Crow_lua_loading and not menu.get_bool("Hitsound") then return end
--     local attacker = event:get_int("attacker")
--     local attacker_to_player = engine.get_player_for_user_id(attacker)
--     local local_index = engine.get_local_player_index()

--     if attacker_to_player == local_index then
--         console.execute("play hitsound.wav");
--     end
	
-- end)
-- -- Hitsound end








menu.next_line()
menu.next_line()