--Displays a message on start if a paid version of the plugin is not detected.
--!strict

--When true, the paid version message will not be displayed.
--This should be changed to true before distributing though paid platforms.
--For anyone reading this trying to not be reminded about the paid version, set this to true.
local IS_PAID_VERSION = false
local UNPAID_VERSION_IGNORE_SETTING_NAME = "Avant_LastPaidVersionIgnoreTime"
local UNPAID_VERSION_REMINDER_TIME_SECONDS = 30 * 24 * 60 * 60

local CreateFusionScope = require(script.Parent.Parent:WaitForChild("NexusPluginComponents"):WaitForChild("CreateFusionScope"))
local Fusion = require(script.Parent.Parent:WaitForChild("NexusPluginComponents"):WaitForChild("Fusion"))

local Children = Fusion.Children

return function(Scope: CreateFusionScope.FusionScope, Plugin: Plugin, Parent: Instance): ()
    --Return if a paid version is detected.
    if IS_PAID_VERSION then return true end

    --Return if the ignore button was pressed within the last 30 days.
    local LastPaidIgnoreTime = Plugin:GetSetting(UNPAID_VERSION_IGNORE_SETTING_NAME) or 0
    if os.time() - LastPaidIgnoreTime < UNPAID_VERSION_REMINDER_TIME_SECONDS then return end

    --Create the message.
    local Message = Scope:Create("Frame")({
        Size = UDim2.new(1, 0, 1, 0),
        Parent = Parent,
        [Children] = {
            --Top text.
            Scope:Create("TextLabel")({
                Name = "HeaderText",
                AnchorPoint = Vector2.new(0.5, 0),
                Size = UDim2.new(1, 0, 0, 24),
                Position = UDim2.new(0.5, 0, 0, 2),
                Text = "Avant is not free!",
                TextSize = 20,
                TextColor3 = Enum.StudioStyleGuideColor.ErrorText,
                TextXAlignment = Enum.TextXAlignment.Center,
            }),

            --Explaination text.
            Scope:Create("TextLabel")({
                Name = "BodyText",
                AnchorPoint = Vector2.new(0.5, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                Size = UDim2.new(1, -6, 0, 0),
                Position = UDim2.new(0.5, 0, 0, 28),
                Text = "In order to use Avant, it is expected to have paid for the plugin. Information about this is covered in the README of Avant-Rbx/Avant-Plugin on GitHub. Versions of the plugin obtained through paid methods will not show this message.\n\nUnless the plugin is replaced with one from a paid source, this message will appear again in 30 days.",
                TextWrapped = true,
                TextXAlignment = Enum.TextXAlignment.Center,
                TextYAlignment = Enum.TextYAlignment.Top,
                [Children] = {
                    --Close button.
                    Scope:Create("TextButton")({
                        Name = "CloseButton",
                        BackgroundColor3 = Enum.StudioStyleGuideColor.DialogMainButton,
                        AnchorPoint = Vector2.new(0.5, 0),
                        Size = UDim2.new(0, 100, 0, 20),
                        Position = UDim2.new(0.5, 0, 1, 10),
                        Text = "I already paid.",
                        TextColor3 = Enum.StudioStyleGuideColor.DialogMainButtonText,
                    }),
                },
            }),
        },
    })

    --Wait for the message to be acknowledged.
    local CloseButton = Message:WaitForChild("BodyText"):WaitForChild("CloseButton") :: TextButton
    CloseButton.MouseButton1Down:Wait()
    Message:Destroy()
    Plugin:SetSetting(UNPAID_VERSION_IGNORE_SETTING_NAME, os.time())
end