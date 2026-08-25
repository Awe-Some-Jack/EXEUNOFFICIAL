package backend.windows;

#if windows
@:cppFileCode('
#include <windows.h>
#include <dwmapi.h>
#pragma comment(lib, "dwmapi.lib")

// Definición de tipos para la función DwmSetWindowAttribute nativa
typedef HRESULT (WINAPI *pfnDwmSetWindowAttribute)(HWND hwnd, DWORD dwAttribute, LPCVOID pvAttribute, DWORD cbAttribute);
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
		// 1. Obtener la ventana activa con respaldo
		HWND hwnd = GetActiveWindow();
		if (hwnd == NULL)
		{
			hwnd = GetForegroundWindow();
		}

		if (hwnd != NULL)
		{
			// 2. Cargar DWM de forma segura en tiempo de ejecución (compatible con Win7/8/10/11)
			HMODULE hDwm = LoadLibraryA("dwmapi.dll");
			if (hDwm != NULL)
			{
				pfnDwmSetWindowAttribute setAttr = (pfnDwmSetWindowAttribute)GetProcAddress(hDwm, "DwmSetWindowAttribute");
				if (setAttr != NULL)
				{
					BOOL useDarkMode = TRUE;

					// Atributo 20: Windows 11 y Win 10 Build 19041+
					HRESULT hr = setAttr(hwnd, 20, &useDarkMode, sizeof(useDarkMode));
					
					if (FAILED(hr))
					{
						// Atributo 19: Win 10 Build 1809 - 1903
						hr = setAttr(hwnd, 19, &useDarkMode, sizeof(useDarkMode));
					}
				}
				FreeLibrary(hDwm);
			}
		}
	')
	private static function setDarkModeCPP():Void
	{
	}
	#end
}