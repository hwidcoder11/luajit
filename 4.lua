-- LuaJIT script to simulate double right-clicking when the right control key is pressed
local ffi = require("ffi")

-- Define Windows API functions and constants
ffi.cdef[[
    typedef unsigned long DWORD;
    typedef int BOOL;
    typedef unsigned short WORD;
    typedef void* HANDLE;
    typedef unsigned long ULONG_PTR; // Define ULONG_PTR explicitly

    BOOL GetAsyncKeyState(int vKey);
    void mouse_event(DWORD dwFlags, DWORD dx, DWORD dy, DWORD dwData, ULONG_PTR dwExtraInfo);
    void Sleep(DWORD dwMilliseconds);

    static const DWORD MOUSEEVENTF_RIGHTDOWN = 0x0008;
    static const DWORD MOUSEEVENTF_RIGHTUP = 0x0010;
    static const int VK_RCONTROL = 0xA3; // Virtual key code for Right Control
]]

-- Sleep function
local function sleep(ms)
    ffi.C.Sleep(ms)
end

-- Function to simulate a double right-click
local function doubleRightClick()
    print("Simulating double right-click") -- Debug print
    ffi.C.mouse_event(ffi.C.MOUSEEVENTF_RIGHTDOWN, 0, 0, 0, 0)
    ffi.C.mouse_event(ffi.C.MOUSEEVENTF_RIGHTUP, 0, 0, 0, 0)
    ffi.C.mouse_event(ffi.C.MOUSEEVENTF_RIGHTDOWN, 0, 0, 0, 0)
    ffi.C.mouse_event(ffi.C.MOUSEEVENTF_RIGHTUP, 0, 0, 0, 0)
end

-- Main loop to check for the Right Control key press
while true do
    local state = ffi.C.GetAsyncKeyState(ffi.C.VK_RCONTROL)
    print("Right Control Key State:", state) -- Debug print

    if state ~= 0 then
        doubleRightClick()
        -- Wait for the key to be released to avoid multiple triggers
        while ffi.C.GetAsyncKeyState(ffi.C.VK_RCONTROL) ~= 0 do
            sleep(1) -- Small delay to prevent high CPU usage
        end
    end
    sleep(1) -- Small delay to prevent high CPU usage
end