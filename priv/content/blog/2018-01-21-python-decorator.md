---
title: Python decorator là gì? dùng khi nào
date: 2018-01-21
author: Dung Nguyen
tags: ["python", "python-basic"]
---

## 1. Decorator là gì?

* Decorator là một mẫu thiết kế (Design pattern) thường được dùng để thay đổi hành vi, chức năng của hàm(function) hoặc lớp (class) mà không cần phải thay đổi code của hàm hoặc lớp.
  [Tham khảo](https://sourcemaking.com/design_patterns/decorator)
* Python hỗ trợ cú pháp (syntax) cho Decorator từ version 2.4
* Về cơ bản Decorator giống như một lớp vỏ bọc (wrapper), nó thay đổi hành vi(behavior) của code trước và sau khi gọi hàm chính (hàm được decorate).

## 2. Decorator được dùng làm gì?

Tại sao chúng ta cần Decorator?

* Cho phép tái sử dụng code.
* Mở rộng các hàm, hoặc lớp mà không cần phải thay đổi code có sẵn --> không cần test lại.

Ví dụ trong chương trình của bạn bạn cần kiểm tra quyền (permission) của người dùng trước khi thực hiện hàm. Bạn có thể phải thêm code vào tất cả các hàm đã có để kiểm tra. Thay vào đó với decorator, bạn chỉ cần định nghĩa một decorator và khai báo nó trước hàm.

## 3. Làm sao để định nghĩa một decorator?

* Decorator cũng là một hàm chỉ khác là hàm decorator nhận vào một hàm và kết quả trả về của nó là hàm sau khi được decorate.
* Như vậy để định nghĩa một decorator chỉ đơn giản là định nghĩa một hàm nhận vào một hàm khác và trả về một hàm mới có prototype tương đương với hàm nhận vào.
* **Ví dụ 1:**

  ```python
  def ten_decorator(f):
      def wrapper(ten):
          chuoi_moi = "Ten tui la %s" % ten
          return f(chuoi_moi)
      return wrapper

  def xuat_ten( ten ):
      print ten
  ```

* **CHÚ Ý QUAN TRỌNG**: hàm `wrapper` và hàm f phải có tham số phù hợp với nhau. Ví dụ như hàm f nhận vào chỉ 2 tham số thì hàm `decorator` không thể nhận vào 3 tham số hoặc 1 tham số.

## 4. Sử dụng decorator như thế nào?

* Sử dụng Decorator hết sức đơn giản. Sử dụng decorator trong ví dụ trên cho hàm `xuat_ten` như sau:

```python
@ten_decorator
def xuat_ten(ten):
	print ten
```

* Dùng dấu @ để thông báo đó là một decorator. Một hàm có thể dùng nhiều decorator cùng lúc:

```python
@ten_decorator1
@ten_decorator2
@ten_decorator3
def xuat_ten(ten):
	print ten
```

## 5. Decorator hoạt động như thế nào?

Như trong ví dụ ở trên:

* `ten_decorator` nhận vào hàm f, sau đó bọc hàm f trong hàm `wrapper` của nó và trả về hàm `wrapper`. Hàm `wrapper` có nhiệm vụ gắn thêm thông tin vào tên rồi mới gọi thực hiện hàm f với chuỗi mới.
* Việc sử dụng:

  ```python
  @ten_decorator
  def xuat_ten(ten):
      print ten
  xuat_ten('coulson')
  ```

  Tương đương với:

  ```python
  def xuat_ten(ten):
  print ten
  ham_xuat_ten_moi = ten_decorator(xuat_ten)
  ham_xuat_ten_moi('coulson')
  ```

* Rõ ràng với việc sử dụng cú pháp decorator thì code sẽ ngắn gọn và đơn giản hơn. Developer không phải gọi decorator mỗi lần sử dụng mà trình thông dịch sẽ làm việc đó.

**Đối với hàm sử dụng nhiều decorator**

**Ví dụ 2**

```python
@ten_decorator1
@ten_decorator2
@ten_decorator3
def xuat_ten(ten):
	print ten
```

* Decorator nào càng ở trên, xa function thì sẽ bọc lớp ngoài Giống như khi bạn bọc trái xoài vào trong bị, rồi lại lấy cái bị khác để bọc bên ngoài nữa.
* Thứ tự thực thi code: - Code của decorator được thực thi ngay lúc file nguồn Python được load lên. Ngoại trừ code trong hàm wrapper của decorator trong cùng sẽ được thực thi lúc gọi hàm. - Decorator được gọi thực thi theo thứ tự từ trong (gần hàm nhất) ra ngoài.

## 6 Truyền tham số cho decorator

> Ở trên, để cho đơn giản, và dễ hiểu thì decorator là một hàm có tham số là một hàm khác. Nhưng điều đó không bắt buộc, decorator cũng có thể là một hàm nhận vào tham số bất kỳ và trả về một hàm và hàm trả về này nhận vào tham số là một hàm khác.

**Ví dụ 3**: thêm chức danh vào chuỗi xuất ra mình có thể định nghĩa decorator như sau:

```python
def chuc_danh_decorator(ten_chuc_danh):
    def ten_decorator(f):
        def wrapper(ten):
            chuoi_moi = "Xin gioi thieu %s %s" % (ten_chuc_danh, ten)
            return f(chuoi_moi)
        return wrapper
    return ten_decorator

@chuc_danh_decorator("Giao su")
def gioi_thieu(ten):
	print ten

@chuc_danh_decorator("Tien si")
def gioi_thieu_2(ten):
	print ten

gioi_thieu("Teo")
gioi_thieu_2("Ti")

>> Xin gioi thieu Giao su Teo
>> Xin gioi thieu Tien si Ti
```

**Sự khác biệt:**

* Hàm decorator bây giờ không phải nhận vào tham số là một hàm mà có thể là tham số bất kỳ.
* Hàm trả về từ decorator nhận vào một hàm và chính nó mới trả về hàm wrapper
* Cách sử dụng decorator cũng khác một chút. Decorator được gọi chạy ( dùng dấu () ) và truyền vào tham số.

**Nó chạy như thế nào:**

* Trong ví dụ 3 decorator được sử dụng `@chuc_danh_decorator("Giao su")`. Chú ý dấu (...), decorator được gọi thực thi và nó trả về hàm `ten_decorator` và chính nó sẽ bọc hàm được decorate.
* Hàm `chuc_danh_decorator` chỉ có tác dụng là dùng để truyền tham số vào decorator.

## 7. Debug hàm decorator.

Khi sử dụng decorator thì hàm thực sự được gọi là hàm wrapper của trả về từ decorator. Nên các thuộc tính `__name__`, `__doc__`, `__module__` không còn là của hàm được decorate nữa mà là của wrapper

Sử dụng lại code trong ví dụ 1:

```python
print xuat_ten.__name__

>> wrapper
```

**Khắc phục:** sử dụng thư viện `functools`
**Ví dụ 4:**

```python
from functools import wraps

def ten_decorator(f):
   @wraps(f)
   def wrapper(ten):
       chuoi_moi = "Ten tui la %s" % ten
       return f(chuoi_moi)
   return wrapper

def xuat_ten( ten ):
   print ten

print xuat_ten.__name__

>> xuat_ten
```

Decorator `wraps` sẽ lấy các thuộc tính `__name__`, `__doc__`, `__module__` của hàm được decorate và gán cho hàm wrapper nên khi lấy những thuộc tính này sẽ trả về thông tin đúng.

## 8. Khi nào nên sử dụng decorator?

Tham khảo trang [Wiki](https://wiki.python.org/moin/PythonDecoratorLibrary) của Python
