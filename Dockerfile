FROM manjarolinux/base:20220220 as base

# squashing the whole base image into one layer
FROM scratch AS release
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

RUN pacman -S --noconfirm --needed --overwrite glibc pacman

RUN pacman -S --noconfirm --needed \
    shadow \
    git \
    git-lfs \
    cmake \
    libseccomp \
    autoconf \ 
    automake \
    binutils \
    bison  \
    fakeroot \
    file \
    findutils \
    flex \
    gawk \
    gcc \
    gettext \
    grep \
    groff \
    gzip \
    libtool \
    m4 \
    make \
    pacman \
    patch \
    pkgconf \
    sed  \
    sudo \
    texinfo \
    lsb-release \
    manjaro-release \
    which

# Enable at least one locale in locale.gen
RUN sed -i 's/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g' /etc/locale.gen && \
    locale-gen

RUN ls /etc/*-release && cat /etc/*-release

# user 'builder' can be used as the running user for applications prohibiting root usage (pacman)
RUN id -u builder &>/dev/null || (useradd -d /builder -m builder && \
    echo "builder ALL=(ALL) NOPASSWD: ALL" >>/etc/sudoers)

CMD ["/usr/bin/bash"]
