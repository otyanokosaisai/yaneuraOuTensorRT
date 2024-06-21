# Shogi AI Docker Environment for GPU(TensorRT)

## 概要
このプロジェクトは、Nvidiaの最近のGPUが搭載されたデバイスにDockerをインストールし、ShogiHome、YaneuraOu、FukauraOuの環境を簡単にセットアップするためのDockerfileを提供します。Dockerを使うことにより、ローカル環境を変更することなくGPU(TensorRT)を用いた将棋AIを利用することができます。また、Dockerを利用するため、再現性が高く、導入の苦労が少ないです。

## 構成
- ShogiHome
- YaneuraOu(TensorRT)
- FukauraOu

## 必要条件
- Nvidia GPUが搭載されたデバイス
- Dockerのインストール
- エンジンと定跡ファイルの準備

## 使用方法
1. リポジトリをクローンします。
   ```sh
   git clone https://github.com/otyanokosaisai/yaneuraOuTensorRT.git
   ```
2. 用いたい将棋AIの評価関数と定跡ファイルを用意して以下のディレクトリ構造を作る
    booksフォルダとevalsフォルダを作成してください。それぞれ定跡ファイルと評価関数が入ります。
    - ディレクトリ構造の例
    ```
    ├── Dockerfile
    ├── books
    │   ├── joseki_book
    │   │   └── standard_book.db
    └── evals
        ├── tensorRT_model
        │   └── model.onnx
        └── nneu_model
            └── nn.bin
    ```
3. コンテナ作成
    ```sh
    docker build -t ShogiContainer .
    ```
4. コンテナ起動
    適宜memoryサイズとcpuのコア数は変更してください。
    ```sh
    docker run -it --name ShogiContainer  --gpus all -v $(pwd):/mnt --shm-size=28g --cpus="30"  -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix \shogi_box2
    ``` 

##　注意
使用するモデルや定跡ファイルのライセンスについては、それぞれのライセンスファイルを確認してください。また、詳細については[やねうら王wiki](https://github.com/yaneurao/YaneuraOu/wiki)を参考にしてください。

## 対応エンジンと評価関数
対応エンジンと評価関数の詳細については、[やねうら王のインストール手順](https://github.com/yaneurao/YaneuraOu/wiki/%E3%82%84%E3%81%AD%E3%81%86%E3%82%89%E7%8E%8B%E3%81%AE%E3%82%A4%E3%83%B3%E3%82%B9%E3%83%88%E3%83%BC%E3%83%AB%E6%89%8B%E9%A0%86#6-%E8%A9%95%E4%BE%A1%E9%96%A2%E6%95%B0%E3%81%AE%E3%82%BF%E3%82%A4%E3%83%97)を参照してください。
エンジンについてはやねうら王(TensorRT), 標準NNUE, NNUE1024のみがビルドされるようになっており、必要であればDockerfileのビルド部に別のエンジンのビルドコマンドを追加して適宜使用してください。
## ライセンス
このプロジェクトはApache License 2.0の下でライセンスされています。詳細は[LICENSE](LICENSE)ファイルを参照してください。
