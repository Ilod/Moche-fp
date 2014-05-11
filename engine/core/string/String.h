#pragma once
#include <cwchar>

#define snprintf _snprintf

namespace moche
{
    class String final
    {
    public:
        String();
        String(const char* str);
        String(size_t length, const char* str);
        String(const wchar_t* str);
        String(size_t length, const wchar_t* str);
        String(const String& str);
        String(String&& str);
        template<typename... Args> String(const char* str, Args... args);
        ~String();
        size_t len() const { return m_length; }
        bool isEmpty() const { return m_length == 0; }
        const char* cStr() const { return m_buffer; }
        template<typename... Args> void format(const char* str, Args... args);
        template<typename... Args> void applyCurrentFormat(Args... args);
        bool operator<(const String& other) const;
        void truncate(size_t length);
        void clear();
    private:
        //template<typename T, typename... Args> void formatInternal(char* buffer, size_t iBuffer, const char* str, size_t iStr, T arg, Args... args);
        void formatInternal(char* buffer, size_t iBuffer, const char* str, size_t iStr);
        char * m_buffer;
        size_t m_length;
        size_t m_bufferLength;
        static const char Null = '\0';
        void setText(size_t length, const char* str);
    };

    template<typename... Args> String::String(const char* str, Args... args)
        : String()
    {
        format(str, args...);
    }

    template<typename... Args> void String::applyCurrentFormat(Args... args)
    {
        format(m_buffer, args...);
    }

#define __MOCHE_STRING_LOCAL_FORMAT_SIZE 2048

    template<typename... Args> void String::format(const char* str, Args... args)
    {
        char buffer[__MOCHE_STRING_LOCAL_FORMAT_SIZE];
        int length = snprintf(&buffer[0], __MOCHE_STRING_LOCAL_FORMAT_SIZE, str, args...);
        if (length < 0)
        {
            // todo error
        }
        else if (length >= __MOCHE_STRING_LOCAL_FORMAT_SIZE)
        {
            // todo error
        }
        else
        {
            setText(length, buffer);
        }
    }

#undef __MOCHE_STRING_LOCAL_FORMAT_SIZE 
}