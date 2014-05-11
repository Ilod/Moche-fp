#pragma once
#include "StringLogger.h"

namespace moche
{
    namespace log
    {
        class DebugOutputLogger : public StringLogger
        {
        public:
            DebugOutputLogger() {}
            virtual ~DebugOutputLogger() {}
        protected:
            void print(const String& msg) override;
        };
    }
}