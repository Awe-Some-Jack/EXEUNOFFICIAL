package backend.windows;

#if windows
@:cppFileCode('
#include <windows.h>
#include <dwmapi.h>
#pragma comment(lib, "dwmapi.lib")
')
#end
class WindowsApi
{
	public static function enableDarkMode():Void
	{
		#if windows
		setDarkModeCPP();
		#end
	}

	#if windows
	@:functionCode('
		HWND hwnd = GetActiveWindow();
		if (hwnd != NULL)
		{
			BOOL useDarkMode = TRUE;
			HRESULT hr = DwmSetWindowAttribute(hwnd, 20, &useDarkMode, sizeof(useDarkMode));
			if (FAILED(hr))
			{
				DwmSetWindowAttribute(hwnd, 19, &useDarkMode, sizeof(useDarkMode));
			}
		}
	')
	private static function setDarkModeCPP():Void
	{
	}
	#end
}