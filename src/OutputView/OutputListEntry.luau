--Entry part of the output list.
--!strict

local TEXT_MARGIN_PIXELS = 3

local CreateFusionScope = require(script.Parent.Parent:WaitForChild("NexusPluginComponents"):WaitForChild("CreateFusionScope"))
local Fusion = require(script.Parent.Parent:WaitForChild("NexusPluginComponents"):WaitForChild("Fusion"))

local Children = Fusion.Children
local MainTextColorByScope = {}
local ColorsByScope = {}

local OutputListEntry = {}
OutputListEntry.__index = OutputListEntry

export type OutputData = {
    MessageType: Enum.MessageType?,
    Text: string,
}
export type OutputListEntry = {
    Scope: CreateFusionScope.FusionScope,
    Data: Fusion.Value<OutputData>,
    GuiInstance: GuiObject,
} & typeof(setmetatable({}, OutputListEntry))



--[[
Creates an output list entry.
--]]
function OutputListEntry.new(ParentScope: CreateFusionScope.FusionScope, InitialData: OutputData): OutputListEntry
    --Populate the plugin colors for the scope.
    --PluginColor does not cache internally, so this is required for now.
    if not MainTextColorByScope[ParentScope] then
        MainTextColorByScope[ParentScope] = ParentScope:PluginColor(Enum.StudioStyleGuideColor.MainText)
    end
    if not ColorsByScope[ParentScope] then
        ColorsByScope[ParentScope] = {
            [Enum.MessageType.MessageOutput] = ParentScope:PluginColor(Enum.StudioStyleGuideColor.MainText),
            [Enum.MessageType.MessageWarning] = ParentScope:PluginColor(Enum.StudioStyleGuideColor.WarningText),
            [Enum.MessageType.MessageError] = ParentScope:PluginColor(Enum.StudioStyleGuideColor.ErrorText),
            [Enum.MessageType.MessageInfo] = ParentScope:PluginColor(Enum.StudioStyleGuideColor.InfoText),
        }
    end

    --Create and return the object.
    local Scope = ParentScope:innerScope() :: CreateFusionScope.FusionScope
    local DataValue = Scope:Value(InitialData) :: Fusion.Value<OutputData>
    local MainTextColor = MainTextColorByScope[ParentScope]
    local CurrentColorsByScope = ColorsByScope[ParentScope]
    return setmetatable({
        Scope = Scope,
        Data = DataValue,
        GuiInstance = Scope:Create("Frame")({
            BackgroundTransparency = 1,
            [Children] = {
                Scope:Create("TextLabel")({
                    Size = UDim2.new(1, -(2 * TEXT_MARGIN_PIXELS), 1, 0),
                    Position = UDim2.new(0, TEXT_MARGIN_PIXELS, 0, 0),
                    TextColor3 = Scope:Computed(function(use)
                        local CurrentOutput = use(DataValue)
                        return CurrentOutput.MessageType and use(CurrentColorsByScope[CurrentOutput.MessageType]) or use(MainTextColor)
                    end),
                    Text = Scope:Computed(function(use)
                        return use(DataValue).Text
                    end),
                    Font = Scope:Computed(function(use)
                        return use(DataValue).MessageType and Enum.Font.SourceSans or Enum.Font.SourceSansItalic
                    end),
                }),
            },
        }) :: GuiObject,
    }, OutputListEntry) :: OutputListEntry
end

--[[
Updates the entry.
--]]
function OutputListEntry.Update(self: OutputListEntry, Index: number, Data: OutputData): ()
    self.Data:set(Data)
end

--[[
Destroys the entry.
--]]
function OutputListEntry.Destroy(self: OutputListEntry): ()
    self.Scope:doCleanup()
end



return OutputListEntry