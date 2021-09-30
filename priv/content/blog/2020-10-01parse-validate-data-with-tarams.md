---
title: "Chuẩn hoá và validate dữ liệu trong Phoenix với thư viện Tarams"
date: 2020-10-01
tags: ["elixir", "ecto", "phoenix", "tarams"]
author: Dung Nguyen
draft: false
image: "/img/tarams-parse.png"
---

**Version mới của thư viện `Tarams` không tương thích với bản cũ. Các bạn đọc bài mới ở đây nhé [How to validate request params in Phoenix](/blog/2021-08-14-validate-request-params-with-phoenix)

Yêu cầu chuẩn hoá và validate các tham số truyền lên từ client là yêu cầu cơ bản khi xây dựng API Web. Mình đã có một bài hướng dẫn sử dụng Ecto.Changeset để chuẩn hoá trong bài viết này:

[Parse và validate request param trong Phoenix với Ecto ](https://dev.to/bluzky/parse-va-validate-request-param-trong-phoenix-v-i-ecto-151a)

Trong bài viết này, mình sẽ hướng dẫn một cách ngắn và đơn giản hơn bằng cách sử dụng thư viện sẵn có [Tarams](https://github.com/bluzky/tarams/). Thư viện này thực ra là sử dụng lại `Ecto.Changeset` nhưng nó giúp cho chúng ta không phải lặp lại quá nhiều code như khi dùng `Ecto.Changeset`

Một vài tính năng thú vị của Tarams:
- Cung cấp cách thức đơn giản để định nghĩa các cấu trúc tham số
- Cho phép định nghĩa các giá trị default động
- Cho phép định nghĩa các hàm để cast giá trị về đúng kiểu dữ liệu
- Định nghĩa hàm để validate dữ liệu

Sau đây là cách sử dụng `Tarams`. Ví dụ chúng ta đang viết API để cập nhật profile của nhân viên. Yêu cầu là

```
email: bắt buộc, đúng định dạng
first_name: bắt buộc
last_name: bắt buộc
birthday: không bắt buộc, kiểu ngày tháng
title: không bắt buộc
start_date: ngày bắt đầu làm việc, ngày tháng, mặc định là ngày hiện tại
```

## 1. Định nghĩa cấu trúc của tham số truyền lên khá đơn giản

```elixir
@schema  %{
    email: [type: :string],
    first_name: [type: :string],
    last_name: [type: :string],
    title: :string,
    birth_day: [type: :date],
    start_date: [type: :date]
}
```

Schema đơn giản chỉ là một map với key là tên field và value là 1 list option của field đó.


## 2. Bây giờ thêm các ràng buộc 

- Để đánh dấu 1 trường là bắt buộc, thêm option `required: true`
- `Taram` cũng cho phép validate data sử dụng lại các hàm validate của `Changeset`

```elixir
@schema  %{
    email: [type: :string, required: true, validate: {:format, ~r/@/}],
    first_name: [type: :string, required: true],
    last_name: [type: :string, required: true],
    title: :string,
    birth_day: [type: :date],
    start_date: [type: :date]
}
```

## 3. Bây giờ thì set các giá trị default

`default` có thể là 1 giá trị hoặc 1 hàm. Mỗi khi parse tham số thì hàm này sẽ được gọi để lấy giá trị mặc định

```elixir
@schema  %{
    ...
    title: [type: :string, default: "staff"],
    birth_day: [type: :date],
    start_date: [type: :date, default: &Timex.today/0]
}
```

## 4. Cast các giá trị tham số về đúng kiểu

Nhiều các giá trị tham số truyền lên phải được chuyển về đúng các loại dữ liệu phức tạp như ngày tháng, list.
Ví dụ ngày tháng truyền lên là string `01/12/1994` thì phải chuyển về kiểu date để sử dụng lại được. Tarams hỗ trợ định nghĩa 1 hàm custom để cast giá trị, hàm này trả về 
- `{:ok, value}` nếu parse thành công
- `{:error, error_message}` nếu thất bại

```elixir
def parse_date(date_str) do
    Timex.parse(date_str, "{0D}/{0M}/{YYYY}")
end

@schema  %{
    ...
    title: [type: :string, default: "staff"],
    birth_day: [type: :date, cast_func: &parse_date/1],
    start_date: [type: :date, default: &Timex.today/0]
}
```

## 5. Bây giờ sử dụng nào
```elixir
def update(conn, params) do
    with {:ok, user_data} <- Tarams.parse(@schema, params) do
        # do anything with your params
        # access data bằng atom key: user_data.email
    else
        {:error, changset} -> # return params error
    end
end
```
Hàm `parse` sẽ parse và validate dữ liệu. Nếu mọi thứ đều ổn, sẽ trả về `{:ok, data}` và ngược lại thì trả về `{:error, changeset}`.

Done! Code của bạn sẽ trở nên đơn giản và ngắn gọn hơn nhiều

