itemPoolOfPickedUpActive={}
--item pools--
local itemPoolOfNull={}
local itemPoolOfAngel={
    7,33,72,78,98,101,108,112,124,138,142,146,156,162,173,178,
    182,184,185,197,243,313,326,331,332,333,334,335,363,374,387,
    390,400,407,413,415,423,464,477,490,498,499,510,519,526,528,
    533,543,567,568,573,574,579,584,586,601,622,634,640,643,651,
    653,685,686,691,696
}
local itemPoolOfDevil={
    8,34,35,51,67,74,79,80,81,82,83,84,97,109,113,114,115,118,122,
    123,127,133,134,145,157,159,163,172,186,187,212,215,216,225,230,
    237,241,259,262,268,269,275,278,292,311,360,391,399,408,409,411,
    412,417,420,431,433,441,442,462,468,475,477,498,503,506,519,526,
    530,536,545,554,556,569,572,577,606,634,646,654,665,672,679,684,
    692,694,695,698,699,702,704,705,706,712,728
}
local itemPoolOfSecret={
    11,16,17,20,35,84,120,121,127,168,190,213,226,242,258,262,263,271,
    286,287,316,321,348,388,389,402,405,424,450,489,500,501,546,562,571,
    580,582,609,612,625,628,632,636,664,667,669,674,675,677,688,689,691,
    697,700,701,703,711,716,717,719,721,723
}
local itemPoolOfUltraSecret={
    12,13,15,30,31,40,45,49,51,53,67,72,73,79,80,82,96,105,109,110,118,
    119,122,135,137,157,159,166,167,176,177,182,193,208,214,230,247,253,
    254,261,276,289,334,373,394,399,411,412,421,435,443,452,462,466,475,
    481,506,511,531,541,554,556,565,572,573,580,606,607,614,616,618,621,
    637,650,654,657,671,678,682,684,692,694,695,700,702,703,704,705,706,
    711,724,726,728

}
local itemPoolOfPlanetarium={
    588,589,590,591,592,593,594,595,596,597,598
}
local itemTagOfFood={
    collectibles={22,23,24,25,26,346,456,707}
}
local itemTagOfDice={
    collectibles={476,284,105,437,406,285,386,166,283,489},
    Trinkets={67,154},
    pickUps={49}
}
local itemTagOfIllness={
    collectibles={103,214,261,347,350,368,379,440,446,452,453,454,459,460,
    466,469,502,510,525,531,549,553,645,657,558,680,683,724,725,726,731}
}
local slotPoolOfBeggar={
    4,5,6,7,9,13,15,18
}
local entityPoolOfSins={
    {type=EntityType.ENTITY_SLOTH},
    {type=EntityType.ENTITY_LUST},
    {type=EntityType.ENTITY_WRATH},
    {type=EntityType.ENTITY_GLUTTONY},
    {type=EntityType.ENTITY_GREED},
    {type=EntityType.ENTITY_ENVY},
    {type=EntityType.ENTITY_PRIDE}
}
--use the void or the blackrune--
local isUseVoidOrBlackRune={
    isUseVoid=false,
    isUseBlackRune=false
}
-- 存储角色和任务相矛盾的键值对表
local conflictCharacter={
    c0={50}, -- 表以撒
    c10={29,50}, -- 表罗
    c4={42},  --表蓝人
    c7={29},  --表az
    c17={29},  --表骨哥魂
    c31={29},  --里罗
    c35={29},  --里骨哥
---------表伊甸----------
    c9={3,10,11,12,13,17,19,20,29,30,38,39,42,43,44,50}
}
-- 趣味模式奖励表
local specialModeReward={
    type={5},
    variantWithSubType={{10,12},{20,7},{30,4},{40,7},{50,0},{51,0},{52,0},{53,0},{54,0},{55,0},{56,0},
                        {57,0},{58,0},{60,0},{69,2},{70,14},{90,4},{100,732}}
}
local function getHashMapLength(map)
    local length=0
    for key, value in pairs(map) do
        length=length+1
    end
    return length
end

-- 通用单继承函数
-- 参数说明：
--   parentClass: 父类（如 tasks、pickUpCollectible）
--   childOptions: 子类配置表（可选），支持：
--     - constructor: 子类自定义构造函数（若需灵活处理参数）
--     - methods: 子类特有方法（如 isItemInCurrentRoomItemPool）
-- 返回：
--   childClass: 生成的子类
local function createSingleClass(parentClass, childOptions)
    -- 1. 初始化子类表
    local childClass = {}
    -- 2. 建立子类与父类的元表继承（子类找不到方法时查父类）
    setmetatable(childClass, { __index = parentClass })
    -- 3. 子类实例的方法查找入口（实例 → 子类 → 父类）
    childClass.__index = childClass

    -- 4. 处理子类构造函数（优先用自定义构造，否则用默认模板）
    local childConstructor = (childOptions and childOptions.constructor) or function(self, ...)
        -- 默认构造逻辑：调用父类构造 + 空扩展（子类可在外部补充）
        local obj = parentClass:new(...)  -- 调用父类构造初始化基础属性
        setmetatable(obj, self)           -- 绑定实例元表到子类
        return obj
    end
    -- 将构造函数赋值给子类（统一用 :new 语法）
    function childClass:new(...)
        return childConstructor(self, ...)
    end

    -- 5. 合并子类特有方法（如 pickUpCollectible 的 isItemInCurrentRoomItemPool）
    if childOptions and childOptions.methods then
        for methodName, methodFunc in pairs(childOptions.methods) do
            childClass[methodName] = methodFunc
        end
    end

    return childClass
end
--tasks--
--基类 tasks
local tasks={}
tasks.achieveSound=SFXManager()
function tasks:new(map,index)
    local obj={
        taskIcon=Sprite(),
        taskIndex=index,
        isAchieved=false,
        renderXOffset=0,
        renderYOffset=0,
        signal1=0,
        conflictTasks=nil,
        isOnMap=map,
    }
    setmetatable(obj,self)
    self.__index=self
    return obj
end
--基类方法
function tasks:setTaskForCallback(taskFunction)
    if self.isOnMap and not self.isAchieved then
        Bingo:AddCallback(ModCallbacks.MC_POST_UPDATE,taskFunction)
    elseif (not self.isOnMap) or self.isAchieved then
        Bingo:RemoveCallback(ModCallbacks.MC_POST_UPDATE,taskFunction)
    end
end

-- 专门处理以动画为判据的任务
function tasks:setSpriteTaskForCallback(taskFunction)
    if self.isOnMap and not self.isAchieved then
        Bingo:AddCallback(ModCallbacks.MC_POST_RENDER,taskFunction)
    elseif (not self.isOnMap) or self.isAchieved then
        Bingo:RemoveCallback(ModCallbacks.MC_POST_RENDER,taskFunction)
    end
end

function tasks:checkTaskIfAchived()
    if self.achieveCount~=nil and self.TARGET_NUM~=nil and self.achieveCount>=self.TARGET_NUM then
        self.isAchieved=true
    end
end

function tasks:updateBingoMapConfigAndRemoveCallBack()
    if self.isAchieved and self.signal1==0 and self.isOnMap then
        self.achieveSound:Play(579,20)
        self.achieveSound:Play(128,1)
        Bingo:getMapConfig(self.renderXOffset,self.renderYOffset)
        Bingo.finishTasksNum=Bingo.finishTasksNum+1
        self.signal1=1
        if Bingo.enableSpecialMode then
            local randomNum=math.random(18)
            Bingo.game:Spawn(specialModeReward.type[1],specialModeReward.variantWithSubType[randomNum][1],Vector(100,100),Vector(0,0),Bingo.player,specialModeReward.variantWithSubType[randomNum][2],math.random(1145141919))
        end
    end
end

------------------------------------------

--子类1 pickUpCollectible

