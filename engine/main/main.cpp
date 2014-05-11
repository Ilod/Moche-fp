#include "core/log/LogManager.h"
#include "core/log/DebugOutputLogger.h"
#include "core/log/BreakLogger.h"
#include "core/log/CrashLogger.h"

using namespace moche;
using namespace moche::log;

int main()
{
    DebugOutputLogger a;
    a.setLogLevel(Level::Warning);
    a.setLogLevel("ONLINE", Level::Debug);
    BreakLogger b;
    b.setLogLevel(Level::Error);
    CrashLogger c;
    c.setLogLevel(Level::Crash);
    LogManager d;
    d.setLogLevel(Level::All);
    d.registerLogger(&a);
    d.registerLogger(&b);
    d.registerLogger(&c);
    d.log("TEST", Level::Debug, "Ceci est un test %u", 1);
    d.log("ONLINE", Level::Debug, "Ceci est un test %u", 2);
    d.log(Level::Debug, "Ceci est un test %u", 3);
    d.log(Level::Warning, "Ceci est un test %u", 4);
    d.log(Level::Error, "Ceci est un test %u", 5);
    d.log(Level::Crash, "Ceci est un test %u", 6);
    return 1;
}
