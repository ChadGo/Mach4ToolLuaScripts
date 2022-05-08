local DefaultXSlide = 87
local DefaultYSlide = 92
local DefaultZBump = 93

local Tools = 
{
    {
        X = 1.000,
        Y = 20.000,
        Z = -3.000,
        XSlide = 5,
        YSlide = 6,
        ZBump = 9
    },
    {
        X = 1.000, Y = 20.000, Z = -3.000
    }
}

local CurrentTool = 2

if(CurrentTool > table.getn(Tools)) then 
  print('error')
end

local XPos = 0.0
local YPos = 0.0
local ZPos = 0.0

XPos = Tools[CurrentTool].X;
YPos = Tools[CurrentTool].Y;
ZPos = Tools[CurrentTool].Z;
XSlide = Tools[CurrentTool].XSlide;
YSlide = Tools[CurrentTool].YSlide;
ZBump = Tools[CurrentTool].ZBump;

if XSlide == nil then XSlide = DefaultXSlide end
if YSlide == nil then YSlide = DefaultYSlide end
if ZBump == nil then ZBump = DefaultZBump end

print(XPos)
print(YPos)
print(ZPos)
print(XSlide)
print(YSlide)
print(ZBump)

