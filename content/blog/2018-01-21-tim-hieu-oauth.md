---
title: Tìm hiểu về Oauth / Oauth hoạt động như thế nào?
date: 2018-01-21
author: Dung Nguyen
tags: ["others", "protocol", 'oauth2']
---

## 1. Oauthh 2 và các khái niệm

### 1.1 Oauth 2 là gì:

`Oauth 2` là bản nâng cấp của giao thức chứng thực Oauth 1.0

### 1.2 Các Role (vai trò) trong mô hình oauth

* **resource owner** là đối tượng có khả năng cấp quyền truy cập tới tài nguyên (resource) được bảo vệ
* **Resource server** là một server lưu trữ các tài nguyên, có khả năng xử lý các yêu cầu truy cập tới tài nguyên được bảo vệ.
* **Client** Ứng dụng muốn truy cập vào protected resource với tư cách của người sở hữu resource
* **Authorization server** là server chuyên cấp access token cho client sau khi resource owner đồng ý cấp phép cho client truy xuất vào resource được bảo vệ

### 1.3 Luồng xử lý của giao thức

```js
+--------+ +---------------+
| |--(A)- Authorization Request ->| Resource |
| | | Owner |
| |<-(B)-- Authorization Grant ---| |
| | +---------------+
| |
| | +---------------+
| |--(C)-- Authorization Grant -->| Authorization |
| Client | | Server |
| |<-(D)----- Access Token -------| |
| | +---------------+
| |
| | +---------------+
| |--(E)----- Access Token ------>| Resource |
| | | Server |
| |<-(F)--- Protected Resource ---| |
+--------+ +---------------+
```

* (A) Ứng dụng client yêu cầu resource owner cấp quyền
* (B) Client nhận được sự cấp phép từ resource owner tùy theo loại grant trong yêu cầu. Nếu được chứng thực, client sẽ được cấp 1 authorization grant
* (C) Client yêu cầu Authorization server xác thực authorization grant từ resource owner.
* (D) Authorization server sẽ kiểm tra và xác nhận authorization grant. Nếu được xác thực, Client sẽ nhận được access token
* (E) Client request resource từ resource server, dính kèm access token trong request.
* (F)Resource Server sẽ kiểm tra tính hợp lệ của access token. Nếu token hợp lệ, resource theo yêu cầu sẽ được cấp phát.

### 1.4 Authorization Grant

Authorization grant là một chứng nhận xác định những resource nào đã được cấp quyền truy cập bởi chủ sở hữu của resource. Nó được sử dụng bởi ứng dụng client để đổi lấy access token.
Có 4 loại authorization grant:

* Authorization code
* Implicit
* Resource owner password credential
* Client credential

#### 1.4.1 Authorization code

Authorization code được cấp phát trong mô hình mà server ủy quyền đóng vai trò trung gian giữa client và resource owner. Client sẽ chuyển resource owner tới server ủy quyền. Sau khi resource owner đồng ý, server ủy quyền sẽ trả về cho clien authorization code

#### 1.4.2 Implicit

Implicit grant là sự bản đơn giản hóa của Authorization code, thường được dùng trên các ứng dụng không có khả năng bảo mật authorization grant. Ví dụ như web browser hoặc ứng dụng mobile. Thay vì tạo ra các authorization code, client được nhận trực tiếp access token.
Do sự đơn giản hóa của nó nên implicit grant dễ bị tấn công, và các vấn đề về bảo mật.

#### 1.4.3 Resource Owner Password Credentials

Đây là phương thức xác thực trong đó ứng dụng clieownernt sẽ dùng username và password của người dùng/ resource owner để xác thực với server ủy quyền. Sau khi xác thực thì server ủy quyền sẽ trả về cho ứng dụng client access token và refresh token. Do đó ứng dụng client không cần phải lưu thông tin đăng nhập của resource owner.
Kiểu chứng thực này chỉ được sử dụng trên những ứng dụng của đối tác có độ tin cậy cao.

### 1.4 Các khái niệm khác

#### 1.4.1 Access token

* Access token là những chứng nhận dùng để truy cập vào những tài nguyên được bảo vệ. Access token là một chuỗi ký tự, chứa thông tin về chứng nhận được cấp cho ứng dụng client như: thời gian hết hạn, phạm vi tài nguyên được sử dụng ....
* Access token có thể dùng để định danh người dùng. nó dùng để lấy thông tin của resource owner hoặc bản thân nó chứa thông tin của resource owner.
* Access token giúp cho việc xác thực đơn giản hơn. 4 cách yêu cầu cấp quyền từ resource owner đều tạo ra access token do đó resource server không cần phải biết phương thức chứng thực nào được sử dụng. Nó chỉ cần biết sử dụng access token là đủ.

#### 1.4.2 Refresh token

* Refresh token là chứng chỉ được sử dụng để trao đổi lấy access token. Nó được trả về cùng với authorization grant, và được dùng để yêu cầu cấp mới access token khi access token hiện tại hết hạn.
* Refresh token được sử dụng với server ủy quyền, không sử dụng với resource server.

```js
+--------+                                           +---------------+
  |        |--(A)------- Authorization Grant --------->|               |
  |        |                                           |               |
  |        |<-(B)----------- Access Token -------------|               |
  |        |               & Refresh Token             |               |
  |        |                                           |               |
  |        |                            +----------+   |               |
  |        |--(C)---- Access Token ---->|          |   |               |
  |        |                            |          |   |               |
  |        |<-(D)- Protected Resource --| Resource |   | Authorization |
  | Client |                            |  Server  |   |     Server    |
  |        |--(E)---- Access Token ---->|          |   |               |
  |        |                            |          |   |               |
  |        |<-(F)- Invalid Token Error -|          |   |               |
  |        |                            +----------+   |               |
  |        |                                           |               |
  |        |--(G)----------- Refresh Token ----------->|               |
  |        |                                           |               |
  |        |<-(H)----------- Access Token -------------|               |
  +--------+           & Optional Refresh Token        +---------------+
```

Figure 2: Refreshing an Expired Access Token

