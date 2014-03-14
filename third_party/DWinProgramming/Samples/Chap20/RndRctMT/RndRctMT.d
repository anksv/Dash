/+
 + Copyright (c) Charles Petzold, 1998.
 + Ported to the D Programming Language by Andrej Mitrovic, 2011.
 +/

module RndRctMT;

import core.memory;
import core.runtime;
import core.thread;
import std.algorithm : min, max;
import std.concurrency;
import std.conv;
import std.math;
import std.random;
import std.range;
import std.string;
import std.utf;

auto toUTF16z(S)(S s)
{
    return toUTFz!(const(wchar)*)(s);
}

pragma(lib, "gdi32.lib");
pragma(lib, "comdlg32.lib");
pragma(lib, "winmm.lib");
import win32.windef;
import win32.winuser;
import win32.wingdi;
import win32.winbase;
import win32.commdlg;
import win32.mmsystem;

alias win32.winuser.MessageBox MessageBox;

string appName     = "RndRctMT";
string description = "Random Rectangles";
HINSTANCE hinst;

extern (Windows)
int WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int iCmdShow)
{
    int result;
    void exceptionHandler(Throwable e) { throw e; }

    try
    {
        Runtime.initialize(&exceptionHandler);
        result = myWinMain(hInstance, hPrevInstance, lpCmdLine, iCmdShow);
        Runtime.terminate(&exceptionHandler);
    }
    catch (Throwable o)
    {
        MessageBox(null, o.toString().toUTF16z, "Error", MB_OK | MB_ICONEXCLAMATION);
        result = 0;
    }

    return result;
}

int myWinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int iCmdShow)
{
    hinst = hInstance;
    HACCEL hAccel;
    HWND hwnd;
    MSG  msg;
    WNDCLASS wndclass;

    wndclass.style         = CS_HREDRAW | CS_VREDRAW;
    wndclass.lpfnWndProc   = &WndProc;
    wndclass.cbClsExtra    = 0;
    wndclass.cbWndExtra    = 0;
    wndclass.hInstance     = hInstance;
    wndclass.hIcon         = LoadIcon(NULL, IDI_APPLICATION);
    wndclass.hCursor       = LoadCursor(NULL, IDC_ARROW);
    wndclass.hbrBackground = cast(HBRUSH) GetStockObject(WHITE_BRUSH);
    wndclass.lpszMenuName  = appName.toUTF16z;
    wndclass.lpszClassName = appName.toUTF16z;

    if (!RegisterClass(&wndclass))
    {
        MessageBox(NULL, "This program requires Windows NT!", appName.toUTF16z, MB_ICONERROR);
        return 0;
    }

    hwnd = CreateWindow(appName.toUTF16z,              // window class name
                        description.toUTF16z,          // window caption
                        WS_OVERLAPPEDWINDOW,           // window style
                        CW_USEDEFAULT,                 // initial x position
                        CW_USEDEFAULT,                 // initial y position
                        CW_USEDEFAULT,                 // initial x size
                        CW_USEDEFAULT,                 // initial y size
                        NULL,                          // parent window handle
                        NULL,                          // window menu handle
                        hInstance,                     // program instance handle
                        NULL);                         // creation parameters

    ShowWindow(hwnd, iCmdShow);
    UpdateWindow(hwnd);

    while (GetMessage(&msg, NULL, 0, 0))
    {
        TranslateMessage(&msg);
        DispatchMessage(&msg);
    }
    
    return msg.wParam;
}

__gshared HWND hwndGlob;
__gshared int cxClient, cyClient;

void ThreadFunc()
{
    HBRUSH hBrush;
    HDC hdc;
    int xLeft, xRight, yTop, yBottom, iRed, iGreen, iBlue;

    while (true)
    {
        if (cxClient != 0 || cyClient != 0)
        {
            xLeft   = uniform(0, cxClient);
            xRight  = uniform(0, cxClient);
            yTop    = uniform(0, cyClient);
            yBottom = uniform(0, cyClient);
            iRed    = uniform(0, 255);
            iGreen  = uniform(0, 255);
            iBlue   = uniform(0, 255);

            hdc    = GetDC(hwndGlob);
            hBrush = CreateSolidBrush(RGB(cast(ubyte)iRed, cast(ubyte)iGreen, cast(ubyte)iBlue));
            SelectObject(hdc, hBrush);

            Rectangle(hdc, min(xLeft, xRight), min(yTop, yBottom), max(xLeft, xRight), max(yTop, yBottom));

            ReleaseDC(hwndGlob, hdc);
            DeleteObject(hBrush);
        }
        
        Thread.sleep(dur!"msecs"(70));
    }
}

extern (Windows)
LRESULT WndProc(HWND hwnd, UINT message, WPARAM wParam, LPARAM lParam)
{
    hwndGlob = hwnd;
    switch (message)
    {
        case WM_CREATE:
            spawn(&ThreadFunc);
            return 0;

        case WM_SIZE:
            cxClient = LOWORD(lParam);
            cyClient = HIWORD(lParam);
            return 0;

        case WM_DESTROY:
            PostQuitMessage(0);
            ExitProcess(0);
            return 0;
        
        default:
    }

    return DefWindowProc(hwnd, message, wParam, lParam);
}