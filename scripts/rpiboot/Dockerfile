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
RUN git clone --depth=1 https://github.com/raspberrypi/usbboot.git
WORKDIR /usr/src/usbboot
RUN make && cp rpiboot /usr/local/bin/
RUN cp -r /usr/src/usbboot /usr/share/rpiboot

ENTRYPOINT ["rpiboot"]
