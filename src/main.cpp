#include <coffee/core/CApplication>
#include <coffee/core/CDebug>
#include <coffee/core/CFiles>

using namespace Coffee;

int32 coffee_project_main(int32, cstring_w*)
{
    CResources::FileResourcePrefix("coffee_project/");
    
    cDebug("Hello World!");

    return 0;
}

COFFEE_APPLICATION_MAIN(coffee_project_main)
