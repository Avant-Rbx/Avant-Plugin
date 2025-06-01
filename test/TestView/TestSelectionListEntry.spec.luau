--Tests TestSelectionListEntry.
--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local AvantRuntime = require(ReplicatedStorage.AvantPlugin.Packages.AvantRuntime)
local NexusPluginComponents = require(ReplicatedStorage.AvantPlugin.Packages.NexusPluginComponents)
local TestSelectionListEntry = require(ReplicatedStorage.AvantPlugin.TestView.TestSelectionListEntry)

local Test = AvantRuntime.Test
local CreateFusionScope = NexusPluginComponents.CreateFusionScope

return function()
    describe("A TestSelectionListEntry", function()
        local TestScope, TestTest1, TestTest2 = nil, nil, nil
        local TestTestSelectionListEntry = nil
        beforeEach(function()
            TestScope = CreateFusionScope()
            TestTest1 = Test.new()
            TestTest1.Name = "Test1"
            TestTest2 = TestTest1:CreateChildTest()
            TestTest2.Name = "Test2"

            TestTestSelectionListEntry = TestSelectionListEntry.new(TestScope, TestTest1)
        end)

        afterEach(function()
            TestScope:doCleanup()
            TestTest1:Destroy()
        end)

        it("should be set up existing child tests.", function()
            expect(TestTestSelectionListEntry.SortMethod).to.equal("Name")
            expect(#TestScope.peek(TestTestSelectionListEntry.Entry.Children)).to.equal(1)
            expect(TestTestSelectionListEntry.ChildEntries[TestTest2].SortMethod).to.equal("SortIndex")
            expect(#TestScope.peek(TestTestSelectionListEntry.ChildEntries[TestTest2].Entry.Children)).to.equal(0)
        end)

        it("should sort child tests by name.", function()
            local NewTest1 = TestTest1:CreateChildTest()
            NewTest1.Name = "Test3"
            local NewTest2 = TestTest1:CreateChildTest()
            NewTest2.Name = "Test4"
            task.wait()

            local CurrentChildren = TestScope.peek(TestTestSelectionListEntry.Entry.Children)
            expect(#CurrentChildren).to.equal(3)
            expect(TestScope.peek(CurrentChildren[1].Data)).to.equal(TestTest2)
            expect(TestScope.peek(CurrentChildren[2].Data)).to.equal(NewTest1)
            expect(TestScope.peek(CurrentChildren[3].Data)).to.equal(NewTest2)

            NewTest1.Name = "Test5"
            task.wait()
            expect(TestScope.peek(CurrentChildren[1].Data)).to.equal(TestTest2)
            expect(TestScope.peek(CurrentChildren[2].Data)).to.equal(NewTest2)
            expect(TestScope.peek(CurrentChildren[3].Data)).to.equal(NewTest1)
        end)

        it("should sort child tests by sort index.", function()
            local NewTest1 = TestTest2:CreateChildTest()
            NewTest1.SortIndex = 1
            local NewTest2 = TestTest2:CreateChildTest()
            NewTest2.SortIndex = 2
            local NewTest3 = TestTest2:CreateChildTest()
            NewTest3.SortIndex = 3
            task.wait()

            local CurrentChildren = TestScope.peek(TestTestSelectionListEntry.ChildEntries[TestTest2].Entry.Children)
            expect(#CurrentChildren).to.equal(3)
            expect(TestScope.peek(CurrentChildren[1].Data)).to.equal(NewTest1)
            expect(TestScope.peek(CurrentChildren[2].Data)).to.equal(NewTest2)
            expect(TestScope.peek(CurrentChildren[3].Data)).to.equal(NewTest3)

            NewTest2.SortIndex = 4
            task.wait()
            expect(TestScope.peek(CurrentChildren[1].Data)).to.equal(NewTest1)
            expect(TestScope.peek(CurrentChildren[2].Data)).to.equal(NewTest3)
            expect(TestScope.peek(CurrentChildren[3].Data)).to.equal(NewTest2)
        end)

        it("should not sort child tests by sort index when they are preparing for a new run.", function()
            local NewTest1 = TestTest2:CreateChildTest()
            NewTest1.SortIndex = 1
            local NewTest2 = TestTest2:CreateChildTest()
            NewTest2.SortIndex = 2
            local NewTest3 = TestTest2:CreateChildTest()
            NewTest3.SortIndex = 3
            task.wait()

            local CurrentChildren = TestScope.peek(TestTestSelectionListEntry.ChildEntries[TestTest2].Entry.Children)
            expect(#CurrentChildren).to.equal(3)
            expect(TestScope.peek(CurrentChildren[1].Data)).to.equal(NewTest1)
            expect(TestScope.peek(CurrentChildren[2].Data)).to.equal(NewTest2)
            expect(TestScope.peek(CurrentChildren[3].Data)).to.equal(NewTest3)

            NewTest2.SortIndex += 1000000
            task.wait()
            expect(TestScope.peek(CurrentChildren[1].Data)).to.equal(NewTest1)
            expect(TestScope.peek(CurrentChildren[2].Data)).to.equal(NewTest2)
            expect(TestScope.peek(CurrentChildren[3].Data)).to.equal(NewTest3)
        end)
    end)
end