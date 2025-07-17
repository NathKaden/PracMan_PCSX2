require 'Item'

Game = class("Game")

function Game:initialize()
    self.address = {
        bolts = 0x201A79F8,
        position = {
            x = 0x20189EA0,--
            y = 0x20189EA4,--
            z = 0x20189EA8--
        },
        rotation = {
            x = 0x147F270,
            y = 0x147F274,
            z = 0x147F278
        },
        respawn = {
            x = 0x15D26E0,
            y = 0x15D26E4,
            z = 0x15D26E8
        },
        state = 0x2018C0B4,
        input = 0x147A430,
        analog = 0x147A60C,
        shouldLoadPlanet = 0x1A8ED4,--
        planetTarget = 0x1A8ED4,
        currentPlanet = 0x1A79F0,--?
        ghostTimer = 0x147F3CE,
        raritanium = 0x201A79FC,--
        challengeMode = 0x1329AA2,
        mobyInstances = 0x15927B0,
        mobyInstancesEnd = 0x15927B8,
        snivBoss = 0x1A6FB73,
        sibBoss = 0x1A5A99F,
        yeedilBoss = 0x1A9DF90,
        padManip = 0x13185B8,
        prevHeldWeapon = 0x1329A9F,
        ammoArray = 0x148185C,
        expEconomy = 0x1329AA8,
        playerHealth = 0x2018C36C,--
        healthExp = 0x2018C2EC,--
        imInShortcuts = 0x135268C,
        shortcutsIndex = 0x1352684,
        savedRaceIndex = 0x1A4D7E0,
        gornManip = 0x1A99A4C,
        feltzinOpening = 0x1A8495B,
        gornOpening = 0x1A99A34,
        feltzinMissionComplete = 0x1A84973,
        hrugisMissionComplete = 0x143DB0F,
        gornMissionComplete = 0x1A99A5B,
        loadingScreenType = 0x147A257,
        loadingScreenCount = 0x147A25B,
        selectedSaveSlot = 0x13298CC,
        debugFeatures = 0x15B3070,
        platinumBoltArray = 0x1562540,
        levelFlags = 0x15625B0,
        currentChunk = 0x157CE03
    }
    
    self.planets = {
        {0, "Aranos"},
        {1, "Oozla"},
        {2, "Maktar"},
        {3, "Endako"},
        {4, "Barlow"},
        {5, "Feltzin"},
        {6, "Notak"},
        {7, "Siberius"},
        {8, "Tabora"},
        {9, "Dobbo"},
        {10, "Hrugis"},
        {11, "Joba"},
        {12, "Todano"},
        {13, "Boldan"},
        {14, "Aranos 2"},
        {15, "Gorn"},
        {16, "Snivelak"},
        {17, "Smolg"},
        {18, "Damosel"},
        {19, "Grelbin"},
        {20, "Yeedil"},
        {21, "Insomniac Museum"},
        {22, "Dobbo Orbit"},
        {23, "Damosel Orbit"},
        {24, "Slim-Cognito"},
        {25, "Wupash"},
        {26, "Jamming Array"}
    }
    
    self.weapons = {
        Item("Lancer", 0x201A7B16),--
        Item("Gravity-Bomb", 0x201A7B22),--
        Item("Chopper", 0x201A7B0E),--
        Item("Seeker-Gun", 0x201A7B10),--
        Item("Pulse-Rifle", 0x201A7B0F),--
        Item("Miniturret-Glove", 0x201A7B21),--
        Item("Blitz-Gun", 0x201A7B12),--
        Item("Shield-Charger", 0x201A7B25),--
        Item("Synthenoid", 0x201A7B17),--
        Item("Lava-Gun", 0x201A7B15),--
        Item("Bouncer", 0x201A7B1D),--
        Item("Minirocket-Tube", 0x201A7B13),--
        Item("Plasma-Coil", 0x201A7B14),--
        Item("Hoverbomb-Gun", 0x201A7B11),--
        Item("Spiderbot-Glove", 0x201A7B18),--
        Item("Sheepinator", 0x201A7B08),--
        Item("Tesla-Claw", 0x201A7B0A),--
        Item("Bomb-Glove", 0x201A7B04),--
        Item("Wolloper", 0x201A7B2D),--
        Item("Visi-bomb-Gun", 0x201A7B06),--
        Item("Decoy Glove", 0x201A7B09),--
        Item("Zodiac", 0x201A7B23),--
        Item("RYNO-II", 0x201A7B24),--
        Item("Clank-Zapper", 0x201A7B01)--
    }
    
    self.gadgets = {
        Item("Swingshot", 0x1481A8d),
        Item("Dynamo", 0x1481AA4),
        Item("Therminator", 0x1481AA7),
        Item("Tractor-Beam", 0x1481AAE),
        Item("Hypnomatic", 0x1481AB7),
        Item("Heli-Pack", 0x1481A82),
        Item("Thruster-Pack", 0x1481A83),
        Item("Gravity Boots", 0x1481A93),
        Item("Grindboots", 0x1481A94),
        Item("Charge Boots", 0x1481AB6)
    }
    
    self.items = {
        Item("Biker-Helmet", 0x1481AB0),
        Item("Glider", 0x1481A95),
        Item("Quark-Statuette(Magnetizer_pt1)", 0x1481AB1),
        Item("Armor-Magnetizer", 0x1481A87),
        Item("Box-Breaker", 0x1481AB2),
        Item("Mapper", 0x1481A85),
        Item("Electrolyzer", 0x1481AA6),
        Item("Infiltrator", 0x1481AB3),
        Item("HydroPack", 0x1481A84),
        Item("Levitator", 0x1481A88)
    }
