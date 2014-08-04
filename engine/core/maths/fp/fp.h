#pragma once

#include <cstdint>
#include <type_traits>

namespace moche
{
    namespace
    {
        template<typename T, uintmax_t flag = 1>
        struct bits_in {
            enum { value = 1 + bits_in<T, (uintmax_t)(T)(flag << 1)>::value };
        };

        template<typename T>
        struct bits_in<T, 0uLL> {
            enum { value = 0 };
        };

        template<typename T> struct next_integral
        {
            typedef typename std::enable_if<bits_in<T>::value <= 16 && std::is_signed  <T>::value, int32_t>::type type;
            typedef typename std::enable_if<bits_in<T>::value <= 16 && std::is_unsigned<T>::value, uint32_t>::type type;
            typedef typename std::enable_if<(bits_in<T>::value > 16) && bits_in<T>::value <= 32 && std::is_signed  <T>::value, int64_t > ::type type;
            typedef typename std::enable_if<(bits_in<T>::value > 16) && bits_in<T>::value <= 32 && std::is_unsigned<T>::value, uint64_t > ::type type;
            typedef typename std::enable_if<(bits_in<T>::value > 32) && bits_in<T>::value <= 64 && std::is_signed  <T>::value, __int128_t > ::type type;
            typedef typename std::enable_if<(bits_in<T>::value > 32) && bits_in<T>::value <= 64 && std::is_unsigned<T>::value, __uint128_t > ::type type;
        };
    }

    template<class IntBase, uint8_t DecBits>  class fp
    {
        static_assert(std::is_integral<IntBase>::value, "Non-integral type used");
        static const bool isSigned = std::is_signed<IntBase>::value;
        static const uint8_t decimalBitsCount = DecBits;
        static const uint8_t integerBitsCount = bits_in<IntBase>::value - DecBits;

        fp() : m_value(0) {}
        fp(const fp<IntBase, DecBits>& o) : m_value(o.m_value) { }
        fp<IntBase, DecBits>& operator++() { m_value += (1 << decimalBitsCount); return *this; }
        fp<IntBase, DecBits> operator++(int) { fp<IntBase, DecBits> old = *this; m_value += (1 << decimalBitsCount); return *this; }
        template<class T> typename std::enable_if<std::is_integral<T>::value, fp<IntBase, DecBits>>::type& operator+=(T o) { m_value += (o << decimalBitsCount); return *this; }
        template<class T> typename std::enable_if<std::is_integral<T>::value, fp<IntBase, DecBits>>::type& operator-=(T o) { m_value -= (o << decimalBitsCount); return *this; }
        template<class T> typename std::enable_if<std::is_integral<T>::value, fp<IntBase, DecBits>>::type& operator*=(T o) { m_value *= o; return *this; }
        template<class T> typename std::enable_if<std::is_integral<T>::value, fp<IntBase, DecBits>>::type& operator/=(T o) { m_value /= o; return *this; }

        fp<IntBase, DecBits> operator-() { fp<IntBase, DecBits> ret; ret.m_value = -m_value; return ret; }
        bool operator< (const fp<IntBase, DecBits>& o) { return m_value <  o.m_value; }
        bool operator<=(const fp<IntBase, DecBits>& o) { return m_value <= o.m_value; }
        bool operator>(const fp<IntBase, DecBits>& o) { return m_value >  o.m_value; }
        bool operator>=(const fp<IntBase, DecBits>& o) { return m_value >= o.m_value; }
        bool operator==(const fp<IntBase, DecBits>& o) { return m_value == o.m_value; }
        bool operator!=(const fp<IntBase, DecBits>& o) { return m_value != o.m_value; }

        fp<IntBase, DecBits>& operator+=(fp<IntBase, DecBits>& o) { m_value += o.m_value; return *this; }
        fp<IntBase, DecBits>& operator-=(fp<IntBase, DecBits>& o) { m_value -= o.m_value; return *this; }
        fp<IntBase, DecBits>& operator*=(fp<IntBase, DecBits>& o) { m_value = (internal_type)(((typename next_integral<IntBase>::type) m_value * o.m_value) >> DecBits); return *this; }
        fp<IntBase, DecBits>& operator/=(fp<IntBase, DecBits>& o) { m_value = (internal_type)((((typename next_integral<IntBase>::type) m_value) << DecBits) / o.m_value); return *this; }

    private:

        typedef IntBase internal_type;
        internal_type m_value;
    };
}