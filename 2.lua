local ffi = require("ffi")

ffi.cdef[[
    typedef int BOOL;
    typedef unsigned char BYTE;
    typedef unsigned long DWORD;
    typedef long LONG;
    typedef unsigned long ULONG_PTR;  // Added this line
    typedef struct tagPOINT {
        LONG x;
        LONG y;
    } POINT, *PPOINT;

    BOOL GetAsyncKeyState(int vKey);
    void mouse_event(DWORD dwFlags, DWORD dx, DWORD dy, DWORD dwData, ULONG_PTR dwExtraInfo);
    void keybd_event(BYTE bVk, BYTE bScan, DWORD dwFlags, ULONG_PTR dwExtraInfo);

    static const int VK_MBUTTON = 0x04;
    static const int VK_2 = 0x32;  // Virtual key code for '2'
    static const int VK_3 = 0x33;  // Virtual key code for '3'
    static const DWORD KEYEVENTF_KEYUP = 0x0002;
    static const DWORD MOUSEEVENTF_RIGHTDOWN = 0x0008;
    static const DWORD MOUSEEVENTF_RIGHTUP = 0x0010;
    static const DWORD MOUSEEVENTF_LEFTDOWN = 0x0002;
    static const DWORD MOUSEEVENTF_LEFTUP = 0x0004;
]]

local function sleep(ms)
    local start = os.clock()
    while os.clock() - start < ms / 1000 do end
end

local function sendKey(key, down)
    local vkCode
    if key == "2" then
        vkCode = ffi.C.VK_2
    elseif key == "3" then
        vkCode = ffi.C.VK_3
    else
        return
    end

    if down then
        ffi.C.keybd_event(vkCode, 0, 0, 0)
    else
        ffi.C.keybd_event(vkCode, 0, ffi.C.KEYEVENTF_KEYUP, 0)
    end
end

local function clickButton(button, duration)
    if button == "right" then
        ffi.C.mouse_event(ffi.C.MOUSEEVENTF_RIGHTDOWN, 0, 0, 0, 0)
        sleep(duration)
        ffi.C.mouse_event(ffi.C.MOUSEEVENTF_RIGHTUP, 0, 0, 0, 0)
    elseif button == "left" then
        ffi.C.mouse_event(ffi.C.MOUSEEVENTF_LEFTDOWN, 0, 0, 0, 0)
        sleep(duration)
        ffi.C.mouse_event(ffi.C.MOUSEEVENTF_LEFTUP, 0, 0, 0, 0)
    end
end

local function isMButtonPressed()
    return ffi.C.GetAsyncKeyState(ffi.C.VK_MBUTTON) ~= 0
end

local function onMButtonAction()
    -- On Press Sequence
    sendKey("2", true)
    sleep(1)
    sendKey("2", false)
    clickButton("right", 30) -- Faster right-click duration
    sleep(30)
    sendKey("3", true)
    sleep(1)
    sendKey("3", false)
    sleep(1)
    clickButton("right", 30) -- Right-click after releasing "3"
    sleep(30)
    clickButton("left", 30) -- Left-click after right-click
    sleep(1)
end

local function onMButtonHold()
    -- While Holding
    while isMButtonPressed() do
        clickButton("right", 30) -- Faster right-click duration
        sleep(30)
        clickButton("left", 30) -- Faster left-click duration
        sleep(10)
    end
end

-- Main loop to check for middle mouse button press
local wasMButtonPressed = false
while true do
    local isPressed = isMButtonPressed()
    if isPressed and not wasMButtonPressed then
        onMButtonAction()
        wasMButtonPressed = true
        onMButtonHold()
    elseif not isPressed and wasMButtonPressed then
        wasMButtonPressed = false
        print("Middle mouse button released, resetting state")
    end
    sleep(1)  -- Check every 1ms for more responsiveness
end