end

function Game:GetCurrentPlanet()
    return Target:ReadInt(self.address.currentPlanet)
end

function Game:SavePosition(savedPositionIndex)
    local position = {
        x = Target:ReadFloat(self.address.position.x),
        y = Target:ReadFloat(self.address.position.y),
        z = Target:ReadFloat(self.address.position.z)
    }
    
    local rotation = {
        x = Target:ReadFloat(self.address.rotation.x),
        y = Target:ReadFloat(self.address.rotation.y),
        z = Target:ReadFloat(self.address.rotation.z)
    }

    Settings:SetFloat("SavedPositions." .. self:GetCurrentPlanet() .. "." .. savedPositionIndex .. ".x", position.x)
    Settings:SetFloat("SavedPositions." .. self:GetCurrentPlanet() .. "." .. savedPositionIndex .. ".y", position.y)
    Settings:SetFloat("SavedPositions." .. self:GetCurrentPlanet() .. "." .. savedPositionIndex .. ".z", position.z)
    
    Settings:SetFloat("SavedRotations." .. self:GetCurrentPlanet() .. "." .. savedPositionIndex .. ".x", rotation.x)
    Settings:SetFloat("SavedRotations." .. self:GetCurrentPlanet() .. "." .. savedPositionIndex .. ".y", rotation.y)
    Settings:SetFloat("SavedRotations." .. self:GetCurrentPlanet() .. "." .. savedPositionIndex .. ".z", rotation.z)
end

function Game:LoadPosition(savedPositionIndex)
    local position = {
        x = Settings:GetFloat("SavedPositions." .. self:GetCurrentPlanet() .. "." .. savedPositionIndex .. ".x", 0),
        y = Settings:GetFloat("SavedPositions." .. self:GetCurrentPlanet() .. "." .. savedPositionIndex .. ".y", 0),
        z = Settings:GetFloat("SavedPositions." .. self:GetCurrentPlanet() .. "." .. savedPositionIndex .. ".z", 0)
    }
    
    local rotation = {
        x = Settings:GetFloat("SavedRotations." .. self:GetCurrentPlanet() .. "." .. savedPositionIndex .. ".x", 0),
        y = Settings:GetFloat("SavedRotations." .. self:GetCurrentPlanet() .. "." .. savedPositionIndex .. ".y", 0),
        z = Settings:GetFloat("SavedRotations." .. self:GetCurrentPlanet() .. "." .. savedPositionIndex .. ".z", 0)
    }

    Target:WriteFloat(self.address.position.x, position.x)
    Target:WriteFloat(self.address.position.y, position.y)
    Target:WriteFloat(self.address.position.z, position.z)
    
    Target:WriteFloat(self.address.rotation.x, rotation.x)
    Target:WriteFloat(self.address.rotation.y, rotation.y)
    Target:WriteFloat(self.address.rotation.z, rotation.z)
end

function Game:Die()
    Log("die");
    --die
    Target:WriteMemory(self.address.position.z, 0xC2480000)
end

function Game:LoadPlanet(index, resetFlags)
    if resetFlags then
        self:ResetLevelFlags()
    end
    
    Target:WriteMemory(self.address.planetTarget, index)
    Target:WriteMemory(self.address.shouldLoadPlanet, 1)
end

function Game:ToggleFastLoads(toggle)
    local fastLoadInstructionAddress = 0xBEA8A0

    if (toggle) then
        Target:WriteMemory(fastLoadInstructionAddress, 0x60000000)  -- Write NOP
    else
        Target:WriteMemory(fastLoadInstructionAddress, 0x4BFFEA69)  -- Restore original instruction
    end
end 

function Game:ResetLevelFlags()
    local flagsForPlanet = self.address.levelFlags + (self:GetCurrentPlanet() * 0x10)
    
    Target:Memset(flagsForPlanet, 16, 0)
