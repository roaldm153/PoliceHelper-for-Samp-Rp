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