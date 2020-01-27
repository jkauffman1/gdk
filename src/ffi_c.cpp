#include "include/gdk.h"

#include <cstdio>
#include <exception>

namespace {

} // namespace

int GA_init()
{
    try {
        printf("JKDBG GA_init");
        return 0;
    } catch (const std::exception& e) {
        return GA_ERROR;
    }
}

