### prepearing

##### install gem library

```
shell> cd newbieapp;
shell> bundle install --path=vendor/bundle
```
##### start development environment

```
shell> bundle exec shutgun -o 0.0.0.0
```

##### start production environemnt

計測はproductionで実行しないと速度でないと思います

```
shell> bundle exec unicorn -c unicorn.rb -E production
```

### hands on

アプリケーションをproduction environmentで起動し、
以下のコマンドを実行しなさい。
```
shell> bundle exec ./bin/bench_1.rb
shell> bundle exec ./bin/bench_2.rb
shell> bundle exec ./bin/bench_3.rb
```

SUCCESS の表示を得られれば成功です。
ただし、修正していいのはapp.rbとmysqlのschemaのみです。

上記がクリアした人は以下の機能を追加してください。

+ echoにlike追加してください。
  + echoを表示している箇所にはlikeの数も表示してください。
  + likeの数と一緒にlikeを直近で行ったユーザ3名も表示しなさい
  + 既存のテーブルへのカラム追加は認めません
+ 上記の機能の結果悪化するパフォーマンスを改善しなさい。


