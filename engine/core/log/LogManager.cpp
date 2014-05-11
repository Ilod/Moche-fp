#include "LogManager.h"

namespace moche
{
    namespace log
    {
        void LogManager::print(const Vector<String>& categories, Level level, const String& msg)
        {
            for (size_t i = 0; i < m_loggers.size(); ++i)
            {
                m_loggers[i]->log(categories, level, msg);
            }
        }

        void LogManager::registerLogger(Logger* logger)
        {
            m_loggers.push_back(logger);
        }

        void LogManager::unregisterLogger(Logger* logger)
        {
            m_loggers.erase(std::find(m_loggers.begin(), m_loggers.end(), logger));
        }
    }
}