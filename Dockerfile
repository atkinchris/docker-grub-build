FROM debian:stretch

RUN apt-get update -yqq && apt-get install -yqq \
    grub-efi-amd64-bin \
    make \
    dosfstools

VOLUME /tmp/output
WORKDIR /tmp

COPY . /tmp
CMD make grub && \
    cp bootx64.efi /tmp/output && \
    make build-floppy && \
    cp floppy.img /tmp/output
