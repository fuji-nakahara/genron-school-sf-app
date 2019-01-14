# genron-sf-app

https://genron-sf.herokuapp.com/

[超・SF作家育成サイト](http://school.genron.co.jp/works/sf/) の作品を楽しむための [Ruby on Rails](https://rubyonrails.org/) アプリケーション。
  
以下の用途のために作成しました。

- 超・SF作家育成サイトのコンテンツをスクレイピングし、データベースへ保存する
- シンプルな Web UI でコンテンツを閲覧する
- 課題ごとに作品をまとめた電子書籍を作成する
- コンテンツの更新をツイートする

## 要件

- Ruby 2.6
- PostgreSQL 9.2 以降

## 基本的な使い方

### コンテンツをスクレイピングし、データベースへ保存する

はじめに、以下のコマンドで依存ライブラリのインストール、データベースの作成、全コンテンツのスクレイピングを行います。  
超・SF作家育成サイトの全ページに同期的にアクセスするため、 **非常に時間がかかります** 。

    $ bin/setup

### コンテンツを閲覧する

データベースに保存したコンテンツをブラウザで確認するには、以下のコマンドで Web サーバを起動して http://localhost:3000 にアクセスします。

    $ bin/rails server

![スクリーンショット](screenshot.png)

### 作品を電子書籍化する

以下のコマンドを実行すると `output` ディレクトリに課題ごとの作品をまとめた EPUB と MOBI ファイルが作成されます。

    $ bin/rails ebook:subject YEAR=2018 NUMBER=1 # 2018年第1回課題の作品をまとめた電子書籍を作成

## 発展的な使い方

### 作品データを分析する

受講生、課題、梗概、実作といったデータを構造化してデータベースに保存しているため、様々なデータ分析が可能です。  
`Student`, `Subject`, `Synopsis`, `Work` の ActiveRecord モデルを介してアクセスすることもできます。

たとえば、以下のコマンドは2018年度の受講生を梗概の平均字数の多い順に表示します。

    $ bin/rails runner 'p Term.find(2018).students.includes(:synopses).reject { |s| s.synopses.size.zero? }.map { |s| [s.name, s.synopses.map(&:content).map(&:size).sum / s.synopses.size.to_f] }.sort { |a, b| b[1] <=> a[1] }.to_h' 

### コンテンツを定期的に更新する

https://genron-sf.herokuapp.com/ では以下の3つのコマンドを定期実行して、超・SF作家育成サイトの更新を無理のない範囲で反映しています。

    $ bin/rails import:latest && bin/rails tweet
    $ bin/rails import:studetns
    $ bin/rails import:scores 

超・SF作家育成サイト 更新通知 bot (非公式) [@genron_sf_bot](https://twitter.com/genron_sf_bot) は `bin/rails tweet` で運用しています。

## ライセンス

このアプリケーションは [MIT ライセンス](http://opensource.org/licenses/MIT) の下、オープンソースとして提供されています。 