-- 构造函数参数说明：
--   map: 该任务是否在图上
--   index: 该任务的索引（如任务1索引则为1）
--   targetNum: 目标道具的数量
--   item: 用于记录拾取的拿一个道具的类型（主动or被动）
--   pool: 目标道具的道具池
--   room: 当前房间的类型
--   targetItem: 目标道具，当不需要此选项时赋值为-1
--   targetQuality: 目标道具品质，当不需要此选项时赋值为-1
local pickUpCollectibleOption={
    constructor=function (self,map,index,targetNum,item,pool,room,targetItem,targetQuality)
        local obj=tasks:new(map,index)
        obj.achieveCount=0
        obj.TARGET_NUM=targetNum
        obj.item=item
        obj.itemPool=pool
        obj.roomType=room
        obj.targetItem=targetItem
        obj.targetQuality=targetQuality
        obj.signal=0
        setmetatable(obj,self)
        return obj
    end,
    methods={
        isItemInCurrentRoomItemPool=function (self)
            local itemPickedUp
            local class=self.class
            if (not Bingo.player:IsItemQueueEmpty()) and 
                (Bingo.player.QueuedItem.Item.Type~=ItemType.ITEM_TRINKET) and
                ((class.isItemInPool(Bingo.player.QueuedItem.Item.ID,self.itemPool) and 
                (function ()
                    for _, value in ipairs(self.roomType) do
                        if Bingo.level:GetCurrentRoomDesc().Data.Type==value then
                            return true
                        end
                    end
                    return false
                end)() and self.itemPool~=itemPoolOfNull) or 
                (self.itemPool==itemPoolOfNull and self.targetQuality==-1 and Bingo.player.QueuedItem.Item.ID==self.targetItem) or 
                (self.itemPool==itemPoolOfNull and self.targetItem==-1 and Bingo.player.QueuedItem.Item.Quality==self.targetQuality)) then
                self.signal=1
                self.item=Bingo.player.QueuedItem.Item.Type
                isUseVoidOrBlackRune.isUseVoid=false
                isUseVoidOrBlackRune.isUseBlackRune=false
                itemPickedUp=Bingo.player.QueuedItem.Item.ID
            end
            if Bingo.player:IsItemQueueEmpty() and self.signal==1 and self.isAchieved==false and self.achieveCount<self.TARGET_NUM then
                if isUseVoidOrBlackRune.isUseBlackRune or (isUseVoidOrBlackRune.isUseVoid and self.item==ItemType.ITEM_PASSIVE) then
                    isUseVoidOrBlackRune.isUseBlackRune=false
                    isUseVoidOrBlackRune.isUseVoid=false
                    self.item=ItemType.ITEM_NULL
                    self.signal=0
                elseif isUseVoidOrBlackRune.isUseVoid and self.item==ItemType.ITEM_ACTIVE and not(class.isItemInPool(itemPickedUp,itemPoolOfPickedUpActive)) then
                    isUseVoidOrBlackRune.isUseVoid=false
                    self.achieveCount=self.achieveCount+1
                    self.signal=0
                    self.item=ItemType.ITEM_NULL
                    itemPoolOfPickedUpActive[#itemPoolOfPickedUpActive+1] = itemPickedUp
                end
            end
            if Bingo.player:IsItemQueueEmpty() and self.signal==1 and not (isUseVoidOrBlackRune.isUseBlackRune or isUseVoidOrBlackRune.isUseVoid) then
                if self.item==ItemType.ITEM_ACTIVE and not class.isItemInPool(itemPickedUp,itemPoolOfPickedUpActive) then
                        itemPoolOfPickedUpActive[#itemPoolOfPickedUpActive+1] = itemPickedUp
                end
                if self.item==ItemType.ITEM_PASSIVE or not class.isItemInPool(itemPickedUp,itemPoolOfPickedUpActive) then
                        self.achieveCount=self.achieveCount+1
                        self.signal=0
                        self.item=ItemType.ITEM_NULL
                end
            end
            tasks.checkTaskIfAchived(self)
        end
    }
}
local pickUpCollectible=createSingleClass(tasks,pickUpCollectibleOption)
function pickUpCollectible:new(...)
    local obj=pickUpCollectibleOption.constructor(self,...)
    obj.class=pickUpCollectible
    return obj
end
function pickUpCollectible.isItemInPool(numOfItem,itemPool)
    for index, value in ipairs(itemPool) do
        if value==numOfItem then
            return true
        end
    end
    return false
end

local a=function ()
    
end
-- pickUpCollectible 的子类，都为具体的任务

-- 任务1：在天使房拿1个天使房底座道具
local task1Options={
    constructor=function (self)
        local obj=pickUpCollectible:new(true,
        1,
        1,
        ItemType.ITEM_NULL,
        itemPoolOfAngel,
        {RoomType.ROOM_ANGEL},
        -1,
        -1
    )
        obj.description="在天使房拿1个天使房底座道具"
        setmetatable(obj,self)
        obj.callBackfunction=function ()
            Bingo:taskForPickUpCollectibles(obj)
        end
        obj:setTaskForCallback(obj.callBackfunction)
        return obj
    end
}
local task1=createSingleClass(pickUpCollectible,task1Options)

-- 任务2：在恶魔房拿3个恶魔房底座道具
local task2Options={
    constructor=function (self)
        local obj=pickUpCollectible:new(true,
        2,
        3,
        ItemType.ITEM_NULL,
        itemPoolOfDevil,
        {RoomType.ROOM_DEVIL},
        -1,
        -1
    )
        obj.description="在恶魔房拿3个恶魔房底座道具"
        setmetatable(obj,self)
        obj.callBackfunction=function ()
            Bingo:taskForPickUpCollectibles(obj)
        end
        obj:setTaskForCallback(obj.callBackfunction)
        return obj
    end
}
local task2=createSingleClass(pickUpCollectible,task2Options)

-- 任务6：在隐藏房拿1个隐藏房底座道具
local task6Options={
    constructor=function (self)
        local obj=pickUpCollectible:new(true,
        6,
        1,
        ItemType.ITEM_NULL,
        itemPoolOfSecret,
        {RoomType.ROOM_SECRET,RoomType.ROOM_SUPERSECRET},
        -1,
        -1
    )
        obj.description="在隐藏房拿1个隐藏房底座道具"
        setmetatable(obj,self)
        obj.callBackfunction=function ()
            Bingo:taskForPickUpCollectibles(obj)
        end
        obj:setTaskForCallback(obj.callBackfunction)
        return obj
    end
}
local task6=createSingleClass(pickUpCollectible,task6Options)

-- 任务7：在红隐藏房拿1个红隐藏底座道具
local task7Options={
    constructor=function (self)
        local obj=pickUpCollectible:new(true,
        7,
        1,
        ItemType.ITEM_NULL,
        itemPoolOfUltraSecret,
        {RoomType.ROOM_ULTRASECRET},
        -1,
        -1
    )
        obj.description="在红隐藏房拿1个红隐藏底座道具"
        setmetatable(obj,self)
        obj.callBackfunction=function ()
            Bingo:taskForPickUpCollectibles(obj)
        end
        obj:setTaskForCallback(obj.callBackfunction)
        return obj
    end
}
local task7=createSingleClass(pickUpCollectible,task7Options)

-- 任务15：在星象房拿1个星象房底座道具
local task15Options={
    constructor=function (self)
        local obj=pickUpCollectible:new(true,
        15,
        1,
        ItemType.ITEM_NULL,
        itemPoolOfPlanetarium,
        {RoomType.ROOM_PLANETARIUM},
        -1,
        -1
    )
        obj.description="在星象房拿1个星象房底座道具"
        setmetatable(obj,self)
        obj.callBackfunction=function ()
            Bingo:taskForPickUpCollectibles(obj)
        end
        obj:setTaskForCallback(obj.callBackfunction)
        return obj
    end
}
local task15=createSingleClass(pickUpCollectible,task15Options)

-- 任务8： 拿到1个0级底座道具
local task8Options={
    constructor=function (self)
        local obj=pickUpCollectible:new(true,
        8,
        1,
        ItemType.ITEM_NULL,
        itemPoolOfNull,
        {RoomType.ROOM_NULL},
        -1,
        0
    )
        obj.description="拿到1个0级底座道具"
        setmetatable(obj,self)
        obj.callBackfunction=function ()
            Bingo:taskForPickUpCollectibles(obj)
        end
        obj:setTaskForCallback(obj.callBackfunction)
        return obj
    end
}
local task8=createSingleClass(pickUpCollectible,task8Options)

-- 任务9：拿到1个4级底座道具
local task9Options={
    constructor=function (self)
        local obj=pickUpCollectible:new(true,
        9,
        1,
        ItemType.ITEM_NULL,
        itemPoolOfNull,
        {RoomType.ROOM_NULL},
        -1,
        4
    )
        obj.description="拿到1个4级底座道具"
        setmetatable(obj,self)
        obj.callBackfunction=function ()
            Bingo:taskForPickUpCollectibles(obj)
        end
        obj:setTaskForCallback(obj.callBackfunction)
        return obj
    end
}
local task9=createSingleClass(pickUpCollectible,task9Options)

---------------------------------------------

-- 子类2 hasItems

-- 构造函数参数说明：
--   map: 该任务是否在图上
--   index: 该任务的索引（如任务1索引则为1）
--   itemTag: 目标道具所带的标签
--   targetNum: 目标道具的数量
local hasItemsOption={
    constructor=function (self,map,index,itemTag,targetNum)
        local obj=tasks:new(map,index)
        obj.itemTag=itemTag
        obj.TARGET_NUM=targetNum
        obj.achieveCount=0
        obj.conflictCharacters={}
        setmetatable(obj,self)
        return obj
    end,
    methods={
        hasItemsWithTag=function (self)
            local ItemCount=0
            if self.itemTag.collectibles~=nil then
                for _, value in ipairs(self.itemTag.collectibles) do
                    if Bingo.player:HasCollectible(value,true) then
                        ItemCount=ItemCount+Bingo.player:GetCollectibleNum(value,true)
                    end
                end
            end
            if self.itemTag.Trinkets~=nil then
                for _, value in ipairs(self.itemTag.Trinkets) do
                    if Bingo.player:HasTrinket(value,true) then
                        ItemCount=ItemCount+1
                    end
                end
            end
            if self.itemTag.pickUps~=nil then
                for _, value in ipairs(self.itemTag.pickUps) do
                    if (function ()
                        for i = 0, 2, 1 do
                            if Bingo.player:GetCard(i)==value then
                                return true
                            end
                        end
                        return false
                    end)() then
                        ItemCount=ItemCount+1
                    end
                end
            end
            self.achieveCount=ItemCount
            tasks.checkTaskIfAchived(self)
        end,
        checkIfCharacterHasConflictItems=function (self)
            local ItemCount=0
            if self.itemTag.collectibles~=nil then
                for _, value in ipairs(self.itemTag.collectibles) do
                    if Bingo.player:HasCollectible(value,true) then
                        ItemCount=ItemCount+Bingo.player:GetCollectibleNum(value,true)
                    end
                end
            end
            if self.itemTag.Trinkets~=nil then
                for _, value in ipairs(self.itemTag.Trinkets) do
                    if Bingo.player:HasTrinket(value,true) then
                        ItemCount=ItemCount+1
                    end
                end
            end
            if self.itemTag.pickUps~=nil then
                for _, value in ipairs(self.itemTag.pickUps) do
                    if (function ()
                        for i = 0, 2, 1 do
                            if Bingo.player:GetCard(i)==value then
                                return true
                            end
                        end
                        return false
                    end)() then
                        ItemCount=ItemCount+1
                    end
                end
            end
            if self.TARGET_NUM~=nil and ItemCount>=self.TARGET_NUM then
                self.isOnMap=false
                table.insert(self.conflictCharacters,Bingo.player:GetPlayerType())
            end
        end
    }
}
local hasItems=createSingleClass(tasks,hasItemsOption)

-- hasItems 的子类，都为具体的任务

-- 任务3：拥有死亡证明
local task3Options={
    constructor=function (self)
        local obj=hasItems:new(true,
        3,
        {collectibles={628}},
        1
    )
        obj.description="拥有死亡证明"
        setmetatable(obj,self)
        obj.callBackfunction=function ()
            Bingo:taskForHasItems(obj)
        end
        obj:setTaskForCallback(obj.callBackfunction)
        return obj
    end
}
local task3=createSingleClass(hasItems,task3Options)

-- 任务17：拥有R键
local task17Options={
    constructor=function (self)
        local obj=hasItems:new(true,
        17,
        {collectibles={636}},
        1
    )
        obj.description="拥有R键"
        setmetatable(obj,self)
        obj.callBackfunction=function ()
            Bingo:taskForHasItems(obj)
        end
        obj:setTaskForCallback(obj.callBackfunction)
        return obj
    end
}
local task17=createSingleClass(hasItems,task17Options)

-- 任务4：拥有饰品A+
local task4Options={
    constructor=function (self)
        local obj=hasItems:new(true,
        4,
        {Trinkets={145}},
        1
    )
        obj.description="拥有饰品A+"
        setmetatable(obj,self)
        obj.callBackfunction=function ()
            Bingo:taskForHasItems(obj)
        end
        obj:setTaskForCallback(obj.callBackfunction)
        return obj
    end
}
local task4=createSingleClass(hasItems,task4Options)

-- 任务21：凑齐两把钥匙碎片
local task21Options={
    constructor=function (self)
        local obj=hasItems:new(true,
        21,
        {collectibles={238,239}},
        2
    )
        obj.description="凑齐两把钥匙碎片"
        setmetatable(obj,self)
        obj.callBackfunction=function ()
            Bingo:taskForHasItems(obj)
        end
        obj:setTaskForCallback(obj.callBackfunction)
        return obj
    end
}
local task21=createSingleClass(hasItems,task21Options)

-- 任务36：拥有5个带食物标签的道具
local task36Options={
    constructor=function (self)
        local obj=hasItems:new(true,
        36,
        itemTagOfFood,
        5
    )
        obj.description="拥有5个带食物标签的道具"
        setmetatable(obj,self)
        obj.callBackfunction=function ()
            Bingo:taskForHasItems(obj)
        end
        obj:setTaskForCallback(obj.callBackfunction)
        return obj
    end
}
local task36=createSingleClass(hasItems,task36Options)

-- 任务50：拥有1个骰子主题的道具、饰品、掉落物
local task50Options={
    constructor=function (self)
        local obj=hasItems:new(true,
        50,
        itemTagOfDice,
        1
    )
        obj.description="拥有1个骰子主题的道具、饰品、掉落物"
        setmetatable(obj,self)
        obj.callBackfunction=function ()
            Bingo:taskForHasItems(obj)
        end
        obj:setTaskForCallback(obj.callBackfunction)
        return obj
    end
}
local task50=createSingleClass(hasItems,task50Options)

-- 任务44：拥有饰品血虱
local task44Options={
    constructor=function (self)
        local obj=hasItems:new(true,
        44,
        {Trinkets={53}},
        1
    )
        obj.description="拥有饰品血虱"
        setmetatable(obj,self)
        obj.callBackfunction=function ()
            Bingo:taskForHasItems(obj)
        end
        obj:setTaskForCallback(obj.callBackfunction)
        return obj
    end
}
local task44=createSingleClass(hasItems,task44Options)

-- 任务43：拥有道具小石头
local task43Options={
    constructor=function (self)
        local obj=hasItems:new(true,
        43,
        {collectibles={90}},
        1
    )
        obj.description="拥有道具小石头"
        setmetatable(obj,self)
        obj.callBackfunction=function ()
            Bingo:taskForHasItems(obj)
        end
        obj:setTaskForCallback(obj.callBackfunction)
        return obj
    end
}
local task43=createSingleClass(hasItems,task43Options)

-- 任务39 拿到1张倒卡
local task39Options={
    constructor=function (self)
        local obj=hasItems:new(true,
        39,
        {pickUps={56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77}},
        1
    )
        obj.description="拥有1张倒卡"
        setmetatable(obj,self)
        obj.callBackfunction=function ()
            Bingo:taskForHasItems(obj)
        end
        obj:setTaskForCallback(obj.callBackfunction)
        return obj
    end
}
local task39=createSingleClass(hasItems,task39Options)

-- 任务59：拥有一个疾病主题的道具
local task59Options={
    constructor=function (self)
        local obj=hasItems:new(true,
        59,
        itemTagOfIllness,
        1
    )
        obj.description="拥有1个疾病主题的道具"
        setmetatable(obj,self)
        obj.callBackfunction=function ()
            Bingo:taskForHasItems(obj)
        end
        obj:setTaskForCallback(obj.callBackfunction)
        return obj
    end
}
local task59=createSingleClass(hasItems,task59Options)

-- 任务75：拥有1个符文
local task75Options={
    constructor=function (self)
        local obj=hasItems:new(true,
        75,
        {pickUps={32,33,34,35,36,37,38,39,40,41,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95,96,97}},
        1
    )
        obj.description="拥有1个符文"
        setmetatable(obj,self)
        obj.callBackfunction=function ()
            Bingo:taskForHasItems(obj)
        end
        obj:setTaskForCallback(obj.callBackfunction)
        return obj
    end
}
local task75=createSingleClass(hasItems,task75Options)

---------------------------------------------

-- 子类3 bosses

-- 构造函数参数说明：
--   map: 该任务是否在图上
--   index: 该任务的索引（如任务1索引则为1）
--   TARGET_BOSS: 目标boss
local bossesOption={
    constructor=function (self,map,index,TARGET_BOSS,targetNum)
        local obj=tasks:new(map,index)
        obj.bossPtr={}
        obj.TARGET_BOSS=TARGET_BOSS
        obj.TARGET_NUM=targetNum
        obj.currentRoom=0
        obj.achieveCount=0
        setmetatable(obj,self)
        return obj
    end,
    methods={
        hasKilledBosses=function (self)
            local room=Bingo.game:GetLevel():GetCurrentRoomDesc().ListIndex
            if self.currentRoom~=room and self.TARGET_BOSS[1].type~=EntityType.ENTITY_MOTHERS_SHADOW then
                self.bossPtr={}
                self.currentRoom=room
            end
            for _, value in ipairs(Isaac.GetRoomEntities()) do
                for _, value1 in ipairs(self.TARGET_BOSS) do
                    if value.Type==value1.type and
                    (value.Variant==value1.variant or value1.variant==nil) and
                    (value.SubType==value1.subType or value1.subType==nil) and
                    (self.bossPtr[GetPtrHash(value)]==nil) then
                        self.bossPtr[GetPtrHash(value)]=EntityPtr(value)
                    end
                end
            end
            for key, value in pairs(self.bossPtr) do
                if value~=true and ((value.Ref~=nil and value.Ref:IsDead()) or value.Ref==nil) then
                    self.achieveCount=self.achieveCount+1
                    print("114")
                    self.bossPtr[key]=true
                end
            end
            tasks.checkTaskIfAchived(self)
        end
    }
}
local bosses=createSingleClass(tasks,bossesOption)

-- bosses 的子类，都为具体的任务

-- 任务22：击败以撒
local task22Options={
    constructor=function (self)
        local obj=bosses:new(true,
        22,
        {{type=EntityType.ENTITY_ISAAC,variant=0}},
        1
    )
        obj.description="击败以撒"
        obj.conflictTasks={28,31,41}
        setmetatable(obj,self)
        obj.callBackfunction=function ()
            Bingo:taskForBosses(obj)
        end
        obj:setTaskForCallback(obj.callBackfunction)
        return obj
    end
}
local task22=createSingleClass(bosses,task22Options)

-- 任务23：击败小蓝人
local task23Options={
    constructor=function (self)
        local obj=bosses:new(true,
        23,
        {{type=EntityType.ENTITY_ISAAC,variant=1}},
        1
    )
        obj.description="击败小蓝人"
        obj.conflictTasks={28,31,41}
        setmetatable(obj,self)
        obj.callBackfunction=function ()
            Bingo:taskForBosses(obj)
        end
        obj:setTaskForCallback(obj.callBackfunction)
        return obj
    end
}
local task23=createSingleClass(bosses,task23Options)

-- 任务24：击败凹凸
local task24Options={
    constructor=function (self)
        local obj=bosses:new(true,
        24,
        {{type=EntityType.ENTITY_HUSH,variant=0}},
        1
    )
        obj.description="击败凹凸"
        obj.conflictTasks={31}
        setmetatable(obj,self)
        obj.callBackfunction=function ()
            Bingo:taskForBosses(obj)
        end
        obj:setTaskForCallback(obj.callBackfunction)
        return obj
    end
}
local task24=createSingleClass(bosses,task24Options)

-- 任务28：击败羔羊
local task28Options={
    constructor=function (self)
        local obj=bosses:new(true,
        28,
        {{type=EntityType.ENTITY_THE_LAMB,variant=0}},
        1
    )
        obj.description="击败羔羊"
        obj.conflictTasks={22,23,31}
        setmetatable(obj,self)
        obj.callBackfunction=function ()
            Bingo:taskForBosses(obj)
        end
        obj:setTaskForCallback(obj.callBackfunction)
        return obj
    end
}
local task28=createSingleClass(bosses,task28Options)

-- 任务31：击败见证者
local task31Options={
    constructor=function (self)
        local obj=bosses:new(true,
        31,
        {{type=EntityType.ENTITY_MOTHER,variant=10}},
        1
    )
        obj.description="击败见证者"
        obj.conflictTasks={22,23,24,28,41,47}
        setmetatable(obj,self)
        obj.callBackfunction=function ()
            Bingo:taskForBosses(obj)
        end
        obj:setTaskForCallback(obj.callBackfunction)
        return obj
    end
}
local task31=createSingleClass(bosses,task31Options)

-- 任务41：击败撒旦
local task41Options={
    constructor=function (self)
        local obj=bosses:new(true,
        41,
        {{type=EntityType.ENTITY_SATAN,variant=10}},
        1
    )
        obj.description="击败撒旦"
        obj.conflictTasks={22,23,31}
        setmetatable(obj,self)
        obj.callBackfunction=function ()
            Bingo:taskForBosses(obj)
        end
        obj:setTaskForCallback(obj.callBackfunction)
        return obj
    end
}
local task41=createSingleClass(bosses,task41Options)

-- 任务47：击败超级撒旦
local task47Options={
    constructor=function (self)
        local obj=bosses:new(true,
        47,
        {{type=EntityType.ENTITY_MEGA_SATAN_2,variant=0}},
        1
    )
        obj.description="击败超级撒旦"
        obj.conflictTasks={31}
        setmetatable(obj,self)
        obj.callBackfunction=function ()
            Bingo:taskForBosses(obj)
        end
        obj:setTaskForCallback(obj.callBackfunction)
        return obj
    end
}
local task47=createSingleClass(bosses,task47Options)

-- 任务32：完成一次矿层追逐战（神庙逃亡）
local task32Options={
    constructor=function (self)
        local obj=bosses:new(true,
        32,
        {{type=EntityType.ENTITY_MOTHERS_SHADOW,variant=0}},
        1
    )
        obj.description="完成一次矿层追逐战（神庙逃亡）"
        setmetatable(obj,self)
        obj.callBackfunction=function ()
            Bingo:taskForBosses(obj)
        end
        obj:setTaskForCallback(obj.callBackfunction)
        return obj
    end
}
local task32=createSingleClass(bosses,task32Options)

-- 任务52：击败祸兽
local task52Options={
    constructor=function (self)
        local obj=bosses:new(true,
        52,
        {{type=EntityType.ENTITY_BEAST,variant=0}},
        1
    )
        obj.description="击败祸兽"
        obj.conflictTasks={22,23,24,28,31,41,47,}
        setmetatable(obj,self)
        obj.callBackfunction=function ()
            Bingo:taskForBosses(obj)
        end
        obj:setTaskForCallback(obj.callBackfunction)
        return obj
    end
}
local task52=createSingleClass(bosses,task52Options)

-- 任务58：击败大小贪婪头目
local task58Options={
    constructor=function (self)
        local obj=bosses:new(true,
        58,
        {{type=EntityType.ENTITY_GREED,variant=0},{type=EntityType.ENTITY_GREED,variant=1}},
        2
    )
        obj.description="击败大小贪婪头目"
        setmetatable(obj,self)
        obj.callBackfunction=function ()
            Bingo:taskForBosses(obj)
        end
        obj:setTaskForCallback(obj.callBackfunction)
        return obj
    end
}
local task58=createSingleClass(bosses,task58Options)

-- 任务67：摧毁6次店长尸体
local task67Options={
    constructor=function (self)
        local obj=bosses:new(true,
        67,
        {{type=EntityType.ENTITY_SHOPKEEPER,variant=0},
         {type=EntityType.ENTITY_SHOPKEEPER,variant=1},
         {type=EntityType.ENTITY_SHOPKEEPER,variant=2},
         {type=EntityType.ENTITY_SHOPKEEPER,variant=3},
         {type=EntityType.ENTITY_SHOPKEEPER,variant=4}
        },
        6
    )
        obj.description="摧毁6次店长尸体"
        setmetatable(obj,self)
        obj.callBackfunction=function ()
            Bingo:taskForBosses(obj)
        end
        obj:setTaskForCallback(obj.callBackfunction)
        return obj
    end
}
local task67=createSingleClass(bosses,task67Options)

-- 任务69：击败3个七宗罪boss
local task69Options={
    constructor=function (self)
        local obj=bosses:new(true,
        69,
        entityPoolOfSins,
        3
    )
        obj.description="击败3个七宗罪boss"
        setmetatable(obj,self)
        obj.callBackfunction=function ()
            Bingo:taskForBosses(obj)
        end
        obj:setTaskForCallback(obj.callBackfunction)
        return obj
    end
}
local task69=createSingleClass(bosses,task69Options)

-- 任务71：Boss Rush和凹凸连打
local task71Options={
    constructor=function (self)
        local obj=bosses:new(true,
        71,
        {{type=EntityType.ENTITY_HUSH,variant=0}},
        2
    )
        obj.signal=0
        obj.isFinishedBossRush=function ()
            if Bingo.game:GetStateFlag(GameStateFlag.STATE_BOSSRUSH_DONE) and
            obj.signal==0 then
                obj.achieveCount=obj.achieveCount+1
                tasks.checkTaskIfAchived(obj)
                obj.signal=1
            end
        end
        obj.description="Boss Rush和凹凸连打"
        setmetatable(obj,self)
        obj.callBackfunction=function ()
            Bingo:taskForBosses(obj)
        end
        obj:setTaskForCallback(obj.callBackfunction)
        return obj
    end
}
local task71=createSingleClass(bosses,task71Options)

-- 任务76：击败腐化妈腿
local task76Options={
    constructor=function (self)
        local obj=bosses:new(true,
        76,
        {{type=EntityType.ENTITY_MOM,subType=3},
         {type=EntityType.ENTITY_MOM,variant=10,subType=3}},
        1
    )
        obj.description="击败腐化妈腿"
        setmetatable(obj,self)
        obj.callBackfunction=function ()
            Bingo:taskForBosses(obj)
        end
        obj:setTaskForCallback(obj.callBackfunction)
        return obj
    end
}
local task76=createSingleClass(bosses,task76Options)

---------------------------------------------

-- 子类4 playerForms

-- 构造函数参数说明：
--   map: 该任务是否在图上
--   index: 该任务的索引（如任务1索引则为1）
--   TARGET_PLAYERFORM: 目标套装
local playerFormsOption={
    constructor=function (self,map,index,playerForm)
        local obj=tasks:new(map,index)
        obj.TARGET_PLAYERFORM=playerForm
        setmetatable(obj,self)
        return obj
    end,
    methods={
        hasPlayerForm=function (self)
            if Bingo.player:HasPlayerForm(self.TARGET_PLAYERFORM) then
                self.isAchieved=true
            end
        end
    }
}
local playerForms=createSingleClass(tasks,playerFormsOption)

-- playerForms 的子类，都为具体的任务

-- 任务5：针套
local task5Options={
    constructor=function (self)
        local obj=playerForms:new(true,
        5,
        PlayerForm.PLAYERFORM_DRUGS
    )
        obj.description="针套"
        setmetatable(obj,self)
        obj.callBackfunction=function ()
            Bingo:taskForPlayerForms(obj)
        end
        obj:setTaskForCallback(obj.callBackfunction)
        return obj
    end
}
local task5=createSingleClass(playerForms,task5Options)

-- 任务14：猫套
local task14Options={
    constructor=function (self)
        local obj=playerForms:new(true,
        14,
        PlayerForm.PLAYERFORM_GUPPY
    )
        obj.description="猫套"
        setmetatable(obj,self)
        obj.callBackfunction=function ()
            Bingo:taskForPlayerForms(obj)
        end
        obj:setTaskForCallback(obj.callBackfunction)
        return obj
    end
}
local task14=createSingleClass(playerForms,task14Options)

-- 任务25：书套
local task25Options={
    constructor=function (self)
        local obj=playerForms:new(true,
        25,
        PlayerForm.PLAYERFORM_BOOK_WORM
    )
        obj.description="书套"
        setmetatable(obj,self)
        obj.callBackfunction=function ()
            Bingo:taskForPlayerForms(obj)
        end
        obj:setTaskForCallback(obj.callBackfunction)
        return obj
    end
}
local task25=createSingleClass(playerForms,task25Options)

-- 任务33：天使套
local task33Options={
    constructor=function (self)
        local obj=playerForms:new(true,
        33,
        PlayerForm.PLAYERFORM_ANGEL
    )
        obj.description="天使套"
        obj.conflictTasks={48}
        setmetatable(obj,self)
        obj.callBackfunction=function ()
            Bingo:taskForPlayerForms(obj)
        end
        obj:setTaskForCallback(obj.callBackfunction)
        return obj
    end
}
local task33=createSingleClass(playerForms,task33Options)

-- 任务48：恶魔套
local task48Options={
    constructor=function (self)
        local obj=playerForms:new(true,
        48,
        PlayerForm.PLAYERFORM_EVIL_ANGEL
    )
        obj.description="恶魔套"
        obj.conflictTasks={33}
        setmetatable(obj,self)
        obj.callBackfunction=function ()
            Bingo:taskForPlayerForms(obj)
        end
        obj:setTaskForCallback(obj.callBackfunction)
        return obj
    end
}
local task48=createSingleClass(playerForms,task48Options)

-- 任务63：妈套
local task63Options={
    constructor=function (self)
        local obj=playerForms:new(true,
        63,
        PlayerForm.PLAYERFORM_MOM
    )
        obj.description="妈套"
        setmetatable(obj,self)
        obj.callBackfunction=function ()
            Bingo:taskForPlayerForms(obj)
        end
        obj:setTaskForCallback(obj.callBackfunction)
        return obj
    end
}
local task63=createSingleClass(playerForms,task63Options)

---------------------------------------------

-- 子类5 attribute

-- 构造函数参数说明：
--   map: 该任务是否在图上
--   index: 该任务的索引（如任务1索引则为1）
--   targetAttribute: 目标属性
--   TARGET_NUM: 属性的目标数值
local attributeOption={
    constructor=function (self,map,index,attribute,targetNum)
        local obj=tasks:new(map,index)
        obj.targetAttribute=attribute
        obj.TARGET_NUM=targetNum
        setmetatable(obj,self)
        return obj
    end,
    methods={
        attributeComparison=function (self)
            self.achieveCount=self.targetAttribute()
            tasks.checkTaskIfAchived(self)
        end
    }
}
local attribute=createSingleClass(tasks,attributeOption)

-- attribute 的子类，都为具体的任务

-- 任务10：射速≥7
local task10Options={
    constructor=function (self)
        local obj=attribute:new(true,
        10,
        function ()
            return 30.0000/(Bingo.player.MaxFireDelay+1)
        end,
        7.00
    )
        obj.description="射速≥7"
        setmetatable(obj,self)
        obj.callBackfunction=function ()
            Bingo:taskForAttribute(obj)
        end
        obj:setTaskForCallback(obj.callBackfunction)
        return obj
    end
}
local task10=createSingleClass(attribute,task10Options)

-- 任务20：幸运≥4
local task20Options={
    constructor=function (self)
        local obj=attribute:new(true,
        20,
        function ()
            return Bingo.player.Luck
        end,
        4
    )
        obj.description="幸运≥4"
        setmetatable(obj,self)
        obj.callBackfunction=function ()
            Bingo:taskForAttribute(obj)
        end
        obj:setTaskForCallback(obj.callBackfunction)
        return obj
    end
}
local task20=createSingleClass(attribute,task20Options)

-- 任务30：攻击力≥15
local task30Options={
    constructor=function (self)
        local obj=attribute:new(true,
        30,
        function ()
            return Bingo.player.Damage
        end,
        15.00
    )
        obj.description="攻击力≥15"
        setmetatable(obj,self)
        obj.callBackfunction=function ()
            Bingo:taskForAttribute(obj)
        end
        obj:setTaskForCallback(obj.callBackfunction)
        return obj
    end
}
local task30=createSingleClass(attribute,task30Options)

-- 任务51：弹速≥1.8
local task51Options={
    constructor=function (self)
        local obj=attribute:new(true,
        51,
        function ()
            return Bingo.player.ShotSpeed
        end,
        1.8
    )
        obj.description="弹速≥1.8"
        setmetatable(obj,self)
        obj.callBackfunction=function ()
            Bingo:taskForAttribute(obj)
        end
        obj:setTaskForCallback(obj.callBackfunction)
        return obj
    end
}
local task51=createSingleClass(attribute,task51Options)

-- 任务55：移速等于2.0
local task55Options={
    constructor=function (self)
        local obj=attribute:new(true,
        55,
        function ()
            return Bingo.player.MoveSpeed
        end,
        2.00
    )
        obj.description="移速等于2.0"
        setmetatable(obj,self)
        obj.callBackfunction=function ()
            Bingo:taskForAttribute(obj)
        end
        obj:setTaskForCallback(obj.callBackfunction)
        return obj
    end
}
local task55=createSingleClass(attribute,task55Options)

---------------------------------------------

-- 子类6 pickUps

-- 构造函数参数说明：
--   map: 该任务是否在图上
--   index: 该任务的索引（如任务1索引则为1）
--   targetPickUp: 目标掉落
--   TARGET_NUM: 属性的目标数值
local pickUpsOption={
    constructor=function (self,map,index,targetPickup,targetNum)
        local obj=tasks:new(map,index)
        obj.targetPickUp=targetPickup
        obj.TARGET_NUM=targetNum
        setmetatable(obj,self)
        return obj
    end,
    methods={
        pickUpComprison=function (self)
            self.achieveCount=self.targetPickUp(Bingo.player)
            tasks.checkTaskIfAchived(self)
        end
    }
}
local pickUps=createSingleClass(tasks,pickUpsOption)

-- pickUps 的子类，都为具体的任务

-- 任务11：钥匙数量≥30
local task11Options={
    constructor=function (self)
        local obj=pickUps:new(true,
        11,
        Bingo.player.GetNumKeys,
        30
    )
        obj.description="钥匙数量≥30"
        setmetatable(obj,self)
        obj.callBackfunction=function ()
            Bingo:taskForPickUps(obj)
        end
        obj:setTaskForCallback(obj.callBackfunction)
        return obj
    end
}
local task11=createSingleClass(pickUps,task11Options)

-- 任务12：金币数量≥99
local task12Options={
    constructor=function (self)
        local obj=pickUps:new(true,
        12,
        Bingo.player.GetNumCoins,
        99
    )
        obj.description="金币数量≥99"
        setmetatable(obj,self)
        obj.callBackfunction=function ()
            Bingo:taskForPickUps(obj)
        end
        obj:setTaskForCallback(obj.callBackfunction)
        return obj
    end
}
local task12=createSingleClass(pickUps,task12Options)

-- 任务13：炸弹数量≥30
local task13Options={
    constructor=function (self)
        local obj=pickUps:new(true,
        13,
        Bingo.player.GetNumBombs,
        30
    )
        obj.description="炸弹数量≥30"
        setmetatable(obj,self)
        obj.callBackfunction=function ()
            Bingo:taskForPickUps(obj)
        end
        obj:setTaskForCallback(obj.callBackfunction)
        return obj
    end
}
local task13=createSingleClass(pickUps,task13Options)

---------------------------------------------

-- 子类7 hearts

-- 构造函数参数说明：
--   map: 该任务是否在图上
--   index: 该任务的索引（如任务1索引则为1）
--   targetHeart: 目标属性的方法
--   TARGET_NUM: 属性的目标数值
local heartsOption={
    constructor=function (self,map,index,heart,targetNum)
        local obj=tasks:new(map,index)
        obj.targetHeart=heart
        obj.TARGET_NUM=targetNum
        setmetatable(obj,self)
        return obj
    end,
    methods={
        heartComparison=function (self)
            self.achieveCount=self.targetHeart()
            tasks.checkTaskIfAchived(self)
        end
    }
}
local hearts=createSingleClass(tasks,heartsOption)

-- hearts 的子类，都为具体的任务

-- 任务16：碎心数量≥4
local task16Options={
    constructor=function (self)
        local obj=hearts:new(true,
        16,
        function ()
            return Bingo.player:GetBrokenHearts()
        end,
        4
    )
        obj.description="碎心数量≥4"
        setmetatable(obj,self)
        obj.callBackfunction=function ()
            Bingo:taskForHearts(obj)
        end
        obj:setTaskForCallback(obj.callBackfunction)
        return obj
    end
}
local task16=createSingleClass(hearts,task16Options)

-- 任务26：有两排血量
local task26Options={
    constructor=function (self)
        local obj=hearts:new(true,
        26,
        function ()
            return Bingo.player:GetMaxHearts()+Bingo.player:GetSoulHearts()+
                Bingo.player:GetBoneHearts()*2
        end,
        24
    )
        obj.description="有完整两排血量"
        setmetatable(obj,self)
        obj.callBackfunction=function ()
            Bingo:taskForHearts(obj)
        end
        obj:setTaskForCallback(obj.callBackfunction)
        return obj
    end
}
local task26=createSingleClass(hearts,task26Options)

-- 任务19：同时拥有魂心、黑心和红心
local task19Options={
    constructor=function (self)
        local obj=hearts:new(true,
        19,
        function ()
            local heartsCount=0
            if Bingo.player:GetHearts()>=1 then
                heartsCount=heartsCount+1
            end
            local blackheartsNum=(function (blackHearts)
                local sum=0
                if blackHearts==0 then
                    return 0
                end
                while blackHearts>0 do
                    if blackHearts%2==1 then
                        sum=sum+1
                    end
                    blackHearts=math.floor(blackHearts/2)
                end
                return sum
            end)(Bingo.player:GetBlackHearts())
            if blackheartsNum>=1 then
                heartsCount=heartsCount+1
            end
            if Bingo.player:GetSoulHearts()-blackheartsNum*2>=1 then
                heartsCount=heartsCount+1
            end
            return heartsCount
        end,
        3
    )
        obj.description="同时拥有魂心、黑心和红心"
        setmetatable(obj,self)
        obj.callBackfunction=function ()
            Bingo:taskForHearts(obj)
        end
        obj:setTaskForCallback(obj.callBackfunction)
        return obj
    end
}
local task19=createSingleClass(hearts,task19Options)

-- 任务53：拥有至少6个心之容器
local task53Options={
    constructor=function (self)
        local obj=hearts:new(true,
        53,
        function ()
            return Bingo.player:GetMaxHearts()
        end,
        12
    )
        obj.description="拥有至少6个心之容器"
        setmetatable(obj,self)
        obj.callBackfunction=function ()
            Bingo:taskForHearts(obj)
        end
        obj:setTaskForCallback(obj.callBackfunction)
        return obj
    end
}
local task53=createSingleClass(hearts,task53Options)

---------------------------------------------

-- 子类8 entities

-- 构造函数参数说明：
--   map: 该任务是否在图上
--   index: 该任务的索引（如任务1索引则为1）
--   targetEntities: 目标实体
--   variant: 目标实体变种清单（包含白名单和黑名单）
--   TARGET_NUM: 实体的目标数值
local entitiesOption={
    constructor=function (self,map,index,entities,variant,targetNum)
        local obj=tasks:new(map,index)
        obj.targetEntities=entities
        obj.variant=variant
        obj.TARGET_NUM=targetNum
        setmetatable(obj,self)
        return obj
    end,
    methods={
        isInWhiteList=function (self,entityVariant)
            if self.variant.whiteList~=nil then
                for _, value in ipairs(self.variant.whiteList) do
                    if entityVariant==value then
                        return true
                    end
                end
                return false
            end
        end,
        isInBlackList=function (self,entityVariant)
            if self.variant.blackList~=nil then
                for _, value in ipairs(self.variant.blackList) do
                    if entityVariant==value then
                        return true
                    end
                end
                return false
            end
        end,
        entitiesComparison=function (self)
            local entities=Isaac.GetRoomEntities()
            local entitiesCount=0
            for _, value in ipairs(entities) do
                if value.Type==self.targetEntities and ((self:isInWhiteList(value.Variant)~=nil and self:isInWhiteList(value.Variant)) 
                or ((self:isInBlackList(value.Variant))~=nil and not self:isInBlackList(value.Variant))) then
                    entitiesCount=entitiesCount+1
                end
            end
            self.achieveCount=entitiesCount
            tasks.checkTaskIfAchived(self)
        end
    }
}
local entities=createSingleClass(tasks,entitiesOption)

-- entities 的子类，都为具体的任务

-- 任务18：单个房间内有6个道具底座
local task18Options={
    constructor=function (self)
        local obj=entities:new(true,
        18,
        EntityType.ENTITY_PICKUP,
        {whiteList={100}},
        6
    )
        obj.description="单个房间内有6个道具底座"
        setmetatable(obj,self)
        obj.callBackfunction=function ()
            Bingo:taskForEntities(obj)
        end
        obj:setTaskForCallback(obj.callBackfunction)
        return obj
    end
}
local task18=createSingleClass(entities,task18Options)

-- 任务37：可见跟班的数量达到10个
local task37Options={
    constructor=function (self)
        local obj=entities:new(true,
        37,
        EntityType.ENTITY_FAMILIAR,
        {blackList={43,73,201,237,228,220}},
        10
    )
        obj.description="可见跟班的数量达到10个"
        setmetatable(obj,self)
        obj.callBackfunction=function ()
            Bingo:taskForEntities(obj)
        end
        obj:setTaskForCallback(obj.callBackfunction)
        return obj
    end
}
local task37=createSingleClass(entities,task37Options)

---------------------------------------------

-- 子类9 gridEntities

-- 构造函数参数说明：
--   map: 该任务是否在图上
--   index: 该任务的索引（如任务1索引则为1）
--   targetGridEntities: 目标实体的哈希表
--   TARGET_NUM: 实体的目标数值
local gridEntityOption={
    constructor=function (self,map,index,gridEntities,targetNum)
        local obj=tasks:new(map,index)
        obj.targetGridEntities=gridEntities
        obj.TARGET_NUM=targetNum
        obj.achieveCount=0
        obj.gridEntitiesMap={}
        setmetatable(obj,self)
        return obj
    end,
    methods={
        isGridEntitiesDestroyed=function (self)
            for i = 0, 1000, 1 do
                if self.isAchieved then
                    break
                end
                local gridEntity=Bingo.game:GetLevel():GetCurrentRoom():GetGridEntity(i)
                if gridEntity~=nil and self.targetGridEntities[gridEntity.Desc.Type]~=nil and
                gridEntity.State==2 and (self.gridEntitiesMap[GetPtrHash(gridEntity)]==nil) then 
                    self.achieveCount=self.achieveCount+1
                    self.gridEntitiesMap[GetPtrHash(gridEntity)]=true
                    tasks.checkTaskIfAchived(self)
                end
            end
        end
    }
}
local gridEntity=createSingleClass(tasks,gridEntityOption)

-- gridEntities 的子类，都为具体的任务

-- 任务27：摧毁x石头或超级x石头1次
local task27Options={
    constructor=function (self)
        local obj=gridEntity:new(true,
        27,
        {[GridEntityType.GRID_ROCKT]=true,[GridEntityType.GRID_ROCK_SS]=true},
        1
    )
        obj.description="摧毁x石头或超级x石头1次"
        setmetatable(obj,self)
        obj.callBackfunction=function ()
            Bingo:taskForGridEntities(obj)
        end
        obj:setTaskForCallback(obj.callBackfunction)
        return obj
    end
}
local task27=createSingleClass(gridEntity,task27Options)

---------------------------------------------

-- 子类10 gameState

-- 构造函数参数说明：
--   map: 该任务是否在图上
--   index: 该任务的索引（如任务1索引则为1）
--   targetStateFlag: 目标游戏状态
local gameStateOption={
    constructor=function (self,map,index,stateFlag)
        local obj=tasks:new(map,index)
        obj.targetStateFlag=stateFlag
        setmetatable(obj,self)
        return obj
    end,
    methods={
        isTargetStateFlagFinished=function (self)
            if Bingo.game:GetStateFlag(self.targetStateFlag) then
                self.isAchieved=true
            end
        end
    }
}
local gameState=createSingleClass(tasks,gameStateOption)

-- gameState 的子类，都为具体的任务

-- 任务46：打完Boss Rush
local task46Options={
    constructor=function (self)
        local obj=gameState:new(true,
        46,
        GameStateFlag.STATE_BOSSRUSH_DONE
    )
        obj.description="打完Boss Rush"
        setmetatable(obj,self)
        obj.callBackfunction=function ()
            Bingo:taskForGameState(obj)
        end
        obj:setTaskForCallback(obj.callBackfunction)
        return obj
    end
}
local task46=createSingleClass(gameState,task46Options)

---------------------------------------------

-- 子类11 playerState

-- 构造函数参数说明：
--   map: 该任务是否在图上
--   index: 该任务的索引（如任务1索引则为1）
--   targetPlayerStateMethod: 目标玩家状态的方法
local playerStateOption={
    constructor=function (self,map,index,playerStateMethod)
        local obj=tasks:new(map,index)
        obj.targetPlayerStateMethod=playerStateMethod
        setmetatable(obj,self)
        return obj
    end,
    methods={
        isPlayerStateFinished=function (self)
            self.targetPlayerStateMethod(self)
        end
    }
}
local playerState=createSingleClass(tasks,playerStateOption)

-- playerState 的子类，都为具体的任务

-- 任务29：获得飞行能力
local task29Options={
    constructor=function (self)
        local playerStateMethod=function (self)
            if Bingo.player.CanFly then
                self.isAchieved=true
            end
        end
        local obj=playerState:new(true,
        29,
        playerStateMethod
    )
        obj.description="获得飞行能力"
        setmetatable(obj,self)
        obj.callBackfunction=function ()
            Bingo:taskForPlayerState(obj)
        end
        obj:setTaskForCallback(obj.callBackfunction)
        return obj
    end
}
local task29=createSingleClass(playerState,task29Options)

--任务38：触发1次传送
local task38Options={
    constructor=function (self)
        local playerStateMethod=function (self)
            local playerSprite=Bingo.player:GetSprite()
            if playerSprite:IsPlaying("TeleportUp") then
                self.isAchieved=true
            end
            if playerSprite:IsPlaying("TeleportDown") then
                self.isAchieved=true
            end
        end
        local obj=playerState:new(true,
        38,
        playerStateMethod
    )
        obj.description="触发1次传送"
        setmetatable(obj,self)
        obj.callBackfunction=function ()
            Bingo:taskForPlayerState(obj)
        end
        obj:setSpriteTaskForCallback(obj.callBackfunction)
        return obj
    end
}
local task38=createSingleClass(playerState,task38Options)

-- 任务40：拥有硫磺火妈刀组合效果
local task40Options={
    constructor=function (self)
        local playerStateMethod=function (self)
            if Bingo.player:HasCollectible(CollectibleType.COLLECTIBLE_MOMS_KNIFE) and
            Bingo.player:HasCollectible(CollectibleType.COLLECTIBLE_BRIMSTONE) then
                self.isAchieved=true
            end
        end
        local obj=playerState:new(true,
        40,
        playerStateMethod
    )
        obj.description="拥有硫磺火妈刀组合效果"
        setmetatable(obj,self)
        obj.callBackfunction=function ()
            Bingo:taskForPlayerState(obj)
        end
        obj:setTaskForCallback(obj.callBackfunction)
        return obj
    end
}
local task40=createSingleClass(playerState,task40Options)

-- 任务42：头的肤色变成蓝色或者红色
local task42Options={
    constructor=function (self)
        local playerStateMethod=function (self)
            if Bingo.player:GetHeadColor()==SkinColor.SKIN_BLUE or 
            Bingo.player:GetHeadColor()==SkinColor.SKIN_RED then
                self.isAchieved=true
            end
        end
        local obj=playerState:new(true,
        42,
        playerStateMethod
    )
        obj.description="头的肤色变成蓝色或者红色"
        setmetatable(obj,self)
        obj.callBackfunction=function ()
            Bingo:taskForPlayerState(obj)
        end
        obj:setTaskForCallback(obj.callBackfunction)
        return obj
    end
}
local task42=createSingleClass(playerState,task42Options)

---------------------------------------------

-- 子类12 machine

-- 构造函数参数说明：
--   map: 该任务是否在图上
--   index: 该任务的索引（如任务1索引则为1）
--   variant: 目标机器的变种
--   machineState: 机器的目标状态（1为机器被卖爆，2为机器被摧毁）
--   targetNum: 目标数量
local machineOption={
    constructor=function (self,map,index,variant,machineState,targetNum)
        local obj=tasks:new(map,index)
        obj.variant=variant
        obj.targetMachineState=machineState
        obj.achieveCount=0
        obj.achieveMap={}
        obj.TARGET_NUM=targetNum
        setmetatable(obj,self)
        return obj
    end,
    methods={
        getMachineState=function (machineSprite)
            if machineSprite:IsPlaying("Death") then
                return 1
            elseif machineSprite:IsPlaying("Broken") then
                return 2
            end
        end,
        isEntityInMachinePool=function (self,entity)
            for _, value in ipairs(self.variant) do
                if entity.Variant==value then
                    return true
                end
            end
            return false
        end,
        hasMachineInTargetState=function (self)
            local entityList=Isaac.GetRoomEntities()
            for _, value in ipairs(entityList) do
                if value.Type==EntityType.ENTITY_SLOT and self:isEntityInMachinePool(value) and
                self.getMachineState(value:GetSprite())==self.targetMachineState and 
                self.achieveMap[GetPtrHash(value)]==nil then
                    self.achieveCount=self.achieveCount+1
                    self.achieveMap[GetPtrHash(value)]=true
                    tasks.checkTaskIfAchived(self)
                end
            end
        end
    }
}
local machine=createSingleClass(tasks,machineOption)

-- machine 的子类，都为具体的任务

-- 任务45：玩爆1台预言机
local task45Options={
    constructor=function (self)
        local obj=machine:new(true,
        45,
        {3},
        1,
        1
    )
        obj.description="玩爆1台预言机"
        setmetatable(obj,self)
        obj.callBackfunction=function ()
            Bingo:taskForMachine(obj)
        end
        obj:setSpriteTaskForCallback(obj.callBackfunction)
        return obj
    end
}
local task45=createSingleClass(machine,task45Options)

---------------------------------------------

-- 子类14 specialRoomsAtStage

-- 构造函数参数说明：
--   map: 该任务是否在图上
--   index: 该任务的索引（如任务1索引则为1）
--   maxStage: 最高楼层（若不需要该选项则设为true，请传入一个函数）
--   targetRoom: 目标房间种类，请传入一个函数
--   TARGET_NUM: 特殊房间全部清理的楼层的目标数量
--   clearType: 房间完成清理的类型（普通房间完成清理和挑战房完成清理不同，1为普通房间，2为挑战房)
--   isCountByStage: 计算目标数量时是否以楼层数为基准（false则为以房间数为基准）
local specialRoomsAtStageOption={
    constructor=function (self,map,index,Stage,room,targetNum,clearType,isCountByStage)
        local obj=tasks:new(map,index)
        obj.maxStage=Stage
        obj.targetRoom=room
        obj.TARGET_NUM=targetNum
        obj.clearType=clearType
        obj.isCountByStage=isCountByStage
        obj.achieveMap={}
        obj.roomNum=0
        obj.achieveCount=0
        obj.signal=0
        setmetatable(obj,self)
        return obj
    end,
    methods={
        checkClearType=function (self,room)
            if self.clearType==1 then
                return room.Clear
            else
                return room.ChallengeDone
            end
        end,
        getHashMapLength=function (map)
            local length=0
            for key, value in pairs(map) do
                length=length+1
            end
            return length
        end,
        checkSpecialRoomCleard=function (self)
            if self.maxStage() then
                local roomList=Bingo.game:GetLevel():GetRooms()
                for i = 0, roomList.Size-1, 1 do
                    if (roomList:Get(i).Data.Type==self.targetRoom(i)) and
                    self:checkClearType(roomList:Get(i)) and self.achieveMap[i]~=true then
                        self.achieveMap[i]=true
                    end
                end
                if self.isCountByStage and self.getHashMapLength(self.achieveMap)==self.roomNum and
                 self.isAchieved==false and self.roomNum~=0 and self.signal==0 then
                    self.achieveCount=self.achieveCount+1
                    self.signal=1
                elseif (not self.isCountByStage) and self.getHashMapLength(self.achieveMap)==self.roomNum and
                 self.isAchieved==false and self.roomNum~=0 and self.signal==0 then
                    self.achieveCount=self.achieveCount+self.getHashMapLength(self.achieveMap)
                    self.signal=1
                end
                tasks.checkTaskIfAchived(self)
            end
        end,
        countTargetRoomsNumInNewStage=function (self)
            local roomList=Bingo.game:GetLevel():GetRooms()
            local roomNum=0
            for i = 0, roomList.Size-1, 1 do
                if roomList:Get(i).Data.Type==self.targetRoom(i) and roomList:Get(i).GridIndex~=-100 then
                    roomNum=roomNum+1
                end
            end
            self.roomNum=roomNum
            self.achieveMap={}
            self.signal=0
        end
    }
}
local specialRoomsAtStage=createSingleClass(tasks,specialRoomsAtStageOption)

-- specialRoomsAtStage 的子类，都为具体的任务

-- 任务49：前两层所有普通房间全探索
local task49Options={

    constructor=function (self)
        local obj=specialRoomsAtStage:new(true,
        49,
        function ()
            local stage=Bingo.game:GetLevel():GetStage()
            local stageType=Bingo.game:GetLevel():GetStageType()
            if (stage==1 or (stage==2 and not (stageType==4 or stageType==5)))then
                return true
            end
        end,
        function ()
            return RoomType.ROOM_DEFAULT
        end,
        2,
        1,
        true
    )
        obj.description="前两层所有普通房间全探索"
        obj.conflictTasks={56}
        setmetatable(obj,self)
        obj.callBackfunction=function ()
            Bingo:taskForSpecialRoomsAtStage1(obj)
        end
        obj:setTaskForCallback(obj.callBackfunction)
        obj:countTargetRoomsNumInNewStage()
        obj.callBackfunction1=function ()
            Bingo:taskForSpecialRoomsAtStage2(obj)
        end
        Bingo:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL,obj.callBackfunction1)
        return obj
    end
}
local task49=createSingleClass(specialRoomsAtStage,task49Options)