* (A) Client gửi authorization grant và yêu cầu server ủy quyền cấp access tocken và refresh token
* (B) server ủy quyền xác thực client và authorization grant. Nếu hợp lệ, nó sẽ tạo ra access token và refresh token và trả về cho client
* (C) Client yêu cầu truy xuất tới resource được bảo vệ sử dụng access token
* (D) Resource server kiểm tra access token, nếu hợp lệ, thực hiện yêu cầu từ client.
* (E) bước (C) và (D) được lặp lại cho tới khi access token hết hạn. Nếu client biết access token hết hạn, nó sẽ chủ động chuyển qua bước (G), nếu không nó sẽ gửi request mới.
* (F) Phát hiện access token hết hạn, resource server trả về lỗi access token không hợp lệ.
* (G) Client gửi refresh token lên server ủy quyền và yêu cầu cấp phát access token mới.
* (H) server ủy quyền kiểm tra thông tin client và refresh token, nếu hợp lệ, nó sẽ cấp phát access token và có thể là cả refresh token mới

## 2. Đăng ký client

> Trước khi có thể sử dụng giao thức oauth 2, client phải đăng ký với server ủy quyền. Việc đăng ký tùy thuộc vào server
> Thông tin đăng ký có thể bao gồm:
>
> * Loại client
> * redirection URI
> * Một số thông tin khác: mô tả, tên ứng dụng ....

### 2.1 Loại Client

Oauth định nghĩa 2 loại client:

* **confidential**(bí mật): client có khả năng lưu trữ và bảo mật các chứng nhận được cấp.
* **public** (công khai): client không thể bảo vệ các chửng nhận được cấp một cách bí mật.

Việc phân loại này dựa trên các loại ứng dụng sau:

* **Ứng dụng web**: là một loại client bí mật(confidential) chạy trên web server. Resource owner truy cập tới ứng dụng web thông qua browser. Các chứng nhận được cấp cũng như access token được lưu trữ trên server và resource owner không thể đọc những thông tin này.
* **Ứng dụng trên nền browser**: là loại public client trong đó code của ứng dụng client được tải về và chạy trên thiết bị của người dùng. Các chứng nhận, access token có thể dễ dàng truy cập bởi người sử dụng.
* **Ứng dụng native**: là một dạng public client, được cài và thực thi trên thiết bị của người dùng. Các dữ liệu của giao thức và các dữ liệu bí mật như access token có thể được truy xuất bởi người dùng với giả sử rằng ứng dụng có thể bị tách ra(extracted). Tuy nhiên ứng dụng có thể định nghĩa một số phương thức bảo vệ các thông tin bí mật của giao thức. Tùy vào nền tảng(platform) các thông tin này có thể được bảo vệ tránh sự truy xuất của các ứng dụng khác trên cùng thiết bị.

### 2.2 Định danh client (client identifier)

Với mỗi client đăng ký, server ủy quyền sẽ tạo ra một chuỗi duy nhất để xác định client đó(được gọi là client identifier). Client identifier được công khai, được dùng để server ủy quyền kiểm tra liệu client có hợp lệ hay không.

### 2.3 Chứng thực client

Đối với loai client bí mật(confidential), client và server ủy quyền thiết lập một phương pháp phù hợp để xác thực client. Phương thức xác thực này là tùy vào client và server

### 2.4 Mật khẩu của client

* Nếu client sử dụng password. Nó có thể dùng mô hình chứng thực cung cấp bởi giao thức HTTP(RFC2617). Định danh của client được mã hóa sử dụng thuật toán "application/x-www-form-urlencoded". Giá trị sau khi mã hóa được sử dụng như mật khẩu của client. server ủy quyền phải hỗ trợ mô hình chứng thực của giao thức HTTP.
* Một cách khác, server ủy quyền có thể hỗ trợ việc gửi thông tin của client trong thân của request( request-body) với các tham số: - client_id [REQUIRED]: định danh của client - client_secret [REQUIRED]: chuỗi bí mật của client  
  **Ví dụ:**

```
POST /token HTTP/1.1
    Host: server.example.com
    Content-Type: application/x-www-form-urlencoded

    grant_type=refresh_token&refresh_token=tGzv3JOkF0XG5Qx2TlKWIA
    &client_id=s6BhdRkqt3&client_secret=7Fjfp0ZBr1KtDRbnfVdmIw
```

> Phương pháp gửi thông tin client qua request-body không được khuyến khích sử dụng. Bởi vì nó dễ bị tấn công hơn so với phương pháp đầu tiên.

## 3. Các điểm cuối của giao thức (Protocol Endpoint)

Tiến trình chứng thực trên server có 2 điểm cuối(endpoint)

* **Authorization endpoint** : được sử dụng bởi client để yêu cầu sự xác nhận từ resource owner thông qua user-agent(thường là browser).
* **Token endpoint**: được sử dụng bởi client để trao đổi authorization grant lấy access token.

Phía client chỉ có 1 điểm cuối:

* **Redirection endpoint**: là điểm mà server ủy quyền dùng để trả về thông tin cho client thông qua user-agent(thường là browser) của resource owner

> Không phải tất cả các kiểu chứng thực đều tạo ra 2 endpoint. Một số kiểu chứng thực mở rộng có thể tạo ra các endpoint khác

### 3.1 Authorization Endpoint(sơ lược)

Authorization endpoint được sử dụng để tương tác với resource owner, yêu cầu sự cấp quyền từ resource owner. server ủy quyền trước tiên phải xác thực resource owner.

#### 3.1.1 Response type (kiểu trả về)

Đối với trường hợp **authorization endpoint** được sử dụng bởi _authorization code_ và _implicit_ grant, client thông báo với server ủy quyền kiểu cấp quyền sử dụng tham số:
`response_type` [REQUIRED] có thể là một trong 2 giá trị sau:

* `code` --> yêu cầu sử dụng kiểu _authorization code_
* `token` --> yêu cầu cấp phát access token (sử dụng cho _implicit_)

có thể mở rộng `response_type` tùy nhu cầu. Có thể cùng lúc request nhiều `response_type`; các gía trị phải cách nhau bằng khoảng trắng.

### 3.2 Redirection Endpoint (sơ lược)

