--Tests a test window view.
--!strict

local BUTTON_ICONS = "rbxassetid://4734758315"
local BUTTON_SIZE = Vector2.new(512, 512)

local CreateFusionScope = require(script.Parent.Parent:WaitForChild("NexusPluginComponents"):WaitForChild("CreateFusionScope"))
local Fusion = require(script.Parent.Parent:WaitForChild("NexusPluginComponents"):WaitForChild("Fusion"))
local CreateTestIcon = require(script.Parent:WaitForChild("CreateTestIcon"))
local CreateTestList = require(script.Parent:WaitForChild("CreateTestList"))
local TestSelectionListEntry = require(script.Parent:WaitForChild("TestSelectionListEntry"))

local Children = Fusion.Children
local OnEvent = Fusion.OnEvent

return function(Scope: CreateFusionScope.FusionScope, ListEntry: TestSelectionListEntry.TestSelectionListEntry): Frame
    --Create the value for having tests.
    local TotalTests = Scope:Value(#ListEntry.Test.ChildTests)
    table.insert(Scope, ListEntry.Test.TestAdded:Connect(function()
        TotalTests:set(#ListEntry.Test.ChildTests)
    end))
    table.insert(Scope, ListEntry.Test.TestRemoved:Connect(function()
        TotalTests:set(#ListEntry.Test.ChildTests)
    end))

    --Create and return the view.
    return Scope:Create("Frame")({
        Size = UDim2.new(1, 0, 1, 0),
        [Children] = {
            --Side buttons.
            Scope:Create("Frame")({
                BorderSizePixel = 1,
                Size = UDim2.new(0, 28, 1, 0),
                [Children] = {
                    --Run all tests button.
                    Scope:Create("ImageButton")({
                        BackgroundColor3 = Enum.StudioStyleGuideColor.MainBackground,
                        BorderSizePixel = 0,
                        Size = UDim2.new(0, 14, 0, 14),
                        Position = UDim2.new(0, 7, 0, 7),
                        Image = BUTTON_ICONS,
                        ImageRectSize  = BUTTON_SIZE,
                        ImageColor3 = Color3.fromRGB(0, 170, 0),
                        [OnEvent("MouseButton1Down")] = function()
                            --TODO: Run all tests.
                        end,
                    }),

                    --Run failed tests button.
                    Scope:Create("ImageButton")({
                        BackgroundColor3 = Enum.StudioStyleGuideColor.MainBackground,
                        BorderSizePixel = 0,
                        Size = UDim2.new(0, 14, 0, 14),
                        Position = UDim2.new(0, 7, 0, 32),
                        Image = BUTTON_ICONS,
                        ImageRectSize  = BUTTON_SIZE,
                        ImageColor3 = Color3.fromRGB(0, 170, 0),
                        [OnEvent("MouseButton1Down")] = function()
                            --TODO: Run failed tests.
                        end,
                        [Children] = {
                            Scope:Create("ImageLabel")({
                                Size = UDim2.new(0.5, 0, 0.5, 0),
                                Position = UDim2.new(0.5, 0, 0.5, 0),
                                BackgroundTransparency = 1,
                                Image = BUTTON_ICONS,
                                ImageColor3 = Color3.fromRGB(200, 0, 0),
                                ImageRectSize = BUTTON_SIZE,
                                ImageRectOffset = Vector2.new(512, 0),
                            }),
                        },
                    }),

                    --Run selected tests button.
                    Scope:Create("ImageButton")({
                        BackgroundColor3 = Enum.StudioStyleGuideColor.MainBackground,
                        BorderSizePixel = 0,
                        Size = UDim2.new(0, 14, 0, 14),
                        Position = UDim2.new(0, 7, 0, 57),
                        Image = BUTTON_ICONS,
                        ImageRectSize  = BUTTON_SIZE,
                        ImageColor3 = Color3.fromRGB(0, 170, 0),
                        [OnEvent("MouseButton1Down")] = function()
                            --TODO: Run selected tests.
                        end,
                        [Children] = {
                            Scope:Create("ImageLabel")({
                                Size = UDim2.new(0.5, 0, 0.5, 0),
                                Position = UDim2.new(0.5, 0, 0.5, 0),
                                BackgroundTransparency = 1,
                                Image = BUTTON_ICONS,
                                ImageColor3 = Color3.fromRGB(0, 170, 255),
                                ImageRectSize = BUTTON_SIZE,
                                ImageRectOffset = Vector2.new(0, 512),
                            }),
                        },
                    }),
                },
            }),

            --No tests text.
            Scope:Create("TextLabel")({
                Size = UDim2.new(1, -32, 0, 16),
                Position = UDim2.new(0, 31, 0, 2),
                Visible = Scope:Computed(function(use)
                    return use(TotalTests) == 0
                end),
                Font = Enum.Font.SourceSansItalic,
                Text = "No tests found. Make sure test ModuleScripts end in .spec.",
            }),

            --Test list.
            CreateTestList(Scope, ListEntry),

            --Status bar.
            Scope:Create("Frame")({
                BorderSizePixel = 1,
                Size = UDim2.new(1, -29, 0, 28),
                Position = UDim2.new(0, 29, 1, -28),
                [Children] = {
                    --Combined test state.
                    --TODO: Read test state.
                    Scope:Hydrate(CreateTestIcon(Scope, "NOT_RUN", "NORMAL"))({
                        Size = UDim2.new(0, 16, 0, 16),
                        Position = UDim2.new(0, 6, 0, 6),
                    }),

                    --Test bar.
                    --TODO: Fill with contents.
                    Scope:Create("Frame")({
                        Size = UDim2.new(1, -32, 0, 6),
                        Position = UDim2.new(0, 30, 0, 2),
                        BorderSizePixel = 1,
                    }),

                    --Test totals and run time.
                    --TODO: Fill with contents.
                    Scope:Create("TextLabel")({
                        Size = UDim2.new(1, -32, 0, 16),
                        Position = UDim2.new(0, 30, 0, 10),
                        Text = "Not run",
                        RichText = true,
                    }),
                },
            })
        },
    }) :: Frame
end