---
title: "Chạy server Phoenix với SSL trên localhost"
date: 2018-05-02T22:42:14+07:00
draft: false
author: Dung Nguyen
tags: ["elixir", "til"]
---


> Từ tháng 04/2018 tất cả các app mới tạo trên Facebook chỉ chấp nhận callback url có sử dụng SSL.
> Đây là những bước đơn giản để có thể sử dụng giao thức `https` trên localhost đối với `Phoenix`


**1. Tạo chứng chỉ**  
Run command

```shell
openssl genrsa 1024 > app.key &&
openssl req -new -x509 -nodes -sha1 -days 365 -key ~/app.key > ~/app.cert
```

**2. Copy file**  
`app.key` and `app.cert` file to `priv/keys`

**3. Chỉnh sửa cấu hình**  
file `dev.exs`

```elixir
config :my_app, MyAppWeb.Endpoint,
  http: [port: 4000],
  https: [port: 4443, keyfile: "priv/keys/app.key", certfile: "priv/keys/app.cert"],
```

Access [https://localhost:4443](https://localhost:4443) to use SSL connection
