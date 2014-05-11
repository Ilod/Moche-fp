#pragma once
#include "Logger.h"
#include <cstdint>

namespace moche
{
    namespace log
    {
        class LogManager final : public Logger
        {
        public:
            LogManager() {}
            virtual ~LogManager() {}
            void registerLogger(Logger* logger);
            void unregisterLogger(Logger* logger);
        protected:
            void print(const Vector<String>& categories, Level level, const String& msg) override;
        private:
            Vector<Logger*> m_loggers;
        };
    }
}