-- 任务57：打2个Boss挑战房
local task57Options={
    constructor=function (self)
        local obj=specialRoomsAtStage:new(true,
        57,
        function ()
            return Bingo.game:GetLevel():HasBossChallenge()
        end,
        function ()
            return RoomType.ROOM_CHALLENGE
        end,
        2,
        2,
        true
    )
        obj.description="打2个Boss挑战房"
        setmetatable(obj,self)
        obj.callBackfunction=function ()
            Bingo:taskForSpecialRoomsAtStage1(obj)
        end
        obj:setTaskForCallback(obj.callBackfunction)
        obj:countTargetRoomsNumInNewStage()
        obj.callBackfunction1=function ()
            Bingo:taskForSpecialRoomsAtStage2(obj)
        end
        Bingo:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL,obj.callBackfunction1)
        return obj
    end
}
local task57=createSingleClass(specialRoomsAtStage,task57Options)

-- 任务60：进入5个商店房
local task60Options={
    constructor=function (self)
        local obj=specialRoomsAtStage:new(true,
        60,
        function ()
            return true
        end,
        function ()
            return RoomType.ROOM_SHOP
        end,
        5,
        1,
        false
    )
        obj.description="进入5个商店房"
        setmetatable(obj,self)
        obj.callBackfunction=function ()
            Bingo:taskForSpecialRoomsAtStage1(obj)
        end
        obj:setTaskForCallback(obj.callBackfunction)
        obj:countTargetRoomsNumInNewStage()
        obj.callBackfunction1=function ()
            Bingo:taskForSpecialRoomsAtStage2(obj)
        end
        Bingo:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL,obj.callBackfunction1)
        return obj
    end
}
local task60=createSingleClass(specialRoomsAtStage,task60Options)

