--[[
	Bundled Using LuBu - Simple Lua Bundler
	LuBu: https://github.com/chaposcripts/lubu
]]


-- Constants
LUBU_BUNDLED = true;
LUBU_BUNDLED_AT = 1752824652;
VERSION = "1.1a";

-- Module "target" (from C:\games\gta sa embeded\moonly\PoliceHelper-for-Samp-Rp\src\target.lua)
package.preload['target'] = (function()
Target = {
    nickname_,
    id_
};

function Target:new(player)
    player = player or {};
    setmetatable(player, self);
    self.__index = self;

    return player;
end

function Target:getTargetId()
    return self.id_;
end

function Target:getTargetNickname()
    local i, j = string.find(self.nickname_, "_");
    while (i and j) do
        self.nickname_ = string.gsub(self.nickname_, "_", " ");
        i, j = string.find(self.nickname_, "_");
    end

    return self.nickname_;
end
end);

-- Module "actions_list" (from C:\games\gta sa embeded\moonly\PoliceHelper-for-Samp-Rp\src\actions_list.lua)
package.preload['actions_list'] = (function()
ActionsList = {
    list_ = {}
};

function ActionsList:new(object)
    object = object or {};
    setmetatable(object, self);
    self.__index = self;

    return object;
end

function ActionsList:pushBack(action)
    self.list_[#self.list_ + 1] = action;
end

function ActionsList:popBack()
    if (#self.list_ > 0) then
        self.list_[#self.list_] = nil;
    end
end

function ActionsList:at(position)
    return self.list_[position];
end

function ActionsList:getSize()
    return #self.list_;
end

end);

-- Module "action" (from C:\games\gta sa embeded\moonly\PoliceHelper-for-Samp-Rp\src\action.lua)
package.preload['action'] = (function()
local hotkey = require("mimgui_hotkeys");
local ffi = require("ffi");
local imgui = require("mimgui");

Action = {
    command_,
    buffer_,
    json_,
    hotkey_,
    description_
};

local action = {};

local variables = {
    ["@target_nickname"] = function(t) return t:getTargetNickname() end,
    ["@target_id"] = function(t) return t:getTargetId() end
};

action.variables = variables;

function Action:new(object)
    object = object or {};
    setmetatable(object, self);
    self.__index = self;

    return object;
end

function Action:setCommand(command)
    self.command_ = command;
end

function Action:getCommand()
    return self.command_;
end

function Action:setBuffer(buffer)
    self.buffer_ = buffer;
end

function Action:getBuffer(buffer)
    return self.buffer_;
end

function Action:setJson(json)
    self.json_ = json;
end

function Action:getJson()
    return self.json_;
end

function Action:setDescription(description)
    self.description_ = description;
end

function Action:getDescription()
    return self.description_;
end

function Action:setHotkey(hotkey)
    self.hotkey_ = hotkey;
end

function Action:getHotkey()
    return hotkey.GetHotKey(self.command_);
end

function Action:createRoleplayCommand(target)
    local fullCommand = "/" .. self.command_ .. " " .. target:getTargetId();
    local text = ffi.string(self.buffer_);
    for var, func in pairs(variables) do
        local left, right = string.find(text, var);
        while (left and right) do
            text = string.gsub(text, string.sub(text, left, right), func(target));
            left, right = string.find(text, var);
        end
    end
    
    return fullCommand, text;
end

function Action:printParams()
    print(self.command_, ffi.string(self.buffer_), self.json_, self.description_, self.hotkey_);
end

return action;
end);

-- Init (from C:\games\gta sa embeded\moonly\PoliceHelper-for-Samp-Rp\src\init.lua) 
LUBU_ENTRY_POINT = (function()
local action = require("action");
local target = require("target");
local alist = require("actions_list");
local imgui = require("mimgui");
local hotkey = require("mimgui_hotkeys");
local inicfg = require("inicfg");
local encoding = require("encoding");
local font_flags = require("lib.moonloader").font_flag;
local vkeys = require("lib.vkeys");
local ffi = require("ffi");


encoding.default = "CP1251";
local u8 = encoding.UTF8;
local DISPATCH_DELAY = 250;
local FONT = renderCreateFont("Tahoma", 14, font_flags.BOLD + font_flags.BORDER);


hotkey.Text.NoKey = u8"Нет клавиши";
hotkey.Text.WaitForKey = u8"Нажмите клавишу";


local cuff = Action:new{
    command_ = "cuff",
    buffer_ = u8"/me выхватил наручники и надел их на @target_nickname.",
    json_ = "{}",
    hotkey_ = hotkey.RegisterHotKey("cuff", true, {}, function() end),
    description_ = u8"Надеть наручники"
};
local uncuff = Action:new{
    command_ = "uncuff",
    buffer_ = u8"/me снял наручники с @target_nickname.",
    json_ = "{}",
    hotkey_ = hotkey.RegisterHotKey("uncuff", true, {}, function() end),
    description_ = u8"Снять наручники"
};
local follow = Action:new{
    command_ = "follow",
    buffer_ = u8"/me повел @target_nickname за собой.",
    json_ = "{}",
    hotkey_ = hotkey.RegisterHotKey("follow", true, {}, function() end),
    description_ = u8"Вести за собой"
};
local cput = Action:new{
    command_ = "cput",
    buffer_ = u8"/me посадил @target_nickname в транспорт.",
    json_ = "{}",
    hotkey_ = hotkey.RegisterHotKey("cput", true, {}, function() end),
    description_ = u8"Посадить в транспорт"
};
local ceject = Action:new{
    command_ = "ceject",
    buffer_ = u8"/me высадил @target_nickname из транспорта.",
    json_ = "{}",
    hotkey_ = hotkey.RegisterHotKey("ceject", true, {}, function() end),
    description_ = u8"Высадить из транспорта"
};
local frisk = Action:new{
    command_ = "frisk",
    buffer_ = u8"/me надел перчатки и обыскал @target_nickname.",
    json_ = "{}",
    hotkey_ = hotkey.RegisterHotKey("frisk", true, {}, function() end),
    description_ = u8"Провести обыск"
};

local actionsList = ActionsList:new({});
actionsList:pushBack(cuff);
actionsList:pushBack(uncuff);
actionsList:pushBack(follow);
actionsList:pushBack(cput);
actionsList:pushBack(ceject);
actionsList:pushBack(frisk);

local settings_filename = "ph_settings.ini";
local settings = inicfg.load(nil, settings_filename);
if (settings) then
    actionsList = ActionsList:new{settings};
    for i = 1, actionsList:getSize() do
        hotkey.RemoveHotKey(actionsList:at(i):getCommand());
        actionsList:at(i).hotkey_ = hotkey.RegisterHotKey(
            actionsList:at(i):getCommand(), true, decodeJson(
                settings[i].json_), function() end);
    end
else
    settings = inicfg.load(actionsList.list_, settings_filename);
    inicfg.save(settings, settings_filename);
end

local script_command = "ph";

local is_debug = true;
local screen_width, screen_height = getScreenResolution();
local show_window = imgui.new.bool(false);

function main()
    while not isSampAvailable() do wait(0) end

    if (is_debug) then sampAddChatMessage('Loaded!', -1) end
    sampRegisterChatCommand(script_command, function() show_window[0] = not show_window[0] end);

    while true do
		wait(0);
		local hasTarget, handle = getCharPlayerIsTargeting(PLAYER_HANDLE);
		local isCurrentWeaponFist = isCurrentCharWeapon(PLAYER_PED, 0);
		if hasTarget and isCurrentWeaponFist and not sampIsCursorActive() then
			lua_thread.create(renderInteractionMenu);
			lua_thread.create(onPlayerTargeting, handle);
		end
	end
end

function onPlayerTargeting(targetHandle)
    local targetId = select(2, sampGetPlayerIdByCharHandle(targetHandle));
    local targetNickname = sampGetPlayerNickname(targetId);
    local target = Target:new{
        nickname_ = targetNickname
        , id_ = targetId
    };

    for i = 1, actionsList:getSize() do
        local key = decodeJson(settings[i].json_)[1];
        if (wasKeyPressed(key)) then
            local command, text = actionsList:at(i):createRoleplayCommand(target);
            text = u8:decode(text);
            if (is_debug) then
                sampSendChat("/c " .. command);
                wait(DISPATCH_DELAY);
                sampSendChat("/c " .. text);
            else
                sampSendChat(command);
                wait(DISPATCH_DELAY);
                sampSendChat(text);
            end
        end
    end
end

function renderInteractionMenu()
    local text = {};
    for i = 1, actionsList:getSize() do
        local key = decodeJson(settings[i].json_)[1];
        if (not key) then key = "None" end
        local description = settings[i].description_;
        text[#text + 1] = string.format("[%s] - %s", vkeys.id_to_name(key), description);
    end

    renderFontDrawText(FONT, u8:decode(table.concat(text, "\n")), 500, 550, 0xFFffffff, false);
end

imgui.OnInitialize(function()
    imgui.GetIO().IniFilename = nil;
end);

imgui.OnFrame(
    function()
        return show_window[0] 
    end,
    function(this)
        local hotkey_button_size = imgui.ImVec2(115, 20);
        local main_window_size = imgui.ImVec2(650, 500);
        local hotkey_child_size = imgui.ImVec2(300, actionsList:getSize() * 26);
        local text_child_size = imgui.ImVec2(650, actionsList:getSize() * 26);
        local variables_list_child_size = imgui.ImVec2(650, 100);

        imgui.SetNextWindowPos(imgui.ImVec2(screen_width / 2, screen_height / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.SetNextWindowSize(main_window_size, imgui.Cond.FirstUseEver)
        imgui.Begin("PoliceHelper for Samp-Rp", show_window, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.AlwaysAutoResize)
        if (imgui.BeginTabBar(u8"Настройки")) then
            if (imgui.BeginTabItem(u8"Горячие клавиши")) then
                imgui.BeginGroup();
                imgui.BeginChild("hotkeys", hotkey_child_size, true);
                for i = 1, actionsList:getSize() do
                    if hotkey.ShowHotKey(actionsList:at(i):getCommand(), hotkey_button_size) then
                        actionsList:at(i):setJson(encodeJson(actionsList:at(i):getHotkey()));
                        settings[i].json_ = actionsList:at(i):getJson();
                        inicfg.save(settings, settings_filename);
                    end
                    imgui.SameLine();
			        imgui.Text(actionsList:at(i):getDescription());
                end     
                imgui.EndChild();
                imgui.EndGroup();
                imgui.EndTabItem();
            end

            if (imgui.BeginTabItem(u8"Отыгровки")) then
                imgui.BeginGroup();
                imgui.BeginChild("text", text_child_size, true);

                for i = 1, actionsList:getSize() do
                    local description = (actionsList:at(i):getDescription());
                    local buffer = imgui.new.char[256](actionsList:at(i):getBuffer());

                    imgui.PushItemWidth(450);
                    if imgui.InputText(description, buffer, ffi.sizeof(buffer)) then
                        actionsList:at(i):setBuffer(ffi.string(buffer));
                        settings[i].buffer_ = actionsList:at(i):getBuffer();
                    end
                    imgui.PopItemWidth();

                end

                imgui.EndChild();

                imgui.BeginChild("variables_list", variables_list_child_size, true);
                imgui.Text(u8"Список переменных:"); 
                for key, value in pairs(action.variables) do
                    imgui.Text(key);
                end
                imgui.EndChild();

                imgui.EndGroup();
                imgui.EndTabItem();
            end
            
            imgui.EndTabBar();
        end
        imgui.End()
    end
);
end);
LUBU_ENTRY_POINT();