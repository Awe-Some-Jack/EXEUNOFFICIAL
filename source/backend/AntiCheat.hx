package backend;

#if cpp
@:cppFileCode('
#if defined(_WIN32)
    #include <windows.h>
#elif defined(__linux__)
    #include <stdio.h>
    #include <string.h>
    #include <stdlib.h>
#elif defined(__APPLE__)
    #include <sys/types.h>
    #include <sys/sysctl.h>
    #include <unistd.h>
#endif
')
#end
class AntiCheat {
    
    public static function checkDebugger():Void {
        #if cpp
            var debuggerFound:Bool = false;

            #if windows
            untyped __cpp__('
                if (IsDebuggerPresent()) {
                    debuggerFound = true;
                }
                
                BOOL isRemoteDebuggerPresent = FALSE;
                CheckRemoteDebuggerPresent(GetCurrentProcess(), &isRemoteDebuggerPresent);
                if (isRemoteDebuggerPresent) {
                    debuggerFound = true;
                }
            ');

            #elseif linux
            untyped __cpp__('
                FILE *fp = fopen("/proc/self/status", "r");
                if (fp != NULL) {
                    char line[256];
                    while (fgets(line, sizeof(line), fp)) {
                        if (strncmp(line, "TracerPid:", 10) == 0) {
                            int tracerPid = atoi(&line[10]);
                            if (tracerPid > 0) {
                                debuggerFound = true;
                            }
                            break;
                        }
                    }
                    fclose(fp);
                }
            ');

            #elseif mac
            untyped __cpp__('
                int mib[4];
                struct kinfo_proc info;
                size_t size = sizeof(info);
                
                info.kp_proc.p_flag = 0;
                
                mib[0] = CTL_KERN;
                mib[1] = KERN_PROC;
                mib[2] = KERN_PROC_PID;
                mib[3] = getpid();
                
                if (sysctl(mib, 4, &info, &size, NULL, 0) == 0) {
                    if (info.kp_proc.p_flag & P_TRACED) {
                        debuggerFound = true;
                    }
                }
            ');
            #end

            if (debuggerFound) {
                CoolUtil.showPopUp("SON.", "SONIC.SEX");
                CoolUtil.browserLoad("https://youtu.be/dQw4w9WgXcQ?si=NZzQ8_ez3LCo-FD5");
                Sys.exit(1); 
            }
        #end
    }
}