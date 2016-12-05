FROM ubuntu:16.04

# リポジトリを日本に変更
RUN sed -i".original" -e "s/\/\/archive.ubuntu.com/\/\/ftp.jaist.ac.jp/g" /etc/apt/sources.list

# ソフトウェアインストール
RUN apt-get update && apt-get install -y \
    build-essential \
    openssh-server \
    locales \
    language-pack-ja \
    man-db \
    manpages-ja \
    vim \
    git \
    tig \
    tree \
    libxslt-dev

# anyenv
RUN git clone https://github.com/riywo/anyenv ~/.anyenv \
 && echo 'export PATH="$HOME/.anyenv/bin:$PATH"' >> ~/.bashrc \
 && echo 'eval "$(anyenv init -)"' >> ~/.bashrc

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
 && echo 'root:docker' | chpasswd \
 && sed -i".original" -e 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config \
 && sed -i".original" -e 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]
