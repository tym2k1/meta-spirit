FROM debian:stable-slim

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        git \
        build-essential \
        libusb-1.0-0-dev \
        pkg-config \
        ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /usr/src
# last release as of 14.09.2025
RUN git clone --branch 20250908-162618 --depth=1 https://github.com/raspberrypi/usbboot.git
WORKDIR /usr/src/usbboot
RUN make && cp rpiboot /usr/local/bin/
RUN cp -r /usr/src/usbboot /usr/share/rpiboot

ENTRYPOINT ["rpiboot"]
