#include "BreakLogger.h"
#include <Windows.h>

namespace moche
{
    namespace log
    {
        void BreakLogger::print(const Vector<String>&, Level, const String&)
        {
            DebugBreak();
        }
    }
}