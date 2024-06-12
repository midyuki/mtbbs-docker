# ref: https://github.com/solarkennedy/wine-x11-novnc-docker/blob/master/Dockerfile
# ref: https://zukucode.com/2019/07/docker-japanese-input.html

FROM ubuntu:22.04

# 非対話モードを設定する (Docker ビルド中の対話プロンプトを防ぐため)
ENV DEBIAN_FRONTEND=noninteractive

# 必要なパッケージをインストール
## 2024年2月現在の Wine 9.x 系には EpgTimerSrv のタスクトレイ表示のコンテキストメニューのフォントがガビガビな上に日本語が豆腐化する問題がある
## Wine は近年バージョン更新が活発で毎バージョン間の変更も大きいため、当面動作確認が確実に取れている 8.x 系に固定する
RUN dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        fonts-noto-cjk \
        ncdu \
        language-pack-ja \
        locales \
        python3 \
        sudo \
        supervisor \
        tar \
        tzdata \
        wget && \
    apt-get install -y --no-install-recommends \
        desktop-base \
        dbus-x11 \
        gnome-themes-extra \
        papirus-icon-theme \
        pm-utils \
        thunar \
        thunar-volman \
        x11-xserver-utils \
        x11vnc \
        xorg \
        xfce4 \
        xfce4-settings \
        xfce4-taskmanager \
        xfce4-terminal \
        xserver-xorg-input-all \
        xserver-xorg-video-all \
        xvfb && \
    apt-get install -y --install-recommends \
        fcitx5 \
        fcitx5-mozc && \
    mkdir -pm755 /etc/apt/keyrings && \
    wget -O /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key && \
    wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/ubuntu/dists/jammy/winehq-jammy.sources && \
    apt-get update && \
    apt-get install -y \
        winehq-stable=8.0.2~jammy-1 \
        wine-stable=8.0.2~jammy-1 \
        wine-stable-amd64=8.0.2~jammy-1 \
        wine-stable-i386=8.0.2~jammy-1 \
        winetricks && \
    apt-get -y autoremove && \
    apt-get -y clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /tmp/*

# noVNC のインストール
RUN wget -O - https://github.com/novnc/noVNC/archive/v1.3.0.tar.gz | \
        tar -xzv -C /opt/ && mv /opt/noVNC-1.3.0 /opt/noVNC && \
    ln -s /opt/noVNC/vnc.html /opt/noVNC/index.html && \
    wget -O - https://github.com/novnc/websockify/archive/v0.11.0.tar.gz | \
        tar -xzv -C /opt/ && mv /opt/websockify-0.11.0 /opt/noVNC/utils/websockify

# タイムゾーンを東京に設定
ENV TZ=Asia/Tokyo
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
    echo $TZ > /etc/timezone && \
    dpkg-reconfigure -f noninteractive tzdata

# 日本語環境を設定
RUN fc-cache -f -v && \
    im-config -n fcitx5 && \
    locale-gen ja_JP.UTF-8
ENV GTK_IM_MODULE=xim \
    QT_IM_MODULE=fcitx5 \
    XMODIFIERS=@im=fcitx5 \
    DefalutIMModule=fcitx5 \
    LANG=ja_JP.UTF-8 \
    LANGUAGE=ja_JP:ja \
    LC_ALL=ja_JP.UTF-8

# 一般ユーザーを作成
RUN useradd -m --uid 1000 --groups sudo ubuntu && \
    echo ubuntu:ubuntu | chpasswd && \
    echo 'ubuntu ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
USER ubuntu
WORKDIR /home/ubuntu/

# Wine に必要な環境変数を設定
# DISPLAY=:88 は、Xvfb で起動した X サーバーのディスプレイ番号 (ホストと被らなさそうな番号に設定している)
ENV HOME=/home/ubuntu \
    DISPLAY=:88 \
    WINEARCH=win64 \
    WINEPREFIX=/home/ubuntu/.wine64

# Wine の初期化
RUN winetricks settings fontsmooth=rgb && \
    wineboot && \
    sudo rm -rf /tmp/*

# Xfce のデスクトップ設定をコピー
COPY --chown=ubuntu:ubuntu ./Xfce/ /home/ubuntu/

# Supervisor の設定ファイルをコピー
COPY ./supervisor.conf /etc/supervisor/conf.d/supervisor.conf

EXPOSE 4510 5510 6510
USER root
CMD ["/usr/bin/supervisord"]