-- 任务61：进入5个宝箱房
local task61Options={
    constructor=function (self)
        local obj=specialRoomsAtStage:new(true,
        61,
        function ()
            return true
        end,
        function ()
            return RoomType.ROOM_TREASURE
        end,
        5,
        1,
        false
    )
        obj.description="进入5个宝箱房"
        setmetatable(obj,self)
        obj.conflictTasks={15}
        obj.callBackfunction=function ()
            Bingo:taskForSpecialRoomsAtStage1(obj)
        end
        obj:setTaskForCallback(obj.callBackfunction)
        obj:countTargetRoomsNumInNewStage()
        obj.callBackfunction1=function ()
            Bingo:taskForSpecialRoomsAtStage2(obj)
        end
        Bingo:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL,obj.callBackfunction1)
        return obj
    end
}
local task61=createSingleClass(specialRoomsAtStage,task61Options)

-- 任务62：镜子世界中所有房间全探索
local task62Options={
    constructor=function (self)
        local obj=specialRoomsAtStage:new(true,
        62,
        function ()
            return Bingo.game:GetRoom():IsMirrorWorld()
        end,
        function (i)
            local roomList=Bingo.game:GetLevel():GetRooms()
            if roomList:Get(i).Data.Type==RoomType.ROOM_ULTRASECRET then
                return RoomType.ROOM_NULL
            end
            if i>=roomList.Size/2 then
                return roomList:Get(i).Data.Type
            end
        end,
        1,
        1,
        true
    )
        obj.description="镜子世界中的白房间全探索"
        setmetatable(obj,self)
        obj.callBackfunction=function ()
            Bingo:taskForSpecialRoomsAtStage1(obj)
        end
        obj:setTaskForCallback(obj.callBackfunction)
        obj:countTargetRoomsNumInNewStage()
        obj.callBackfunction1=function ()
            Bingo:taskForSpecialRoomsAtStage2(obj)
        end
        Bingo:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL,obj.callBackfunction1)
        return obj
    end
}
local task62=createSingleClass(specialRoomsAtStage,task62Options)

