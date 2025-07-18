------------------------------DIRECTIVES------------------------------
script_name("PoliceHelper for Samp-Rp")
script_author("shlang")
script_version("v1.0")
script_description("Use -> /ph")
---------------------------------LIBS---------------------------------
local imgui = require("mimgui");
local hotkey = require("mimgui_hotkeys");
local inicfg = require("inicfg");
local encoding = require("encoding");
local font_flags = require("lib.moonloader").font_flag;
local vkeys = require("lib.vkeys");
-------------------------------ENCODING-------------------------------
encoding.default = "CP1251";
local u8 = encoding.UTF8;
--------------------------------FONTS---------------------------------
local font = renderCreateFont("Tahoma", 14, font_flags.BOLD + font_flags.BORDER);
------------------------------CONSTANTS-------------------------------
local show_loading_text = true;
local script_loading_color = 0x4682B4;
local script_main_color = 0xFFFFFF;
----------------------------------------------------------------------
local script_command = "ph";
local settings_filename = "ph_settings.ini";
local default_settings = inicfg.load({
    keys = {
        cuff_key = "[49]",
		uncuff_key = "[50]",
		follow_key = "[51]",
		cput_key = "[52]",
		ceject_key = "[53]",
		frisk_key = "[54]"
    },
}, settings_filename);
inicfg.save(default_settings, settings_filename);

local screen_width, screen_height = getScreenResolution();
local show_window = imgui.new.bool(false);

local commands_for_keys;
local cuff_hotkey;
local uncuff_hotkey;
local follow_hotkey;
local cput_hotkey;
local ceject_hotkey;
local frisk_hotkey;

function ShowLoadingText()
	sampAddChatMessage(
		table.concat({thisScript().name .. " " .. thisScript().version
		, table.concat(thisScript().authors, " & ")}, " by ") .. " loaded. " .. thisScript().description
		, script_loading_color
	);
end

function main()
    while not isSampAvailable() do wait(0) end

	if show_loading_text then ShowLoadingText() end

	hotkey.Text.NoKey = u8"Нет клавиши";
    cuff_hotkey = hotkey.RegisterHotKey("cuff_hotkey", true, decodeJson(default_settings.keys.cuff_key), function() end);
	uncuff_hotkey = hotkey.RegisterHotKey("uncuff_hotkey", true, decodeJson(default_settings.keys.uncuff_key), function() end);
	follow_hotkey = hotkey.RegisterHotKey("follow_hotkey", true, decodeJson(default_settings.keys.follow_key), function() end);
	cput_hotkey = hotkey.RegisterHotKey("cput_hotkey", true, decodeJson(default_settings.keys.cput_key), function() end);
	ceject_hotkey = hotkey.RegisterHotKey("ceject_hotkey", true, decodeJson(default_settings.keys.ceject_key), function() end);
	frisk_hotkey = hotkey.RegisterHotKey("frisk_hotkey", true, decodeJson(default_settings.keys.frisk_key), function() end);
	
	commands_for_keys = {
		[cuff_hotkey:GetHotKey()] = "/cuff",
		[uncuff_hotkey:GetHotKey()] = "/uncuff",
		[follow_hotkey:GetHotKey()] = "/follow",
		[cput_hotkey:GetHotKey()] = "/cput",
		[ceject_hotkey:GetHotKey()] = "/ceject",
		[frisk_hotkey:GetHotKey()] = "/frisk"
	};
	
	sampRegisterChatCommand(script_command, function() show_window[0] = not show_window[0] end);
		
    while true do
		wait(0);
		local has_target, handle = getCharPlayerIsTargeting(PLAYER_HANDLE);
		local current_weapon_is_fist = isCurrentCharWeapon(PLAYER_PED, 0);

		if has_target and current_weapon_is_fist and not sampIsCursorActive() then
			lua_thread.create(RenderInteractionMenu);
			lua_thread.create(OnPlayerTargeting, handle);
		end
	end
end

function SaveAllKeys()
	commands_for_keys = {
		[cuff_hotkey:GetHotKey()] = "/cuff",
		[uncuff_hotkey:GetHotKey()] = "/uncuff",
		[follow_hotkey:GetHotKey()] = "/follow",
		[cput_hotkey:GetHotKey()] = "/cput",
		[ceject_hotkey:GetHotKey()] = "/ceject",
		[frisk_hotkey:GetHotKey()] = "/frisk"
	};
	
	default_settings.keys.cuff_key = encodeJson(cuff_hotkey:GetHotKey());
	default_settings.keys.uncuff_key = encodeJson(uncuff_hotkey:GetHotKey());
	default_settings.keys.follow_key = encodeJson(follow_hotkey:GetHotKey());
	default_settings.keys.cput_key = encodeJson(cput_hotkey:GetHotKey());
	default_settings.keys.ceject_key = encodeJson(ceject_hotkey:GetHotKey());
	default_settings.keys.frisk_key = encodeJson(frisk_hotkey:GetHotKey());
	
	inicfg.save(default_settings, settings_filename);
end

