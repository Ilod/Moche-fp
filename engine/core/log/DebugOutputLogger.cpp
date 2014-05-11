#include "DebugOutputLogger.h"
#include <Windows.h>

namespace moche
{
    namespace log
    {
        void DebugOutputLogger::print(const String& msg)
        {
            OutputDebugStringA(msg.cStr());
        }
    }
}