end

function Game:StoreSwingshot()
    Target:WriteByte(self.address.prevHeldWeapon, 0xD)
end

function Game:SetChallengeMode(value)
    Target:WriteByte(self.address.challengeMode, value)
end

function Game:SetBoltCount(value)
    Log("bolt")
    Log(value)
    Target:WriteInt(self.address.bolts, value)
end 

function Game:SetRaritanium(value)
    Target:WriteInt(self.address.raritanium, value)
end

function Game:SetHealthXP(value)
    Target:WriteUInt(self.address.healthExp, value)
end

function Game:UnlockAllPlatinumBolts()
    Target:Memset(self.address.platinumBoltArray, 0x70, 0xFF)
end

function Game:ResetAllPlatinumBolts()
    Target:Memset(self.address.platinumBoltArray, 0x70, 0)
end

function Game:ToggleInfiniteAmmo(toggle)
    local ammoResetAddr = 0x0B30C7C

    if toggle then
        Target:WriteMemory(self.address.ammoArray, 136, "7FFFFFFF7FFFFFFF7FFFFFFF7FFFFFFF7FFFFFFF7FFFFFFF7FFFFFFF7FFFFFFF7FFFFFFF7FFFFFFF7FFFFFFF7FFFFFFF7FFFFFFF7FFFFFFF7FFFFFFF7FFFFFFF7FFFFFFF7FFFFFFF7FFFFFFF7FFFFFFF7FFFFFFF7FFFFFFF7FFFFFFF7FFFFFFF7FFFFFFF7FFFFFFF7FFFFFFF7FFFFFFF7FFFFFFF7FFFFFFF7FFFFFFF7FFFFFFF7FFFFFFF7FFFFFFF")
        Target:WriteMemory(ammoResetAddr, 0x60000000)  -- Write NOP
    else
        Target:WriteMemory(ammoResetAddr, 0x7C64292E)  -- Restore original instruction
    end
end 

function Game:SetupGeneralNGPlus()
    Target:WriteByte(self.address.snivBoss, 20)
    -- We should setup pad manip, since this happens whenever Snivelak is visited.
    Target:WriteFloat(self.address.padManip, 25)
    Target:WriteByte(self.address.yeedilBoss, 66)
    Target:WriteByte(self.address.sibBoss, 20)
    Target:WriteUInt(self.address.gornManip, 1)
    Target:WriteUInt(self.address.gornOpening, 1)
    Target:WriteUInt(self.address.imInShortcuts, 1)
    
    Target:Notify("Manips done!")
end 

function Game:SetupNGPlus()
    Target:WriteUInt(self.address.shortcutsIndex, 7)  -- Museum
    self:SetupGeneralNGPlus()
end

function Game:SetupNGNoIMG()
    Target:WriteUInt(self.address.shortcutsIndex, 1)  -- Barlow
    self:SetupGeneralNGPlus()
end

function Game:SetupAllMissions()
    Target:WriteUInt(self.address.shortcutsIndex, 7)  -- Museum
    Target:WriteUInt(0x1A5815B, 1)  -- Endako cutscene
    self:SetupGeneralNGPlus()
end

function Game:SetupAnyPercent()
    Target:WriteUInt(self.address.expEconomy, 0)  -- Bolt economy
    Target:WriteUInt(0x1A5815B, 0)  -- Endako cutscene
    Target:WriteUInt(0x1AAC767, 0)  -- Game pyramid bolt drop
    Target:WriteUInt(0x1A4D7E0, 0)  -- Race storage

    Target:Notify("Game Pyramid, Bolts manip,  Race Storage and Endako Boss Cutscene are now reset and ready for runs")
end

function Game:ResetMenuStorage()
    -- Disable race storage
    Target:WriteUInt(self.address.savedRaceIndex, 0)
    -- Disable ship opening cutscenes
    Target:WriteUInt(self.address.feltzinOpening, 1)
    Target:WriteUInt(self.address.gornOpening, 1)
    -- Fix ship mission menus
    Target:WriteUInt(self.address.feltzinMissionComplete, 0)
    Target:WriteUInt(self.address.hrugisMissionComplete, 0)
    Target:WriteUInt(self.address.gornMissionComplete, 0)
end 

function Game:SetAsideFile()
    Target:WriteByte(0x10CD71F, 1)
end 

function Game:LoadAsideFile()
    Target:WriteByte(0x10CD71E, 1)
end 

function Game:SetSaveWriteOffset(offset)
    Target:WriteInt(self.address.selectedSaveSlot, offset)
end 

function Game:ToggleDebugFeatures(toggle)
    Target:WriteByte(self.address.debugFeatures, toggle and 1 or 0)
end