#include "Serializer.h"

namespace moche
{
    namespace serializer
    {


        int b() { return 3; }
        void Serializer::a()
        {
            serialize(A::E);
            serialize(&Serializer::a);
            //Serializer z[4];
            //serialize(z);
        }
    }
}