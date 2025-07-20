# OAuth 2 Test

認証（Authentication）
ユーザーが「本人である」ことを確認するプロセス
例）Webサイトにログインするときに、ユーザー名とパスワードを入力する

認可（Authorization）あるユーザーやアプリが「特定のデータや機能にアクセスできる」ことを許可するプロセス
例）Googleアカウントを使って外部アプリにカレンダーの予定を読み取る権限を与える

セキュリティ向上：パスワードを外部サービスに渡さなくても、認可された範囲内でアクセスを許可できる
ユーザー体験の向上：一度認可すれば、パスワードを入力することなくスムーズにアクセスできる

```bash
docker run --rm \
  --network hydraguide \
  oryd/hydra:v1.10.6 \
  clients create \
    --endpoint http://ory-hydra-example--hydra:4445 \
    --id facebook-photo-backup \
    --secret some-secret \
    --grant-types authorization_code,refresh_token,client_credentials,implicit \
    --response-types token,code,id_token \
    --scope openid,offline,photos.read \
    --callbacks http://127.0.0.1:9010/callback
```


```bash
docker run --rm -it \
  --network hydraguide \
  -p 9010:9010 \
  oryd/hydra:v1.10.6 \
  token user \
    --port 9010 \
    --auth-url http://127.0.0.1:5444/oauth2/auth \
    --token-url http://ory-hydra-example--hydra:4444/oauth2/token \
    --client-id facebook-photo-backup \
    --client-secret some-secret \
    --scope openid,offline,photos.read \
    --skip-tls-verify
```
