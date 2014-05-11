#include "String.h"
#include <string>

#define STRING_LOCAL_CONVERSION_BUFFER_SIZE 1024

namespace moche
{
    String::String()
        : m_buffer(const_cast<char*>(&Null))
        , m_bufferLength(0)
        , m_length(0)
    {}

    String::String(const char* str)
        : String()
    {
        setText(strlen(str), str);
    }

    String::String(size_t length, const char* str)
        : String()
    {
        setText(length, str);
    }

    String::String(const wchar_t* str)
        : String()
    {
        char convBuf[STRING_LOCAL_CONVERSION_BUFFER_SIZE];
        size_t convSize = wcstombs(&convBuf[0], str, STRING_LOCAL_CONVERSION_BUFFER_SIZE);
        if (convSize == (size_t)-1)
        {
            // TODO error
        }
        else if (convSize >= STRING_LOCAL_CONVERSION_BUFFER_SIZE)
        {
            // TODO error
        }
        setText(convSize, convBuf);
    }

    String::String(size_t length, const wchar_t* str)
        : String()
    {
        char convBuf[STRING_LOCAL_CONVERSION_BUFFER_SIZE];
        size_t convSize = 0;
        errno_t convError = wcstombs_s(&convSize, &convBuf[0], STRING_LOCAL_CONVERSION_BUFFER_SIZE, str, length);
        if (convError == ERANGE)
        {
            // TODO error
        }
        else if (convError)
        {
            // TODO error
        }
        setText(convSize, convBuf);
    }

    String::String(const String& str)
        : String()
    {
        setText(str.m_length, str.m_buffer);
    }

    String::String(String&& str)
    {
        m_length = str.m_length;
        m_buffer = str.m_buffer;
        m_bufferLength = str.m_bufferLength;
        str.m_buffer = nullptr;
        str.m_length = 0;
        str.m_bufferLength = 0;
    }

    String::~String()
    {
        if (m_bufferLength > 0)
        {
            delete[] m_buffer;
        }
    }

    bool String::operator<(const String& other) const
    {
        return (strcmp(m_buffer, other.m_buffer) < 0);
    }

    void String::setText(size_t length, const char* str)
    {
        if (length == 0 && m_bufferLength == 0)
        {
            return;
        }
        if (m_bufferLength == 0)
        {
            m_bufferLength = length + 1;
            m_buffer = new char[m_bufferLength];
        }
        else if (length >= m_bufferLength)
        {
            delete[] m_buffer;
            m_bufferLength = length + 1;
            m_buffer = new char[m_bufferLength];
        }
        m_length = length;
        strncpy(m_buffer, str, m_length + 1);
    }

    void String::truncate(size_t length)
    {
        if (length >= m_length) return;
        m_length = length;
        m_buffer[m_length] = '\0';
    }

    void String::clear()
    {
        if (m_length == 0) return;
        m_length = 0;
        m_buffer[0] = '\0';
    }
}