* Sau khi yêu cầu cấp quyền xong, server ủy quyền chuyển hướng user-agent vào redirection URI lúc đăng ký client. Request này chứa các thông tin về chứng chỉ đã được cấp phát cho client.
* Một client có thể đăng ký nhiều redirection URI. Nếu không có URI nào được đăng ký thì rất dễ bị tấn công. Nếu nhiều URI được đăng ký, thì lúc yêu cầu chứng thực, client phải gửi kèm tham số `redirect_uri`. server ủy quyền sẽ tìm URI giống với trong request để trả về các chứng nhận

### 3.3 Token endpoint (sơ lược)

Token endpoint được sử dụng bởi client, là nơi xác thực authorization grant và trả vê access token và refresh token cho client.

### 3.4 Phạm vi(scope) của access token

* Authorization endpoint và Token endpoint cho phép client xác định phạm vi/ giới hạn truy xuất của request thông qua tham số `scope`. Sau khi được cấp quyền, authorization server sử dụng `scope` để xác định các giới hạn/ phạm vi được quyền truy cập đối với access token được trả về.
* Scope được thể hiện dưới dạng một chuỗi gồm nhiều scope cách nhau bằng khoảng trắng.
* Nếu scope của access token được cấp phát giống với scope trong request của client thì server có thể bỏ qua tham số `scope` trong response. Nếu scope khác với trong request thì bắt buộc phải trả về tham số `scope` trong response.

## 4. Lấy ủy quyền (Obtain authorization)

Để yêu cầu một access token, client cần phải nhận được sự ủy quyền từ resource owner. Sự ủy quyền được thể hiện dưới dạng authorization grant. Client sử dụng nó để yêu cầu lấy một access token.
Có 4 loại cấp quyền: authorization code, implicit, resource owner password credentials, và client credentials.

### 4.1 Cấp quyền sử dụng code thay thế cho ủy quyền (Athorization code grant)

* Kiểu này sử dụng để yêu cầu cả access token và refresh token, thường dùng với confidential client.
* Kiểu cấp quyền này dựa trên redirection (chuyển hướng) nên client phải có thể tương tác với user-agent (browser) cà nhận request thông qua redirection từ server ủy quyền.
* Sơ đồ:

```
     +----------+
     | Resource |
     |   Owner  |
     |          |
     +----------+
          ^
          |
         (B)
     +----|-----+          Client Identifier      +---------------+
     |         -+----(A)-- & Redirection URI ---->|               |
     |  User-   |                                 | Authorization |
     |  Agent  -+----(B)-- User authenticates --->|     Server    |
     |          |                                 |               |
     |         -+----(C)-- Authorization Code ---<|               |
     +-|----|---+                                 +---------------+
       |    |                                         ^      v
      (A)  (C)                                        |      |
       |    |                                         |      |
       ^    v                                         |      |
     +---------+                                      |      |
     |         |>---(D)-- Authorization Code ---------'      |
     |  Client |          & Redirection URI                  |
     |         |                                             |
     |         |<---(E)----- Access Token -------------------'
     +---------+       (w/ Optional Refresh Token)

   Note: Các đường thẳng minh hoạ bước (A), (B), và (C) được chia thành 2 phần bởi vì chúng được thực hiện thông qua user agent

                     Figure 3: Quá trình cấp code ủy quyền
```

* (A)client khởi tạo luồng xử lý bằng việc chuyển hướng user-agent(browser) của resource owner tới authorizatio endpoint. Client gửi kèm theo định danh của nó được server ủy quyền cấp, phạm vi quyền hạn (scope), redirection URI.
* (B)Server ủy quyền sẽ xác thực resource owner (yêu cầu đăng nhập) và yêu cầu resource owner quyết định đồng ý hay từ chối yêu cầu cấp quyền.
* (C) Giả sử resource owner đồng ý cấp quyền, server ủy quyền sẽ chuyển hướng user-agent đến clien sử dụng redirection URI, kèm theo đó là auhthorization code (code xác nhận ủy quyền).
* (D) Client yêu cầu cấp access token tới server ủy quyền, kèm theo đó là authorization code từ bước (C) vả redirection URI.
* (E) Server ủy quyền xác thực client, kiểm tra sự hợp lệ của authorization code và redirection URI. Nếu tất cả đều hợp lệ, server xác thực sẽ trả về cho client access token và có thể gồm refresh token.

#### 4.1.1 Yêu cầu ủy quyền (Authorization request)

Client tạo 1 request với các tham số sau, sử dụng định dạng `application/x-www-form-urlencoded`

