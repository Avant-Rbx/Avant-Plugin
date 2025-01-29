--Manages the output of a test.
--!strict

local Test = require(script.Parent.Parent:WaitForChild("AvantRuntime"):WaitForChild("State"):WaitForChild("Test"):WaitForChild("Test"))
local FormatLines = require(script.Parent.Parent:WaitForChild("AvantRuntime"):WaitForChild("Util"):WaitForChild("FormatLines"))
local CreateFusionScope = require(script.Parent.Parent:WaitForChild("NexusPluginComponents"):WaitForChild("CreateFusionScope"))
local Fusion = require(script.Parent.Parent:WaitForChild("NexusPluginComponents"):WaitForChild("Fusion"))
local OutputListEntry = require(script.Parent:WaitForChild("OutputListEntry"))

local TestOutput = {}
TestOutput.__index = TestOutput

export type TestOutput = {
    Lines: {OutputListEntry.OutputData},
    Output: Fusion.Value<{OutputListEntry.OutputData}>,
    EventConnections: {RBXScriptConnection},
} & typeof(setmetatable({}, TestOutput))



--[[
Creates a test output.
--]]
function TestOutput.new(Scope: CreateFusionScope.FusionScope, Test: Fusion.UsedAs<Test.Test?>): TestOutput
    --Create the object.
    local self = setmetatable({
        Lines = {},
        Output = Scope:Value({}),
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
function TestOutput.LoadForTest(self: TestOutput, Test: Test.Test?): ()
    --Clear the existing events.
    for _, EventConnection in self.EventConnections do
        EventConnection:Disconnect()
    end
    self.EventConnections = {}
    if not Test then
        self:UpdateLines()
        return
    end

    --Connect the log events.
    table.insert(self.EventConnections, Test.OutputAdded:Connect(function(Contents)
        for _, Line in FormatLines(Contents.Contents, Contents.ContentsSize) do
            table.insert(self.Lines, {
                MessageType = Contents.MessageType,
                Text = Line,
            })
        end
        self:UpdateLines()
    end) :: any)
    table.insert(self.EventConnections, Test.OutputCleared:Connect(function()
        self.Lines = {}
        self:UpdateLines()
    end) :: any)

    --Store the initial logs.
    self.Lines = {}
    for _, Contents in Test.Output do
        for _, Line in FormatLines(Contents.Contents, Contents.ContentsSize) do
            table.insert(self.Lines, {
                MessageType = Contents.MessageType,
                Text = Line,
            })
        end
    end
    self:UpdateLines()
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