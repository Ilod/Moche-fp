#pragma once
#include "Logger.h"

namespace moche
{
    namespace log
    {
        class BreakLogger : public Logger
        {
        public:
            BreakLogger() {}
            virtual ~BreakLogger() {}
        protected:
            void print(const Vector<String>& categories, Level level, const String& msg) override;
        };
    }
}