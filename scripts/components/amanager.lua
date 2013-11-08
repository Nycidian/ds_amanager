local string = require("string")

local AManager = Class(function(self, inst)
	self.inst = inst
    self.once = {}
    self.tick = {}

    ------------------------------------------------------------------------

    self.killed = {}

    self.techLevel ={}
    self.techLearned ={}

    ------------------------------------------------------------------------
    self:StartIt()
	
end)

function AManager:StartIt(inst)

    if not self.tick.task then
        
        self.tick.task = true

        -- killed
        self.tick.killed = self.inst:ListenForEvent("killed", function(inst, data) self:EvalKilled(data.victim.prefab) end) --what
        self.tick.makerecipe = self.inst:ListenForEvent("makerecipe", function(inst, data) self:EvalTechLevel(data.recipe) end) -- recipe table
        --self.tick.techtreechange = self.inst:ListenForEvent("techtreechange", function(inst, data) self:EvalTechLevel(data) end) --techtree table

        --self.tick.armorbroke = self.inst:ListenForEvent("armorbroke", function(inst, data) self:EvalEvent("armorbroke", data) end) -- what armor broke
        --self.tick.attacked = self.inst:ListenForEvent("attacked", function(inst, data) self:EvalEvent("attacked", data) end) -- by what and damage taken (does not show grue, grue = nil?)
        --self.tick.attackedbygrue = self.inst:ListenForEvent("attackedbygrue", function(inst, data) self:EvalEvent("attackedbygrue", data) end)
        --self.tick.builditem = self.inst:ListenForEvent("builditem", function(inst, data) self:EvalEvent("builditem", data) end) -- items built from sidebar that go into inv
        --self.tick.buildstructure = self.inst:ListenForEvent("buildstructure", function(inst, data) self:EvalEvent("buildstructure", data) end) -- items built from sidebar that do notgo into inv
        --self.tick.catch = self.inst:ListenForEvent("catch", function(inst, data) self:EvalEvent("catch", data) end) -- no data --boomerang
        --self.tick.changearea = self.inst:ListenForEvent("changearea", function(inst, data) self:EvalEvent("changearea", data) end) --confusing
        --self.tick.clocktick = self.inst:ListenForEvent("clocktick", function(inst, data) self:EvalEvent("clocktick", data) end, GetWorld()) -- phase , normalizedtime
        
        
        
        --self.tick.daycomplete = self.inst:ListenForEvent("daycomplete", function(inst, data) self:EvalEvent("daycomplete", data) end, GetWorld()) --day(#)
        --self.tick.daytime = self.inst:ListenForEvent("daytime", function(inst, data) self:EvalEvent("daytime", data) end, GetWorld()) -- day(#)
        --self.tick.death = self.inst:ListenForEvent("death", function(inst, data) self:EvalEvent("death", data) end) cause
        --self.tick.donetalking = self.inst:ListenForEvent("donetalking", function(inst, data) self:EvalEvent("donetalking", data) end) -- works, no data
        --self.tick.dropitem = self.inst:ListenForEvent("dropitem", function(inst, data) self:EvalEvent("dropitem", data) end) -- item
        --self.tick.dusktime = self.inst:ListenForEvent("dusktime", function(inst, data) self:EvalEvent("dusktime", data) end, GetWorld()) -- day(#)
        --self.tick.enterdark = self.inst:ListenForEvent("enterdark", function(inst, data) self:EvalEvent("enterdark", data) end) --nodata
        --self.tick.endquake = self.inst:ListenForEvent("endquake", function(inst, data) self:EvalEvent("endquake", data) end, GetWorld()) -- no data
        --self.tick.startquake = self.inst:ListenForEvent("startquake", function(inst, data) self:EvalEvent("startquake", data) end, GetWorld()) -- no data
        --self.tick.warnquake = self.inst:ListenForEvent("warnquake", function(inst, data) self:EvalEvent("warnquake", data) end, GetWorld()) -- no data
        --self.tick.explosion = self.inst:ListenForEvent("explosion", function(inst, data) self:EvalEvent("explosion", data) end) -- what explosive
        --self.tick.firedamage = self.inst:ListenForEvent("firedamage", function(inst, data) self:EvalEvent("firedamage", data) end) --nodata
        --`self.tick.fishingcatch = self.inst:ListenForEvent("fishingcatch", function(inst, data) self:EvalEvent("fishingcatch", data) end) --caught sort of
        --self.tick.fishingnibble = self.inst:ListenForEvent("fishingnibble", function(inst, data) self:EvalEvent("fishingnibble", data) end) -- nodata
        
        --self.tick.huntbeastnearby = self.inst:ListenForEvent("huntbeastnearby", function(inst, data) self:EvalEvent("huntbeastnearby", data) end) -- nodata
        --self.tick.huntlosttrail = self.inst:ListenForEvent("huntlosttrail", function(inst, data) self:EvalEvent("huntlosttrail", data) end) -- nodata ?
        --self.tick.healthdelta = self.inst:ListenForEvent("healthdelta", function(inst, data) self:EvalEvent("healthdelta", data) end) -- oldpercent newpercent cause
        
        --self.tick.killed = self.inst:ListenForEvent("killed", function(inst, data) self:EvalEvent("killed", data) end) --what
        --self.tick.lightningstrike= self.inst:ListenForEvent("lightningstrike", function(inst, data) self:EvalEvent("lightningstrike", data) end) -- nodata
    
        --self.tick.nighttime = self.inst:ListenForEvent("nighttime", function(inst, data) self:EvalEvent("nighttime", data) end, GetWorld()) -- day(#)
        --self.tick.oneatsomething = self.inst:ListenForEvent("oneatsomething", function(inst, data) self:EvalEvent("oneatsomething", data) end) -- food = data.prefab
        --self.tick.onpickup = self.inst:ListenForEvent("onpickup", function(inst, data) self:EvalEvent("onpickup", data) end) -- item = data.prefab
        --self.tick.onhitother = self.inst:ListenForEvent("onhitother", function(inst, data) self:EvalEvent("onhitother", data) end) -- attacked what and damage done
        --self.tick.picksomething = self.inst:ListenForEvent("picksomething", function(inst, data) self:EvalEvent("picksomething", data) end) -- item = data.prefab
        --self.tick.resurrect = self.inst:ListenForEvent("resurrect", function(inst, data) self:EvalEvent("resurrect", data) end) -- no data
        --self.tick.seasonChange = self.inst:ListenForEvent("seasonChange", function(inst, data) self:EvalEvent("seasonChange", data) end, GetWorld()) -- season
        --self.tick.startstarving = self.inst:ListenForEvent("startstarving", function(inst, data) self:EvalEvent("startstarving", data) end) --nodata
        --self.tick.stopstarving = self.inst:ListenForEvent("stopstarving", function(inst, data) self:EvalEvent("stopstarving", data) end) --nodata
        
        --self.tick.temperaturedelta = self.inst:ListenForEvent("temperaturedelta", function(inst, data) self:EvalEvent("temperaturedelta", data) end) --no data
        --self.tick.torchranout = self.inst:ListenForEvent("torchranout", function(inst, data) self:EvalEvent("torchranout", data) end) -- item = data.prefab
        
        --self.tick.transform_person = self.inst:ListenForEvent("transform_person", function(inst, data) self:EvalEvent("transform_person", data) end) --no data
        --self.tick.transform_werebeaver = self.inst:ListenForEvent("transform_werebeaver", function(inst, data) self:EvalEvent("transform_werebeaver", data) end) --no data

        ------------------------------
        --self.tick.equipped = self.inst:ListenForEvent("equipped", function(inst, data) self:EvalEvent("equipped", data) end) --item
        --self.tick.unequipped = self.inst:ListenForEvent("unequipped", function(inst, data) self:EvalEvent("unequipped", data) end) --item
        --self.tick.growfrombutterfly = self.inst:ListenForEvent("growfrombutterfly", function(inst, data) self:EvalEvent("growfrombutterfly", data) end) -- nodata
        --self.tick.growfromseed = self.inst:ListenForEvent("growfromseed", function(inst, data) self:EvalEvent("growfromseed", data) end) -- nodata
        --self.tick.harvesttrap = self.inst:ListenForEvent("harvesttrap", function(inst, data) self:EvalEvent("harvesttrap", data) end) -- what's harvested
        -------------------------------
        --self.tick.onignite = self.inst:ListenForEvent("playerignite", function(inst, data) self:EvalEvent("playerignite", data) end) -- what started fire, primary/secondary whats burning, nuber total ignite
        --self.tick.startfollowing = self.inst:ListenForEvent("uniquefollower", function(inst, data) self:EvalEvent("uniquefollower", data) end) -- number of unique followers ever
       -- self.tick.broke  = self.inst:ListenForEvent("broken", function(inst, data) self:EvalEvent("broken", data) end) -- what broke
        ------------------------------

        -- how much wood chopped
        --player sleeping look at sleepign bags
        -- catching bugs
        -- self.tick.techlevelchange = self.inst:ListenForEvent("techlevelchange", function(inst, data) self:EvalEvent("techlevelchange", data) end) --?????
        --self.tick.sanitydelta = self.inst:ListenForEvent("sanitydelta", function(inst, data) self:EvalEvent("sanitydelta", data) end) -- have to make gosane goinsane
    end
end

function AManager:Merit()

    print("merit run")

end

function AManager:EvalEvent(event, data)

    if data then
        for key,value in pairs(data) do print(event, key,value) end 
    else
        print(event)
    end

end


function AManager:EvalKilled(victim)

    if not self.killed[victim] then
        self.killed[victim] = 1
    else
        self.killed[victim] = self.killed[victim] + 1
    end
    self:Merit()
end

function AManager:EvalTechLevel(data)

    if not self.techLearned[data.name] then
            self.techLearned[data.name] = data.level
    end
    
    local function calc()
        local techLevelCalc = {}
        for key,value in pairs(GetPlayer().components.builder.recipes) do 
            print(key,value) 

            local pass = self.techLearned[value]

            if pass.SCIENCE == 0 and pass.MAGIC  == 0 and pass.ANCIENT == 0 then
                
                if not techLevelCalc["base"] then
                    techLevelCalc["base"] = 1
                else
                    techLevelCalc["base"] = techLevelCalc["base"] + 1
                end
                
            elseif pass.SCIENCE == 1 then

                if not techLevelCalc["science_low"] then
                    techLevelCalc["science_low"] = 1
                else
                    techLevelCalc["science_low"] = techLevelCalc["science_low"] + 1
                end

            elseif pass.SCIENCE == 2 then

                if not techLevelCalc["science_high"] then
                    techLevelCalc["science_high"] = 1
                else
                    techLevelCalc["science_high"] = techLevelCalc["science_high"] + 1
                end

            elseif pass.MAGIC == 1 then

                if not techLevelCalc["magic_low"] then
                    techLevelCalc["magic_low"] = 1
                else
                    techLevelCalc["magic_low"] = techLevelCalc["magic_low"] + 1
                end

            elseif pass.MAGIC == 2 then

                if not techLevelCalc["magic_high"] then
                    techLevelCalc["magic_high"] = 1
                else
                    techLevelCalc["magic_high"] = techLevelCalc["magic_high"] + 1
                end

            elseif pass.ANCIENT == 2 then

                 if not techLevelCalc["ancient_low"] then
                    techLevelCalc["ancient_low"] = 1
                else
                    techLevelCalc["ancient_low"] = techLevelCalc["ancient_low"] + 1
                end

            elseif pass.ANCIENT == 4 then

                if not techLevelCalc["ancient_high"] then
                    techLevelCalc["ancient_high"] = 1
                else
                    techLevelCalc["ancient_high"] = techLevelCalc["ancient_high"] + 1
                end

            else

            end
            

        end
        self.techLevel = techLevelCalc
        self:Merit()
    end

    self.once.onDelayed = self.inst:DoTaskInTime(2, function(inst, data) calc() end)
    
end

function AManager:OnSave()
	return { killed = self.killed }
end


function AManager:OnLoad(data)
	if data.killed ~= nil then
		self.killed = data.killed
	end
end


return AManager