-- 任务79：进入刺房3次
local task79Options={
    constructor=function (self)
        local obj=specialRoomsAtStage:new(true,
        79,
        function ()
            return true
        end,
        function ()
            return RoomType.ROOM_CURSE
        end,
        3,
        1,
        false
    )
        obj.description="进入3个刺房"
        setmetatable(obj,self)
        obj.callBackfunction=function ()
            Bingo:taskForSpecialRoomsAtStage1(obj)
        end
        obj:setTaskForCallback(obj.callBackfunction)
        obj:countTargetRoomsNumInNewStage()
        obj.callBackfunction1=function ()
            Bingo:taskForSpecialRoomsAtStage2(obj)
        end
        Bingo:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL,obj.callBackfunction1)
        return obj
    end
}
local task79=createSingleClass(specialRoomsAtStage,task79Options)

---------------------------------------------

-- 子类15 beggar

-- 构造函数参数说明：
--   map: 该任务是否在图上
--   index: 该任务的索引（如任务1索引则为1）
--   variant: 目标乞丐种类池
--   beggarState: 目标乞丐的状态（1为被喂饱，2为被摧毁）
--   TARGET_NUM: 目标数量
--   currentRoom: 当前房间
local beggarOption={
    constructor=function (self,map,index,variant,beggarState,targetNum)
        local obj=tasks:new(map,index)
        obj.variant=variant
        obj.targetBeggarState=beggarState
        obj.achieveCount=0
        obj.achieveMap={}
        obj.TARGET_NUM=targetNum
        obj.currentRoom=0
        setmetatable(obj,self)
        return obj
    end,
    methods={
        getBeggarState=function (beggar)
            if beggar~=nil and beggar:GetSprite():IsPlaying("Teleport") then
                print("sb")
                return 1
            elseif beggar==nil then
                print("ok")
                return 2
            end
        end,
        isEntityInBeggarPool=function (self,entity)
            for _, value in ipairs(self.variant) do
                if entity.Variant==value then
                    return true
                end
            end
            return false
        end,
        hasSatisfyBeggar=function (self)
            local roomIndex=Bingo.game:GetLevel():GetCurrentRoomDesc().ListIndex
            if self.currentRoom~=roomIndex then
                self.currentRoom=roomIndex
                self.achieveMap={}
            end
            local entityList=Isaac.GetRoomEntities()
            for _, value in ipairs(entityList) do
                if value.Type==EntityType.ENTITY_SLOT and self:isEntityInBeggarPool(value) and
                 self.achieveMap[GetPtrHash(value)]==nil then
                    self.achieveMap[GetPtrHash(value)]={EntityPtr(value),true}
                end
            end
            for key, value in pairs(self.achieveMap) do
                if value[2]==true and self.getBeggarState(value[1].Ref)~=nil and
                 self.getBeggarState(value[1].Ref)==self.targetBeggarState then
                    self.achieveCount=self.achieveCount+1
                    tasks.checkTaskIfAchived(self);
                    (self.achieveMap[key])[2]=false
                end
            end
        end
    }
}
local beggar=createSingleClass(tasks,beggarOption)

