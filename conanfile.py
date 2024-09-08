from conan import ConanFile
from conan.tools.files import load, copy
from conan.errors import ConanInvalidConfiguration
from conan.tools.cmake import CMake, CMakeToolchain, CMakeDeps
import conan.tools.files as cfiles
from pathlib import Path
import tarfile, os

# for compatibility
release_arch = {
  # "windows": {
  #   "x86_64": "x64",
  # },
  "linux": {
    "x86_64": "x64",
  },
  "android": {
    "x86_64": "x86_64",
    "armv8": "arm64-v8a",
    "armv7": "armeabi-v7a",
  },
  "macos": {
    "x86_64": "x64",
    "armv8": "arm64",
  },
  # "ios": {
  #   "x86_64": "x64",
  #   "armv8": "arm64",
  # },
}

class fhel(ConanFile):
  name = "fhel"
  settings = "os", "arch", "compiler", "build_type"
  exports_sources = "src/*", "include/*", "test/*", "CMakeLists.txt"
  options = {
    "ci": [True, False],
  }

  default_options = {
    "ci": False,
  }

  def set_version(self):
    if not self.recipe_folder:
      raise ConanInvalidConfiguration("recipe_folder not set")

    if not self.version:
      version_file = Path(
        os.path.join(self.recipe_folder, "dart" , "binary.version")
      )
      if not version_file.exists():
        raise ConanInvalidConfiguration("binary.version file not found")

      self.version = load(self, version_file).strip();

  def generate(self):
    "Generate the cmake toolchain file"
    tc = CMakeToolchain(self)
    tc.generate()

  def seal_negative_args(self) -> list[str]:
    """
    Append negative options to the cmake command,
      e.g. -DSEAL_USE_MSGZL=OFF (default is ON)
    """
    args = []
    if self.settings.os == "Android": # Supports only 64-bit for now
      args.append("-DSEAL_BUILD_SEAL_C=1");
      args.append("-DSEAL_USE_INTRIN=1")
      args.append("-DSEAL_ARM64_EXITCODE=0")
      args.append("-DSEAL_ARM64_EXITCODE__TRYRUN_OUTPUT=''")
      args.append("-DSEAL___BUILTIN_CLZLL_FOUND_EXITCODE=0")
      args.append("-DSEAL___BUILTIN_CLZLL_FOUND_EXITCODE__TRYRUN_OUTPUT=''")
      args.append("-DSEAL__ADDCARRY_U64_FOUND_EXITCODE=0")
      args.append("-DSEAL__ADDCARRY_U64_FOUND_EXITCODE__TRYRUN_OUTPUT=''")
      args.append("-DSEAL__SUBBORROW_U64_FOUND_EXITCODE=0")
      args.append("-DSEAL__SUBBORROW_U64_FOUND_EXITCODE__TRYRUN_OUTPUT=''")
    return args

  def build(self):
    "Compile libfhel dynamic library"
    cmake = CMake(self)
    cmake.configure(cli_args=self.seal_negative_args())
    cmake.build()

  def copy_files(self):
    "Copy the library to the package folder"
    if not self.source_folder:
      raise ConanInvalidConfiguration("source_folder not set")
    if not self.package_folder:
      raise ConanInvalidConfiguration("package_folder not set")

    copy(self,
      pattern=f"libfhel*",
      src=self.source_folder,
      dst=self.package_folder,
    )

  def package(self):
    "Compresse the library for distribution"
    self.copy_files()

  def package_info(self):
    "Export to GITHUB_OUTPUT"
    if self.options.ci:
      with open("GITHUB_OUTPUT", "a") as f:
        print(f'conan_package_path={self.package_folder}', file=f)
