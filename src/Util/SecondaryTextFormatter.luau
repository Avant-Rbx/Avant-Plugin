--Helper to format primary text with a secondary part.
--!strict

local NexusPluginComponents = require(script.Parent.Parent:WaitForChild("Packages"):WaitForChild("NexusPluginComponents"))

return function(Scope: NexusPluginComponents.FusionScope, PrimaryText: NexusPluginComponents.UsedAs<string>, SecondaryText: NexusPluginComponents.UsedAs<string?>): NexusPluginComponents.UsedAs<string>
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