local string = require("string")
local GLOBAL ={}
local ASave = Class(function(self, inst)
	self.inst = inst
    ------------------------------------------------------------------------
    self.save = {}
end)

function ASave:LoadSave()
    return self.save
end

function ASave:OnSave()
	return GetPlayer().components.amanager:OnSave()
end

function ASave:OnLoad(data)
	if data ~= nil then
		self.save = data
	end

end

return ASave
