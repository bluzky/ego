---
title: "Cấu hình kết nối HTTPS để test Facebook app trên localhost"
date: 2018-05-08T20:56:31+07:00
draft: false
author: Dung Nguyen
tags: ["tech", "til"]
---

Trong quá trình tìm hiểu về lập trình chat bot sử dụng các API của Facebook Messenger thì việt test chat bot trên localhost là một trở ngại.  

Khi tạo một subscription cho app chat bot, Facebook sẽ gửi một request đến server mà chat bot đang chạy để xác nhận có đúng là chat bot của bạn không. Cũng như sau đó, tất cả những tin nhắn của nguời dùng sẽ đuợc gửi tới chat bot thông qua `callback url`. Và vấn đề là khi dev và test trên localhost thì làm sao để server local của bạn có thể nhận và phản hồi request của Facebook.

Một giải pháp đơn giản là sử dụng dịch vụ của [https://ngrok.com](https://ngrok.com/) để chuyển các request về máy localhost. `ngrok.com` cung cấp gói miễn phí test vô tư, hơn nữa `ngrok` hỗ trợ cả `https`.
Điều này rất quan trọng, bởi vì từ 2018 thì tất cả các `callback url` khi đăng ký ứng dụng trên Facebook Developer đều phải sử dụng kết nối `TLS`.

## Buớc 1: Đăng ký tài khoản
- Đăng ký tại [https://ngrok.com/pricing](https://ngrok.com/pricing)
Vì là tài khoản miễn phí nên sẽ có một số giới hạn:
- 40 kết nối / phút
- Mỗi lần chỉ chạy được 1 `ngrok` process

## Bước 2: Download ngrok và cấu hình API key
- Download tại [https://ngrok.com/download](https://ngrok.com/download)
- Giải nén file vừa Download bạn sẽ có file `ngrok`
- Thêm token vào ngrok config bằng lệnh
 
```shell
$ ./ngrok authtoken <YOUR_AUTH_TOKEN>
```

Bạn có thể copy command trên từ [Dashboard](https://dashboard.ngrok.com/get-started) trong phần `Connect your account`

## Bước 3: Khởi chạy ngrok process
**Chạy lệnh**

```shell
./ngrok http <PORT>
```

trong đó `PORT` là port number của server localhost mà bạn muốn test.
	
**Ouput mẫu của `ngrok`**

![ngrok](/img/ngrok.png)

`ngrok` cung cấp cho bạn 2 public URL để kết nối vào server localhost. 1 URL với giao thức `http` và 1 URL với `https`.
Ngon không nào!

Bây giờ bạn đã có thể cấu hình Facebook để test trên localhost rồi.

**Lưu ý:**  
Khi sử dụng tài khoản Free, mỗi lần chạy `ngrok` thì forwarding URL sẽ khác nhau nên sẽ phải sửa lại sửa lại cấu hình app trên Facebook Developer. Đồ chùa thường là đồ chua mà. Khi sử dụng gói có phí bạn có thể cấu hình forwarding URL theo ý mình. Mình nghèo nên chịu khó thôi.
