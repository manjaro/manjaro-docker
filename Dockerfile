FROM manjarosway/base:latest

ARG TARGETPLATFORM

ARG CACHEBUST=1
ENV LANG=en_US.UTF-8

RUN pacman-key --init && \
    pacman-mirrors -f 5

RUN [[ "${TARGETPLATFORM}" == "linux/amd64" ]] || exit 0 && \
    pacman -Syy --noconfirm --needed archlinux-keyring manjaro-keyring && \
	pacman-key --populate archlinux manjaro

RUN [[ "${TARGETPLATFORM}" == "linux/arm64" ]] || exit 0 && \
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
    sed -i -e 's~CheckSpace.*~#CheckSpace~g' '/etc/pacman.conf' && \
    pacman -Syyu --noconfirm --needed

# user 'builder' can be used as the running user for applications prohibiting root usage (pacman)
RUN id -u builder &>/dev/null || (useradd -d /builder -m builder && \
    echo "builder ALL=(ALL) NOPASSWD: ALL" >>/etc/sudoers)

CMD ["/usr/bin/bash"]
