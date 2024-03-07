#include <gtest/gtest.h> // NOLINT
#include <aseal.h>       /* Microsoft SEAL */
#include <map>

using namespace std;

/**
 * @brief Print a line
*/
inline void print_line(int line_number)
{
    cout << "Line " << setw(3) << line_number << " --> ";
}

/**
 * @brief Print the parameters in a SEALContext
*/
// inline void print_parameters(const AsealContext &context)
// {
//     const auto &context_data = context->key_context_data();

//     string scheme_name;
//     switch (context_data->parms().scheme())
//     {
//     case seal::scheme_type::bfv:
//         scheme_name = "BFV";
//         break;
//     case seal::scheme_type::ckks:
//         scheme_name = "CKKS";
//         break;
//     case seal::scheme_type::bgv:
//         scheme_name = "BGV";
//         break;
//     default:
//         throw invalid_argument("Unsupported scheme");
//     }
//     cout << "/" << endl;
//     cout << "| Encryption parameters:" << endl;
//     cout << "|   scheme: " << scheme_name << endl;
//     cout << "|   poly_modulus_degree: " << context_data->parms().poly_modulus_degree() << endl;

//     auto &coeff_modulus = context_data->parms().coeff_modulus();
//     cout << "|   coeff_modulus size: " << coeff_modulus.size() << " (";
//     for (size_t i = 0; i < coeff_modulus.size() - 1; i++)
//     {
//         cout << coeff_modulus[i].bit_count() << " + ";
//     }
//     cout << coeff_modulus.back().bit_count() << ") bits" << endl;

//     if (context_data->parms().scheme() == seal::scheme_type::bfv)
//     {
//         cout << "|   plain_modulus: " << context_data->parms().plain_modulus().value() << endl;
//     }
//     cout << "\\" << endl;
// }

/**
 * @brief Assert that two vectors are equal
 * 
 * @param actual The actual result vector
 * @param expected The expected result vector
 * @param tolerance The maximum tolerance allowed for the difference between parallel elements of the vectors.
 *                  Typically this is a very small decimal number.
*/
template <typename T>
void expect_equal_vector(vector<T>& actual, vector<T>& expected, double tolerance = 0)
{
    ASSERT_EQ(expected.size(), actual.size());
    for (size_t i = 0; i < expected.size(); i++)
    {
        ASSERT_NEAR(expected[i], actual[i], tolerance);
    }
}

/**
 * @brief Print a vector
*/
template <typename T>
inline void print_vector(vector<T> vec, size_t print_size = 4, int prec = 3)
{
    /*
    Save the formatting information for cout.
    */
    ios old_fmt(nullptr);
    old_fmt.copyfmt(cout);

    size_t slot_count = vec.size();

    cout << fixed << setprecision(prec);
    cout << endl;
    if (slot_count <= 2 * print_size)
    {
        cout << "    [";
        for (size_t i = 0; i < slot_count; i++)
        {
            cout << " " << vec[i] << ((i != slot_count - 1) ? "," : " ]\n");
        }
    }
    else
    {
        vec.resize(max(vec.size(), 2 * print_size));
        cout << "    [";
        for (size_t i = 0; i < print_size; i++)
        {
            cout << " " << vec[i] << ",";
        }
        if (vec.size() > 2 * print_size)
        {
            cout << " ...,";
        }
        for (size_t i = slot_count - print_size; i < slot_count; i++)
        {
            cout << " " << vec[i] << ((i != slot_count - 1) ? "," : " ]\n");
        }
    }
    cout << endl;

    /*
    Restore the old cout formatting.
    */
    cout.copyfmt(old_fmt);
}

/**
 * @brief Print a matrix
*/
template <typename T>
inline void print_matrix(vector<T> matrix, size_t row_size)
{
    /*
    We're not going to print every column of the matrix (there are 2048). Instead
    print this many slots from beginning and end of the matrix.
    */
    size_t print_size = 5;

    cout << endl;
    cout << "    [";
    for (size_t i = 0; i < print_size; i++)
    {
        cout << setw(3) << right << matrix[i] << ",";
    }
    cout << setw(3) << " ...,";
    for (size_t i = row_size - print_size; i < row_size; i++)
    {
        cout << setw(3) << matrix[i] << ((i != row_size - 1) ? "," : " ]\n");
    }
    cout << "    [";
    for (size_t i = row_size; i < row_size + print_size; i++)
    {
        cout << setw(3) << matrix[i] << ",";
    }
    cout << setw(3) << " ...,";
    for (size_t i = 2 * row_size - print_size; i < 2 * row_size; i++)
    {
        cout << setw(3) << matrix[i] << ((i != 2 * row_size - 1) ? "," : " ]\n");
    }
    cout << endl;
}
