FROM scratch

ARG TARGETPLATFORM

ARG CACHEBUST=1
ADD ${TARGETPLATFORM}.tar /
ENV LANG=en_US.UTF-8

RUN pacman-key --init && \
    pacman-mirrors -f 5

# TODO: remove when https://github.com/actions/virtual-environments/issues/2658 is fixed
RUN [[ "${TARGETPLATFORM}" == "linux/amd64" ]] || exit 0 && \
    curl -LO "https://repo.archlinuxcn.org/x86_64/glibc-linux4-2.33-4-x86_64.pkg.tar.zst" && \
    bsdtar -C / -xvf "glibc-linux4-2.33-4-x86_64.pkg.tar.zst" && \
    rm glibc*.zst && \
    pacman -Syy --noconfirm --needed archlinux-keyring manjaro-keyring && \
	pacman-key --populate archlinux manjaro

# TODO: remove when https://github.com/actions/virtual-environments/issues/2658 is fixed
RUN [[ "${TARGETPLATFORM}" == "linux/arm64" ]] || exit 0 && \
    curl -LO "https://github.com/Manjaro-Sway/glibc-linux4-arm/raw/main/glibc-2.33-4-aarch64.pkg.tar.zst" && \
    bsdtar -C / -xvf "glibc-2.33-4-aarch64.pkg.tar.zst" && \
    rm glibc*.zst && \
    pacman -Syy --noconfirm --needed archlinuxarm-keyring manjaro-arm-keyring && \
    pacman-key --populate archlinuxarm manjaro-arm

RUN pacman -S --noconfirm --needed \
        shadow \
        git \
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
        which && \
    sed -i -e 's~#IgnorePkg.*~IgnorePkg = glibc~g' '/etc/pacman.conf' && \
    sed -i -e 's~CheckSpace.*~#CheckSpace~g' '/etc/pacman.conf' && \
    pacman -Syyu --noconfirm --needed

# user 'builder' can be used as the running user for applications prohibiting root usage (pacman)
RUN useradd -d /builder -m builder && \
    echo "builder ALL=(ALL) NOPASSWD: ALL" >>/etc/sudoers

CMD ["/usr/bin/bash"]
