--Creates an icon for a test.
--!strict

local TEST_ICON_SPRITESHEET = "rbxassetid://4595118527"
local ICON_SIZE = Vector2.new(256, 256)
local ICON_POSITIONS = {
    NOT_RUN = Vector2.new(0, 0),
    IN_PROGRESS = Vector2.new(256, 0),
    PASSED = Vector2.new(512, 0),
    FAILED = Vector2.new(768, 0),
    SKIPPED = Vector2.new(0, 256),
}
local ICON_COLORS = {
    NOT_RUN = Color3.fromRGB(0, 170, 255),
    IN_PROGRESS = Color3.fromRGB(255, 150, 0),
    PASSED = Color3.fromRGB(0, 200, 0),
    FAILED = Color3.fromRGB(200, 0, 0),
    SKIPPED = Color3.fromRGB(220, 220, 0),
}
local CONTENTS_COLORS = {
    NORMAL = Color3.fromRGB(0, 0, 0), --Unused; will be hidden.
    UPDATED = Color3.fromRGB(200, 160, 0),
    MISSING = Color3.fromRGB(200, 50, 0),
}

local Test = require(script.Parent.Parent:WaitForChild("AvantRuntime"):WaitForChild("State"):WaitForChild("Test"):WaitForChild("Test"))
local CreateFusionScope = require(script.Parent.Parent:WaitForChild("NexusPluginComponents"):WaitForChild("CreateFusionScope"))
local Fusion = require(script.Parent.Parent:WaitForChild("NexusPluginComponents"):WaitForChild("Fusion"))

local Children = Fusion.Children

return function(Scope: CreateFusionScope.FusionScope, State: Fusion.UsedAs<Test.TestState>, ContentsState: Fusion.UsedAs<Test.TestContentsState>, HasOutput: Fusion.UsedAs<boolean>?): ImageLabel
    return Scope:Create("ImageLabel")({
        Name = "TestState",
        BackgroundTransparency = 1,
        Image = TEST_ICON_SPRITESHEET,
        ImageColor3 = Scope:Computed(function(use)
            return ICON_COLORS[use(State)]
        end),
        ImageRectSize = ICON_SIZE,
        ImageRectOffset  = Scope:Computed(function(use)
            return ICON_POSITIONS[use(State)]
        end),
        [Children] = {
            --Contents indicator.
            Scope:Create("Frame")({
                Name = "ContentState",
                BackgroundColor3 = Scope:Computed(function(use)
                    return CONTENTS_COLORS[use(ContentsState)]
                end),
                Size = UDim2.new(0.45, 0, 0.45, 0),
                Position = UDim2.new(0, 0, 0.55, 0),
                Visible = Scope:Computed(function(use)
                    return use(ContentsState) ~= "NORMAL"
                end),
                [Children] = {
                    Scope:Create("UICorner")({
                        CornerRadius = UDim.new(0.5, 0),
                    }),
                },
            }),

            --Output indicator.
            Scope:Create("Frame")({
                Name = "OutputState",
                BackgroundColor3 = Color3.fromRGB(0, 170, 255),
                Size = UDim2.new(0.45, 0, 0.45, 0),
                Position = UDim2.new(0.55, 0, 0.55, 0),
                Visible = HasOutput or false,
                [Children] = {
                    Scope:Create("UICorner")({
                        CornerRadius = UDim.new(0.5, 0),
                    }),
                },
            }),
        },
    }) :: ImageLabel
end