--Tests a test window view.
--!strict

local BUTTON_ICONS = "rbxassetid://4734758315"
local BUTTON_SIZE = Vector2.new(512, 512)

local CreateFusionScope = require(script.Parent.Parent:WaitForChild("NexusPluginComponents"):WaitForChild("CreateFusionScope"))
local Fusion = require(script.Parent.Parent:WaitForChild("NexusPluginComponents"):WaitForChild("Fusion"))
local SecondaryTextFormatter = require(script.Parent.Parent:WaitForChild("Util"):WaitForChild("SecondaryTextFormatter"))
local TestRunner = require(script.Parent.Parent:WaitForChild("TestRunner"))
local CreateTestIcon = require(script.Parent:WaitForChild("CreateTestIcon"))
local CreateTestList = require(script.Parent:WaitForChild("CreateTestList"))
local TestSummary = require(script.Parent:WaitForChild("TestSummary"))

local Children = Fusion.Children
local OnEvent = Fusion.OnEvent

return function(Scope: CreateFusionScope.FusionScope, TestRunner: TestRunner.TestRunner): Frame
    --Create the value for having tests.
    local ListEntry = TestRunner.ListEntry
    local TotalTests = Scope:Value(#ListEntry.Test.ChildTests)
    table.insert(Scope, ListEntry.Test.TestAdded:Connect(function()
        TotalTests:set(#ListEntry.Test.ChildTests)
    end))
    table.insert(Scope, ListEntry.Test.TestRemoved:Connect(function()
        TotalTests:set(#ListEntry.Test.ChildTests)
    end))

    --Create the test summary.
    local EntryTestSummary = TestSummary.new(Scope, ListEntry.Test)
    local SummaryDisplayState = Scope:Computed(function(use)
        local CurrentPassedTests = use(EntryTestSummary.PassedTests)
        local CurrentSkippedTests = use(EntryTestSummary.SkippedTests)
        local CurrentFailedTests = use(EntryTestSummary.FailedTests)
        if CurrentFailedTests > 0 then
            return "FAILED"
        elseif CurrentPassedTests > 0 then
            return "PASSED"
        elseif CurrentSkippedTests > 0 then
            return "SKIPPED"
        end
        return "NOT_RUN"
    end)
    local SummaryPrimaryText = Scope:Computed(function(use)
        --Return if the tests weren't run yet.
        local CurrentLastTestRunTime = use(TestRunner.LastTestRunTime)
        if not CurrentLastTestRunTime then
            return "Not run"
        end

        --Build the summary.
        return `{use(EntryTestSummary.PassedTests)} passed, {use(EntryTestSummary.FailedTests)} failed, {use(EntryTestSummary.SkippedTests)} skipped ({use(EntryTestSummary.TotalTests)} total)`
    end)
    local SummarySecondaryText = Scope:Computed(function(use): string?
        local CurrentLastTestRunTime = use(TestRunner.LastTestRunTime)
        if not CurrentLastTestRunTime then return nil end
        return `Started at {CurrentLastTestRunTime:FormatLocalTime("LTS", "en-us")}`
    end)

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
                            TestRunner:RunTestsForGroup("ALL")
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
                            TestRunner:RunTestsForGroup("FAILED")
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
                            TestRunner:RunTestsForGroup("SELECTED")
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
                    Scope:Hydrate(CreateTestIcon(Scope, SummaryDisplayState :: any, "NORMAL"))({
                        Size = UDim2.new(0, 16, 0, 16),
                        Position = UDim2.new(0, 6, 0, 6),
                    }),

                    --Test bar.
                    Scope:Create("Frame")({
                        Size = UDim2.new(1, -32, 0, 6),
                        Position = UDim2.new(0, 30, 0, 2),
                        BorderSizePixel = 1,
                        [Children] = {
                            --Passed tests.
                            Scope:Create("Frame")({
                                Size = Scope:Computed(function(use)
                                    local TotalTests = math.max(1, use(EntryTestSummary.TotalTests))
                                    return UDim2.new(use(EntryTestSummary.PassedTests) / TotalTests, 0, 1, 0)
                                end),
                                BorderSizePixel = 0,
                                BackgroundColor3 = Color3.fromRGB(0, 200, 0),
                            }),

                            --Skipped tests.
                            Scope:Create("Frame")({
                                Size = Scope:Computed(function(use)
                                    local TotalTests = math.max(1, use(EntryTestSummary.TotalTests))
                                    return UDim2.new(use(EntryTestSummary.SkippedTests) / TotalTests, 0, 1, 0)
                                end),
                                Position = Scope:Computed(function(use)
                                    local TotalTests = math.max(1, use(EntryTestSummary.TotalTests))
                                    return UDim2.new(use(EntryTestSummary.PassedTests) / TotalTests, 0, 0, 0)
                                end),
                                BorderSizePixel = 0,
                                BackgroundColor3 = Color3.fromRGB(200, 200, 0),
                            }),

                            --Failed tests.
                            Scope:Create("Frame")({
                                Size = Scope:Computed(function(use)
                                    local TotalTests = math.max(1, use(EntryTestSummary.TotalTests))
                                    return UDim2.new(use(EntryTestSummary.FailedTests) / TotalTests, 0, 1, 0)
                                end),
                                Position = Scope:Computed(function(use)
                                    local TotalTests = math.max(1, use(EntryTestSummary.TotalTests))
                                    return UDim2.new((use(EntryTestSummary.PassedTests) + use(EntryTestSummary.SkippedTests)) / TotalTests, 0, 0, 0)
                                end),
                                BorderSizePixel = 0,
                                BackgroundColor3 = Color3.fromRGB(200, 0, 0),
                            }),
                        },
                    }),

                    --Test totals and run time.
                    Scope:Create("TextLabel")({
                        Size = UDim2.new(1, -32, 0, 16),
                        Position = UDim2.new(0, 30, 0, 10),
                        Text = SecondaryTextFormatter(Scope, SummaryPrimaryText, SummarySecondaryText),
                        RichText = true,
                    }),
                },
            })
        },
    }) :: Frame
end