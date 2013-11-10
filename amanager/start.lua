local GetPlayer = GLOBAL.GetPlayer
local SpawnPrefab = GLOBAL.SpawnPrefab
local GetWorld = GLOBAL.GetWorld
local require = GLOBAL.require
local table = require("table")
local aVersion = {}

--local stub = string.sub(GLOBAL.debug.getinfo(1).source, 1, -20)
--local stubfind = string.find(stub, "/mods/")
local ModNameLoc = modname --string.sub(stub,(stubfind+6))

local bestVersion = nil
local thisVersion = 2


AddPrefabPostInit("world", function(inst)
		
    GLOBAL.assert( GLOBAL.GetPlayer() == nil )
    local player_prefab = GLOBAL.SaveGameIndex:GetSlotCharacter()
 
    -- Unfortunately, we can't add new postinits by now. So we have to do
    -- it the hard way...
 
    GLOBAL.TheSim:LoadPrefabs( {player_prefab} )
    local oldfn = GLOBAL.Prefabs[player_prefab].fn
    GLOBAL.Prefabs[player_prefab].fn = function()
        local inst = oldfn()
 		-- Add components here.
 		inst:AddComponent("asave")
		
        if not GetWorld().aVersions then
        	GetWorld()["aVersions"] = {}
        end
        GetWorld().aVersions[ModNameLoc] = thisVersion
        return inst
    end
	    
    
end)

