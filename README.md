# MTBBS-Docker

[MTBBS](https://bunshun.jp/articles/-/7483)というTELNETとFTPとWEBのインターフェイスを持つパソコン通信BBSソフトウェアを、Docker+noVnc+wine+Sshwiftyで実現してみました。といっても、大半は[EDCB-Wine](https://github.com/tsukumijima/EDCB-Wine)から流用させていただきました。フォークって感じでもないので、フォークにはしませんでした。

## 必要なファイルと起動方法
[ういるすねっと](https://bunshun.jp/articles/-/7483)の説明をよく読んでから、[Vector](https://www.vector.co.jp/soft/win95/net/se063239.html)から実行ファイルをダウンロードして、BBSというディレクトリ名で解凍してください。
Windowsの自己解凍形式ですが、Linux環境だとLhasaで解凍できます。
それをこのリポジトリのディレクトリ内に置いて、docker compose up -d(docker-compose up -d)するだけです。

## 細かい設定

基本的にTelnetは公開していません。公開したい方はdocker-compose.ymlを変更してください。
日本語入力を残してありますが、おそらく使い物になりません。節約したい人はfcitx周辺を外しちゃってください。
現実的な編集は"vim -c 'e ++enc=shift_jis' filename.TXT"で直に編集してMyoHostを一度閉じて反映させるほうが良いと思います。

## ライセンス
MTBBSはmyoさんに著作権があります。表記は見つからなかったけど、あるとおもいます。再配布が可能と書いてありますが、バイナリ等は含めていません。Vectorが存続してる間はVectorからダウンロードしてください。
EDCB-WineはMITライセンスなのでtsukumijimaさんにあります。
sshwiftyはGNU AFFERO GENERAL PUBLICライセンスなのでNi Ruiさんにあります。
改変部分はmidyukiにあります。MITライセンスってことにしておけば良いのかな?
