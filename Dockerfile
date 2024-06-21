# NVIDIAのベースイメージを使用
FROM nvcr.io/nvidia/tensorrt:23.11-py3

# 必要なパッケージをインストール
RUN dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get install -y \
    git \
    sudo \
    curl \
    wget \
    build-essential \
    cmake \
    libboost-all-dev \
    p7zip-full \
    libnss3 \
    libdbus-1-3 \
    libatk1.0-0 \
    libatk-bridge2.0-0 \
    libcups2 \
    libdrm2 \
    libxkbcommon0 \
    libgbm1 \
    libgtk-3-0 \
    dbus \
    wine64 \
    wine32 \
    xvfb \
    clang \
    libc++-dev \
    libc++abi-dev \
    g++-multilib \
    libc6-dev \
    libc6-dev-i386 \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN apt-get update && \
    apt-get install -y fonts-noto-cjk && \
    fc-cache -fv && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

    # Node.jsのインストール
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs

# 新しいユーザーを作成
RUN useradd -m -s /bin/bash falcon && echo 'falcon:falcon' | chpasswd && adduser falcon sudo

# ユーザーの権限を更新
RUN chown -R falcon:falcon /home/falcon

# ユーザーに切り替え
USER falcon

# 作業ディレクトリを作成
WORKDIR /home/falcon/workspace

# Electron Shogiのソースコードをクローン
RUN git clone https://github.com/sunfish-shogi/electron-shogi.git

# Electron Shogiのインストール
WORKDIR /home/falcon/workspace/electron-shogi
RUN npm install
# Electron Shogiのビルド
RUN npm run electron:build
RUN ./dist/ShogiHome-1.15.0.AppImage --appimage-extract


USER root
# YaneuraOuのソースコードをクローン
WORKDIR /home/falcon/workspace
RUN wget https://github.com/yaneurao/YaneuraOu/archive/refs/tags/v8.30git.zip && unzip v8.30git.zip && mv YaneuraOu-8.30git YaneuraOu-8.30
# YaneuraOuのビルド
WORKDIR /home/falcon/workspace/YaneuraOu-8.30/source
RUN make clean tournament TARGET_CPU=AVX2 YANEURAOU_EDITION=YANEURAOU_ENGINE_NNUE && \
    make -j8 tournament TARGET_CPU=AVX2 COMPILER=g++ YANEURAOU_EDITION=YANEURAOU_ENGINE_NNUE ENGINE_NAME="YaneuraOuNNUE"
RUN cp ./YaneuraOu-by-gcc /home/falcon/workspace/YaneuraOuNNUE
# YANEURAOU_ENGINE_NNUE_HALFKP_1024X2_8_32のビルド
RUN make clean tournament TARGET_CPU=AVX2 YANEURAOU_EDITION=YANEURAOU_ENGINE_NNUE_HALFKP_1024X2_8_32 && \
    make -j8 tournament TARGET_CPU=AVX2 COMPILER=g++ YANEURAOU_EDITION=YANEURAOU_ENGINE_NNUE_HALFKP_1024X2_8_32 ENGINE_NAME="YaneuraOuNNUEHalfKP1024x2_8_32"
RUN cp ./YaneuraOu-by-gcc /home/falcon/workspace/YaneuraOuNNUEHalfKP1024x2_8_32
# FukauraOuのビルド
RUN make clean YANEURAOU_EDITION=YANEURAOU_ENGINE_DEEP_TENSOR_RT_UBUNTU && \
    make -j8 tournament COMPILER=clang++ YANEURAOU_EDITION=YANEURAOU_ENGINE_DEEP_TENSOR_RT_UBUNTU ENGINE_NAME="FukauraOuV8.20" TARGET_CPU=AVX2 EXTRA_CPPFLAGS="-DMAX_GPU=1"
RUN cp ./YaneuraOu-by-gcc /home/falcon/workspace/FukauraOuTensorRT

# ポートを公開
EXPOSE 8080

WORKDIR /home/falcon/workspace/electron-shogi/squashfs-root
COPY books /home/falcon/workspace/books
COPY evals /home/falcon/workspace/evals
RUN chown -R falcon:falcon ../../books && chown -R falcon:falcon ../../evals/*
USER falcon

CMD [ "./AppRun" ]