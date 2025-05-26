local ffi = require("ffi")

ffi.cdef[[
    typedef int BOOL;
    typedef unsigned char BYTE;
    typedef unsigned long DWORD;
    typedef long LONG;
    typedef unsigned long ULONG_PTR;
    typedef struct tagPOINT {
        LONG x;
        LONG y;
    } POINT, *PPOINT;

    BOOL GetAsyncKeyState(int vKey);
    void mouse_event(DWORD dwFlags, DWORD dx, DWORD dy, DWORD dwData, ULONG_PTR dwExtraInfo);
    void keybd_event(BYTE bVk, BYTE bScan, DWORD dwFlags, ULONG_PTR dwExtraInfo);

    static const int VK_MBUTTON = 0x04;
    static const int VK_PAGEDOWN = 0x22;
    static const int VK_4 = 0x34;
    static const int VK_5 = 0x35;
    static const int VK_R = 0x52;  // Virtual key code for 'R'
    static const DWORD KEYEVENTF_KEYUP = 0x0002;
    static const DWORD MOUSEEVENTF_RIGHTDOWN = 0x0008;
    static const DWORD MOUSEEVENTF_RIGHTUP = 0x0010;
    static const DWORD MOUSEEVENTF_LEFTDOWN = 0x0002;
    static const DWORD MOUSEEVENTF_LEFTUP = 0x0004;
    static const DWORD MOUSEEVENTF_XDOWN = 0x0080;
    static const DWORD MOUSEEVENTF_XUP = 0x0100;
]]

-- Virtual key code for 'X' (comment moved outside the ffi.cdef block)
local VK_X = 0x58

local function sleep(ms)
    local start = os.clock()
    while os.clock() - start < ms / 1000 do end
end

local function isKeyPressed(key)
    return ffi.C.GetAsyncKeyState(key) ~= 0
end

local function pressKey(key, down)
    if down then
        ffi.C.keybd_event(key, 0, 0, 0)
    else
        ffi.C.keybd_event(key, 0, ffi.C.KEYEVENTF_KEYUP, 0)
    end
end

local function clickMouse(button, down)
    if button == "right" then
        if down then
            ffi.C.mouse_event(ffi.C.MOUSEEVENTF_RIGHTDOWN, 0, 0, 0, 0)
        else
            ffi.C.mouse_event(ffi.C.MOUSEEVENTF_RIGHTUP, 0, 0, 0, 0)
        end
    elseif button == "left" then
        if down then
            ffi.C.mouse_event(ffi.C.MOUSEEVENTF_LEFTDOWN, 0, 0, 0, 0)
        else
            ffi.C.mouse_event(ffi.C.MOUSEEVENTF_LEFTUP, 0, 0, 0, 0)
        end
    elseif button == "mouse5" then
        if down then
            ffi.C.mouse_event(ffi.C.MOUSEEVENTF_XDOWN, 0, 0, 0x0002, 0)
        else
            ffi.C.mouse_event(ffi.C.MOUSEEVENTF_XUP, 0, 0, 0x0002, 0)
        end
    end
end

local function doubleAnchor()
    -- Your existing doubleAnchor sequence
    pressKey(ffi.C.VK_4, true)
    sleep(50)
    pressKey(ffi.C.VK_4, false)
    clickMouse("right", true)
    clickMouse("right", false)
    sleep(50)
    pressKey(ffi.C.VK_5, true)
    pressKey(ffi.C.VK_5, false)
    sleep(15, 25)
    clickMouse("right", true)
    clickMouse("right", false)
    sleep(50)
    pressKey(ffi.C.VK_4, true)
    pressKey(ffi.C.VK_4, false)
    sleep(50)
    clickMouse("right", true)
    clickMouse("right", false)
    clickMouse("right", true)
    clickMouse("right", false)
    sleep(50)
    pressKey(ffi.C.VK_5, true)
    sleep(15, 25)
    pressKey(ffi.C.VK_5, false)
    clickMouse("right", true)
    clickMouse("right", false)
    sleep(75)
    sleep(75, 85)
    clickMouse("left", true)
    clickMouse("left", false)
    sleep(30, 50)
    clickMouse("right", true)
    clickMouse("right", false)
    clickMouse("mouse5", true)  -- Changed back to mouse button 5
    clickMouse("mouse5", false)
    sleep(40, 65)
    clickMouse("right", true)
    sleep(40, 65)
    clickMouse("right", false)
end

-- Toggle state for the Page Down key
local toggleEnabled = false

-- Main loop to check for key presses
while true do
    -- Check for Page Down toggle
    if isKeyPressed(ffi.C.VK_PAGEDOWN) then
        toggleEnabled = not toggleEnabled
        print("Toggle state:", toggleEnabled and "Enabled" or "Disabled")
        -- Wait for the key to be released to avoid multiple toggles
        while isKeyPressed(ffi.C.VK_PAGEDOWN) do
            sleep(10)
        end
    end

    -- If toggle is enabled, check for the 'X' key press
    if toggleEnabled and isKeyPressed(VK_X) then
        doubleAnchor()
        -- Wait for the key to be released to avoid multiple triggers
        while isKeyPressed(VK_X) do
            sleep(10)
        end
    end

    sleep(10)  -- Check every 10ms for more responsiveness
end
