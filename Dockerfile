FROM ubuntu:16.04

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
    tree

# pyenv
RUN git clone https://github.com/yyuu/pyenv.git ~/.pyenv \
 && git clone https://github.com/yyuu/pyenv-virtualenv.git ~/.pyenv/plugins/pyenv-virtualenv \
 && echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bash_profile \
 && echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bash_profile \
 && echo 'eval "$(pyenv init -)"' >> ~/.bash_profile \
 && echo 'eval "$(pyenv virtualenv-init -)"' >> ~/.bash_profile

# rbenv
RUN git clone https://github.com/rbenv/rbenv.git ~/.rbenv \
 && git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build \
 && cd ~/.rbenv && src/configure && make -C src \
 && echo 'export RBENV_ROOT="$HOME/.rbenv"' >> ~/.bash_profile \
 && echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bash_profile \
 && echo 'eval "$(rbenv init -)"' >> ~/.bash_profile

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
