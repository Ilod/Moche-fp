#pragma once
#include "core/string/String.h"
#include "core/containers/Vector.h"
#include "core/containers/Map.h"
#include <cstdint>

namespace moche
{
    namespace log
    {
        enum class Level : uint8_t
        {
            NoAssert = 0,
            Crash,
            Fatal,
            NoLog,
            Always,
            Error,
            Warning,
            Info,
            Debug,
            Trace,
            All,
        };

        class Logger
        {
        public:
            Logger();
            virtual ~Logger() {};

            void log(Level level, const String& msg);
            template<typename... Args> void log(Level level, const String& msg, Args... args) { log(level, String(msg.cStr(), args...)); }
            void log(const String& category, Level level, const String& msg);
            template<typename... Args> void log(const String& category, Level level, const String& msg, Args... args) { log(category, level, String(msg.cStr(), args...)); }
            void log(const String& category, const String& category2, Level level, const String& msg);
            template<typename... Args> void log(const String& category, const String& category2, Level level, const String& msg, Args... args) { log(category, category2, level, String(msg.cStr(), args...)); }
            void log(const String& category, const String& category2, const String& category3, Level level, const String& msg);
            template<typename... Args> void log(const String& category, const String& category2, const String& category3, Level level, const String& msg, Args... args) { log(category, category2, category3, level, String(msg.cStr(), args...)); }
            void log(const Vector<String>& categories, Level level, const String& msg);
            template<typename... Args> void log(const Vector<String>& categories, Level level, const String& msg, Args... args) { log(categories, level, String(msg.cStr(), args...)); }
            void setLogLevel(Level level) { m_defaultLevel = level; }
            void setLogLevel(const String& category, Level level);
            void setLogLevel(const String& category, const String& category2, Level level);
            void setLogLevel(const String& category, const String& category2, const String& category3, Level level);
            void setLogLevel(const Vector<String>& categories, Level level);
        protected:
            virtual void print(const Vector<String>& categories, Level level, const String& msg) = 0;
        private:
            bool canLog(const Vector<String>& categories, Level level) const;
            static void makeCategoryString(const Vector<String>& categories, String& res);
            Level m_defaultLevel;
            Map<String, Level> m_levels;
        };
    }
}