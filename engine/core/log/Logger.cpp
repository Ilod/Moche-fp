#include "Logger.h"

namespace moche
{
    namespace log
    {
        Logger::Logger()
            : m_defaultLevel(Level::Warning)
        { }

        void Logger::log(Level level, const String& msg)
        {
            log(Vector<String>(), level, msg);
        }

        void Logger::log(const String& category, Level level, const String& msg)
        {
            Vector<String> categories;
            categories.reserve(1);
            categories.push_back(category);
            log(categories, level, msg);
        }

        void Logger::log(const String& category, const String& category2, Level level, const String& msg)
        {
            Vector<String> categories;
            categories.reserve(2);
            categories.push_back(category);
            categories.push_back(category2);
            log(categories, level, msg);
        }

        void Logger::log(const String& category, const String& category2, const String& category3, Level level, const String& msg)
        {
            Vector<String> categories;
            categories.reserve(3);
            categories.push_back(category);
            categories.push_back(category2);
            categories.push_back(category3);
            log(categories, level, msg);
        }

        bool Logger::canLog(const Vector<String>& categories, Level level) const
        {
            String category;
            makeCategoryString(categories, category);
            for (size_t i = categories.size(); i > 0; --i)
            {
                Map<String, Level>::const_iterator iter = m_levels.find(category);
                if (iter != m_levels.end())
                {
                    return level <= iter->second;
                }
                category.truncate(category.len() - categories[i-1].len() - 1);
            }
            return level <= m_defaultLevel;
        }

        void Logger::makeCategoryString(const Vector<String>& categories, String& res)
        {
            res.clear();
            for (size_t i = 0; i < categories.size(); ++i)
            {
                res.format("%s%s\1", res.cStr(), categories[i].cStr());
            }
            res.truncate(res.len() - 1);
        }

        void Logger::log(const Vector<String>& categories, Level level, const String& msg)
        {
            if (canLog(categories, level))
            {
                print(categories, level, msg);
            }
        }

        void Logger::setLogLevel(const String& category, Level level)
        {
            m_levels[category] = level;
        }

        void Logger::setLogLevel(const String& category, const String& category2, Level level)
        {
            Vector<String> categories;
            categories.reserve(2);
            categories.push_back(category);
            categories.push_back(category2);
            setLogLevel(categories, level);
        }

        void Logger::setLogLevel(const String& category, const String& category2, const String& category3, Level level)
        {
            Vector<String> categories;
            categories.reserve(3);
            categories.push_back(category);
            categories.push_back(category2);
            categories.push_back(category3);
            setLogLevel(categories, level);
        }

        void Logger::setLogLevel(const Vector<String>& categories, Level level)
        {
            String strCategories;
            makeCategoryString(categories, strCategories);
            m_levels[strCategories] = level;
        }
    }
}