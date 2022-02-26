function m6()
    local inst = mc.mcGetInstance()
    mc.mcCntlSetLastError(inst, "Tool change in progress again")

    ------ Get and compare next and current tools ------
    local SelectedTool = mc.mcToolGetSelected(inst)
    local CurrentTool = mc.mcToolGetCurrent(inst)
    if (SelectedTool == CurrentTool) then
        mc.mcCntlSetLastError(inst, "Next tool = Current tool")
        do
            return
        end
    end

    mc.mcCntlSetLastError(inst, "Break 0")

    ------ Define slide distance and direction ------
    ------ Only 1 of these should have a non-zero value -----
    ------ Changing from a positive to negative slide value, or vice-versa, will change the direction that the tool slides into the tool fork -----
    local XSlide = 0.00
    local YSlide = 2.00
    local dwell = 5.00

    ------- Declare Position Variables ------
    local XPos = 0
    local YPos = 0
    local ZPos = 0

    ------ For spindles that have a partial tool push out, define the amount of movement here -----
    local ZBump = 0.100

    ------ Define the OUTPUT# for the drawbar signal -----
    local DrawBarOut = mc.OSIG_OUTPUT6

    ------ Get current state ------
    local CurFeed = mc.mcCntlGetPoundVar(inst, 2134)
    local CurFeedMode = mc.mcCntlGetPoundVar(inst, 4001)
    local CurAbsMode = mc.mcCntlGetPoundVar(inst, 4003)

    ------ Turn off spindle and wait for decel -------
    local GCode = ""
    GCode = GCode .. "M5\n"
    GCode = GCode .. string.format("G04 P%.4f\n", dwell)
    mc.mcCntlGcodeExecuteWait(inst, GCode)

    ------ Move to current tool change position ------
    local tool = CurrentTool

    --You will need to enter the tool position below.
    --Once you enter them, copy and paste the area defined
    --below to the second set of positions further down in
    --the script.  The two sets of tool positions must match
    --exactly, or unexpected motion will occur!!!

    -----------------Copy Start-------------------
    ----- Define Tool Postions ------
    --Tool 1--
    if tool == 1 then
        --Tool 2--
        XPos = 1.000
        YPos = 20.000
        ZPos = -3.000
    elseif tool == 2 then
        --Tool 3--
        XPos = 2.000
        YPos = 20.000
        ZPos = -3.000
    elseif tool == 3 then
        --Copy and past this individual section to add more stations
        --to your tool rack
        --Tool 4--
        --elseif tool == 4 then
        --XPos = 4.000
        --YPos = 20.000
        --ZPos = -3.000
        ---------------Copy Stop------------------
        XPos = 3.000
        YPos = 20.000
        ZPos = -3.000
    else
        wx.wxMessageBox(
            "Invalid tool #. Cancelling tool change!\nYour requested tool will now be set as the current tool in the spindle.\n****Ensure that the tool station that you have selected is empty!****"
        )
        mc.mcToolSetCurrent(inst, SelectedTool)
        do
            return
        end
    end

    local GCode = ""
    GCode = GCode .. "G00 G90 G53 Z0.0\n" -- move to z home
    GCode = GCode .. string.format("G00 G90 G53 X%.4f Y%.4f\n", (XPos - XSlide), (YPos - YSlide)) -- move to the starting point of the slide
    GCode = GCode .. string.format("G00 G90 G53 Z%.4f\n", ZPos) -- move down to the level of the tool change
    GCode = GCode .. string.format("G00 G90 G53 X%.4f Y%.4f\n", XPos, YPos) -- slide in
    mc.mcCntlGcodeExecuteWait(inst, GCode)

    ------ Open drawbar ------

    local hsig = mc.mcSignalGetHandle(inst, DrawBarOut)
    mc.mcSignalSetState(hsig, 1)

    ------ Raise spindle, after releasing tool ------
    GCode = ""
    GCode = GCode .. string.format("G01 G90 G53 Z0.00 F50.0\n")
    mc.mcCntlGcodeExecuteWait(inst, GCode)

    ------ Move to next tool change position ------
    tool = SelectedTool

    -----------------Copy Start-------------------
    ----- Define Tool Postions ------
    --Tool 1--
    if tool == 1 then
        --Tool 4--
        XPos = 1.000
        YPos = 20.000
        ZPos = -3.000
    elseif tool == 2 then
        --Tool 3--
        XPos = 2.000
        YPos = 20.000
        ZPos = -3.000
    elseif tool == 3 then
        --Copy and past this individual section to add more stations
        --to your tool rack
        --Tool 4--
        --elseif tool == 4 then
        --XPos = 4.000
        --YPos = 20.000
        --ZPos = -3.000
        ---------------Copy Stop------------------
        XPos = 3.000
        YPos = 20.000
        ZPos = -3.000
    else
        wx.wxMessageBox("Invalid tool #.  Retrieving previous tool!")
        SelectedTool = CurrentTool
    end

    GCode = ""
    GCode = GCode .. string.format("G00 G90 G53 X%.4f Y%.4f\n", XPos, YPos) -- move over the selected tool
    GCode = GCode .. string.format("G00 G90 G53 Z%.4f\n", ZPos + ZBump) -- lower onto the tool with added bump.
    mc.mcCntlGcodeExecuteWait(inst, GCode)

    ------ Clamp drawbar ------
    mc.mcSignalSetState(hsig, 0)

    GCode = ""
    GCode = GCode .. string.format("G01 G90 G53 Z%.4f F50.0\n", ZPos) -- release bump
    GCode = GCode .. string.format("G00 G90 G53 X%.4f Y%.4f\n", (XPos - XSlide), (YPos - YSlide)) -- slide out
    mc.mcCntlGcodeExecuteWait(inst, GCode)

    ------ Move Z to home position ------
    GCode = ""
    mc.mcCntlGcodeExecuteWait(inst, "G00 G90 G53 Z0.0\n") -- raise back up to z home

    ------ Reset state ------
    mc.mcCntlSetPoundVar(inst, 2134, CurFeed)
    mc.mcCntlSetPoundVar(inst, 4001, CurFeedMode)
    mc.mcCntlSetPoundVar(inst, 4003, CurAbsMode)

    ------ Set new tool ------
    mc.mcToolSetCurrent(inst, SelectedTool)
    mc.mcCntlSetLastError(inst, string.format("Tool change - Tool: %.0f", SelectedTool))
end
