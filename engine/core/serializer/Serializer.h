#pragma once
#include <type_traits>
#include <cstdint>

namespace moche
{
    namespace serializer
    {
        enum class A
        {
            E = 1
        };

        class Serializer
        {
        private:
        public:
            void a();
            template<class E> typename std::enable_if<std::is_enum<E>::value>::type serialize(E) {}
            template<class N> typename std::enable_if<std::is_arithmetic<N>::value>::type serialize(N) {}
            template<class P> typename std::enable_if<std::is_pointer<P>::value>::type serialize(P) {}
            template<class C> typename std::enable_if<std::is_class<C>::value>::type serialize(C&) {}
            template<class U> typename std::enable_if<std::is_union<U>::value>::type serialize(U) {}
            template<class A, unsigned N> void serialize(A(&)[N]) { }
            template<class F> typename std::enable_if<std::is_function<F>::value>::type serialize(F) {}
            template<class F> typename std::enable_if<std::is_member_function_pointer<F>::value>::type serialize(F) {}
            template<class F> typename std::enable_if<std::is_member_object_pointer<F>::value>::type serialize(F) {}
        protected:
            virtual void serialize_f32(float) = 0;
            virtual void serialize_f64(double) = 0;
            virtual void serialize_bool(bool) = 0;
            virtual void serialize_u8(uint8_t) = 0;
            virtual void serialize_u16(uint16_t) = 0;
            virtual void serialize_u32(uint32_t) = 0;
            virtual void serialize_u64(uint64_t) = 0;
            virtual void serialize_i8(int8_t) = 0;
            virtual void serialize_i16(int16_t) = 0;
            virtual void serialize_i32(int32_t) = 0;
            virtual void serialize_i64(int64_t) = 0;
            virtual void serialize_array_start(size_t size) = 0;
            virtual void serialize_array_end() = 0;
        };
    }
}