-- local imgui = require("mimgui");
-- local hotkey = require("mimgui_hotkeys");
-- local inicfg = require("inicfg");
-- local encoding = require("encoding");
-- local font_flags = require("lib.moonloader").font_flag;
-- local vkeys = require("lib.vkeys");

-- encoding.default = "CP1251";
-- local u8 = encoding.UTF8;

require("Target");
require("Action");

local cuff = Action:new{
    command_ = "/cuff",
    buffer_ = "/me took out handcuffs and put them on @target_nickname",
    json_ = "[49]"
};

local uncuff = Action:new{
    command_ = "/uncuff",
    buffer_ = "/me removed handcuffs from @target_nickname",
    json_ = "[50]"
};

local target = Target:new{
    nickname_ = "Oleja_Grobovshik",
    id_ = 999
};

cuff:sendRoleplayCommand(target);