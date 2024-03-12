/**
 * @file error_handling.h
 * ------------------------------------------------------------------
 * @brief Translate C++ exceptions to Dart exceptions. This Singleton
 *        class will be passed by reference to each C function in FHE
 *        to handle exceptions.
 * ------------------------------------------------------------------
 * @author Jeffrey Murray Jr (jeffmur)
 */
#include <cstring>  /* strcpy */
#include <iostream> /* Print in cout */
using namespace std;

class ErrorTranslator {
private:
    const char* error_message;

public:
    // Get the singleton instance of ErrorTranslator
    static ErrorTranslator& getInstance() {
        static ErrorTranslator instance;
        return instance;
    }

    // Delete the copy constructor and assignment operator
    ErrorTranslator(const ErrorTranslator&) = delete;
    ErrorTranslator& operator=(const ErrorTranslator&) = delete;

    // Translate a C++ exception to a Dart exception message
    void set_error(const exception& e) {
        string message = e.what();

        // str -> char* to avoid memory leak
        char *cpy = new char[message.size()+1] ;
        strcpy(cpy, message.c_str());
        // cout << "set_error: " << cpy << endl;
        error_message = cpy;
    }

    void clear() {
        error_message = nullptr;
    }

    // Get the error message, if any
    const char* get_error() {
        return error_message;
    }

private:
    // Make the constructor private to enforce singleton
    ErrorTranslator() {}
};
