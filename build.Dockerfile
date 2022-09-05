FROM manjarolinux/base:latest

RUN pacman -Syy --noconfirm --needed \
    base-devel \
    shadow \
    git \
    git-lfs \
    cmake \
    libseccomp \
    libtool && \
    pacman -S --noconfirm glibc && \
    rm -f /var/cache/pacman/pkg/*
    

# user 'builder' can be used as the running user for applications prohibiting root usage (pacman)
RUN id -u builder &>/dev/null || (useradd -d /builder -m builder && \
    echo "builder ALL=(ALL) NOPASSWD: ALL" >>/etc/sudoers)
