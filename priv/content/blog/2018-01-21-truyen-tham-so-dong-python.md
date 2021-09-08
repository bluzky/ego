---
title: Truyền tham số động trong python (*args | **kwargs)?
date: 2018-01-21
author: Dung Nguyen
tags: ["python", "python-basic"]
---

Thực sự thì không nhất thiết phải là `*args` và `**kwargs`. điều quan trọng là tham số có 1 dấu sao \* hay là 2 dấu sao \*\*. Đặt tên tham số là \*var hay \*\*vars hay bất cứ thứ gì bạn muốn.
Nhưng để dễ hiểu thì nên dùng tên chuẩn là `*args` và `**kwargs`

## 1. `*args` và `**kwargs` dùng để làm gì?

* Khi khai báo 1 hàm, sử dụng `*args` và `**kwargs` cho phép bạn truyền vào bao nhiêu tham số cũng được mà không cần biết trước số lượng.
  **Ví dụ**

```python
# với giả sử các tham số truyền vào đều là số
def sum(*args):
	total = 0
	for number in args:
  	total += number
  return total

# gọi hàm
sum(1, 2, 3,19)
sum( 1, 100)
```

## 2. `*args` và `**kwargs` khác gì nhau?

* Cho những bạn chưa biêt: Khi gọi hàm trong Python, có 2 kiểu truyền tham số:
  * Truyền tham số theo tên.
  * Truyền tham số bình thường theo thứ tự khai báo đối số.
    **Ví dụ**
  ```python
  def register(name, password):
  	....
  # Truyền tham số theo kiểu thông thường, phải theo đúng thứ tự
  register( 'Coulson', 'hail_Hydra')
  # Truyền tham số theo tên, Không cần phải theo thứ tự khai báo thao số
  register( password='cookHim', name='Skye')
  ```
* **`*args`** nhận các tham số truyền bình thường. Sử dụng **args** như một list.
* **`**kwargs`** nhận tham số truyền theo tên. Sử dụng **kwargs\*\* như một. dictionary

**Ví dụ**

```python
def test_args(*args):
	for item in args:
   	print item

>>test_args('Hello', 'world!')
Hello
world!

def test_kwargs(*kwargs):
	for key, value in kwargs.iteritems():
   	print '{0} = {1}'.format(key, value)

>>test_kwargs(name='Dzung', age=10)
age = 10
name = Dzung
```

## 3. Thứ tự sử dụng và truyền tham số `*args`, `**kwargs` và tham số bình thường

Khi sử dụng phải khai báo đối số theo thứ tự:

> **đối số xác đinh --> `*args` --> `**kwargs`\*\*

Đây là thứ tự bắt buộc. Và khi truyền tham số bạn cũng phải truyền theo đúng thứ tự này. Không thể truyền lẫn lộn giữa 2 loại.

> Khi sử dụng đồng thời `*args` `**kwargs` thì không thể truyền tham số bình thường theo tên

**Ví dụ**

```python
def show_detail(name, *args, **kwargs):
	.....

show_detail(name='Coulson', 'agent', age='40', level='A')
>> Lỗi

def show_detail_2(name, **kwargs):
	....

show_detail_2(name=Coulson', age='40', level='A')
>> Chạy Ok
```
