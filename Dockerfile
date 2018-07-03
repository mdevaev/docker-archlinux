FROM base/archlinux
MAINTAINER Devaev Maxim <mdevaev@gmail.com>

RUN rm /etc/localtime \
	&& ln -s /usr/share/zoneinfo/Europe/Moscow /etc/localtime

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
		python \
		python-requests \
		python-regex \
		pyalpm \
		expac \
		fakeroot \
		make \
		patch \
		sudo \
	&& pacman --noconfirm -Sc

RUN useradd -r -m aurman -s /bin/bash
RUN echo "aurman ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
RUN cd /tmp \
	&& sudo -u aurman git clone --depth=1 https://aur.archlinux.org/aurman.git \
	&& cd aurman \
	&& sudo -u aurman makepkg --skippgpcheck \
	&& pacman --noconfirm -U aurman-*.pkg.tar.xz \
	&& cd - \
	&& rm -rf /tmp/aurman

RUN echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
	&& locale-gen

ADD say.sh /usr/local/bin/say
ADD die.sh /usr/local/bin/die
ADD setup-profile.sh /usr/local/bin/setup-profile
ADD user-aurman.sh /usr/local/bin/user-aurman
RUN ln -s /usr/local/bin/user-aurman /usr/local/bin/user-packer

RUN setup-profile /root

ENV LC_ALL en_US.UTF-8
ENV HOME /root
ENV DOCKER 1

WORKDIR /root
CMD /usr/bin/bash
