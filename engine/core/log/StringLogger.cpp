#include "StringLogger.h"

namespace moche
{
    namespace log
    {
        void StringLogger::print(const Vector<String>& categories, Level level, const String& msg)
        {
            String strCategories;
            for (size_t i = 0; i < categories.size(); ++i)
            {
                strCategories.format("%s[%s]", strCategories.cStr(), categories[i].cStr());
            }
            const char* strLevel = "";
            switch (level)
            {
            case Level::Crash:
                strLevel = "[CRASH] ";
                break;
            case Level::Fatal:
                strLevel = "[FATAL] ";
                break;
            case Level::Error:
                strLevel = "[ERROR] ";
                break;
            case Level::Warning:
                strLevel = "[WARNING] ";
                break;
            case Level::Info:
                strLevel = "[INFO] ";
                break;
            case Level::Debug:
                strLevel = "[DEBUG] ";
                break;
            case Level::Trace:
                strLevel = "[TRACE] ";
                break;
            case Level::NoAssert:
            case Level::NoLog:
            case Level::Always:
            default:
                break;
            }
            print(String("%s%s%s%s\n", strCategories.cStr(), strCategories.isEmpty() ? "" : " ", strLevel, msg.cStr()));
        }
    }
}