---
title: "Elixir - Lưu trữ dữ liệu trên RAM với ETS"
date: 2018-05-12T14:28:22+07:00
draft: false
author: Dung Nguyen
tags: ["elixir", "erlang"]
---


## ETS là gì?

Có lẽ các bạn đã nghe qua về `redis` hoặc `memcache`, hoặc là cả hai. Còn nếu bạn chưa nghe tới bao giờ thì đó là những cơ sở dữ liệu lưu trữ trên RAM với ưu điểm là tốc độ truy xuất cực kỳ nhanh. ETS - Erlang Term Service - cũng là một CSDL lưu trữ trên RAM (in-ram DB) nhưng khác ở chỗ là ETS có sẵn khi cài Elixir/Erlang và bạn chẳng phải mất công cài đặt, cấu hình như 2 anh trên kia, nhà trồng được việc gì phải ngại.

**Đặc điểm** của em nó là:

- Không cần cài đặt 
- Dữ liệu lưu trữ trên RAM và mất đi khi process kết thúc
- Dữ liệu lưu trữ dạng `key-value`
- `value` có thể là `set`, `ordered_set`, `bag`, `duplicated_bag`
- Kiểu dữ liệu của `value` trên cùng 1 bảng là giống nhau và đuợc khai báo khi tạo bảng.



## Các thao tác trong ETS

### 1. Tạo bảng

```elixir
iex> :ets.new(:cache, [:set, :protected, :named_table])
```

**Syntax: ** `:ets.new(ten_bang, [type, access, name_table])`

- `type` là kiểu dữ liệu của `value` lưu trong bảng
  - `set` là kiểu dữ liệu, chú này chung thuỷ chỉ có 1 value cho 1 key và key là duy nhất, không bị trùng.
  - `ordered_set` thằng em nghiêm túc của `set`, khác thằng anh ở chỗ đuợc tự động order khi thêm data vào.
  - `bag` khác với `set` ở chỗ chú này chơi harem, cho phép nhiều value cho cùng 1 key, tuy nhiên các value không đuợc trùng nhau.
  - `duplicated_bag` thằng này ăn tạp giống `bag` nhưng cho phép value trùng nhau
- `access`  giới hạn khả năng truy xuất dữ liệu từ bảng, cũng khá dễ nhớ
  - `public`: hàng công cộng, chú process nào thích nhìn (đọc), sờ (ghi) gì anh cho hết
  - `protected`: các chú chỉ đuợc nhìn thôi, anh sở hữu thì anh đuợc sờ
  - `private`: anh giấu hết, chỉ có anh mới đuợc nhìn và sờ, các chú đi ra chỗ khác
- `named_table` Cái này tuỳ chọn, bình thuờng thì sẽ trả về 1 id dùng để truy xuất vào table. Nếu thêm option này vào thì có thể dùng `ten_bang` để truy xuất vào table.

Đã xong phần khởi tạo, giờ phần hay ho nhất đây.

### 2. Insert và update dữ liệu

- Insert dữ liệu nếu `key` đã có chủ thì ghi đè (đập chậu cuớp bông)

	```elixir
	iex> :ets.insert(:cache, {"post-1", "world!", %{view: 1}})
	true
	```

- Insert dữ liệu, nếu `key` đã có chủ thì bỏ qua.

	``` elixir
	iex> :ets.insert_new(:cache, {"post-1", "Lao!", %{view: 2}})
	false
	iex> :ets.insert_new(:cache, {"post-2", "Vietnam!", %{view: 999}})
	true
	```



Dữ liệu cho hàm `insert/2` và `insert_new/2` là 1 `tuple`, phần tử đầu tiên của `tuple` mặc định được dùng làm `key`.

### 3. Query dữ liệu

**3.1 Query đơn giản**: tìm kiếm dữ liệu theo key dùng hàm `lookup/2`

```elixir
iex> :ets.lookup(:cache, "post-1")
[{"post-1", "world!", %{view: 1}}]
```



**3.2 Query với nhiều trường dữ liệu** với hàm `match_object/2`

```elixir
iex> :ets.match_object(:cache, {:"_", "Vietnam!", :"_"})
[{"post-2", "Vietnam!", %{view: 999}}]
```

- **Note** `:"_"` đánh dấu tại vị trí này sẽ không xài để match dữ liệu, truờng này chứa dữ liệu gì cũng đuợc, anh không quan tâm

**3.3 Select trường dữ liệu nào sẽ trả về** với `match/2`

```elixir
iex> :ets.match_object(:cache, {:"$1", :"$2", :"_"})
[{"post-1", "world!"}, {"post-2", "Vietnam!"}]
```

- **Note** `:"$N"`  dùng để `select` kết quả trả về,  `N` là một số nguyên dùng để xác định vị trí của dữ liệu trong kết quả.

```elixir
iex> :ets.match_object(:cache, {:"$30", :"$2", :"_"})
[{"world!", "post-1"}, {"Vietnam!", "post-2"}]
```



**3.4 Giới hạn kết quả tra về**

Sử dụng hàm `match/3` hoặc `match_object/3` tương tự như `match/2` và `match_object/2`, trong đó tham số thứ 3 là số lượng phần tử sẽ trả về.

```elixir
# them 1 phan tu
iex> :ets.insert_new(:cache, {"post-3", "Vietnam!", %{view: 1000}})
true

# khong limit
iex> :ets.match_object(:cache, {:"_", "Vietnam!", :"_"})
[{"post-2", "Vietnam!", %{view: 999}}, {"post-3", "Vietnam!", %{view: 1000}}]

# co limit
iex> :ets.match_object(:cache, {:"_", "Vietnam!", :"_"}, 1)
[{"post-2", "Vietnam!", %{view: 999}}]
```



### 4. Xoá dữ liệu

**Xoá theo key**

```elixir
iex> :ets.delete(:cache, "post-1")
true
```

**Match dữ liệu và xoá**. Cách match giống như trong **query dữ liệu**

```elixir
iex> :ets.match_delete(:cache, {:"_", "Vietnam!", :"_"})
true
```



### 5. Xoá bảng

```elixir
iex> :ets.delete(:cache)
true
```

Nếu không xoá thì dữ liệu sẽ tồn tại cho đến khi process kết thúc mới bị mất đi.



### 6. Các hàm hay xài 

- `member/2` kiểm tra xem key đã tồn taị trong bảng hay chưa
- `tab2list`: đọc tất cả dữ liệu của bảng vào 1 list
- `tab2file`: lưu tất cả dữ liệu trên bảng vào 1 file, bạn có thể lưu dữ liệu lại **truớc khi process kết thúc** và có thể xài lại dữ liệu sau.
- `file2tab` : đọc 1 file đuợc lưu bởi `tab2file` và tạo lại bảng tương ứng 
- `to_dest/2`: copy toàn bộ dữ liệu từ bảng ETS qua bảng DETS (lưu dữ liệu trên ổ cứng)
- `from_dest/2`: copy toàn bộ dữ liệu từ bảng DETS qua bảng ETS


## Tham khảo 

1. [http://erlang.org/doc/man/ets.html](http://erlang.org/doc/man/ets.html) xem nhiều trò hay
2. [http://learnyousomeerlang.com/ets](http://learnyousomeerlang.com/ets) 
3. Ngoài ra Erlang còn hỗ trợ `DETS` (disk-based term storage) lưu trên ổ cứng với API tương tự [http://erlang.org/doc/man/dets.html](http://erlang.org/doc/man/dets.html)


