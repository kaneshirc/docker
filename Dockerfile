FROM ubuntu:16.04
MAINTAINER Naoki Kaneshiro

ARG user="kaneshiro"
ARG password="password"

# リポジトリを日本に変更
RUN sed -i".original" -e "s/\/\/archive.ubuntu.com/\/\/ftp.jaist.ac.jp/g" /etc/apt/sources.list

# ソフトウェアインストール
RUN apt-get update && apt-get install -y \
    build-essential \
    autoconf \
    bison \
    libbz2-dev \
    libsqlite3-dev \
    sqlite3 \
    libxslt-dev \
    libssl-dev \
    libreadline-dev \
    zlib1g-dev \
    libyaml-dev \
    libreadline6-dev \
    libncurses5-dev \
    libffi-dev \
    libgdbm3 \
    libgdbm-dev \
    openssh-server \
    locales \
    language-pack-ja \
    man-db \
    manpages-ja \
    vim \
    git \
    tig \
    tree \
    sudo

# 日本時間
# ref: https://serverfault.com/questions/683605/docker-container-time-timezone-will-not-reflect-changes/683607
ENV TZ=Asia/Tokyo
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# 日本語
RUN sed -i".original" -e "s/# ja_JP.UTF-8 UTF-8/ja_JP.UTF-8 UTF-8/g" /etc/locale.gen \
 && update-locale LANG=ja_JP.UTF-8

# ssh
# refs: https://docs.docker.com/engine/examples/running_ssh_service/
RUN mkdir /var/run/sshd \
 && sed -i".original" -e 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config \
 && sed -i".original" -e 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

# user
# add user
RUN groupadd -g 1000 $user && \
    useradd -g $user -G sudo -m -s /bin/bash $user && \
    echo "$user:$password" | chpasswd

USER root
EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]
