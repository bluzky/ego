---
title: Dùng MAP, FILTER và REDUCE để xử lý danh sách / list trong Python
date: 2018-01-21
author: Dung Nguyen
tags: ["python", "python-basic"]
---

## 1. Giới thiệu

* List là một trong những kiểu dữ liệu được sử dụng rất nhiều trong python.
* Các thao tác thường được thực hiện trên list: xử lý từng phần tử trong list, lọc lấy một số phần tử thỏa điều kiện, tính toán dựa trên tất cả các phần tử của list( vd tính tổng) và trả về kết quả.
* Để đơn giản việc xử lý List, Python hỗ trợ một số hàm có sẵn để thực hiện các tác vụ trên gồm `map()`, `filter()`, `reduce()`

## 2. Map

> `map(func, seq)` > `map` sẽ áp dụng hàm func cho mỗi phần tử của seq và trả về list kết quả.

**Ví dụ:** Tính bình phương các số có trong list

**a. sử dụng map():**

```python
my_list = [1,2,3,4,5]
def binh_phuong(number):
	return number*number

print map(binh_phuong, my_list)
# [1,2,9,16,25]
```

* Trong ví dụ trên, map sẽ tự động áp dụng hàm binh_phuong với mỗi phần tử trong danh sách my_list
* Hàm truyền vào hàm `map` nhận vào một tham số cùng kiểu với phần tử của list
* Có thể sử dụng lamda thay thế cho hàm. Ví dụ trên có thể được viết lại: `print map(lambda x: x*x, my_list)`

**b. Cách thông thường:**

```python
my_list = [1,2,3,4,5]
result = list()
for number in my_list:
	result.append( number*number)

print result # [1,2,9,16,25]
```

## 3. Filter

> * filter(func, list)
> * Hàm filter sẽ gọi hàm func với tham số lần lượt là từng phần tử của list và trả về danh sách các phần tử mà func trả về **True**
> * func chỉ có thể trả về **True** hoặc **False**

**Ví dụ:** lọc ra các số chẵn từ danh sách
a. Sử dụng filter:

```python
my_list = [1, 2, 3, 4, 5]

def so_chan(number):
    if number % 2 == 0:
        return True
    else:
        return False

print filter(so_chan, my_list)  # [2,4]
```

#Sử dụng lambda

```python
print filter(lambda x: x%2 ==0, my_list)# [2,4]
```

b. Không dùng filter

```python
my_list = [1, 2, 3, 4, 5]
ket_qua = list()

for number in my_list:
    if number % 2 == 0:
        ket_qua.append(number)

print ket_qua
```

## 4. Reduce

> `reduce(func, seq)`
> reduce sẽ tính toán với các phần tử của danh sách và trả về kết quả.
> `func` là một hàm nhận vào 2 tham số có dạng`func(arg1, arg2)` trong đó `arg1` là kết quả tính toán với các phần tử trước, `arg2` là giá trị của phần tử của danh sách đang được tính toán.

**Ví dụ:** tính tổng bình phương của các phần tử trong mảng
a. Su dung reduce

```python
data = [1,2,3,4]
def tinh_tong(tong, so):
	return tong + so*so

#su dung ham
print reduce(tinh_tong, data) #30

#su dung lambda
print reduce( (lambda tong, so: tong + so*so), data) #30
```

b. Khong su dung reduce

```python
data = [1,2,3,4]
tong = 0
for so in data:
	tong += so*so

print tong #30
```

## 5. Kết luận

* _Trong bài viết chỉ đưa ra những ví dụ đơn giản nên có thể các bạn chưa thấy được sự tiện dụng của `map, filter, reduce`._
* _Tuy nhiên khi phải làm việc với list nhiều các bạn sẽ thấy nó rất là tiện đặc biệt là khi sử dụng kèm lambda hoặc tái sử dụng các hàm với map, filter và reduce_
