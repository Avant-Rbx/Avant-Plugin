--Creates a view for an output of a test.
--!strict

local CreateFusionScope = require(script.Parent.Parent:WaitForChild("NexusPluginComponents"):WaitForChild("CreateFusionScope"))
local Fusion = require(script.Parent.Parent:WaitForChild("NexusPluginComponents"):WaitForChild("Fusion"))
local SecondaryTextFormatter = require(script.Parent.Parent:WaitForChild("Util"):WaitForChild("SecondaryTextFormatter"))
local TestRunner = require(script.Parent.Parent:WaitForChild("TestRunner"))
local CreateOutputList = require(script.Parent:WaitForChild("CreateOutputList"))

local Children = Fusion.Children

return function(Scope: CreateFusionScope.FusionScope, TestRunner: TestRunner.TestRunner): Frame
    --Create and return the view.
    local FocusedOutputTest = TestRunner.FocusedOutputTest
    return Scope:Create("Frame")({
        Size = UDim2.new(1, 0, 1, 0),
        [Children] = {
            --Test name.
            Scope:Create("Frame")({
                BorderSizePixel = 1,
                Size = UDim2.new(1, 0, 0, 21),
                [Children] = {
                    Scope:Create("TextLabel")({
                        Size = UDim2.new(1, -4, 0, 16),
                        Position = UDim2.new(0, 2, 0, 2),
                        Text = SecondaryTextFormatter(Scope, Scope:Computed(function(use)
                            local CurrentFocusedOutputTest = use(FocusedOutputTest)
                            return CurrentFocusedOutputTest and CurrentFocusedOutputTest.Name or "<i>No selected test</i>"
                        end)), --TODO: Show full test name in secondary text.
                        RichText = true,
                    }),
                },
            }),

            --Test output.
            CreateOutputList(Scope, TestRunner),
        },
    }) :: Frame
end