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