-- beggar 的子类，都是具体的任务

-- 任务54：喂饱1个特殊乞丐（除黑乞丐和白乞丐以外的乞丐）
local task54Options={
    constructor=function (self)
        local obj=beggar:new(true,
        54,
        {6,7,9,13,14,17},
        1,
        1
    )
        obj.description="喂饱1个除黑乞丐和白乞丐以外的乞丐"
        setmetatable(obj,self)
        obj.callBackfunction=function ()
            Bingo:taskForBeggar(obj)
        end
        obj:setSpriteTaskForCallback(obj.callBackfunction)
        return obj
    end
}
local task54=createSingleClass(beggar,task54Options)

-- 任务65：喂饱2个乞丐
local task65Options={
    constructor=function (self)
        local obj=beggar:new(true,
        65,
        slotPoolOfBeggar,
        1,
        2
    )
        obj.description="喂饱2个乞丐"
        setmetatable(obj,self)
        obj.callBackfunction=function ()
            Bingo:taskForBeggar(obj)
        end
        obj:setSpriteTaskForCallback(obj.callBackfunction)
        return obj
    end
}
local task65=createSingleClass(beggar,task65Options)

-- 任务68：摧毁3个乞丐
local task68Options={
    constructor=function (self)
        local obj=beggar:new(true,
        68,
        slotPoolOfBeggar,
        2,
        3
    )
        obj.description="摧毁3个乞丐"
        setmetatable(obj,self)
        obj.callBackfunction=function ()
            Bingo:taskForBeggar(obj)
        end
        obj:setSpriteTaskForCallback(obj.callBackfunction)
        return obj
    end
}
local task68=createSingleClass(beggar,task68Options)

