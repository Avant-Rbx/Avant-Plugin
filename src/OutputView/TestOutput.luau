--Manages the output of a test.
--!strict

local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService")

local AvantRuntime = require(script.Parent.Parent:WaitForChild("Packages"):WaitForChild("AvantRuntime"))
local NexusPluginComponents = require(script.Parent.Parent:WaitForChild("Packages"):WaitForChild("NexusPluginComponents"))
local OutputListEntry = require(script.Parent:WaitForChild("OutputListEntry"))

local FormatLines = AvantRuntime.FormatLines
local Fusion = NexusPluginComponents.Fusion

local TestOutput = {}
TestOutput.__index = TestOutput

export type TestOutput = {
    Lines: {OutputListEntry.OutputData},
    MaxLineWidth: NexusPluginComponents.Value<number>,
    Output: NexusPluginComponents.Value<{OutputListEntry.OutputData}>,
    UpdateQueued: boolean,
    UpdateImmediately: boolean,
    EventConnections: {RBXScriptConnection},
} & typeof(setmetatable({}, TestOutput))



--[[
Creates a test output.
--]]
function TestOutput.new(Scope: NexusPluginComponents.FusionScope, Test: NexusPluginComponents.UsedAs<AvantRuntime.Test?>): TestOutput
    --Create the object.
    local self = setmetatable({
        Lines = {},
        MaxLineWidth = Scope:Value(0),
        Output = Scope:Value({}),
        UpdateQueued = false,
        UpdateImmediately = false,
        EventConnections = {},
    }, TestOutput) :: TestOutput

    --Connect the test changing.
    Scope:Observer(Test):onBind(function()
        self:LoadForTest(Fusion.peek(Test))
    end)

    --Return the object.
    return self
end

--[[
Loads the output from a test.
--]]
function TestOutput.LoadForTest(self: TestOutput, Test: AvantRuntime.Test?): ()
    --Clear the existing events.
    for _, EventConnection in self.EventConnections do
        EventConnection:Disconnect()
    end
    self.Lines = {}
    self.MaxLineWidth:set(0)
    self.EventConnections = {}
    if not Test then
        self:QueueUpdateLines()
        return
    end

    --Connect the log events.
    table.insert(self.EventConnections, Test.OutputAdded:Connect(function(Contents)
        for _, Line in FormatLines(Contents.Contents, Contents.ContentsSize) do
            self:AddOutput(Contents.MessageType, Line)
        end
        self:QueueUpdateLines()
    end) :: any)
    table.insert(self.EventConnections, Test.OutputCleared:Connect(function()
        self.Lines = {}
        self.MaxLineWidth:set(0)
        self:QueueUpdateLines()
    end) :: any)

    --Store the initial logs.
    for _, Contents in Test.Output do
        for _, Line in FormatLines(Contents.Contents, Contents.ContentsSize) do
            self:AddOutput(Contents.MessageType, Line)
        end
    end
    self:QueueUpdateLines()
end

--[[
Adds a line.
Does not update values.
--]]
function TestOutput.AddOutput(self: TestOutput, MessageType: Enum.MessageType, Text: string): ()
    --Add the line.
    table.insert(self.Lines, {
        MessageType = MessageType,
        Text = Text,
    })

    --Update the max width.
    local CurrentMaxWidth = Fusion.peek(self.MaxLineWidth)
    local NewMaxWidth = TextService:GetTextSize(Text, 14, Enum.Font.SourceSans, Vector2.new(1000000, 14)).X
    if NewMaxWidth > CurrentMaxWidth then
        self.MaxLineWidth:set(NewMaxWidth)
    end
end

--[[
Queues updating the displayed lines for the next frame.
This is meant to reduce frequent reloads with new output.
--]]
function TestOutput.QueueUpdateLines(self: TestOutput): ()
    if self.UpdateImmediately then
        self:UpdateLines()
    end
    if self.UpdateQueued then return end
    self.UpdateQueued = true
    RunService.Heartbeat:Once(function()
        self.UpdateQueued = false
        self:UpdateLines()
    end)
end

--[[
Updates the displayed lines.
--]]
function TestOutput.UpdateLines(self: TestOutput): ()
    if #self.Lines == 0 then
        self.Output:set({
            {
                Text = "No output.",
            },
        })
    else
        self.Output:set(self.Lines)
    end
end

--[[
Destroys the test output.
--]]
function TestOutput.Destroy(self: TestOutput): ()
    for _, EventConnection in self.EventConnections do
        EventConnection:Disconnect()
    end
    self.EventConnections = {}
end



return TestOutput