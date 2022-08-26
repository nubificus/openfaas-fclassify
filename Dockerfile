# Get vAccel release
FROM ubuntu:20.04 as vaccel-release
ENV VACCEL_RELEASE=v0.4.0
ENV DEBIAN_FRONTEND="noninteractive"
RUN apt-get update && apt-get install -y wget
ARG ARCH
RUN wget https://github.com/cloudkernels/vaccel/releases/download/${VACCEL_RELEASE}/vaccel_x86_64_Release.tar.gz && \
    mkdir -p /vaccel && tar -zxvf vaccel_${ARCH}_Release.tar.gz -C /vaccel && rm vaccel_${ARCH}_Release.tar.gz

# Build function
FROM ubuntu:20.04 as builder

COPY --from=vaccel-release /vaccel/lib/libvaccel* /usr/local/lib/
COPY --from=vaccel-release /vaccel/include/. /usr/local/include/
COPY --from=vaccel-release /vaccel/share/vaccel.pc /usr/local/share/

RUN apt-get update && apt-get install -y \
        build-essential make 

COPY . /openfaas/

WORKDIR /openfaas
RUN make

FROM ghcr.io/openfaas/classic-watchdog:0.1.4 as watchdog

# Build function container
FROM ubuntu:20.04

RUN mkdir -p /home/app

## Copy binaries
COPY --from=watchdog /fwatchdog /usr/bin/fwatchdog
RUN chmod +x /usr/bin/fwatchdog

## Add non root user
RUN adduser app && adduser app app
RUN chown app /home/app

WORKDIR /home/app

## Add resources dir for vAccel
RUN mkdir /run/user
RUN chmod go+rwX /run/user

USER app

## Copy binaries
COPY --from=builder /openfaas/pipe /pipe
COPY --from=builder /openfaas/libfileread.so /lib
COPY --from=builder /usr/local/lib/libvaccel* /lib/

## Set vAccel env vars
ENV LD_LIBRARY_PATH=/lib/
ENV VACCEL_BACKENDS=/lib/libvaccel-vsock.so 
ENV VACCEL_VSOCK=vsock://2:2048
ENV VACCEL_DEBUG_LEVEL=4

EXPOSE 8080

HEALTHCHECK --interval=3s CMD [ -e /tmp/.lock ] || exit 1

CMD ["fwatchdog"]
