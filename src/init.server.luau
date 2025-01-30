--Runs the Avant plugin.
--!strict

local ModuleScriptDiscovery = require(script:WaitForChild("AvantRuntime"):WaitForChild("State"):WaitForChild("Discovery"):WaitForChild("ModuleScriptDiscovery"))
local CreatePluginToggleButton = require(script:WaitForChild("NexusPluginComponents"):WaitForChild("Input"):WaitForChild("Plugin"):WaitForChild("CreatePluginToggleButton"))
local CreateFusionScope = require(script:WaitForChild("NexusPluginComponents"):WaitForChild("CreateFusionScope"))
local CreateOutputWindow = require(script:WaitForChild("OutputView"):WaitForChild("CreateOutputWindow"))
local CreateTestListWindow = require(script:WaitForChild("TestView"):WaitForChild("CreateTestListWindow"))
local TestSelectionListEntry = require(script:WaitForChild("TestView"):WaitForChild("TestSelectionListEntry"))
local TestRunner = require(script:WaitForChild("TestRunner"))



--Start the ModuleScript test tracking.
local GameModuleScriptDiscovery = ModuleScriptDiscovery.new(game)
local Scope = CreateFusionScope()
local TestListEntry = TestSelectionListEntry.new(Scope, GameModuleScriptDiscovery.RootTest)
local ModuleTestRunner = TestRunner.new(Scope, TestListEntry)

--Create the windows.
local TestListWindow = CreateTestListWindow(plugin, Scope, ModuleTestRunner)
CreateOutputWindow(plugin, Scope, ModuleTestRunner)

--Create the button.
local AvantToolbar = plugin:CreateToolbar("Avant")
local UnitTestsButton = AvantToolbar:CreateButton("Unit Tests", "Opens the Avant Unit Test window", "rbxassetid://4734891702") --TODO: Replace icon.
local UnitTestsToggleButton = CreatePluginToggleButton(UnitTestsButton, TestListWindow)
UnitTestsToggleButton.ClickableWhenViewportHidden = true

--Create the actions.
--TODO: Replace icons.
plugin:CreatePluginAction("Avant_RunAllTests", "Run Unit Tests", "Runs all the unit tests in the game.\nPart of Avant.", "rbxassetid://4734926678").Triggered:Connect(function()
    TestListWindow.Enabled = true
    ModuleTestRunner:RunTestsForGroup("ALL")
end)
plugin:CreatePluginAction("Avant_RunFailedTests", "Run Failed Unit Tests", "Runs the failed unit tests from the last run.\nPart of Avant.", "rbxassetid://4734926820").Triggered:Connect(function()
    TestListWindow.Enabled = true
    ModuleTestRunner:RunTestsForGroup("FAILED")
end)
plugin:CreatePluginAction("Avant_RunSelectedTests", "Run Selected Unit Tests", "Runs the selected unit tests from the last run.\nPart of Avant.", "rbxassetid://4734926979").Triggered:Connect(function()
    TestListWindow.Enabled = true
    ModuleTestRunner:RunTestsForGroup("SELECTED")
end)