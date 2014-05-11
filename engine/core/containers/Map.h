#pragma once
#include <map>

namespace moche
{
    template<class Key, class Value, class Comparator = std::less<Key>, class Alloc = std::allocator<std::pair<const Key, Value>>> using Map = std::map<Key, Value, Comparator, Alloc>;
}