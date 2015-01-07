local function SingleStandardJump(e)
    local component = {}
	component.step   = 1
	component.def    = e.moveDef.jumpImp
	component.action = e.action
    return component
end

local function TrivialJump(e)
    local component = {}
	component.def  = e.moveDef
    return component
end

local function StateMachineJump(e)
    local component = TrivialJump(e)
    component.state = "state_1"
    return component
end

local Jumps = {}
Jumps.SpaceJump          = StateMachineJump
Jumps.SingleStandardJump = SingleStandardJump
Jumps.DoubleStandardJump = TrivialJump
Jumps.WallStandardJump   = TrivialJump
Jumps.BounceStandardJump = TrivialJump
Jumps.FalconJump         = StateMachineJump
Jumps.KirbyJump          = StateMachineJump
Jumps.TeleportJump       = StateMachineJump
Jumps.PeachJump          = StateMachineJump
Jumps.DixieJump          = StateMachineJump
return Jumps