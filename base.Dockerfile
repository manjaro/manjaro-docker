FROM manjarolinux/base:latest as base

# squashing the whole base image into one layer
FROM scratch AS build
COPY --from=base / /

COPY pacman.conf /etc/pacman.conf

ARG TARGETPLATFORM

ARG CACHEBUST=1
ENV LANG=en_US.UTF-8

ENV PATH="/usr/bin:${PATH}"

RUN uname -m && \
    pacman-key --init && \
    pacman-mirrors --geoip

RUN [[ "${TARGETPLATFORM}" == "linux/amd64" ]] || exit 0 && \
    pacman -Syy --noconfirm --needed archlinux-keyring manjaro-keyring && \
    pacman-key --populate archlinux manjaro

RUN [[ "${TARGETPLATFORM}" == "linux/arm64" ]] || exit 0 && \
    pacman -Syy --noconfirm --needed archlinuxarm-keyring manjaro-arm-keyring && \
    pacman-key --populate archlinuxarm manjaro-arm

# set everything to be a dependency
RUN pacman -D --asdeps $(pacman -Qeq)

# mark all bsae pkgs as explicitly installed
RUN pacman -S --asexplicit --needed --noconfirm base

# make sure release info pkgs are installed
RUN pacman -Syy --noconfirm --needed \
    lsb-release \
    manjaro-release

# remove everything not needed
RUN pacman -Rsunc --noconfirm  $(pacman -Qtdq)

# upgrade glibc
RUN rm /usr/include/bits/struct_stat.h \
       /usr/include/bits/types/struct___jmp_buf_tag.h \
       /usr/include/bits/types/struct_timeb.h \
       /usr/share/locale/sr/LC_MESSAGES/libc.mo && \
    pacman -Q --info glibc && \
    pacman -Syy glibc --noconfirm && \
    pacman -Q --info glibc && \
    pacman -Syu --noconfirm

# enable at least one locale in locale.gen
RUN sed -i 's/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g' /etc/locale.gen && \
    locale-gen

# debug output release info
RUN ls /etc/*-release && cat /etc/*-release

## final docker image 
FROM scratch AS release

COPY --from=build / /

CMD ["/usr/bin/sh"]