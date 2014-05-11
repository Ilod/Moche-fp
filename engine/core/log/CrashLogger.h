#pragma once
#include "Logger.h"

namespace moche
{
    namespace log
    {
        class CrashLogger : public Logger
        {
        public:
            CrashLogger() {}
            virtual ~CrashLogger() {}
        protected:
            void print(const Vector<String>& categories, Level level, const String& msg) override;
        };
    }
}