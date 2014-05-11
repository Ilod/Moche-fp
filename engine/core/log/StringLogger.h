#pragma once
#include "Logger.h"

namespace moche
{
    namespace log
    {
        class StringLogger : public Logger
        {
        public:
            StringLogger() {}
            virtual ~StringLogger() {}
        protected:
            void print(const Vector<String>& categories, Level level, const String& msg) override;
            virtual void print(const String& msg) = 0;
        };
    }
}