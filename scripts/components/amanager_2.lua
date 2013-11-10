local string = require("string")
local GLOBAL ={}
local AManager = Class(function(self, inst)
	self.inst = inst
    self.once = {}
    self.tick = {}
    ------------------------------------------------------------------------
    self.mods = {}
    self.version = 2
    ------------------------------------------------------------------------
    -- Multipliers
    self.KILL_MULT = 1.0
    self.TECH_MULT = 1.0
    self.SURV_MULT = 1.0

    -- Amounts Per before Calculation
    self.TIME_AWARD = 25
    self.WINTER_AWARD = 1000
    self.HOUNDED_AWARD = 100
    self.TECH_AWARD = 5

    self.RES_AWARD = -1000

    -- Non award amounts change to numbers to award.
    self.GRUE_AWARD = 0
    ------------------------------------------------------------------------
    self.points = 0
    ------------------------------------------------------------------------
    self.killed = {}
    self.techLevel = {}
    self.survived = {}
    ------------------------------------------------------------------------
    self:StartIt()
    self:EvalTechLevel({dummy=true})
end)

function AManager:StartIt(inst)

    if not self.tick.task then
        
        self.tick.task = true

        -- killed
        self.tick.killed = self.inst:ListenForEvent("killed", function(inst, data) self:EvalKilled(data.victim) end) --what

        -- techLevel
        self.tick.unlockrecipe = self.inst:ListenForEvent("unlockrecipe", function(inst, data) self:EvalTechLevel(data) end) -- recipe table


        
        
        -- Survived
            --days
                self.tick.daycomplete = self.inst:ListenForEvent("daycomplete", function(inst, data) self:EvalSurvived("dayComplete", data) end, GetWorld()) --day(#)
            -- Grue Attacks
                self.tick.attackedbygrue = self.inst:ListenForEvent("attackedbygrue", function(inst, data) self:EvalSurvived("attackedByGrue", data) end)
            -- death
                self.tick.resurrect = self.inst:ListenForEvent("resurrect", function(inst, data) self:EvalSurvived("resurrect", data) end) -- no data
            -- winter
                self.tick.seasonChange = self.inst:ListenForEvent("seasonChange", function(inst, data) self:EvalSurvived("seasonChange", data) end, GetWorld()) -- season
            -- playerhounded
                self.tick.playerhounded = self.inst:ListenForEvent("playerhounded", function(inst, data) self:EvalSurvived("playerHounded", data) end) 
        
        -- explored
            self.tick.changearea = self.inst:ListenForEvent("changearea", function(inst, data) self:EvalExplored(data) end) --confusing

        -- Number times caught boomerang in a row
            --self.tick.catch = self.inst:ListenForEvent("catch", function(inst, data) self:EvalEvent("catch", data) end) -- no data --boomerang

        -- Fish Caught
            --self.tick.fishingcatch = self.inst:ListenForEvent("fishingcatch", function(inst, data) self:EvalEvent("fishingcatch", data) end) --caught sort of
        
        -- struck by lightning 
            --self.tick.lightningstrike= self.inst:ListenForEvent("lightningstrike", function(inst, data) self:EvalEvent("lightningstrike", data) end) -- nodata
        
        -- food eaten
            --self.tick.oneatsomething = self.inst:ListenForEvent("oneatsomething", function(inst, data) self:EvalEvent("oneatsomething", data) end) -- food = data.prefab
        
        -- harvested
            --self.tick.picksomething = self.inst:ListenForEvent("picksomething", function(inst, data) self:EvalEvent("picksomething", data) end) -- item = data.prefab
        
        -- starved
            --self.tick.startstarving = self.inst:ListenForEvent("startstarving", function(inst, data) self:EvalEvent("startstarving", data) end) --nodata
        
        -- freezed
            -- add custom event
        
        -- butterflies planted
            --self.tick.growfrombutterfly = self.inst:ListenForEvent("growfrombutterfly", function(inst, data) self:EvalEvent("growfrombutterfly", data) end) -- nodata
        
        -- trees planted
            --self.tick.growfromseed = self.inst:ListenForEvent("growfromseed", function(inst, data) self:EvalEvent("growfromseed", data) end) -- nodata
        
        -- amount trapped
            --self.tick.harvesttrap = self.inst:ListenForEvent("harvesttrap", function(inst, data) self:EvalEvent("harvesttrap", data) end) -- what's harvested
        
        -- # items player burned
            --self.tick.playerignite = self.inst:ListenForEvent("playerignite", function(inst, data) self:EvalEvent("playerignite", data) end) -- what started fire, primary/secondary whats burning, nuber total ignite
        
        -- # unique followers
            --self.tick.startfollowing = self.inst:ListenForEvent("uniquefollower", function(inst, data) self:EvalEvent("uniquefollower", data) end) -- number of unique followers ever
        
        -- # items broke
            --self.tick.broke  = self.inst:ListenForEvent("broken", function(inst, data) self:EvalEvent("broken", data) end) -- what broke

        -- how much wood chopped

        -- # times player slept

        -- catching bugs


        ------------------------------
        ------Character Specific------
        ------------------------------
        --self.tick.transform_person = self.inst:ListenForEvent("transform_person", function(inst, data) self:EvalEvent("transform_person", data) end) --no data
        --self.tick.transform_werebeaver = self.inst:ListenForEvent("transform_werebeaver", function(inst, data) self:EvalEvent("transform_werebeaver", data) end) --no data
        -------------------------------
        ------------------------------
        
        -- self.tick.techlevelchange = self.inst:ListenForEvent("techlevelchange", function(inst, data) self:EvalEvent("techlevelchange", data) end) --?????
        --self.tick.sanitydelta = self.inst:ListenForEvent("sanitydelta", function(inst, data) self:EvalEvent("sanitydelta", data) end) -- have to make gosane goinsane
        --self.tick.armorbroke = self.inst:ListenForEvent("armorbroke", function(inst, data) self:EvalEvent("armorbroke", data) end) -- what armor broke
        --self.tick.attacked = self.inst:ListenForEvent("attacked", function(inst, data) self:EvalEvent("attacked", data) end) -- by what and damage taken (does not show grue, grue = nil?)
        --self.tick.builditem = self.inst:ListenForEvent("builditem", function(inst, data) self:EvalEvent("builditem", data) end) -- items built from sidebar that go into inv
        --self.tick.buildstructure = self.inst:ListenForEvent("buildstructure", function(inst, data) self:EvalEvent("buildstructure", data) end) -- items built from sidebar that do notgo into inv
        
        --self.tick.clocktick = self.inst:ListenForEvent("clocktick", function(inst, data) self:EvalEvent("clocktick", data) end, GetWorld()) -- phase , normalizedtime
        --self.tick.donetalking = self.inst:ListenForEvent("donetalking", function(inst, data) self:EvalEvent("donetalking", data) end) -- works, no data
        --self.tick.dropitem = self.inst:ListenForEvent("dropitem", function(inst, data) self:EvalEvent("dropitem", data) end) -- item
        --self.tick.enterdark = self.inst:ListenForEvent("enterdark", function(inst, data) self:EvalEvent("enterdark", data) end) --nodata
        --self.tick.endquake = self.inst:ListenForEvent("endquake", function(inst, data) self:EvalEvent("endquake", data) end, GetWorld()) -- no data
        --self.tick.startquake = self.inst:ListenForEvent("startquake", function(inst, data) self:EvalEvent("startquake", data) end, GetWorld()) -- no data
        --self.tick.warnquake = self.inst:ListenForEvent("warnquake", function(inst, data) self:EvalEvent("warnquake", data) end, GetWorld()) -- no data
        --self.tick.explosion = self.inst:ListenForEvent("explosion", function(inst, data) self:EvalEvent("explosion", data) end) -- what explosive
        --self.tick.firedamage = self.inst:ListenForEvent("firedamage", function(inst, data) self:EvalEvent("firedamage", data) end) --nodata
        --self.tick.fishingnibble = self.inst:ListenForEvent("fishingnibble", function(inst, data) self:EvalEvent("fishingnibble", data) end) -- nodata
        --self.tick.huntbeastnearby = self.inst:ListenForEvent("huntbeastnearby", function(inst, data) self:EvalEvent("huntbeastnearby", data) end) -- nodata
        --self.tick.huntlosttrail = self.inst:ListenForEvent("huntlosttrail", function(inst, data) self:EvalEvent("huntlosttrail", data) end) -- nodata ?
        --self.tick.healthdelta = self.inst:ListenForEvent("healthdelta", function(inst, data) self:EvalEvent("healthdelta", data) end) -- oldpercent newpercent cause
        --self.tick.onpickup = self.inst:ListenForEvent("onpickup", function(inst, data) self:EvalEvent("onpickup", data) end) -- item = data.prefab
        --self.tick.onhitother = self.inst:ListenForEvent("onhitother", function(inst, data) self:EvalEvent("onhitother", data) end) -- attacked what and damage done
        --self.tick.stopstarving = self.inst:ListenForEvent("stopstarving", function(inst, data) self:EvalEvent("stopstarving", data) end) --nodata
        --self.tick.equipped = self.inst:ListenForEvent("equipped", function(inst, data) self:EvalEvent("equipped", data) end) --item
        --self.tick.unequipped = self.inst:ListenForEvent("unequipped", function(inst, data) self:EvalEvent("unequipped", data) end) --item
        --self.tick.dusktime = self.inst:ListenForEvent("dusktime", function(inst, data) self:EvalSurvived("dusktime", data) end, GetWorld()) -- day(#)
        --self.tick.nighttime = self.inst:ListenForEvent("nighttime", function(inst, data) self:EvalSurvived("nighttime", data) end, GetWorld()) -- day(#)
        --self.tick.daytime = self.inst:ListenForEvent("daytime", function(inst, data) self:EvalSurvived("daytime", data) end, GetWorld()) -- day(#)
        --self.tick.dusktime = self.inst:ListenForEvent("dusktime", function(inst, data) self:EvalSurvived("dusktime", data) end, GetWorld()) -- day(#)
    end
end

function AManager:PrintVersion()
    nolineprint("")
    print(self.version)
    nolineprint("")
end

function AManager:SetMods(data)
    self.mods = data
end

function AManager:GetMods()
    return self.mods
end

function AManager:Populate(data)

    self:OnLoad(GetPlayer().components.asave:LoadSave())

    GLOBAL = data

    if not self.techLearned then
        self.techLearned ={}
    end
    
    for key,value in pairs(data.Recipes) do 
        self.techLearned[key] = value.level
    end 
    
end

function AManager:Merit()
    local merit = 0
    
    for key,value in pairs(self.killed) do 
        local count = 0
        for x=1, value.amount, 1 do 
        
            count = count + (1/x)
            if math.floor((count*value.worth)+0.5) == (2*value.worth) then
                --print("break", value.worth, count*value.worth)
                break
            end
        end

        merit = merit + (math.floor((count*value.worth)+0.5)*self.KILL_MULT)
        print("merit of "..key..":", count*value.worth*self.KILL_MULT)
    end

    for key,value in pairs(self.techLevel) do 
        local count = 0
        if key == "base" then
            count = value * self.TECH_AWARD
        elseif key == "science_low" then
            count = value * self.TECH_AWARD*2
        elseif key == "science_high" then
            count = value * (self.TECH_AWARD^2)
        elseif key == "magic_low" then
            count = value * (self.TECH_AWARD^2)
        elseif key == "magic_high" then
            count = value * (self.TECH_AWARD^2)*2
        elseif key == "ancient_low" then
            count = value * (self.TECH_AWARD^3)
        elseif key == "ancient_high" then
            count = value * (self.TECH_AWARD^3)*2
        end
        merit = merit + (count*self.TECH_MULT)
    end

    print("merit total:", merit)
    --[[
    for key,value in pairs(self.killed) do 
        
        if type(value) == "table" then
            for key,value in pairs(value) do 
                print(key,value)
            end 
        else
            print(key,value)
        end
    end 
    --]]

end

function AManager:EvalEvent(event, data)

    if data then
        for key,value in pairs(data) do print(event, key,value) end 
    else
        print(event)
    end

end

function AManager:EvalExplored(data)

    self.map = TheSim:FindFirstEntityWithTag("minimap")

    local trod = GetMap() and GetMap():GetNumVisitedTiles()
    local tiles = GetMap() and GetMap():GetNumWalkableTiles()

    print(trod.." out of "..tiles.." tiles explored")
    if data then
        for key,value in pairs(GLOBAL.MiniMap) do 
            if string.find(key, "Get..") then
                print(key,value) 
            end
        end 
    else
        print(event)
    end

end

function AManager:EvalSurvived(event, data)
    if not self.survived[event] then
        self.survived[event] = 0
    end

    if event == "seasonChange" then
        if data.season == "summer" then
            if not self.survived["winter"]  then
                self.survived["winter"] = 0
            end
            --print("survived winter")
            self.survived["winter"] = self.survived["winter"] + 1
        end 
        self.survived[event] = self.survived[event] + 1
    else
        self.survived[event] = self.survived[event] + 1
    end
    self:Merit()
end


function AManager:EvalKilled(victim)

    self.victim = victim

    local combat = victim.components.combat
    local health = victim.components.health 

    if not self.killed[victim.prefab] then
        local calcDam = combat.defaultdamage*(1/combat.min_attack_period)*combat.playerdamagepercent*combat.attackrange
        local calcHealth = health.maxhealth/10
        print(calcHealth.." + "..calcDam.." = "..(calcDam+calcHealth))
        self.killed[victim.prefab] = {amount = 1, worth = (calcDam+calcHealth)}
        
    else
        self.killed[victim.prefab]["amount"] = self.killed[victim.prefab]["amount"] + 1
    end
    self:Merit()
end



function AManager:EvalTechLevel(data)
    if data ~= nil then
        local techLevelCalc = {}
        for key,value in pairs(GetPlayer().components.builder.recipes) do 

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
end

function AManager:OnSave()
	return { killed = self.killed, survived=self.survived}
end


function AManager:OnLoad(data)
	if data.killed ~= nil then
		self.killed = data.killed
	end

    if data.survived ~= nil then
        self.survived = data.survived
    end
end


return AManager
