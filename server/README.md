# 動作確認

### 1. DB のセットアップ

```sh
rails db:migrate
```

### 2. Signup の動作確認

```sh
curl -X POST \
  http://localhost:3000/signup \
  -H 'content-type: application/json' \
  --data '{"name": "user1","age": 20,"email": "user1@example.com","password": "password"}'

{"id":1,"name":"user1","age":20,"firebase_uid":"2Sa7adLCuRO3jFssn7xLg7f4aWf1","created_at":"2022-07-23T20:49:39.328Z","updated_at":"2022-07-23T20:49:39.328Z","email":"user1@example.com"}%
```

- firebase console 上で `user1@example.com` が作成されている
- rails console で User が作成されている

この 2 つを確認してデータが存在していれば OK!

### 3. IDToken の取得

先程作成した `user1@example.com` でログインし、IDToken を取得する。

###### 本番での認証認可フロー

1. React から firebase にログインし IDToken を取得
2. Rails にリクエストを送る際に、ヘッダーに IDToken を付与して送信
3. Rails 側で、送られてきた IDToken(JWT) を検証
4. 検証結果に応じて認可、レスポンスを返す

今回の検証では、この JWT(IDToken) をコマンドラインで取得する。

```sh
export API_KEY=[API_KEY] # firebase console -> プロジェクトの設定からコピペ
curl "https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=$API_KEY" -H 'Content-Type: application/json' --data-binary '{"email":"user1@example.com","password":"password","returnSecureToken":true}'

{
    ︙
  "idToken": "eyJhbGci ... "
    ︙
}
```

取得した IDToken (JSON の idToken の値) をコピーし、以下に貼り付ける。

```sh
export ID_TOKEN=[ここにコピペ]
```

### 4. Signin の動作確認

実際にヘッダーに IDToken を付与してリクエストを送ってみる。

<small>※ 本番ではこれを React から実行する(2)が、この検証ではコマンドラインで試す。</small>

このブランチでは、以下のようなルーティングの実装になっている。

```sh
rails routes

 Prefix Verb   URI Pattern          Controller#Action
  posts GET    /posts(.:format)     posts#index
        POST   /posts(.:format)     posts#create
   post GET    /posts/:id(.:format) posts#show
        PATCH  /posts/:id(.:format) posts#update
        PUT    /posts/:id(.:format) posts#update
        DELETE /posts/:id(.:format) posts#destroy        # ② 自身のアカウントに紐づく Post を削除
account GET    /account(.:format)   account#show         # ① 自身のアカウント情報を取得
        PUT    /account(.:format)   account#update
        DELETE /account(.:format)   account#destroy
 signup POST   /signup(.:format)    auth#signup
```

実際に認証が機能しているか、① と ② を試してみる。

#### ① GET /account

```sh
curl http://localhost:3000/account \
  -H "authorization: Bearer $ID_TOKEN" \
  -H 'content-type: application/json'

{"id":1,"name":"user1","age":20,"firebase_uid":"2Sa7adLCuRO3jFssn7xLg7f4aWf1","created_at":"2022-07-23T20:49:39.328Z","updated_at":"2022-07-23T20:49:39.328Z","email":"user1@example.com"}%
```

自分の情報が返ってきていれば OK!

#### ② DELETE /posts/:id

このブランチでは **自身のアカウントに紐づく Post のみ** 削除出来る実装になっている。([実装](./app/controllers/posts_controller.rb))
つまり、自分以外のアカウントに紐づく Post の id を指定しても削除が出来ないことを確認する。

まずは `user1@example.com`(自分) に紐づく Post を作成

```sh
# rails console から作成でも可
rails runner 'User.find(1).posts.create!("title": "u1_post1", "content": "u1_post1")'
```

次に、別のユーザーとそれに紐づく Post を作成

```sh
# rails console から作成でも可
rails runner 'User.new(name: "user2", age: 20, firebase_uid: "xxx").posts.build(title: "u2_post1", content: "u2_post1").save!' # user2 の作成 & user2 に紐づく u2_post1 の作成
```

これで準備 OK!
まずは、自分以外(user2)に紐づく Post の削除が出来ないことを確認する。

```sh
curl -X DELETE \
  http://localhost:3000/posts/2 \          # user2に紐づく PostのIDを指定
  -H "authorization: Bearer $ID_TOKEN" \
  -H 'content-type: application/json'

{"status":404, ... }
```

自分以外のアカウントの Post は削除出来ない(404=存在しない)ことが確認できる。

次に自分のアカウントに紐づく Post を削除出来ることを確認する。

```sh
curl -X DELETE \
  http://localhost:3000/posts/1 \          # user1(自分)に紐づく PostのIDを指定
  -H "authorization: Bearer $ID_TOKEN" \
  -H 'content-type: application/json'

```

何も返ってこなければ OK!
念の為、コンソール上でも削除されていることを確認する。

```sh
# rails console から確認でも可
rails runner 'pp User.find(1).posts'
[]
```
