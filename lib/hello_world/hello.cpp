// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#include "hello.h"
#include <iostream>

using namespace std;
using namespace seal;

int main()
{
    hello_world();
    int result = (factorial(10));
    std::cout << "Factorial of 10 is: " << result << std::endl;
    return 0;
}

// Note:
// ---only on Windows---
// Every function needs to be exported to be able to access the functions by dart.
// Refer: https://stackoverflow.com/q/225432/8608146

void hello_world()
{
    printf("Hello World!\n");
    printf("From C++, using C-interop via dart:ffi\n");
}

int factorial(int n) {
    if (n==0) return 1;
    return n * factorial(n - 1);
}