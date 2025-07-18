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
