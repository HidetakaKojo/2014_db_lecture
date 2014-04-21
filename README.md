### インスタンス起動

+ RegionがTokyoになっている事を確認
+ EC2のAMIペインに移動
+ searchの条件をPublic imagesに変更
  + ami-11f08b10 を検索
+ それをベースにlaunch
  + m1.mediumを選択
  + 自分で外部からsshできるように
  + いちお外部に出る必要はないけど、ライブラリを追加する場合は必要

