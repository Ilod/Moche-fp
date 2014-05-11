#pragma once
#include <vector>

namespace moche
{
    template<class T, class Alloc = std::allocator<T>> using Vector = std::vector<T, Alloc>;
}