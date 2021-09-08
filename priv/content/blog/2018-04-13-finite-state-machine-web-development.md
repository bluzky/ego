---
title: "Finite state machine trong lập trình"
date: 2018-04-13T22:32:22+07:00
draft: false
author: Dung Nguyen
tags: ["elixir", "tech"]
---



## 1. Tìm hiểu về FSM

> [FSM(Finite state machine)](https://vi.wikipedia.org/wiki/M%C3%A1y_tr%E1%BA%A1ng_th%C3%A1i_h%E1%BB%AFu_h%E1%BA%A1n) - Máy trạng thái hữu hạn là một mô hình toán học biểu diễn trạng thái của hệ, trong đó số trạng thái là hữu hạn. Từ mỗi trạng thái, máy có thể chuyển đổi qua 1 số trạng thái cố định khác, dựa trên các sự kiện, input.

Fsm được biểu diễn như 1 đồ thị có hướng.

**Ví dụ**:

Máy trạng thái thể hiện trạng thái của 1 bài báo trên trang tin tức

![fsm](/img/fsm_post.png)

- `draft`, `in review` `published` là các trạng thái của bài viết
- `review`, `approve`, `reject`, `unpublish` là các sự kiện( event ). Các sự kiện này phát sinh khi nhận các input như click lên button, … Các sự kiện này gây ra việc chuyển trạng thái (ví dụ từ Draft -> In review), gọi là quá trình chuyển đổi (`transition`)

**Đặc điểm**

Trong mô hình sử dụng `DFS` máy  trạng thái đơn định.

- Tại mỗi thời điểm  máy chỉ ở 1 trạng thái duy nhất
- Tại mỗi trạng thái, chỉ có thể chuyển qua những trạng thái được cho phép
- Từ trạng thái hiện tại, có thể biết được những trạng thái kế tiếp mà máy có thể chuyển qua



## 2. Ứng dụng của FSM trong lập trình

- FSM mô tả các trạng thái, sự kiện và quá trình chuyển đổi giữa các trạng thái, nên FSM có thể được sử dụng để quản lý trạng thái của object, hoặc workflow. 

- Ví dụ: Quản lý trạng thái đơn hàng, quản lý trạng thái của ticket, quản lý trạng thái của nhân vật trong game, ...

  ​

  Trong ví dụ trên, mỗi bài viết, chỉ có thể có một trạng thái tại một thời điểm, và từ 1 trạng thái chỉ có thể chuyển đổi qua một số trạng thái được quy định trước:

  - Từ `draft` chỉ có thể chuyển qua `in review`
  - Từ `draft` không thể chuyển qua `published`

### 2.1 Khi không dùng FSM

Khi không sử dụng FSM thì code sẽ phải dùng tới rất nhiều điều kiện `if … else…` hoặc `case` (`switch ... case …` trong các ngôn ngữ khác)

```elixir
defmodule Post do
	defstruct content: "sample content", status: "draft"
	
	def all_status, do: ["draft", "in_review", "published"]
    
    def update_status(%{status: "draft"} = post, status) do
    	if status == "in_review" do
        	IO.put("Update post status to in_review")
        	Map.put(post, :status, "in_review")
        else
        	IO.put("Cannot update to #{status} from draft")
        	post
        end
    end
    
    def update_status(%{status: "in_review"} = post, status) do
    	case status do
			"draft" ->
	    		IO.put("Reject the post")
    	    	Map.put(post, :status, "draft")
    	    
    	    "published"
    	   		IO.put("Publish the post")
    	    	Map.put(post, :status, "published")
        	true ->
        		IO.put("Cannot update to #{status} from in_review")
        		post
        end
    end
    
    def update_status(%{status: "published"} = post, status) do
    	if status == "draft" do
        	IO.put("Unpublish the post")
        	Map.put(post, :status, "draft")
        else
        	IO.put("Cannot update to #{status} from published")
        	post
        end
    end
end
```

**Vấn đề: **

- Code dài, khó mở rộng, dễ xảy ra lỗi


- Nếu thêm nhiều trạng thái khác cho post, phải update toàn bộ các hàm `update_status`
- Nếu có nhiều cách chuyển đổi giữa các trạng thái, phải update toàn bộ
- Làm sao biết từ trạng thái hiện tại có thể chuyển qua trạng thái nào khác?
- Làm sao đảm bảo luồng dữ liệu/ logic chạy đúng



### 2.2 Sử dụng FSM

Trong ví dụ này sử dụng thư viện [as_fsm](https://github.com/bluzky/as_fsm) hỗ trợ việc implement máy trạng thái trên ngôn ngữ elixir

```elixir
defmodule Post do
  # define state, event and transition 
  use AsFsm,
    states: [:draft, :in_review, :published],
    events: [
      review: [
        name:     "In review",
        from:     [:draft],
        to:       :in_review,
        on_transition: fn(post, params) -> 
        	# thực ra việc gán trạng thái mới được tự động thực hiện bởi thư viện
        	# code này chỉ để mục đích cho dễ hiểu
        	post = Map.put(post, :status, :in_review)
        	{:ok, post}
        end
      ], 
      approve: [
        name:     "Approve",
        from:     [:in_review],
        to:       :published
        on_transition: fn(post, params) -> 
        	post = Map.put(post, :status, :published)
        	{:ok, post}
        end
      ], 
      reject: [
        name:     "Reject",
        from:     [:in_review],
        to:       :draft,
        on_transition: fn(post, params) -> 
        	post = Map.put(post, :status, :draft)
        	{:ok, post}
        end
      ],
      unpublish: [
        name:     "Unpublish",
        from:     [:published],
        to:       :draft,
        on_transition: fn(post, params) -> 
        	post = Map.put(post, :status, :draft)
        	{:ok, post}
        end
      ]
    ]
    
    defstruct content: "sample content", status: "draft"
end

# gọi thực hiện 
iex > post = %Post{content: "test content", status: "draft"}
iex > post = Post.review(post)
# hoac
iex > post = Post.trigger(post, :review)
```



- Việc implement FSM cũng không quá phức tạp nhưng có thể tái sử dụng được nhiều lần
- Việc thêm mới các trạng thái (state) hoặc các bước chuyển tiếp (transition) không cần thay đổi quá nhiều code
- các luồng xử lý, event được thể hiện rõ trên cấu hình trạng thái




## 3. Tham khảo

- Học thêm về [FSM trên Brilliant](https://brilliant.org/wiki/finite-state-machines/)

- [Finite-state machine in web-development](https://blog.4xxi.com/finite-state-machine-in-web-development-dc1dc6f67d7c)

- Thư viện FSM cho ecto model [ecto_state_machine](https://github.com/asiniy/ecto_state_machine)

- Slide [State Machine Workflow: Esoteric Techniques & Patterns](https://www.slideshare.net/EuropeanSharePointCommunity/th11-fitzmauricestate-machine-workflows?next_slideshow=1)

  ​
