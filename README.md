# dji_psdk_vendor

`dji_psdk_vendor` is the catkin vendor package for this workspace's DJI Payload SDK integration. It vendors the upstream `Payload-SDK` sources, builds the Linux sample C platform layer into a static library, and exports the headers and archives consumed by [`dji_psdk_ros`](../dji_psdk_ros/README.md).

## What This Package Provides

- The upstream DJI Payload SDK tree under `Payload-SDK/`
- A catkin-built static library: `libpsdk_vendor_c.a`
- The prebuilt DJI core archive for the current architecture: `libpayloadsdk.a`
- Exported include paths for the DJI core headers and Linux sample platform sources

## Repository Layout

```text
dji_psdk_vendor/
├── CMakeLists.txt
├── package.xml
├── README.md
└── Payload-SDK/
    ├── psdk_lib/
    │   ├── include/
    │   └── lib/
    │       ├── aarch64-linux-gnu-gcc/
    │       └── x86_64-linux-gnu-gcc/
    └── samples/
        ├── sample_c/
        │   ├── module_sample/
        │   └── platform/linux/
        │       ├── common/
        │       ├── manifold2/
        │       └── nvidia_jetson/
        └── sample_c++/
            └── platform/linux/
                ├── manifold2/
                └── nvidia_jetson/
```

## Current Build Behavior

The current `CMakeLists.txt` builds only the C vendor library:

- `psdk_vendor_c`

The older C++ vendor target is still visible in commented code, but it is not built or installed by this package today.

The package also installs:

- `Payload-SDK/psdk_lib/include/...`
- `Payload-SDK/samples/sample_c/platform/linux/common/...`
- `Payload-SDK/samples/sample_c/platform/linux/<platform>/hal/...`
- `Payload-SDK/samples/sample_c/platform/linux/<platform>/application/...`
- `libpayloadsdk.a`

## Supported Platforms

### Architecture

- `aarch64`
- `x86_64`

### Platform Selection

This workspace currently builds the vendor package with:

```bash
PSDK_PLATFORM=nvidia_jetson
```

### Important Note About Platform Names

This checkout currently contains Linux sample directories for:

- `nvidia_jetson`
- `manifold2`

The package `CMakeLists.txt` still advertises `raspberry_pi`, but there is no matching `Payload-SDK/samples/sample_c/platform/linux/raspberry_pi/` directory in this repository.

The bundled `nvidia_jetson` HAL sources are mostly generic Linux USB, UART, and network code rather than obviously Jetson-only code, so Raspberry Pi may be able to work with the same source set. However, this repository does not currently map `raspberry_pi` to the `nvidia_jetson` sample path, and Raspberry Pi support is not validated by the current build files. In practice, the documented and tested path in this repository is still `nvidia_jetson`.

## Dependencies

Install the system packages required by `dji_psdk_vendor`:

```bash
sudo apt-get update
sudo apt-get install -y \
  ffmpeg \
  libavcodec-dev \
  libavformat-dev \
  libavutil-dev \
  libswscale-dev \
  libopus-dev \
  libusb-1.0-0-dev \
  pkg-config
```

### FFmpeg Version

This package checks the installed FFmpeg major version at configure time and requires FFmpeg 4.x.

Verify your version with:

```bash
ffmpeg -version
```

## Build

From the workspace root:

```bash
cd ~/catkin_ws
rosdep install --from-paths src --ignore-src -r -y && catkin config --install --cmake-args -DPSDK_PLATFORM=nvidia_jetson -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DCMAKE_BUILD_TYPE=Release && catkin build
source install/setup.bash
```

This configures the workspace to:

- install missing ROS/system dependencies with `rosdep`
- build against `PSDK_PLATFORM=nvidia_jetson`
- export `compile_commands.json`
- use `Release` mode

## Build Outputs

After a successful build/install, the main artifacts are:

- `install/lib/libpsdk_vendor_c.a`
- `install/lib/libpayloadsdk.a`
- `install/include/dji_psdk_vendor/Payload-SDK/...`

## Configuration Files

For the Jetson sample platform, the main SDK configuration files are:

- `Payload-SDK/samples/sample_c/platform/linux/nvidia_jetson/application/dji_sdk_app_info.h`
- `Payload-SDK/samples/sample_c/platform/linux/nvidia_jetson/application/dji_sdk_config.h`

Update these files with your app credentials and platform-specific settings before running against real hardware.

## Using From Another Catkin Package

In `package.xml`:

```xml
<depend>dji_psdk_vendor</depend>
```

In `CMakeLists.txt`:

```cmake
find_package(catkin REQUIRED COMPONENTS
  dji_psdk_vendor
)

include_directories(
  ${catkin_INCLUDE_DIRS}
)

target_link_libraries(your_node
  ${catkin_LIBRARIES}
)
```

Typical includes from consumer code look like:

```cpp
#include "dji_core.h"
#include "dji_flight_controller.h"
#include "dji_platform.h"
```

## Troubleshooting

### `PSDK_PLATFORM is not set`

Configure with an explicit platform:

```bash
catkin config --install --cmake-args -DPSDK_PLATFORM=nvidia_jetson -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DCMAKE_BUILD_TYPE=Release
```

### `Unsupported FFMPEG version`

The configure step only accepts FFmpeg 4.x. Check the installed version:

```bash
ffmpeg -version
```

### `DJI Payload SDK core library not found`

Make sure the matching archive exists for your CPU:

- `Payload-SDK/psdk_lib/lib/aarch64-linux-gnu-gcc/libpayloadsdk.a`
- `Payload-SDK/psdk_lib/lib/x86_64-linux-gnu-gcc/libpayloadsdk.a`

### `Unsupported architecture`

This package only accepts:

- `aarch64`
- `x86_64`

Check your machine with:

```bash
uname -m
```

## Version

- Package version: `0.0.0`
- Package format: `2`
- Minimum CMake version: `3.0.2`

## License

- Package manifest license: `MIT`
- Vendored upstream SDK files also include DJI-provided license and notice files under `Payload-SDK/`, especially `Payload-SDK/LICENSE.txt` and `Payload-SDK/EULA.txt`

## Maintainer

Ahmed Allam - `ahmed.18allam@gmail.com`

## Contributing

When contributing to this package:

1. Keep the README aligned with the actual `CMakeLists.txt` and packaged `Payload-SDK` tree.
2. Validate changes on the target hardware and architecture you are building for.
3. Document any platform-specific assumptions, especially around `PSDK_PLATFORM`.
4. Avoid claiming support for a platform unless the repository layout and build logic actually support it.

## Support

For package-specific questions or maintenance, contact:

- Ahmed Allam - `ahmed.18allam@gmail.com`

For DJI Payload SDK questions beyond this catkin wrapper, refer to:

- DJI Payload SDK Documentation: <https://developer.dji.com/payload-sdk/>
- DJI Developer Forum: <https://forum.dji.com/forum-139-1.html>
