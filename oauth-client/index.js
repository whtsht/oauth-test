import { Buffer } from "node:buffer";
import process from "node:process";
import express from 'express';
import crypto from "node:crypto";
import querystring from "node:querystring";
import fs from "node:fs";
import http from 'node:http';
import open from 'open';

const CLIENT_ID = 'facebook-photo-backup-localhost';
const CLIENT_SECRET = 'some-secret';
const AUTH_URL = 'http://127.0.0.1:5444/oauth2/auth';
const CALLBACK_URL = 'http://localhost:9010/callback';
const SCOPE = 'openid offline photos.read';
const PORT = 9010;

const command = process.argv[2];

if (command === 'auth') {
  startAuthServer();
} else if (command === 'get-name') {
  getUserName();
} else {
  console.log('使用方法:');
  console.log('  node index.js auth      - OAuth2認証を開始');
  console.log('  node index.js get-name  - 保存されたトークンでユーザー名を取得');
  process.exit(1);
}

function startAuthServer() {
  const app = express();
  let state = '';
  let codeVerifier = '';

  app.get('/', (_req, res) => {
    res.send(`
      <h1>OAuth2 Client</h1>
      <a href="/auth">認可フローを開始</a>
    `);
  });

  app.get('/auth', (_req, res) => {
    state = crypto.randomBytes(16).toString('hex');
    codeVerifier = crypto.randomBytes(32).toString('base64url');
    const codeChallenge = crypto.createHash('sha256').update(codeVerifier).digest('base64url');

    const params = {
      response_type: 'code',
      client_id: CLIENT_ID,
      redirect_uri: CALLBACK_URL,
      scope: SCOPE,
      state: state,
      code_challenge: codeChallenge,
      code_challenge_method: 'S256'
    };

    const authUrl = `${AUTH_URL}?${querystring.stringify(params)}`;
    res.redirect(authUrl);
  });

  app.get('/callback', async (req, res) => {
    const { code, state: returnedState } = req.query;

    if (returnedState !== state) {
      return res.status(400).send('State mismatch');
    }

    try {
      const tokenParams = new URLSearchParams({
        grant_type: 'authorization_code',
        code: code,
        redirect_uri: CALLBACK_URL,
        code_verifier: codeVerifier
      });

      const response = await new Promise((resolve, reject) => {
        const options = {
          hostname: '127.0.0.1',
          port: 5444,
          path: '/oauth2/token',
          method: 'POST',
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
            'Authorization': 'Basic ' + Buffer.from(CLIENT_ID + ':' + CLIENT_SECRET).toString('base64')
          }
        };

        const req = http.request(options, (res) => {
          let data = '';
          res.on('data', (chunk) => data += chunk);
          res.on('end', () => resolve({ 
            json: () => Promise.resolve(JSON.parse(data)),
            ok: res.statusCode >= 200 && res.statusCode < 300,
            status: res.statusCode
          }));
        });

        req.on('error', reject);
        req.write(tokenParams.toString());
        req.end();
      });

      const tokens = await response.json();

      fs.writeFileSync('.secret', JSON.stringify(tokens, null, 2));
      console.log('認証成功！トークンを.secretファイルに保存しました');

      res.send(`
        <h1>認証成功！</h1>
        <p>トークンが安全に保存されました。</p>
        <p><strong>ブラウザを閉じてください。</strong></p>
      `);

      setTimeout(() => {
        process.exit(0);
      }, 1000);
    } catch (error) {
      res.status(500).send(`Error: ${error.message}`);
    }
  });

  app.listen(PORT, 'localhost', () => {
    console.log(`OAuth2 client running on http://localhost:${PORT}`);
    console.log('ブラウザで http://localhost:9010 にアクセスして認証を開始してください');
    open(`http://localhost:${PORT}`);
  });
}

async function getUserName() {
  try {
    // .secretファイルからアクセストークンを読み込み
    if (!fs.existsSync('.secret')) {
      console.error('エラー: .secretファイルが見つかりません。');
      console.error('まず "node index.js auth" で認証を行ってください。');
      process.exit(1);
    }

    const secretData = fs.readFileSync('.secret', 'utf8');
    const tokens = JSON.parse(secretData);
    const accessToken = tokens.access_token;

    if (!accessToken) {
      console.error('エラー: アクセストークンが見つかりません。');
      process.exit(1);
    }

    // APIを呼び出してユーザー情報を取得
    const response = await new Promise((resolve, reject) => {
      const options = {
        hostname: 'localhost',
        port: 3000,
        path: '/api/v1/user/profile',
        method: 'GET',
        headers: {
          'Authorization': `Bearer ${accessToken}`
        }
      };

      const req = http.request(options, (res) => {
        let data = '';
        res.on('data', (chunk) => data += chunk);
        res.on('end', () => {
          try {
            const jsonData = JSON.parse(data);
            resolve({
              data: jsonData,
              status: res.statusCode
            });
          } catch (err) {
            reject(new Error(`JSONパースエラー: ${err.message}`));
          }
        });
      });

      req.on('error', reject);
      req.end();
    });

    if (response.status === 200) {
      console.log(`ユーザー名: ${response.data.name}`);
      console.log(`メールアドレス: ${response.data.email}`);
    } else {
      console.error(`エラー: API呼び出しに失敗しました (${response.status})`);
      console.error(`レスポンス: ${JSON.stringify(response.data)}`);
      
      if (response.status === 401) {
        console.error('トークンが無効または期限切れです。再認証してください。');
        console.error('"node index.js auth" を実行してください。');
      }
      process.exit(1);
    }

  } catch (error) {
    console.error(`エラー: ${error.message}`);
    process.exit(1);
  }
}
