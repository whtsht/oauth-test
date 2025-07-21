---

marp: true

---

<style>
.grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 3em;
}
.grid img {
  width: 100%;
  height: auto;
}
h1 {
  position: absolute;
  top: 80px;
  left: 80px;
}
.center-title {
  position: absolute;
  top: 50%;
  left: 10%;
  transform: translateY(-50%);
}
</style>


<h1 class="center-title">OAuth 2.0 を利用したアプリケーションの作成</h1>

---

# Oauth 2.0とは

<div class="grid">
  <div>

  ![](./img/oauth0.svg)

  </div>
  <div>

  ユーザー（リソースオーナー）がサードパーティのアプリケーションにユーザー情報（リソース）へのアクセスを許可するためのフレームワーク
  https://www.rfc-editor.org/rfc/rfc6749

  </div>
</div>

---

# 作成したアプリ概要

Oauth 2.0の認可コードフローを利用して、アプリケーションがユーザーの名前とメールアドレスを取得する

![](./img/app.png)

---

# 認証、認可フロー （認可コードフロー）

<div style="display: flex; justify-content: center; align-items: center; height: 100%; padding-top: 50px;">
  <img src="./img/oauth1.svg" style="width: 700px;">
</div>

---

# 認証、認可フロー

<div style="display: flex; justify-content: center; align-items: center; height: 100%; padding-top: 50px;">
  <img src="./img/oauth2.svg" style="width: 700px;">
</div>

---

# 認証、認可フロー

<div style="display: flex; justify-content: center; align-items: center; height: 100%; padding-top: 50px;">
  <img src="./img/oauth3.svg" style="width: 700px;">
</div>

---

# 認証、認可フロー

<div style="display: flex; justify-content: center; align-items: center; height: 100%; padding-top: 50px;">
  <img src="./img/oauth4.svg" style="width: 700px;">
</div>

---

# 認証、認可フロー

<div style="display: flex; justify-content: center; align-items: center; height: 100%; padding-top: 50px;">
  <img src="./img/oauth5.svg" style="width: 700px;">
</div>

---

# 認証、認可フロー

<div style="display: flex; justify-content: center; align-items: center; height: 100%; padding-top: 50px;">
  <img src="./img/oauth6.svg" style="width: 700px;">
</div>

---

# 認証、認可フロー

<div style="display: flex; justify-content: center; align-items: center; height: 100%; padding-top: 50px;">
  <img src="./img/oauth7.svg" style="width: 700px;">
</div>

---

# 認証、認可フロー

<div style="display: flex; justify-content: center; align-items: center; height: 100%; padding-top: 50px;">
  <img src="./img/oauth8.svg" style="width: 700px;">
</div>

---

# 認証、認可フロー

<div style="display: flex; justify-content: center; align-items: center; height: 100%; padding-top: 50px;">
  <img src="./img/oauth9.svg" style="width: 700px;">
</div>

---

# 認証、認可フロー

<div style="display: flex; justify-content: center; align-items: center; height: 100%; padding-top: 50px;">
  <img src="./img/oauth10.svg" style="width: 700px;">
</div>

---

# リソース取得フロー

<div style="display: flex; justify-content: center; align-items: center; height: 100%; padding-top: 50px;">
  <img src="./img/get1.svg" style="width: 700px;">
</div>

---

# リソース取得フロー

<div style="display: flex; justify-content: center; align-items: center; height: 100%; padding-top: 50px;">
  <img src="./img/get2.svg" style="width: 700px;">
</div>

---

# リソース取得フロー

<div style="display: flex; justify-content: center; align-items: center; height: 100%; padding-top: 50px;">
  <img src="./img/get3.svg" style="width: 700px;">
</div>

---

# リソース取得フロー

<div style="display: flex; justify-content: center; align-items: center; height: 100%; padding-top: 50px;">
  <img src="./img/get4.svg" style="width: 700px;">
</div>

---

# リソース取得フロー

<div style="display: flex; justify-content: center; align-items: center; height: 100%; padding-top: 50px;">
  <img src="./img/get5.svg" style="width: 700px;">
</div>

---

# リソース取得フロー

<div style="display: flex; justify-content: center; align-items: center; height: 100%; padding-top: 50px;">
  <img src="./img/get6.svg" style="width: 700px;">
</div>

---

# 使用ツール

- Ruby on Rails：リソースサーバー

- Ory Hydra：認可サーバー

- Node.js：クライアントアプリケーション

---

<h1 class="center-title">デモ</h1>

---

クライアントアプリケーション（Node.js）
- index.js

認証、認可フロー画面（Ruby on Rails）
- oauth_login_controller.rb（ログイン画面ロジック）
- oauth_login_show.html.erb（ログイン画面ビュー）
- oauth_consent_controller.rb（認可画面ロジック）
- oauth_consent_show.html.erb（認可画面ビュー）

ユーザー情報取得API（Ruby on Rails）
- api_user_controller.rb

Hydraリクエスト（Ruby on Rails）
- hydra_service.rb
