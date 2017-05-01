# いつでもどこでもコンソール環境

## 実行

```
docker run -d -p 2222:22 --name mycli mycli
```

## ssh

```
ssh -p 2222 kaneshiro@localhost

# パスワードは「 password 」
```

## イメージ作成

```
docker build -t kaneshirc/mycli .
```

## Docker Hub更新

```
docker login
docker push kaneshirc/mycli
```
