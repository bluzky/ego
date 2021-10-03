---
title: "Memcache là gì?"
date: 2018-05-01T23:05:10+07:00
draft: false
author: Dung Nguyen
tags: ["tech", "til"]
---

## 1. Memcache
> [Memcache](https://memcached.org) là một cơ sở dữ liệu dạng key-value, các dữ liệu đuợc ghi nhớ trên RAM giúp tối ưu thời gian truy xuất.

## 2. Đặc điểm
- Dữ liệu lưu trữ dạng key-value
- Value là dữ liệu dạng string
- Kích thuớc của Value giới hạn là 1MB
- Dữ liệu sẽ bị mất khi tắt máy/ tắt memcache
- Truy xuất dữ liệu nhanh

## 3. Ứng dụng
Memcache thường đuợc dùng đễ cache dữ liệu trên các web server giúp giảm thời gian xử lý các request giống nhau, thay vào đó chỉ cần đọc dữ liệu từ bộ nhớ và trả về ngay lập tức.

## 4. Ưu - Nhược điểm

**Ưu điểm**

- Dữ liệu truy xuất nhanh
- Sử dụng phổ biến

**Nhược điểm**

- Khi dữ liệu bị xoá, dữ liệu không đuợc phục hồi
- Chỉ hỗ trợ dữ liệu kiểu string
- Kích thước dữ liệu giới hạn chỉ 1MB
- Không hỗ trợ lưu dữ liệu persistent


## 5. Cách sử dụng
Ví dụ sử dụng trong Elixir:
```elixir
def get_post(conn, %{"id" => id}) do
  response = Memcache.Client.get("post-#{id}")
  
  case response.status do
    :ok ->
      # trả về ngay nếu tìm thấy trong cache
      json(conn, Poison.decode!(response.value))
      
    status ->
      # Nếu không thấy, truy xuất dữ liệu mới
      data = get_post_data(id)
      
      # Lưu dữ liệu mới vào cache
      json_data = Poison.encode!(data)
      Memcache.Client.set("post-#{id}", json_data)
      json(conn, data)
  end
end
```

## 6. Refs
- Trang chủ [memcached.org](https://memcached.org/)
- So sánh Memcache và Redis trên [Stack overflow](https://stackoverflow.com/questions/10558465/memcached-vs-redis)
