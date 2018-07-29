FROM base/archlinux
MAINTAINER Devaev Maxim <mdevaev@gmail.com>

RUN rm /etc/localtime && ln -s /usr/share/zoneinfo/Russia/Moscow /etc/localtime

RUN echo "Server = http://mirror.yandex.ru/archlinux/\$repo/os/\$arch" > /etc/pacman.d/mirrorlist

RUN pacman --noconfirm -Syy \
	&& pacman --noconfirm -S pacman \
	&& pacman-db-upgrade \
	&& pacman --noconfirm -Sc

RUN pacman --noconfirm -Syy \
	&& pacman --noconfirm -S \
		archlinux-keyring \
		ca-certificates \
		ca-certificates-cacert \
		ca-certificates-mozilla \
		ca-certificates-utils \
	&& pacman --noconfirm -Sc \
	&& pacman-key --refresh-keys

RUN pacman --noconfirm -Su \
	&& pacman --noconfirm -S \
		vim \
		tree \
		wget \
		unzip \
		htop \
		iftop \
		iotop \
		strace \
		binutils \
		git \
		jshon \
		expac \
		fakeroot \
		make \
		patch \
		sudo \
	&& pacman --noconfirm -Sc

RUN useradd -r packer

RUN cd /tmp \
	&& sudo -u packer git clone https://aur.archlinux.org/packer-color.git \
	&& cd packer-color \
	&& sudo -u packer makepkg \
	&& pacman --noconfirm -U packer-color-*.pkg.tar.xz \
	&& ln -s /usr/bin/packer-color /usr/local/bin/packer \
	&& cp /usr/bin/packer-color /usr/local/bin/user-packer \
	&& sed -i -e "s|makepkg \$MAKEPKGOPTS |chown -R packer:packer \$dir; makepkg \$MAKEPKGOPTS |g" \
		/usr/local/bin/user-packer \
	&& sed -i -e "s|makepkg \$MAKEPKGOPTS --asroot -f|sudo -u packer makepkg \$MAKEPKGOPTS -f|g" \
		/usr/local/bin/user-packer \
	&& cd - \
	&& rm -rf /tmp/packer-color

RUN echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
	&& locale-gen

ADD say.sh /usr/local/bin/say
ADD die.sh /usr/local/bin/die
ADD setup-profile.sh /usr/local/bin/setup-profile

RUN setup-profile /root

ENV LC_ALL en_US.UTF-8
ENV HOME /root
ENV DOCKER 1

WORKDIR /root
CMD /usr/bin/bash
