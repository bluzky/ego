---
title: "Parse và validate request param trong Phoenix với Ecto"
date: 2020-09-26
tags: ["elixir", "ecto", "phoenix"]
author: Dung Nguyen
draft: false
image: "/img/parse-ecto-phoenix.png"
---


Khi viết các API hoặc cả các endpoint thì thông thường chúng ta sẽ có một số nhu cầu:
- Chỉ cho phép một số các tham số xác định được truyền vào.
- Chuyển các tham số về kiểu dữ liệu mong muốn
- Validate các tham số theo yêu cầu

Bài viết này sẽ hướng dẫn các bạn giải quyết các vấn đề trên sử dụng `Ecto.Changeset`

Thư viện `Ecto` đã cung cấp sẵn cho chúng ta module `Changeset`. Nó hỗ trợ việc cast các tham số về đúng kiểu dữ liệu mong muốn, nó cũng hỗ trợ các phương thức để validate các tham số yêu cầu, và nó cũng cho phép bạn giới hạn tham số nào được truyền vào.

Và sau đây là một ví dụ sử dụng `Chageset` để validate các tham số khi filter các đơn hàng.

## 1. Đầu tiên bạn phải định nghĩa một schema
```elixir
defmodule MyApp.OrderFilterParams do
    use Ecto.Schema
    import Ecto.Changeset

    schema "order_filter_params" do
        field :keyword, :string
        field :category_id,  :integer
        field :status, :string
        field :start_date, :utc_datetime
        field :end_date, :utc_datetime
    end
end
```

## 2. Cast và validate 
Sau đó phải định nghĩa một hàm để thực hiện việc cast tham số và validate `changeset`.

```elixir
defmodule MyApp.OrderFilterParams do

    ...

    @required ~w(category_id start_date)
    @optional ~w(keyword status end_date)

    def changeset(changeset_or_model, params) do
         cast(changeset_or_model, params, @required ++ @optional)
        |> validate_required(@required)
    end
end
```

## 3. Set giá trị default động
Nếu bạn muốn sử dụng các giá trị default động, ví dụ như mặc định ngày kết thúc là ngày hiện tại, các bạn phải định nghĩa một function để set giá trị mong muốn.

```elixir
defmodule MyApp.OrderFilterParams do

    ...

    def changeset(changeset_or_model, params) do
         cast(changeset_or_model, params, @required ++ @optional)
        |> validate_required(@required)
        |> set_default_end_date()
    end

    defp set_defaut_end_date(changeset) do
        end_date = get_change(changeset, :end_date)
        if is_nil(end_date) do
            put_change(changeset, :end_date, Timex.today())
        else
            changeset
        end
    end
end
```

## 4. Sử dụng Params schema
```elixir
defmodule MyApp.OrderController do
    use MyApp, :controller
    alias MyApp.OrderFilterParams

    def index(conn, params) do
        changeset = OrderFilterParams.changeset(%OrderFilterParams{}, params)

        if changeset.valid? do
            strong_params = Ecto.Changeset.apply_changes(changeset)
				IO.put(strong_params.keyword)
            # Do something with your params
        else
            # handle error
        end
    end
end

```

Rất đơn giản đúng không, nếu bạn đã sử dụng `Ecto` thì việc này chỉ là ruồi muỗi. Tuy nhiên đơn giản thì phải có thứ đánh đổi chứ.

## Vài thứ mà bạn sẽ thấy bất tiện
### 1. Lượng code mà bạn phải viết quá nhiều.

Thử tưởng tượng mỗi API bạn lại phải định nghĩa thêm một Module params cho nó thì phức tạp vl.

Bạn có thể sử dụng schemaless, nhưng mà function của bạn sẽ rối nùi lên vì code logic và code xử lý params nó không liên quan gì tới nhau cả. Và bạn thì kiểu như đổ sting vào cơm để ăn vậy.

### 2. Thiếu linh hoạt.
Điều này cũng đúng vì mục đích chính của `Ecto` là phục vụ cho việc định nghĩa các schema cho database.

Đơn giản như việc định nghĩa giá trị default động như trên, bạn phải viết luôn 1 hàm mới


**Tuy nhiên nó cũng có một ưu điểm là bạn không phải sử dụng thêm thư viện của bên thứ ba.**


## Kết
Nếu bạn không cần phải xử lý nhiều ràng buộc liên quan đến tham số của request thì đơn giản là cứ dùng `Changeset` thôi. 

Nếu bạn muốn nhanh gọn hơn thì trên Hex có một số thư viện để hỗ trợ định nghĩa param đơn giản hơn, ví dụ như [https://github.com/bluzky/tarams/](https://github.com/bluzky/tarams/)

Thư viện này cung cấp cách thức đơn giản và nhanh chóng hơn để định nghĩa param cho API. Mình sẽ viết bài hướng dẫn sau.