* `response_type` [REQUIRED] phải có giá trị là `code`
* `client_id` [REQUIRED] định danh của client, được nói trong phần 2
* `redirect_uri` [OPTIONAL] url chuyển hướng đến sau khi được ủy quyền
* `scope` [OPTIONAL] giới hạn/phạm vi của request được ủy quyền. Trong phần 3.4
* `state` [RECOMMENDED]. được sử dụng bởi client để truyền thông tin trạng thái từ request và callback. Server ủy quyền sẽ gửi kèm `state` khi chuyển hướng tới redirec URI. `state` nên được sử dụng để ngăn chặn kiểu tấn công [cross-site request forgery](http://en.wikipedia.org/wiki/Cross-site_request_forgery).
  **Ví dụ**

```
GET /authorize?response_type=code&client_id=s6BhdRkqt3&state=xyz
       &redirect_uri=https%3A%2F%2Fclient%2Eexample%2Ecom%2Fcb HTTP/1.1
   Host: server.example.com
```

#### 4.1.2 Kết quả nếu thành công (Authorization response)

Nếu resource server đồng ý cấp quyền truy cập, server ủy quyền sẽ sinh ra một code xác nhận ủy quyền (authorization code) và trả về cho client thông qua redirection URI với các tham số sau:

* `code` [REQUIRED] code ủy quyền được sinh ra bởi server ủy quyền. Nó phải hết hạn trong khoảng thời gian ngắn, khuyến khích tối đa là 10 phút để tránh bị rò rỉ. clien chỉ được sử dụng authorization code 1 lần. Nếu nhiều hơn 1 lần thì server ủy quyền phải từ chối và nên hủy bỏ các access token đã cấp sử dụng authorization code đó ngay khi có thể.
* `state` [REQUIRED] nếu tham số `state` được gửi đi trong authorization request thì nó sẽ được nhận lại nguyên vẹn ở client.
  **Ví dụ**

```
HTTP/1.1 302 Found
    Location: https://client.example.com/cb?code=SplxlOBeZQQYbYS6WxSbIA
              &state=xyz
```

Client phải bỏ qua tất cả các tham số khác nếu có.

#### 4.1.3 Kết quả trả về nếu bị lỗi (Error response)

Nếu yêu cầu ủy quyền thất bại, server ủy quyền phải thông báo cho client biết lý do và không được tự động chuyển hướng qua redirection URI không hợp lệ.
Lỗi nên được trả về thông qua redirection URI với các tham số sau:

* `error` [REQUIRED] một chuỗi ký tự ASCII trong các lỗi sau: - `unauthorized_client`: client không được ủy quyền để yêu cầu authorization code - `access_denied`: resource owner hoặc server ủy quyền từ chối request - `unsupported_response_type`: server ủy quyền không hỗ trwoj việc lấy authorization code sử dụng phương thức này. - `invalid_scope`: scope trong yêu cầu cấp quyền không hợp lệ. - `server_eror`: server ủy quyền gặp một lỗi không xác định nên nó không thể thực hiện việc cấp ủy quyền được. - `temporarily_unavailable`: server ủy quyền tạm thời không thể xử lý yêu cầu vì một lý do nào đó.
* `error_description` [OPTIONAL] chuỗi ký tự cung cấp thông tin chi tiết về lỗi mà con người có thể đọc được
* `error_uri` [OPTIONAL] một URI dẫn tới một trang web cung cấp thông tin về lỗi
* `state` [REQUIRED] bắt buộc phải có nếu trong request gửi lên server có kèm theo tham số `state`.

#### 4.1.4 Yêu cầu cấp Access token

Client gửi yêu cầu cấp token tới token endpoint cùng với các tham số sau sử dụng kiểu định dạng( format) `application/x-www-form-urlencoded`.

* `grant_type` [REQUIRED] giả trị phải là `authorization_code`.
* `code` [REQUIRED] authorization code nhận được từ server ủy quyền.
* `redirect_uri` [REQUIRED] cần phải có nếu tham số `redirect_uri` được gửi đi lúc yêu cầu ủy quyền trong phần 4.1.1
* `client_id` [REREQUIRED] định danh của lient
  **Ví dụ:**

```javascript
	POST /token HTTP/1.1
    Host: server.example.com
    Authorization: Basic czZCaGRSa3F0MzpnWDFmQmF0M2JW
    Content-Type: application/x-www-form-urlencoded

    grant_type=authorization_code&code=SplxlOBeZQQYbYS6WxSbIA
    &redirect_uri=https%3A%2F%2Fclient%2Eexample%2Ecom%2Fcb
```

Server ủy quyền phải:

* Yêu cầu client chứng thực đối với confidential client
* Đảm bảo rằng authorization code được cấp phát cho đúng client. Nếu client là public thì đảm bảo rằng code được cấp đúng cho `client_id` trong request
* Kiểm tra authorization code có còn hợp lệ hay không
* Đảm bảo tham `redirect_uri` được gửi nếu `redirect_uri` đã được gửi trong yêu cầu 4.1.1

#### 4.1.5 Kết quả cấp access token

Nếu yêu cầu hợp lệ và quá trình cấp phát thành công, server ủy quyền sẽ tạo ra một access token và có thể kèm theo refresh token. Nếu yêu cầu thất bại thì server sẽ trả về lỗi được trình bày trong phàn 5.2.
**Ví dụ:**

```javascript
	HTTP/1.1 200 OK
    Content-Type: application/json;charset=UTF-8
    Cache-Control: no-store
    Pragma: no-cache

    {
      "access_token":"2YotnFZFEjr1zCsicMWpAA",
      "token_type":"example",
      "expires_in":3600,
      "refresh_token":"tGzv3JOkF0XG5Qx2TlKWIA",
      "example_parameter":"example_value"
    }
```

### 4.2 Implicit grant

Implicit grant được sử đụng để lấy access token (không hỗ trợ refresh token) và được sử dụng trong các client công khai.
Sơ đồ hoạt động:

```
	 +----------+
    | Resource |
    |  Owner   |
    |          |
    +----------+
         ^
         |
        (B)
    +----|-----+          Client Identifier     +---------------+
    |         -+----(A)-- & Redirection URI --->|               |
    |  User-   |                                | Authorization |
    |  Agent  -|----(B)-- User authenticates -->|     Server    |
    |          |                                |               |
    |          |<---(C)--- Redirection URI ----<|               |
    |          |          with Access Token     +---------------+
    |          |            in Fragment
    |          |                                +---------------+
    |          |----(D)--- Redirection URI ---->|   Web-Hosted  |
    |          |          without Fragment      |     Client    |
    |          |                                |    Resource   |
    |     (F)  |<---(E)------- Script ---------<|               |
    |          |                                +---------------+
    +-|--------+
      |    |
     (A)  (G) Access Token
      |    |
      ^    v
    +---------+
    |         |
    |  Client |
    |         |
    +---------+

  Note: Đường thẳng minh họa các bước (A) và (B) được chia thành 2 phần vì chúng được chuyển thông qua user-agent.

                      Figure 4: Implicit Grant Flow
```

* (A) client khởi tạo luồng chứng thực bằng việc chuyển hướng user-agent của resource owner tới authentication endpoint. Client gửi kèm theo đó là định danh client, phạm vi/giới hạn yêu cầu, trạng thái hiện tại và URI chuyển hướng sau khi được ủy quyền.
* (B) Server ủy quyền sẽ xác thực người dùng, và hỏi người dùng có chấp nhận ủy quyền hay từ chối yêu cầu từ client.
* (C) giả sử resource owner được cấp quyền truy cập, server ủy quyền sẽ chuyển hướng user-agent đến redirection URI trong bước (A) kèm theo access token trong URI fragment(phần sau dấu # trên URL)
* (D) user-agent giữ lại thông tin về access token và chuyển hướng tới redirection URI của ứng dụng web.
* (E) ứng dụng web của client trả về một trag web với khả lấy và sử dụng access token trên user-agent.
* (F) user-agent thực thi các script từ ứng dụng web để lấy access token .
* (G) user-agent chuyển access token cho client sử dụng.

#### 4.2.1 Yêu cầu ủy quyền:

Client tạo một request với các tham số sau, sử dụng định dạng `application/x-www-form-urlencoded`.

* `response_type` [REQUIRED] giá trị phải là `token`
* `client_id` [REQUIRED] định đanh của client
* `redirect_uri` [OPTIONAL] (đã nói ở phần trước).
* `scope` [OPTIONAL] (đã nói ở phần trước).
* `state` [RECOMMENDED] (giống như authorization code grant)

**Ví dụ:**

```
	GET /authorize?response_type=token&client_id=s6BhdRkqt3&state=xyz
        &redirect_uri=https%3A%2F%2Fclient%2Eexample%2Ecom%2Fcb HTTP/1.1
    Host: server.example.com
```

Server ủy quyền sẽ kiểm tra request để đảm bảo các tham số đầy đủ và hợp lệ.
Nếu tất cả thông tin đều hợp lệ thì server ủy quyền sẽ chứng thực resource owner và hỏi việc cấp quyền từ resource owner.
Sau khi hoàn tất, server sẽ chuyển thông tin về cho client thông qua redirection URI

#### 4.2.2 Access token trả về

Nếu resource owner chấp nhận yêu cầu ủy quền thì server sẽ trả về trong redirection URI với các tham số sau:

* `access_token` [REQUIRED] access token cấp phát bởi server
* `token_type` [REQUIRED] loại token được cấp phát. Trình bày trong phần 7
* `expired_in` [RECOMMENDED] thời gian sống của access token tính theo giây
* `scope` [OPTIONAL] tùy chọn nếu giống với scope trong request, bắt buộc trả về trong trường hợp ngược lại.
* `state` bắt buộc nếu trong request có gửi kèm tham số state

Server không được trả về `refresh_token`

**Ví dụ**

```
	HTTP/1.1 302 Found
    Location: http://example.com/cb# access_token=2YotnFZFEjr1zCsicMWpAA
              &state=xyz&token_type=example&expires_in=3600
```

#### 4.2.3 Lỗi trả về

Nếu quá trình xin ủy quyền thất bại thì server sẽ trả về các tham số sau trong thông qua redirect URI

* `error` [REQUIRED] một chuỗi ký tự ASCII chứa mã lỗi trong những chuỗi sau: - `invalid_request` request thiếu tham số hoặc các tham số không hợp lệ. - `unauthorized_client` client không được ủy quyền đối với phương pháp này. - `access_denied` rresource ơnowner từ chối ủy quyền cho client. - `unsupported_response_type`server ủy quyền không hỗ trợ phương thức ủy quyền này. - `invalid_scope` quyền hạn yêu cầu không hợp lệ, sai định đạng. - `server_error` lỗi server không thể tiếp tục quá trình xin cấp ủy quyền. - `temporarily_unavailable` server tạm thời không thể xử lý yêu cầu xin cấp ủy quyền.
* `error_description` [OPTIONAL] mô tả chi tiết của lỗi xảy ra.
* `error_uri` một URI dẫn tới mội trang web chứa thông tin chi tiết về lỗi xảy ra.
* `state` bắt buộc phải có nếu trong request có gửi kèm tham số state.

**Ví dụ:**

```
   HTTP/1.1 302 Found
   Location: https://client.example.com/cb# error=access_denied&state=xyz
```

### 4.3 Cấp quyền sử dụng thông tin đăng nhập của resource owner.

Chỉ nên sử dụng khi client và resource owner có mối quan hệ tin tưởng lẫn nhau.

Luồng xử lý:

```
    +----------+
    | Resource |
    |  Owner   |
    |          |
    +----------+
         v
         |    Resource Owner
        (A) Password Credentials
         |
         v
    +---------+                                  +---------------+
    |         |>--(B)---- Resource Owner ------->|               |
    |         |         Password Credentials     | Authorization |
    | Client  |                                  |     Server    |
    |         |<--(C)---- Access Token ---------<|               |
    |         |    (w/ Optional Refresh Token)   |               |
    +---------+                                  +---------------+

           Figure 5: Resource Owner Password Credentials Flow
```

* (A) resource owner cung cấp thông tin username, password cho client.
* (B) Client yêu cầu server ủy quyền cấp access token cho nó, kèm theo đó là thông tin đăng nhập của resource owner. Đồng thời server ủy quyền cũng chứng thực client.
* (C) server ủy quyền kiểm tra tất cả các thông tin, nếu hợp lệ nó sẽ tạo access token và trả về cho client.

#### 4.3.1 Yêu cầu access token

Client sau khi lấy được thông tin đăng nhập của resource owner , tạo một request kèm các thông số sau, sử dụng format `"application/x-www-form-urlencoded"`

* `grant_type` [REQUIRED] giá trị phải là `"password"`.
* `user_name` [REQUIRED] username của resource owner.
* `password` [REQUIRED] password của resource owner.
* `scope` [OPOPTIONAL] phạm vi quyền hạn được ủy quyền.

**Ví dụ:**

```javascript
	POST /token HTTP/1.1
    Host: server.example.com
    Authorization: Basic czZCaGRSa3F0MzpnWDFmQmF0M2JW
    Content-Type: application/x-www-form-urlencoded

    grant_type=password&username=johndoe&password=A3ddj3w
```

#### 4.3.2 Kết quả access token

Nếu quá trình xin ủy quyền thực hiện thành công. Server ủy quyền tạo ra access token và có thể cả refresh token và trả về cho client

**Ví dụ:** cấp phát thành công

```javascript
 HTTP/1.1 200 OK
   Content-Type: application/json;charset=UTF-8
   Cache-Control: no-store
   Pragma: no-cache

   {
     "access_token":"2YotnFZFEjr1zCsicMWpAA",
     "token_type":"example",
     "expires_in":3600,
     "refresh_token":"tGzv3JOkF0XG5Qx2TlKWIA",
     "example_parameter":"example_value"
   }
```

### 4.4 Cấp quyền bằng thông tin chứng thực của client

Client có thể yêu cầu cấp access token sử dung thông tin chứng thực của chính nó.
Kiểu ủy quyền này chỉ được sử dụng cho confidential client.

Luồng xử lý:

```
    +---------+                                  +---------------+
    |         |                                  |               |
    |         |>--(A)- Client Authentication --->| Authorization |
    | Client  |                                  |     Server    |
    |         |<--(B)---- Access Token ---------<|               |
    |         |                                  |               |
    +---------+                                  +---------------+

                    Figure 6: Client Credentials Flow
```

* (A) client chứn thực nó với server ủy quyền và yêu cầu cấp access token từ token endpoint.
* (B) server ủy quyền chứng thực client, nếu hợp lệ, cấp một access token.

#### 4.4.1 Yêu cầu cấp Access token

Client gửi tạo một request với các tham số sau, sử dụng format `"application/x-www-form-urlencoded"`:

* `grant_type` [REREQUIRED] giá trị bắt buộc là `client_credentials`.
* `scope` [OPTIONAL] phạm vi quyền hạn được ủy quyền.

**Ví dụ:**

```
    POST /token HTTP/1.1
    Host: server.example.com
    Authorization: Basic czZCaGRSa3F0MzpnWDFmQmF0M2JW
    Content-Type: application/x-www-form-urlencoded

    grant_type=client_credentials
```

#### 4.4.2 Kết quả access token

Nếu quá trình chứng thực thành công thì server trả về cho client access token nhưng không nên gửi refresh token.
**Ví dụ:**

```javascript
	HTTP/1.1 200 OK
    Content-Type: application/json;charset=UTF-8
    Cache-Control: no-store
    Pragma: no-cache

    {
      "access_token":"2YotnFZFEjr1zCsicMWpAA",
      "token_type":"example",
      "expires_in":3600,
      "example_parameter":"example_value"
    }
```

### 4.5 Mở rộng kiểu cấp ủy quyền

Client sử dụng kiểu cấp ủy quyền mở rộng bằng cách thay đổi giá trị của tham số `grant_type` trong request gửi tới token endpoint và thêm các tham số khác nếu cần thiết.

**PHẦN NÀY KHÔNG DỊCH CHI TIẾT**

## 5 Cấp phát access token

### 5.1 Kết quả trả về nếu thành công

Các thông tin trả về được chứa trong body của gói tin HTTP trả về với mã lỗi 200. Các tham số:

* `access_token` [REQUIRED] access token được cấp.
* `token_type` [REQUIRED] loại token được cấp phát. xem phần 7
* `expires_in` [RECOMMENDED] thời gian sống của access token.
* `refresh_token` [OPTIONAL] token dùng để xin cấp lại access token khi hết hạn.
* `scope` [OPTIONAL] nếu scope giống với trong request. [REQUIRED] nếu khác với trong request.

_Các tham số được chứa trong thân của của HTTP response có định dạng `"application/json"`_
**Server ủy quyền phải kèm theo header "Cache-Control" trong gói response với giá trị là "no-store"**

**Ví dụ:**

```javascript
	HTTP/1.1 200 OK
    Content-Type: application/json;charset=UTF-8
    Cache-Control: no-store
    Pragma: no-cache

    {
      "access_token":"2YotnFZFEjr1zCsicMWpAA",
      "token_type":"example",
      "expires_in":3600,
      "refresh_token":"tGzv3JOkF0XG5Qx2TlKWIA",
      "example_parameter":"example_value"
    }
```

Client phải bỏ qua các tham số khác không được xách định ở trên.

### 5.2 Lỗi trả về

Nếu quá trình xin ủy quyền thất bại thì server sẽ trả về các tham số sau trong thông qua redirect URI

* `error` [REQUIRED] một chuỗi ký tự ASCII chứa mã lỗi trong những chuỗi sau: - `invalid_request` request thiếu tham số hoặc các tham số không hợp lệ. - `invalid_client` việc chứng thực client thất bại. - `invalid_grant` phương pháp thực hiện việc cấp quền hoặc refresh token không hợp lệ, hết hạn, bị hủy bỏ, redirection URI không đúng. - `unauthorized_client` client không được ủy quyền đối với phương pháp này. - `unsupported_response_type`server ủy quyền không hỗ trợ phương thức ủy quyền này. - `invalid_scope` quyền hạn yêu cầu không hợp lệ, sai định đạng.
* `error_description` [OPTIONAL] mô tả chi tiết của lỗi xảy ra.
* `error_uri` một URI dẫn tới mội trang web chứa thông tin chi tiết về lỗi xảy ra.

Các tham số này được chứa trong body của response sử dụng loại media `"application/json"`

**Ví dụ:**

```javascript
    HTTP/1.1 400 Bad Request
    Content-Type: application/json;charset=UTF-8
    Cache-Control: no-store
    Pragma: no-cache

    {
      "error":"invalid_request"
    }
```

## 6 Làm mới access token

Client gửi request tới token endpoint với các tham số sau sử dụng format `"application/x-www-form-urlencoded"`:

* `grant_type` [REQUIRED] giá trị phải là `refresh_token`.
* `refresh_token` [REQUIRED] chuỗi refresh token.
* `scope` [OPTIONAL] phạm vi quyền hạn truy cập, các quyền ở đây phải là những quyền nằm trong scope lúc yêu cầu cấp access token. Nếu không có tham số scope thì mặc định phạm vi quyền hạn sẽ giống như lúc yêu cầu cấp phát access token.

**Ví dụ:**

```
	POST /token HTTP/1.1
    Host: server.example.com
    Authorization: Basic czZCaGRSa3F0MzpnWDFmQmF0M2JW
    Content-Type: application/x-www-form-urlencoded

    grant_type=refresh_token&refresh_token=tGzv3JOkF0XG5Qx2TlKWIA
```

Server ủy quyền sẽ:

* Chứng thực client.
* Kiểm tra refresh token có đúng là được cấp cho client hay không.
* Kiểm tra refresh token có hợp lệ hay không.

Nếu tất cả các thông tin đều hợp lệ thì server ủy quyền sẽ cấp token mới cho client.
Server có thể tạo refresh token mới, khi đó refresh token cũ sẽ không còn hợp lệ.

## 7. Truy cập vào tài nguyên được bảo vệ

Client truy cập vào tài nguyên được bảo vệ bằng cách cung cấp access token cho resource server. Resource servẻ phải kiểm tra access token để đảm bảo rằng nó còn hiệu lực và nằm trong phạm vi truy cập.

### 7.1 Các loại access token

Loại của access token được trả về cùng với access token khi cấp phát thành công.
Có 2 loại access token:

* `bearer`
* `mac`
  ở đây không nói chi tiết về 2 loại token này. Tham khảo RFC6750 và OAuth-HTTP-MAC

### 7.2 Trả lỗi

Nếu yêu cầu truy xuất tài nguyên thất bại, resource server nên thông báo client lỗi đã xảy ra

## 8. Mở rộng giao thức: (không dịch)

## 9. Ứng dụng native:(không dịch)

## 10. Các nguy cơ bảo mật.

### 10.1 Chứng thực client

### 10.2 Mạo danh client

* Một client nguy hiểm có thể mạo danh một client khác và lấy quyền truy cập tới tài nguyên được bảo vệ nếu client bị mạo danh thất bại hoặc không thể giữ bí mật các thông tinh chứng thực của nó.
* Server phải chứng thực client bất cứ khi nào có thể. Yêu cầu client đăng ký redirection URI để nhận kết quả ủy quyền.
* Server ủy quyền nên cung cấp cho người dùng thông tin về client và quyền hạn mà client yêu cầu.
* Server ủy quyền không nên tự động lặp lại việc ủy quyền mà không xác thực client hoặc dựa trên các cách khác để đảm bảo request đến từ cùng client

### 10.3 Access token

* Access token phải được giữ bí mật trong quá trình lưu trữ và truyền tải. Và chỉ chia sẻ giữa server ủy quyền, resource server và client sở hữu nó. Access token chỉ được truyền tải qua giao thức TLS.
* Khi sử dụng kiểu cấp ủy quyền implicit, access token được gắn vào URI nên dễ dàng bị đánh cắp bởi các bên/ứng dụng khác.
* Server ủy quyền phải đảm bảo rằng access token không thể được tạo ra, thay đổi hoặc đoán được bởi một bên nào khác không được chứng thực.
* Client nên yêu cầu cấp access token với phạm vi truy cập tối thiểu cần thiết cho nó.

### 10.4 Refresh token

* Server ủy quyền có thể cấp refresh token cho ứng dụng web hoặc ứng dụng native.
* Refresh token phải được giữ bí mật trong lưu trữ và truyền tải. Và chỉ được chia sẻ giữa server ủy quyền và client được cấp phát. refresh token phải được truyền tải qua giao thức TLS.
* Server ủy quyền phải kiểm tra liệu refresh token có phải được cấp phát cho client hay không. Trong trường hợp không thể chứng thực client, server nên sử dụng các cách khác để phát hiện việc lạm dụng refresh token.
* Server ủy quyền phải đảm bảo rằng refresh token không thể được tạo ra, thay đổi hoặc đoán được bởi một bên nào khác không được chứng thực.

### 10.5 Authorization code

* Việc truyền tải authorization code nên được thực hiện thông qua một kênh bảo mật. Client nên sử dụng giao thức TLS cho redirection URI. Authorization code được truyền thông qua user-agent nên nó có thể bị bắt lại ở user agent.
* Authorization code phải có thời gian sống ngắn và chỉ được dùng một lần. Nếu server ủy quyền nhận thấy authorization code được sử dụng lại nhiều lần, server nên hủy tất cả các access token đã cấp phát dựa trên authorization code này.

* Nếu có thể, server ủy quyền nên chứng thực clien và kiểm tra authorization code có được cấp phát cho đúng client hay không.

### 10.7 Authorization Code Redirection URI Manipulation

* Khi sử dụng phương thức cấp quyền authorization code, client xác định URI chuyển hướng băng tham số `redirect_uri`. Nếu kẻ tấn công có thể thay đổi giá trị của `redirect_uri` nó có thể làm cho server chuyển hướng kết quả tới URI của kẻ tấn công.
* Kẻ tấn côn có thể tạo tài khoản trên một server hợp lệ và khởi tạo luồng cấp ủy quyền. Khi user-agent của kẻ tấn công đang request tới server ủy quyền để yêu cầu cấp quyền truy cập, hắn thay thế URI của client hợp pháp và thay bằng URI của hắn. Sau đó kẻ tấn công lừa cho nạn nhân sử dụng link đã được thay đổi để cấp quyền truy cập cho client hợp lệ.

Một khi server ủy quyền hoàn thành việc cấp ủy quyền, nạn nhân sau đó sẽ được chuyển hướng tới một trang khác của kẻ tấn công cùng với authorization code. Sau đó attacker gửi authorization code tới client. client sử dụng thông tin đó để cấp quyền truy cập cho account của kẻ tấn công, và hắn có thể sử dụng tài khoản của mình để truy cập vào tài nguyên được bảo vệ của nan nhân thông qua client.

Để ngăn chặn kiểu tấn công như vậy: - Server ủy quyền phải đảm bảo rằng redirection URI được sử dụng để lấy code ủy quyền phải giống với redirection URI khi đổi authorization code lấy access token. - Server ủy quyền yêu cầu public client phải đăng ký redirection URI và confidential client cũng nên đăng ký redirection URI. server sẽ kiểm tra URI trong request có đúng với URI đã đăng ký hay không.

### 10.7 Resource Owner Password Credentials

* Kiểu cấp quyền này có nhiều nguy cơ bị tấn công hơn so với những kiểu khác bởi vì nó sử dụng username và password là điều mà giao thức oauth2 muốn tránh khỏi.Client có thể lạm dụng hoặc để lộ mậu khẩu.
* Thêm vào đó, resource owner không được tham gia vào quá trình cấp quyền nên client có thể yêu cầu cấp phạm vi quyền hạn lớn hơn. Server ủy quyền nên xem xét thời gian sống và và phạm vi(scope) của access token trong kiểu cấp quyền này.
* Server ủy quyền và client nên hạn chế sử dụng kiểu cấp quyền này và sử dụng kiểu ủy quyền khác bất cứ khi nào có thể.

### 10.8 Request Confidentiality

* access token, refresh token , resource owner password, và client credential KHÔNG ĐƯỢC truyền tại dưới dạng text rõ ràng (không được hash hay mã hóa). Authorization code KHÔNG NÊN truyền dưới dạng text rõ ràng.
* `state` và `scope` không nên chứa các thông tin nhạy cảm ủa client hoặc resource owner dưới dạng text rõ ràng bởi vì chúng có thể được truyền tải qua một kênh không an toàn.

### 10.9 Ensuring Endpoint Authenticity

Để ngăn chặn kiểu tấn công man-in-the-middle, server ủy quyền phải yêu cầu sử dụng kênh truyền TLS.

### 10.10 Credentials-Guessing Attacks

* Server ủy quyền phải ngăn chặn kẻ tấn công đoán access token, mật khẩu của resource owner và thông tin đăng nhập của client.
* Khả năng kẻ tấn công đoán ra access token PHẢI nhỏ hơn hoặc bằng 2^(-128) và NÊN nhỏ hơn hoặc bằng 2^(-160)

### 10.11 Phishing Attacks

### 10.12 Cross-Site Request Forgery

* Là kiểu tấn công trong đó kẻ tấn công làm cho user-agent của người dùng chuyển hướng theo một URI nguy hiể tới server đang được tin tưởng (thông thường được thiết lập qua một session cookie hợp lệ).

* Tấn công CSRF dựa trên redirection URI cho phép kẻ tấn công thay thế bằng authorization code hoặc access token của hắn. Kết quả là client sẽ sử dụng access token liên kết với protected resource của kẻ tấn công thay vì của nạn nhân (Ví dụ như lưu thông tin tín dụng của nạn nhân vào tài khoản của kẻ tấn công).
* Client phải hỗ trợ ngăn chặn CSRF đối với redirection URI của nó. Việc này có thể thực hiện bằng việc yêu cầu mọi request gửi tới redirection URI endpoint phải kèm theo một giá trị gắn request với trạng thái chứng thực của user-agent . Client nên tạo tham số `state` trong request gửi tới server ủy quyền.

* Sâu khi cấp quyền, server trả về cho client kết quả kèm theo `state` của request. Thông tin này cho phép client kiểm tra tính hợp lệ của request.
* Tấn công CSRF trên authorization endpoint của server ủy quyền có thể dẫn tới kết quả là kẻ tấn công lấy được ủy quyền của user cho một client nguy hiểm mà user không hề biết.

* Server ủy quyền phải hỗ trợ việc ngăn chặn CSRF đối với authorization enpoint của nó và đảm bảo rằng client nguy hiểm không thể nhận được ủy quyền mà không có sự chấp thuận của resource owner.

### 10.13 Clickjacking

* Đối với tấn công Clickjacking, kẻ tấn công đăng ký một client hợp lệ và tạo một website nguy hiểm để tả authorizatin endpoint của server ủy quyền trong một iframe trong suôt, và tạo các button tại vị trí các button trên trang của server ủy quyền. Khi người dùng click lên các button do kẻ tấn công tạo ra, họ đã vô tình click lên cac button vô hình trên trang cấp quyền(ví dụ như nút Authorize). Điều này giúp kẻ tấn công đánh lừa người dùng cấp quyền truy cập cho hắn mà người dùng không hề hay biết.
* Để ngăn chặn kiểu tấn công này, các ứng dụng native nên sử dụng các trình duyện bên ngoài thay vì nhúng trình duyệt bên trong ứng dụng, việc chặn các iframe có thể được thực hiện bằng việc server ủy quyền sử dụng `"x-frame-options"` header. Header này có nhận 1 trong hai giá trị `deny` hoặc 'sameorigin'. Thiết lập này ngăn việc sử dụng iframe hoặc chặn iframe từ các trang không cùng domain.

### 10.14 Code Injection and Input Validation

* Tấn công code injection xảy ra khi các biến bên ngoài hoặc input nhận vào và được sử dụng mà không được khử độc (:) sanitize) và do đó làm thay đổi logic của ứng dụng. Việc này cho phép kẻ tấn công lấy được quyền truy cập vào device mà ứng dụng đang chạy hoặc dữ liệu ứng dụng, gây từ chối dịch vụ hoặc là nhiều tác động nguy hiểm khác.
* Server ủy quyền và client nên sanitize(khử độc, khử trùng, khử) các giá trị nhận được, đặc biệt là tham số `state` và `redirect_uri`.

### 10.15 Open Redirectors

* Server ủy quyền, authorization endpoint và client redirection endpoint có thể được cấu hình không đúng tạo nên open redirector. Open redirection là một endpoint sử dụng các tham số và chuyển hướng tự động tới các vị trí được xác định trong các tham số mà không kiểm tra trước.
* Open redirection có thể được sử dụng trong tấn công phishing, hoặc bởi kẻ tấn công để khiến người dùng truy cập vào các trang web nguy hiểm bằng cách sử dụng redirection URI. Ngoài ra nếu server ủy quyền cho phép client đăng ký 1 phần của redirection URI, kẻ tấn công có thể sử dụng open redirector để tạo ra các URI qua mặt được việc kiểm tra của server ủy quyền và server sẽ gửi authorization code hoặc access token tới redirection URI do kẻ tấn công quản lý.

### 10.16 isuse of Access Token to Impersonate Resource Owner in Implicit Flow

* Đối với implicit thì không thể biết được access token đang được cấp phát cho client nào.
* resource owner có thể cấp quyền cho client của kẻ tấn công. Kẻ tấn công cũng có thể lấy trộm token thông qua một số cơ chế khác. Sau đó kẻ tấn công có thể giả mạo resource owner bằng cách cung cấp access token cho client hợp lệ.
* Kẻ tấn công cũng có thể thay thế access token mà server ủy quyền trả về bằng access token được cấp cho hắn trước đó.

**---- CÁC PHẦN CÒN LẠI KHÔNG DỊCH----**
