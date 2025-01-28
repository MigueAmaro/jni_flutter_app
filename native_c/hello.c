#include <stdio.h>

// calling this from Dart using FFI.
const char* helloFromC() {
    return "Hello from C Library using good old FFI!";
}
