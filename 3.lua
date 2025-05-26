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

    static const int VK_MENU = 0x12;  // Virtual key code for 'ALT'
    static const int VK_4 = 0x34;  // Virtual key code for '4'
    static const int VK_5 = 0x35;  // Virtual key code for '5'
    static const DWORD KEYEVENTF_KEYUP = 0x0002;
    static const DWORD MOUSEEVENTF_RIGHTDOWN = 0x0008;
    static const DWORD MOUSEEVENTF_RIGHTUP = 0x0010;
    static const DWORD MOUSEEVENTF_LEFTDOWN = 0x0002;
    static const DWORD MOUSEEVENTF_LEFTUP = 0x0004;
    static const DWORD MOUSEEVENTF_XDOWN = 0x0080;
    static const DWORD MOUSEEVENTF_XUP = 0x0100;
]]

local function sleep(ms)
    local start = os.clock()
    while os.clock() - start < ms / 1000 do end
end

local function randomSleep(min, max)
    local ms = math.random(min, max)
    sleep(ms)
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
    -- 4 (down) 4 (up) 30-40 ms delay (random)
    pressKey(ffi.C.VK_4, true)
    pressKey(ffi.C.VK_4, false)
    randomSleep(30, 40)

    -- mouse button 2 (down) mouse button 2 (up) 50-60 ms delay (random)
    clickMouse("right", true)
    clickMouse("right", false)
    randomSleep(50, 60)

    -- 5 (down) 5 (up) 30-40 ms delay (random)
    pressKey(ffi.C.VK_5, true)
    pressKey(ffi.C.VK_5, false)
    randomSleep(50, 40)

    -- mouse button 2 (down) mouse button 2 (up) 50-60 ms delay (random)
    clickMouse("right", true)
    clickMouse("right", false)
    randomSleep(50, 60)

    -- mouse button 5 (down) mouse button 5 (up) 30-40 ms delay (random)
    clickMouse("mouse5", true)
    clickMouse("mouse5", false)
    randomSleep(30, 40)

    -- mouse button 2 (down) mouse button 2 (up)
    clickMouse("right", true)
    clickMouse("right", false)

    -- mouse button 2 (down) mouse button 2 (up)
    clickMouse("right", true)
    clickMouse("right", false)
end

local function isKeyPressed(key)
    return ffi.C.GetAsyncKeyState(key) ~= 0
end

-- Main loop to check for the 'ALT' key press
while true do
    if isKeyPressed(ffi.C.VK_MENU) then
        doubleAnchor()
        -- Wait for the key to be released to avoid multiple triggers
        while isKeyPressed(ffi.C.VK_MENU) do
            sleep(10)
        end
    end
    sleep(1)  -- Check every 10ms for more responsiveness
end