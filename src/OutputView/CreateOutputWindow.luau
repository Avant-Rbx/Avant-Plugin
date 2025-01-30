--Creates a window for the test output.
--!strict

local CreateFusionScope = require(script.Parent.Parent:WaitForChild("NexusPluginComponents"):WaitForChild("CreateFusionScope"))
local Fusion = require(script.Parent.Parent:WaitForChild("NexusPluginComponents"):WaitForChild("Fusion"))
local TestRunner = require(script.Parent.Parent:WaitForChild("TestRunner"))
local CreateOutputView = require(script.Parent:WaitForChild("CreateOutputView"))

return function(Plugin: Plugin, Scope: CreateFusionScope.FusionScope, TestRunner: TestRunner.TestRunner): DockWidgetPluginGui
    --Create the window.
    local Window = Plugin:CreateDockWidgetPluginGui("Test Output", DockWidgetPluginGuiInfo.new(Enum.InitialDockState.Bottom, false, false, 300, 200, 200, 100))
    Window.Title = "Test Output"
    Window.Name = "Test Output"

    --Create the view.
    task.spawn(function()
        --Wait for the window to be opened.
        while not Window.Enabled do
            Window:GetPropertyChangedSignal("Enabled"):Wait()
        end

        --Create the view.
        Scope:Hydrate(CreateOutputView(Scope, TestRunner))({
            Parent = Window,
        })
    end)

    --Open the window when a test is viewed.
    Scope:Observer(TestRunner.FocusedOutputTest):onBind(function()
        if not Fusion.peek(TestRunner.FocusedOutputTest) then return end
        Window.Enabled = true
    end)

    --Return the Window.
    return Window
end