function ResetAllKeys()
	commands_for_keys = {};
	
	cuff_hotkey:EditHotKey({});
	uncuff_hotkey:EditHotKey({});
	follow_hotkey:EditHotKey({});
	cput_hotkey:EditHotKey({});
	ceject_hotkey:EditHotKey({});
	frisk_hotkey:EditHotKey({});
	
	default_settings.keys.cuff_key = encodeJson(cuff_hotkey:GetHotKey());
	default_settings.keys.uncuff_key = encodeJson(uncuff_hotkey:GetHotKey());
	default_settings.keys.follow_key = encodeJson(follow_hotkey:GetHotKey());
	default_settings.keys.cput_key = encodeJson(cput_hotkey:GetHotKey());
	default_settings.keys.ceject_key = encodeJson(ceject_hotkey:GetHotKey());
	default_settings.keys.frisk_key = encodeJson(frisk_hotkey:GetHotKey());

	inicfg.save(default_settings, settings_filename);
end

function RenderHotKey(button_size, curr_hotkey)
	curr_hotkey:ShowHotKey(button_size);
end

imgui.OnInitialize(function()
    imgui.GetIO().IniFilename = nil;
end);

imgui.OnFrame(
    function() return show_window[0] end,
    function(this)
		local hotkey_button_size = imgui.ImVec2(100, 20);
        imgui.SetNextWindowPos(imgui.ImVec2(screen_width / 2, screen_height / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.SetNextWindowSize(imgui.ImVec2(400, 250), imgui.Cond.FirstUseEver)
        imgui.Begin(u8"Главное окно", show_window, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse)
		
		if imgui.BeginTabBar(u8"Настройки") then
			if imgui.BeginTabItem(u8"Горячие клавиши") then
			
				RenderHotKey(hotkey_button_size, cuff_hotkey);
				imgui.SameLine();
				imgui.Text(u8"Надеть наручники");
				
				RenderHotKey(hotkey_button_size, uncuff_hotkey);
				imgui.SameLine();
				imgui.Text(u8"Снять наручники");
		
				RenderHotKey(hotkey_button_size, follow_hotkey);
				imgui.SameLine();
				imgui.Text(u8"Вести задержанного за собой");
		
				RenderHotKey(hotkey_button_size, cput_hotkey);
				imgui.SameLine();
				imgui.Text(u8"Посадить задержанного в транспорт");
		
				RenderHotKey(hotkey_button_size, ceject_hotkey);
				imgui.SameLine();
				imgui.Text(u8"Высадить задержанного из транспорта");
		
				RenderHotKey(hotkey_button_size, frisk_hotkey);
				imgui.SameLine();
				imgui.Text(u8"Провести обыск задержанного");
				
				imgui.NewLine();
				if imgui.Button(u8"Сохранить настройки") then
					sampAddChatMessage("Настройки были сохранены", script_main_color);
					SaveAllKeys();
				end
				
				imgui.SameLine();
				if imgui.Button(u8"Сбросить все настройки") then
					ResetAllKeys();
				end
				
				imgui.EndTabItem();
			end
			
			if imgui.BeginTabItem(u8"Информация") then
				imgui.Text(u8"Помощник для полицейского на проекте Samp-Rp.\nАвтор: shlang (aka Adam_Ward).\nВерсия: 1.");
				imgui.Separator();
				imgui.Text(u8"/ph - открыть главное меню.\nmoonloader/config/ph_settings.ini - файл с настройками.");
				imgui.EndTabItem();
			end
			imgui.EndTabBar();
		end
		
        imgui.End()
    end
);

local is_debug = true;

function OnPlayerTargeting(target_handle)
	local result, target_id = sampGetPlayerIdByCharHandle(target_handle);
	if result then
		for key, command in pairs(commands_for_keys) do
			if wasKeyPressed(key[1]) then
				if is_debug then
					sampSendChat("/c " .. command .. " " .. target_id);
				else
					sampSendChat(command .. " " .. target_id);
				end
			end
		end
	end
end

function RenderInteractionMenu()
	local cuff_key = decodeJson(default_settings.keys.cuff_key);
	local uncuff_key = decodeJson(default_settings.keys.uncuff_key);
	local follow_key = decodeJson(default_settings.keys.follow_key);
	local cput_key = decodeJson(default_settings.keys.cput_key);
	local ceject_key = decodeJson(default_settings.keys.ceject_key);
	local frisk_key = decodeJson(default_settings.keys.frisk_key);
	
	local empty_hotkey_text = "None";
	local cuff_text = "[" .. (cuff_key[1] == nil and empty_hotkey_text or vkeys.id_to_name(cuff_key[1])) .. "]" .. " - Надеть наручники\n";
	local uncuff_text = "[" .. (uncuff_key[1] == nil and empty_hotkey_text or vkeys.id_to_name(uncuff_key[1])) .. "]" .. " - Снять наручники\n";
	local follow_text = "[" .. (follow_key[1] == nil and empty_hotkey_text or vkeys.id_to_name(follow_key[1])) .. "]" .. " - Вести за собой\n";
	local cput_text = "[" .. (cput_key[1] == nil and empty_hotkey_text or vkeys.id_to_name(cput_key[1])) .. "]" .. " - Посадить в транспорт\n";
	local ceject_text = "[" .. (ceject_key[1] == nil and empty_hotkey_text or vkeys.id_to_name(ceject_key[1])) .. "]" .. " - Высадить из транспорта\n";
	local frisk_text = "[" .. (frisk_key[1] == nil and empty_hotkey_text or vkeys.id_to_name(frisk_key[1])) .. "]" .. " - Провести обыск\n";
	
	renderFontDrawText(font, cuff_text .. uncuff_text .. follow_text .. cput_text .. ceject_text .. frisk_text, 500, 550, 0xFFffffff, false);
end