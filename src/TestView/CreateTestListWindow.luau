--Creates a window for the test list.
--!strict

local CreateFusionScope = require(script.Parent.Parent:WaitForChild("NexusPluginComponents"):WaitForChild("CreateFusionScope"))
local TestRunner = require(script.Parent.Parent:WaitForChild("TestRunner"))
local CreateTestView = require(script.Parent:WaitForChild("CreateTestView"))
local DisplayPaidVersionMessage = require(script.Parent:WaitForChild("DisplayPaidVersionMessage"))

return function(Plugin: Plugin, Scope: CreateFusionScope.FusionScope, TestRunner: TestRunner.TestRunner): DockWidgetPluginGui
    --Create the window.
    local Window = Plugin:CreateDockWidgetPluginGui("Unit Tests", DockWidgetPluginGuiInfo.new(Enum.InitialDockState.Bottom, false, false, 300, 200, 200, 100))
    Window.Title = "Unit Tests"
    Window.Name = "Unit Tests"

    --Create the view.
    task.spawn(function()
        --Wait for the window to be opened.
        while not Window.Enabled do
            Window:GetPropertyChangedSignal("Enabled"):Wait()
        end

        --Display the paid version information.
        DisplayPaidVersionMessage(Scope, Plugin, Window)

        --Create the view.
        Scope:Hydrate(CreateTestView(Scope, TestRunner))({
            Parent = Window,
        })
    end)

    --Return the Window.
    return Window
end