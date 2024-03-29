# Fully Homomorphic Encryption Calculator

Demonstrates how to use the fhel plugin integrates into an Flutter Application.

| Supported | Function
| --- | ---
| Platform | Android
| Data Types | Hexadecimal, List[Int], Double, List[Double]
| Schemes | BFV, BGV, CKKS
| Mathematics | Add, Multiply, Subtract

Note: Division has open [issue](https://github.com/jeffmur/fhel/issues/55)

## Getting Started

Compile AFHEL + Dependencies (SEAL):

From the root of this directory, install via CMakeLists.txt
```zsh
cmake -S . -B build -DUNIT_TEST=OFF
cmake --build build
cd example && flutter build apk
```

Note: `UNIT_TEST` enables/disables GTest Suite. \
For APK releases, they are not needed, and it may fail compilation.

OR via Makefile
```zsh
make build-cmake
make apk
```

## Demo


### Addition

<p float="center">
  <img src="./res/add/Hexadecimal.gif" width="24%" />
  <img src="./res/add/ListInt.gif" width="24%" />
  <img src="./res/add/Double.gif" width="24%" /> 
  <img src="./res/add/ListDouble.gif" width="24%" />
</p>

### Multiplication

<p float="center">
  <img src="./res/mul/Hexadecimal.gif" width="24%" />
  <img src="./res/mul/ListInt.gif" width="24%" />
  <img src="./res/mul/Double.gif" width="24%" /> 
  <img src="./res/mul/ListDouble.gif" width="24%" />
</p>

### Subtraction

<p float="center">
  <img src="./res/sub/Hexadecimal.gif" width="24%" />
  <img src="./res/sub/ListInt.gif" width="24%" />
  <img src="./res/sub/Double.gif" width="24%" /> 
  <img src="./res/sub/ListDouble.gif" width="24%" />
</p>


### Settings

To configure Microsoft SEAL, there are 3 supported schemes: BFV, BGV, and CKKS. If you'd like, there are default parameters available to get started. Toggling Default Parameters, will autofill default parameters. Once Validate is clicked, the parameters will be verified and keys will be generated.

On success, a green banner will appear with 'success: valid'
On failure, a red banner will appear with the corresponding error.

<img src="./res/SettingsPage.gif" alt="SettingsPage" width="25%">

