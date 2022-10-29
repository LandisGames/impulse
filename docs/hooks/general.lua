-- luacheck: ignore 111

--- Hooks that can be used in a Plugin or a Schema
-- @hooks General

--- Controls wether a player can use their inventory, returning false stops all inventory interaction and stops the inventory from displaying
-- @realm shared
-- @entity ply The player that is trying to use their inventory
-- @treturn bool Can use inventory
function CanUseInventory(ply)
end

--- Called when a player opens their storage box
-- @realm server
-- @entity ply The player that has opened their storage
-- @entity box The storage box
function PlayerOpenStorage(ply, box)
end

--- Called when a player is un-arrested
-- @realm server
-- @entity convict The player that has been un-arrested
-- @entity officer The officer who un-arrested the player
function PlayerUnArrested(convict, officer)
end

--- Called when a player is arrested
-- @realm server
-- @entity convict The player that has been arrested
-- @entity officer The officer who arrested the player
function PlayerArrested(convict, officer)
end

--- Returns a custom death sound to override the default impulse one
-- @realm client
-- @treturn string Sound path
function GetDeathSound()
end

--- Called when you can define settings, all settings you want to define should be done inside this hook
-- @realm client
-- @see Setting
function DefineSettings()
end

--- Called when the menu is active and MenuMessages are ready to be created
-- @realm client
-- @see MenuMessage
function CreateMenuMessages()
end

--- Called when the menu is active and MenuMessages are ready to be displayed
-- @realm client
-- @internal
-- @see MenuMessage
function DisplayMenuMessages()
end

--- Called when the local player is sent to jail, provides jail sentence data
-- @realm client
-- @int endTime When the jail sentence will end
-- @param jailData Data regarding the sentence including crimes commited
function PlayerGetJailData()
end

--- Called when the player has fully loaded into the server after connecting
-- @realm server
-- @entity ply Player who is now fully connected
function PlayerInitialSpawnLoaded()
end

--- Called before a players inventory is queried from the database
-- @realm server
-- @entity ply The player
function PreEarlyInventorySetup()
end

--- Called after a players inventory has been setup
-- @realm server
-- @entity ply The player
function PostInventorySetup()
end

--- Called after a player has been fully setup by impulse
-- @realm server
-- @entity ply The player
function PostSetupPlayer()
end

--- Called when an in-character chat message is sent
-- @realm server
-- @entity sender The sender
-- @string message The message
-- @treturn string The new message
function ProcessICChatMessage()
end

--- Called when an chat class message is sent
-- @realm server
-- @int chatClass ID of the chat class
-- @entity sender The sender
-- @string message The message
-- @treturn string The new message
function ChatClassMessageSend()
end

--- Called after a chat class message is sent
-- @realm server
-- @int chatClass ID of the chat class
-- @string message The message
-- @entity sender The sender
function PostChatClassMessageSend()
end

--- Called when the player accesses their storage container
-- @realm server
-- @entity ply The player who opened their storage
-- @entity storage The storage box
function PlayerOpenStorage()
end

--- Called after a chat class message is sent
-- @realm client
-- @treturn bool Should we draw the HUD box?
function ShouldDrawHUDBox()
end

--- Called every tick, use this to check for key presses to open user interface elements (input.IsKeyDown)
-- @realm client
function CheckMenuInput()
end

--- Called to check if one player can hear another
-- @realm server
-- @entity listener The player listening
-- @entity speaker The player speaking
-- @treturn bool Can the listener hear the speaker?
function PlayerCanHearCheck()
end

--- Called before a players death ragdoll spawns
-- @realm server
-- @entity ragdoll The ragdoll entity
-- @entity ply The player who died
-- @entity attacker The killer
function PlayerRagdollPreSpawn()
end

--- Called when a player dies, you can drop loot in this hook
-- @realm server
-- @entity ply The player who died
-- @entity killer The killer
-- @param pos The pos to spawn any droppable items at
-- @param dropped A table of dropped items
-- @param inv The players inventory on death
function PlayerDropDeathItems()
end

--- Called after impulse has setup it's entities
-- @realm server
function PostInitPostEntity()
end

--- Called to decide if a player should break their legs
-- @realm server
-- @entity ply The player
-- @int damage The fall damage
-- @treturn bool Should their legs break?
function PlayerShouldBreakLegs()
end

