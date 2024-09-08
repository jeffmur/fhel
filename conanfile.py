import os
from conan import ConanFile
from conan.tools.files import load
from conan.errors import ConanInvalidConfiguration
from conan.tools.cmake import CMake, CMakeToolchain, CMakeDeps
import conan.tools.files as cfiles
from pathlib import Path
import tarfile

# for compatibility
arch_map = {
  "windows": {
    "x86_64": "x64",
  },
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

  def set_version(self):
    if not self.version and self.recipe_folder:
      version_file = Path(
        os.path.join(self.recipe_folder, "dart" , "binary.version")
      )
      if not version_file.exists():
        raise ConanInvalidConfiguration("binary.version file not found")

      self.version = load(self, version_file);

  def __init__(self, display_name=""):
    super().__init__(display_name)

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

  def generate(self):
    tc = CMakeToolchain(self)
    tc.generate()

  def build(self):
    cmake = CMake(self)
    cmake.configure(cli_args=self.seal_negative_args())
    cmake.build()