-- 任务73：喂饱1个抽奖乞丐
local task73Options={
    constructor=function (self)
        local obj=beggar:new(true,
        73,
        {6,15},
        1,
        1
    )
        obj.description="喂饱1个抽奖乞丐"
        setmetatable(obj,self)
        obj.callBackfunction=function ()
            Bingo:taskForBeggar(obj)
        end
        obj:setSpriteTaskForCallback(obj.callBackfunction)
        return obj
    end
}
local task73=createSingleClass(beggar,task73Options)

---------------------------------------------

-- 子类20 other

-- 构造函数参数说明：
--   map: 该任务是否在图上
--   index: 该任务的索引（如任务1索引则为1）
--   method: 该任务的逻辑方法
local otherOption={
    constructor=function (self,map,index,method)
        local obj=tasks:new(map,index)
        obj.method=method
        setmetatable(obj,self)
        return obj
    end,
    methods={
        taskMethod=function (self)
            self.method(self)
        end
    }
}
local other=createSingleClass(tasks,otherOption)

-- other 的子类，都为具体的任务

-- 任务34：献祭踩单个刺踩到第10下
local task34Options={
    constructor=function (self)
        local method=function (self)
            for i = 0, 1000, 1 do
                if self.isAchieved then
                    break
                end
                local gridEntity=Bingo.game:GetLevel():GetCurrentRoom():GetGridEntity(i)
                if gridEntity~=nil and gridEntity.Desc.Type==GridEntityType.GRID_SPIKES then
                    self.achieveCount=gridEntity.VarData
                    tasks.checkTaskIfAchived(self)
                end
            end
        end
        local obj=other:new(true,
        34,
        method
    )
        obj.description="献祭踩单个刺踩到第10下"
        obj.TARGET_NUM=10
        setmetatable(obj,self)
        obj.callBackfunction=function ()
            Bingo:taskForOther(obj)
        end
        obj:setTaskForCallback(obj.callBackfunction)
        return obj
    end
}
local task34=createSingleClass(other,task34Options)