--- Called to decide if a player should get hungry
-- @realm server
-- @entity ply The player
-- @treturn bool Should they get hungry?
function PlayerShouldGetHungry()
end

--- Called when a player purchases a buyable
-- @realm server
-- @entity ply The player
-- @string buyable The buyable name
function PlayerBuyablePurchase()
end

--- Called when a players chat state changes
-- @realm server
-- @entity ply The player
-- @bool oldState The old chat state
-- @bool newState The new chat state
function ChatStateChanged()
end

--- Called to decide if a player can edit a door
-- @realm server
-- @entity ply The player
-- @entity door The door
-- @treturn bool Can edit
function CanEditDoor()
end

--- Called when a player purchases a door
-- @realm server
-- @entity ply The player
-- @entity door The door
function PlayerPurchaseDoor()
end

--- Called when a player sells a door
-- @realm server
-- @entity ply The player
-- @entity door The door
function PlayerSellDoor()
end

--- Called when a player adds a user to a door
-- @realm server
-- @entity ply The player
-- @param owners Table of owners
function PlayerAddUserToDoor()
end

--- Called when a player drops an item
-- @realm server
-- @entity ply The player
-- @param itemData A table of item data
-- @int invID The inventory ID of the item
function PlayerDropItem()
end

--- Called when a player confiscates an item
-- @realm server
-- @entity ply The player who is confiscating
-- @entity targ The player who is being targeted
-- @string itemclass The item class of the confiscated item
function PlayerConfiscateItem()
end

--- Called to decide if a player can store/unstore an item
-- @realm server
-- @entity ply The player
-- @entity storage The storage box
-- @string itemclass The item class
-- @int from Is this to or from the players inventory?
-- @treturn bool Allow the item to be stored or unstored?
function CanStoreItem()
end

--- Called when a player changes their RP name
-- @realm server
-- @entity ply The player
-- @string name The new name
function PlayerChangeRPName()
end

--- Called when a player crafts an item
-- @realm server
-- @entity ply The player
-- @string output The item class of the output
function PlayerCraftItem()
end

--- Called when a player buys an item from a vendor
-- @realm server
-- @entity ply The player
-- @entity vendor The vendor
-- @string itemclass The item class of the bought item
-- @int cost The cost of the purchase
function PlayerVendorBuy()
end

--- Called when a player sets a container passcode
-- @realm server
-- @entity ply The player
-- @entity container The container
function ContainerPasscodeSet()
end

--- Called when animation classes have been loaded
-- @realm shared
function LoadAnimationClasses()
end

--- Called when an OOC message is sent
-- @realm server
-- @string message The message
function ProcessOOCMessage()
end

--- Called when a player tries to use /r or /radio, but is not a CP
-- @realm server
-- @entity ply The player
-- @string message The message
function RadioMessageFallback()
end

--- Called when a player drops money
-- @realm server
-- @entity ply The player
-- @entity money The money
function PlayerDropMoney()
end

--- Called when a player inventory searches another player
-- @realm server
-- @entity ply The searcher player
-- @entity target The target player
function DoInventorySearch()
end

--- Called to decide what the known name of a player should be
-- @realm shared
-- @entity ply The player to get the name of
-- @treturn string The known name
function PlayerGetKnownName()
end

--- Called after the config has loaded
-- @realm shared
function PostConfigLoad()
end

--- Called when the schema has loaded fully
-- @realm shared
function OnSchemaLoaded()
end

--- Called when a Sync variable is updated
-- @realm shared
-- @int varID The sync variable ID
-- @int targetID The entity ID of the target
-- @param any The new value
function OnSyncUpdate()
end

--- Called to decide if a player can change team
-- @realm shared
-- @entity ply The player
-- @int team The team to switch to
-- @treturn bool Can we switch team?
function CanPlayerChangeTeam()
end

--- Called when a player gains XP
-- @realm server
-- @entity ply The player
-- @int xp The amount gained
function PlayerGetXP()
end

--- Called when a player changes zone
-- @realm server
-- @entity ply The player
-- @int id The new zone ID
function PlayerZoneChanged()
end

--- Called when a player is unjailed
-- @realm server
-- @entity ply The player
function PlayerUnJailed()
end