function SimInit(inst)

	
	local highestVersion = 0

	for key,value in pairs(GetWorld().aVersions) do 
		if highestVersion < value then
			highestVersion = value
		end
		print(key,value, "highestVersion", highestVersion)
	end 
	
	if GetWorld().aVersions[ModNameLoc] >= highestVersion then
		bestVersion = true
	else
		bestVersion = false
	end
	
	if bestVersion then
		--inst:RemoveComponent("amanager")
		inst:AddComponent("amanager_"..highestVersion)
		GetPlayer().components["amanager_"..highestVersion]:Populate(GLOBAL)
		--modimport("amanager/amanager.lua")
		--local amanager = require ("amanager/amanager")
    	--inst:AddComponent("amanager")
		print("The AManger submodule "..thisVersion.." in the mod "..ModNameLoc.." was instaled")
	end
	
    --inst:DoTaskInTime(3, function(inst, data) 
    --	GetPlayer().components["amanager_"..highestVersion]:PrintVersion()
    --end)

    if bestVersion then

    	local Deployable = require("components/deployable")
		--------------------------------------------------------------------------------------------------
		--------------------------------------------------------------------------------------------------
		local Deployable_Deploy_base = Deployable.Deploy
		function Deployable:Deploy(pt, deployer)
			local DidDeploy = Deployable_Deploy_base(self, pt, deployer)
			if DidDeploy then
				if self.inst and self.inst.prefab and self.inst.prefab == "pinecone" and deployer == GetPlayer() then
					GetPlayer():PushEvent("growfromseed")
				end
				if self.inst and self.inst.prefab and self.inst.prefab == "butterfly" and deployer == GetPlayer() then
					GetPlayer():PushEvent("growfrombutterfly")
				end
			end
			return DidDeploy
		end
		--------------------------------------------------------------------------------------------------
		-----------------------------------------------------------------
		-----------------------------

		local Equippable = require("components/equippable")
		--------------------------------------------------------------------------------------------------
		--------------------------------------------------------------------------------------------------
		local Equippable_Equip_base = Equippable.Equip
		function Equippable:Equip(owner, slot)
			local DidEquip = Equippable_Equip_base(self, owner, slot)
		    if self.onequipfn then
		        GetPlayer():PushEvent("equipped", {owner=owner, slot=slot, item=self.inst.prefab})
		    end
		    return DidEquip
		end
		--------------------------------------------------------------------------------------------------
		local Equippable_Unequip_base = Equippable.Unequip
		function Equippable:Unequip(owner, slot)
			local DidUnequip = Equippable_Unequip_base(self, owner, slot)
		    if self.onunequipfn then
		        GetPlayer():PushEvent("unequipped", {owner=owner, slot=slot, item=self.inst.prefab})
		    end
		    return DidUnequip
		end
		--------------------------------------------------------------------------------------------------
		-----------------------------------------------------------------
		-----------------------------

		local Trap = require("components/trap")
		--------------------------------------------------------------------------------------------------
		--------------------------------------------------------------------------------------------------
		local Trap_Harvest_base = Trap.Harvest
		function Trap:Harvest(doer)
			local harvest = "nothing"
			for key,value in pairs(self.lootprefabs) do
			 --if key == "rabbit" then
			 	harvest = value
			 --end
			end 
			doer:PushEvent("harvesttrap", {harvest=harvest})
			
			local DidHarvest = Trap_Harvest_base(self, doer)
			return DidHarvest
		end
		--------------------------------------------------------------------------------------------------
		-----------------------------------------------------------------
		----------------------------- 

		----------------------------- 
		local spreadTable = {}
		local ignites = 0
		----------------------------- 
		-----------------------------------------------------------------
		--------------------------------------------------------------------------------------------------
		local Lighter = require("components/lighter")
		--------------------------------------------------------------------------------------------------
		--------------------------------------------------------------------------------------------------
		local Lighter_Light_base = Lighter.Light
		function Lighter:Light(target)
			
			if target.components.burnable then
		        local is_empty = target.components.fueled and target.components.fueled:GetPercent() <= 0
		        if not is_empty then
					if self.inst.prefab == "torch" then
						ignites = ignites + 1
						table.insert(spreadTable, target.entity) 
						GetPlayer():PushEvent("onignite", {item=self.inst.prefab, sorce="primary", target=target.prefab, ignites=ignites})
					end
				end
		    end
			local DidLight = Lighter_Light_base(self,target)
			return DidLight
		end
		--------------------------------------------------------------------------------------------------
		-----------------------------------------------------------------
		-----------------------------
		local Propagator = require("components/propagator")
		--------------------------------------------------------------------------------------------------
		--------------------------------------------------------------------------------------------------
		local Propagator_OnUpdate_base = Propagator.OnUpdate
		function Propagator:OnUpdate(dt)
			
			if self.spreading then
		       
		        local pos = GLOBAL.Vector3(self.inst.Transform:GetWorldPosition())
		        local ents = TheSim:FindEntities(pos.x, pos.y, pos.z, self.propagaterange)
		        
		        for k,v in pairs(ents) do
		            if not v:IsInLimbo() then

					    if v ~= self.inst and v.components.propagator and v.components.propagator.acceptsheat then
		                    local check = false
		                    local notHere = true
		                    for key,value in pairs(spreadTable) do

		                    	--print(value, self.inst.GUID, v.GUID)
		                    	
		                    	if value == self.inst.entity then
		                    		
		                    		check = true
		                    	end
		                    	if value == v.entity then
		                    		notHere = false
		                    	end
		                	end
		                	if check and notHere then
		                		ignites = ignites + 1
		                		table.insert(spreadTable, v.entity)
		                    	GetPlayer():PushEvent("playerignite", {item=self.inst.prefab, sorce="secondary", target=v.prefab, ignites=ignites})
		                    end
					    end
					end
		        end
		    end
		    local DidOnUpdate = Propagator_OnUpdate_base(self, dt)
			return DidOnUpdate
		end
		--------------------------------------------------------------------------------------------------
		-----------------------------------------------------------------
		-----------------------------
		local Leader = require("components/leader")
		local followers = {}
		--------------------------------------------------------------------------------------------------
		--------------------------------------------------------------------------------------------------
		local Leader_AddFollower_base = Leader.AddFollower
		function Leader:AddFollower(follower)
			local DidAddFollower = Leader_AddFollower_base(self, follower)
			
			if self.inst == GetPlayer() and follower.prefab and not suppress then

				local there = false
				local number = 0
		        for key,value in pairs(followers) do
		        	number = number + 1
		        	if value == follower then
		        		there = true
		        	end

		    	end
		    	if not there then
		    		table.insert(followers, follower)
		        	GetPlayer():PushEvent("uniquefollower", {follower=follower, number = (number + 1)})
		  
				end
			end

			return DidAddFollower
		end
		--------------------------------------------------------------------------------------------------
		-----------------------------------------------------------------
		----------------------------- 
		local FiniteUses = require("components/finiteuses")
		--------------------------------------------------------------------------------------------------
		--------------------------------------------------------------------------------------------------
		local FiniteUses_SetUses_base = FiniteUses.SetUses
		function FiniteUses:SetUses(val)
			
			local is_done = val <= 0
		    if is_done then
		        GetPlayer():PushEvent("broken", {item = self.inst.prefab})
		    end
			
			local DidSetUses = FiniteUses_SetUses_base(self, val)
			return DidSetUses
		end
		--------------------------------------------------------------------------------------------------
		-----------------------------------------------------------------
		----------------------------- 
		local Hounded = require("components/hounded")
		--------------------------------------------------------------------------------------------------
		--------------------------------------------------------------------------------------------------
		local Hounded_ReleaseHound_base = Hounded.ReleaseHound
		function Hounded:ReleaseHound(dt)
			local DidReleaseHound = Hounded_ReleaseHound_base(self, dt)
			GetPlayer():PushEvent("playerhounded")
			return DidReleaseHound
		end
		--------------------------------------------------------------------------------------------------
		-----------------------------------------------------------------
		----------------------------- 
    end
  	
end

AddSimPostInit(SimInit)

