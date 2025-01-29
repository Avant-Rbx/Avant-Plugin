--Helper to format primary text with a secondary part.
--!strict

local CreateFusionScope = require(script.Parent.Parent:WaitForChild("NexusPluginComponents"):WaitForChild("CreateFusionScope"))
local Fusion = require(script.Parent.Parent:WaitForChild("NexusPluginComponents"):WaitForChild("Fusion"))

return function(Scope: CreateFusionScope.FusionScope, PrimaryText: Fusion.UsedAs<string>, SecondaryText: Fusion.UsedAs<string?>): Fusion.UsedAs<string>
    local SubTextColor = Scope:PluginColor(Enum.StudioStyleGuideColor.SubText)
    return Scope:Computed(function(use)
        local CurrentSubTextColor = use(SubTextColor)
        local CurrentPrimaryText = use(PrimaryText)
        local CurrentSecondaryText = use(SecondaryText)
        if CurrentSecondaryText and string.len(CurrentSecondaryText) > 0 then
            return `{CurrentPrimaryText} <i><font color=\"rgb({math.floor(255 * CurrentSubTextColor.R)},{math.floor(255 * CurrentSubTextColor.G)},{math.floor(255 * CurrentSubTextColor.B)})\">({CurrentSecondaryText})</font></i>`
        end
        return CurrentPrimaryText
    end)
end