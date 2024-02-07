FROM instrumentisto/flutter:3.16.9 as builder

FROM mcr.microsoft.com/devcontainers/cpp:1-debian-11

RUN apt-get update \
    && apt-get install -y default-jre libgtk-3-dev

WORKDIR /tmp/

# Android Studio, Dart, Flutter
COPY --from=builder /opt/android-sdk-linux /tmp/android-sdk-linux
COPY --from=builder /usr/local/flutter /tmp/flutter

RUN git config --global --add safe.directory /tmp/flutter

ENV PATH="${PATH}:/tmp/flutter/bin"
RUN flutter config --android-sdk /tmp/android-sdk-linux
RUN flutter channel stable

# Mount Backend
COPY src/backend /tmp/backend
COPY Makefile /tmp/Makefile

# Compile Backend Libraries
# RUN make install-deps