-- 任务35：在1分钟内击杀第一层的boss
local task35Options={
    constructor=function (self)
        local method=function (self)
            local roomList=Bingo.game:GetLevel():GetRooms()
            local stage=Bingo.game:GetLevel():GetStage()
            local stageType=Bingo.game:GetLevel():GetStageType()
            if Bingo.gameTime<=60000 and roomList:Get(0).Clear and stage==LevelStage.STAGE1_1 and
            (stageType~=StageType.STAGETYPE_REPENTANCE and stageType~=StageType.STAGETYPE_REPENTANCE_B) then
                self.isAchieved=true
            end
        end
        local obj=other:new(true,
        35,
        method
    )
        obj.description="在1分钟内击杀第一层的boss"
        setmetatable(obj,self)
        obj.callBackfunction=function ()
            Bingo:taskForOther(obj)
        end
        obj:setTaskForCallback(obj.callBackfunction)
        return obj
    end
}
local task35=createSingleClass(other,task35Options)

-- 任务56：第一层不拿任何额外道具（初始携带的不算）
local task56Options={
    constructor=function (self)
        local method=function (self)
            local stage=Bingo.game:GetLevel():GetStage()
            local stageType=Bingo.game:GetLevel():GetStageType()
            if stage==LevelStage.STAGE1_1 and stageType~=StageType.STAGETYPE_REPENTANCE and
            stageType~=StageType.STAGETYPE_REPENTANCE_B and (Bingo.player.QueuedItem.Item~=nil and Bingo.player.QueuedItem.Item.Type~=ItemType.ITEM_TRINKET) then
                self.isPickCollectible=true
            end
            if (stageType==StageType.STAGETYPE_REPENTANCE or stageType==StageType.STAGETYPE_REPENTANCE_B or
            stage>=2) and self.isPickCollectible==false then
                self.isAchieved=true
            end
        end
        local obj=other:new(true,
        56,
        method
    )
        obj.isPickCollectible=false
        obj.description="第一层不拿除了初始携带的道具以外的任何道具"
        obj.conflictTasks={49}
        obj.callBackfunction=function ()
            Bingo:taskForOther(obj)
        end
        obj:setTaskForCallback(obj.callBackfunction)
        return obj
    end
}
local task56=createSingleClass(other,task56Options)

-- 任务64：连续3个房间不清理
local task64Options={
    constructor=function (self)
        local method=function (self)
            local lastRoom=Bingo.game:GetLevel():GetLastRoomDesc()
            if lastRoom~=nil and (not lastRoom.Clear) and
            self.achieveMap[lastRoom.ListIndex]==nil then
                self.achieveMap[lastRoom.ListIndex]=true
            elseif lastRoom~=nil and lastRoom.Clear then
                self.achieveMap={}
            end
            if self.isAchieved==false then
                self.achieveCount=getHashMapLength(self.achieveMap)
            end
            tasks.checkTaskIfAchived(self)
        end
        local obj=other:new(true,
        64,
        method
    )
        obj.achieveMap={}
        obj.achieveCount=0
        obj.TARGET_NUM=3
        obj.description="连续3个房间不清理"
        setmetatable(obj,self)
        obj.callBackfunction=function ()
            Bingo:taskForOther(obj)
        end
        obj:setTaskForCallback(obj.callBackfunction)
        return obj
    end
}
local task64=createSingleClass(other,task64Options)

-- 任务 66：在某层不打这一层boss并跳层
local task66Options={
    constructor=function (self)
        local method=function (self)
            if Bingo.game:GetLevel():GetRooms():Get(0).Clear then
                self.isClearBoss=true
            end
        end
        local obj=other:new(true,
        66,
        method
    )
        obj.description="在某层不打这一层boss并跳层"
        setmetatable(obj,self)
        obj.callBackfunction=function ()
            Bingo:taskForOther(obj)
        end
        obj:setTaskForCallback(obj.callBackfunction)
        obj.callBackfunction1=function ()
            if not obj.isClearBoss then
                obj.isAchieved=true
            end
            obj.isClearBoss=false
        end
        Bingo:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL,obj.callBackfunction1)
        return obj
    end
}
local task66=createSingleClass(other,task66Options)

-- 任务70：完成全支线路线，以离开陵墓2层为完成
local task70Options={
    constructor=function (self)
        local method=function (self)
            if Bingo.game:GetLevel():GetStage()>=7 and self.isOnbranchLine then
                self.isAchieved=true
            end
            if Bingo.game:GetLevel():GetStageType()<=3 then
                self.isOnbranchLine=false
            end
        end
        local obj=other:new(true,
        70,
        method
    )
        obj.isOnbranchLine=true
        obj.description="完成全支线路线，以离开陵墓2层为完成"
        setmetatable(obj,self)
        obj.callBackfunction1=function ()
            obj:method()
        end
        Bingo:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL,obj.callBackfunction1)
        return obj
    end
}
local task70=createSingleClass(other,task70Options)



























function Bingo:taskForPickUpCollectibles(task)
    task:isItemInCurrentRoomItemPool()
    task:updateBingoMapConfigAndRemoveCallBack()
end

function Bingo:taskForHasItems(task)
    task:hasItemsWithTag()
    task:updateBingoMapConfigAndRemoveCallBack()
end

function Bingo:taskForBosses(task)
    task:hasKilledBosses()
    task:updateBingoMapConfigAndRemoveCallBack()
end

function Bingo:taskForPlayerForms(task)
    task:hasPlayerForm()
    task:updateBingoMapConfigAndRemoveCallBack()
end

function Bingo:taskForAttribute(task)
    task:attributeComparison()
    task:updateBingoMapConfigAndRemoveCallBack()
end

function Bingo:taskForPickUps(task)
    task:pickUpComprison()
    task:updateBingoMapConfigAndRemoveCallBack()
end

function Bingo:taskForHearts(task)
    task:heartComparison()
    task:updateBingoMapConfigAndRemoveCallBack()
end

function Bingo:taskForEntities(task)
    task:entitiesComparison()
    task:updateBingoMapConfigAndRemoveCallBack()
end

function Bingo:taskForGridEntities(task)
    task:isGridEntitiesDestroyed()
    task:updateBingoMapConfigAndRemoveCallBack()
end

function Bingo:taskForGameState(task)
    task:isTargetStateFlagFinished()
    task:updateBingoMapConfigAndRemoveCallBack()
end

function Bingo:taskForPlayerState(task)
    task:isPlayerStateFinished()
    task:updateBingoMapConfigAndRemoveCallBack()
end

function Bingo:taskForMachine(task)
    task:hasMachineInTargetState()
    task:updateBingoMapConfigAndRemoveCallBack()
end

function Bingo:taskForSpecialRoomsAtStage1(task)
    task:checkSpecialRoomCleard()
    task:updateBingoMapConfigAndRemoveCallBack()
end
function Bingo:taskForSpecialRoomsAtStage2(task)
    task:countTargetRoomsNumInNewStage()
end

function Bingo:taskForBeggar(task)
    task:hasSatisfyBeggar()
    task:updateBingoMapConfigAndRemoveCallBack()
end

function Bingo:taskForOther(task)
    task:taskMethod()
    task:updateBingoMapConfigAndRemoveCallBack()
end





function Bingo:isUseVoid()
    isUseVoidOrBlackRune.isUseVoid=true
end
function Bingo:isUseBlackRune()
    isUseVoidOrBlackRune.isUseBlackRune=true
end





return {
    task1=task1,
    task2=task2,
    task3=task3,
    task4=task4,
    task5=task5,
    task6=task6,
    task7=task7,
    task8=task8,
    task9=task9,
    task10=task10,
    task11=task11,
    task12=task12,
    task13=task13,
    task14=task14,
    task15=task15,
    task16=task16,
    task17=task17,
    task18=task18,
    task19=task19,
    task20=task20,
    task21=task21,
    task22=task22,
    task23=task23,
    task24=task24,
    task25=task25,
    task26=task26,
    task27=task27,
    task28=task28,
    task29=task29,
    task30=task30,
    task31=task31,
    task32=task32,
    task33=task33,
    task34=task34,
    task35=task35,
    task36=task36,
    task37=task37,
    task38=task38,
    task39=task39,
    task40=task40,
    task41=task41,
    task42=task42,
    task43=task43,
    task44=task44,
    task45=task45,
    task46=task46,
    task47=task47,
    task48=task48,
    task49=task49,
    task50=task50,
    task51=task51,
    task52=task52,
    task53=task53,
    task54=task54,
    task55=task55,
    task56=task56,
    task57=task57,
    task58=task58,
    task59=task59,
    task60=task60,
    task61=task61,
    task62=task62,
    task63=task63,
    task64=task64,
    task65=task65,
    task66=task66,
    task67=task67,
    task68=task68,
    task69=task69,
    task70=task70,
    tasks=tasks,
    conflictCharacter
}
