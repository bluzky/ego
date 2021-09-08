---
title: "Sử dụng ETS để tăng tốc ứng dụng với Phoenix"
date: 2018-05-18T01:05:50+07:00
draft: false
author: "Dung Nguyen"
tags: ["elixir", "phoenix", "ETS"]
---


> Bài viết này sẽ hướng dẫn các bạn sử dụng ETS như là bộ nhớ cache để tăng tốc các ứng dụng web Phoenix



Dành cho các bạn chưa biết: 

- ETS (Erlang Term Storage) là cơ sở dữ liệu dạng `key-value` lưu trữ trên RAM, tương tự như **Memcache** và **Redis**, với ưu điểm là tốc độ truy xuất cực nhanh. Đọc thêm về [ETS](http://bluzky.github.io/post/2018-05-12-erlang-term-storage/)
- Cache là việc lưu lại các kết quả xử lý của request vào bộ nhớ và trả về cho các request sau mà không cần phải tính toán lại -> giảm response time.



### 1. Setup project

- Tạo 1 project mới
  ```shell
  mix phx.new phoenix_cache
  mix deps.get
  ```

- Thêm chức năng tạo/xoá/sửa bài viết
  ```shell
  mix phx.gen.html Posts Post posts title:string summary:text content:text
  mix ecto.create
  mix ecto.migrate
  ```

- Vào [http://0.0.0.0:4000/posts](http://0.0.0.0:4000/posts) để xem chức năng bài viết. Thêm vài bài viết để có dữ liệu test
![img](/img/ets-phoenix.png)

### 2. Tạo một module để quản lý cache

Do table trong ETS sẽ bị huỷ khi process khởi tạo table kết thúc, nên cần phải có 1 process luôn luôn chạy để table không bị xoá. Sử dụng `GenServer` để quản lý Cache là tiện nhất vì nó được cung cấp sẵn bởi Elixir.
Đọc thêm về [GenServer](https://hexdocs.pm/elixir/GenServer.html)

#### 2.1 Tạo module

Tạo một file mới `phoenix_cache/lib/phoenix_cache/bucket.ex`
```elixir
defmodule PhoenixCache.Bucket do
  use GenServer
  alias :ets, as: Ets

  # thời gian sống của 1 entry mặc định là 6 phút
  @expired_after 6 * 60

  def start_link(args \\ []) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end
end
```


#### 2.2 Khởi tạo cache table khi bắt đầu chạy `GenServer`

```elixir
def init(state) do
    Ets.new(:simple_cache, [:set, :protected, :named_table, read_concurrency: true])
    {:ok, state}
end
```
**Module cache sẽ hỗ trợ 3 thao tác:**

- `set`: lưu data vào bộ nhớ cache
- `get`: lấy data từ bộ nhớ cache
- `delete`: xoá data khỏi cache (cái này có vẻ không cần lắm thì phải)



#### 2.3 Thêm data vào cache

```elixir

  def set(key, value) do
    GenServer.cast(__MODULE__, {:set, key, value})
  end

  @doc """
  Default TTL 
  """
  def handle_cast({:set, key, val}, state) do
    expired_at =
      NaiveDateTime.utc_now()
      |> NaiveDateTime.add(@expired_after, :second)

    Ets.insert(:simple_cache, {key, val, expired_at})
    {:noreply, state}
  end
```

Ở đây chúng ta sẽ tạo tính toán thời điểm expire/hết hạn của giá trị cache, tính từ thời điểm hiện tại, sử dụng giá trị `TTL`(thời gian sống) mặc định là 6phút. Bạn có thể cấu hình lưu `TTL` mặc định vào config hoặc biến môi trường. Mình lưu vào thuộc tính module cho tiện.



#### 2.4 Thêm data vào cache và thiết lập thời gian sống của data

Để có thể thoải mái thiết lập `TTL`, ta thêm 1 hàm cho phép truyền vào tham số `TTL`

```elixir
@doc """
  Custom TTL for cache entry
  ttl: Time to live in second
  """
  def set(key, value, ttl) do
    GenServer.cast(__MODULE__, {:set, key, value, ttl})
  end
  
  @doc """
  Custom TTL
  """
  def handle_cast({:set, key, val, ttl}, state) do
    inserted_at =
      NaiveDateTime.utc_now()
      |> NaiveDateTime.add(ttl, :second)

    Ets.insert(:simple_cache, {key, val, inserted_at})
    {:noreply, state}
  end
```

Cũng tương tự như trên nhưng hàm `set` sẽ nhận thêm tham số thứ 3 là `TTL` thay vì xài giá trị mặc định.



#### 2.5 Truy xuất dữ liệu từ cache

Có vào thì phải có lấy ra chứ nhỉ, bây giờ ta sẽ thêm code để truy xuất data từ cache.

```elixir
  def get(key) do
	# lấy giá trị đầu tiên tìm đuợc
    rs = Ets.lookup(:simple_cache, key) |> List.first()

		# Nếu không tìm thấy thì trả về lỗi
    if rs == nil do
      {:error, :not_found}
    else
      expired_at = elem(rs, 2)
			
			# So sánh thời điểm hết hạn với hiện tại, nếu hết hạn thì trả về lỗi
      cond do
        NaiveDateTime.diff(NaiveDateTime.utc_now(), expired_at) > 0 ->
          {:error, :expired}

        true ->
          {:ok, elem(rs, 1)}
      end
    end
  end
```

**Note**: Nhờ feedback của bác @HQC, chỗ này mình đọc trực tiếp từ table, thay vì dùng `GenServer.call` như trước vì khi send request vào GenServer thì code sẽ được chạy `sync`/đồng bộ. Do vậy sẽ tạo nên ngẽn cổ chai. Mình sửa lại ở phần tạo table thêm `read_concurrency: true` và đưa phần code query dữ liệu ra ngoài GenServer



#### 2.6 Xoá dữ liệu khỏi cache

```elixir
  def delete(key) do
    GenServer.cast(__MODULE__, {:delete, key})
  end
  
  def handle_cast({:delete, key}, state) do
    Ets.delete(:simple_cache, key)
    {:noreply, state}
  end
```



#### 2.7 Module hoàn chỉnh

```elixir
defmodule PhoenixCache.Bucket do
  use GenServer
  alias :ets, as: Ets

  @expired_after 6 * 60

  def start_link(args \\ []) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def set(key, value) do
    GenServer.cast(__MODULE__, {:set, key, value})
  end

  @doc """
  Custom TTL for cache entry
  ttl: Time to live in second
  """
  def set(key, value, ttl) do
    GenServer.cast(__MODULE__, {:set, key, value, ttl})
  end

  def get(key) do
    rs = Ets.lookup(:simple_cache, key) |> List.first()

    if rs == nil do
      {:error, :not_found}
    else
      expired_at = elem(rs, 2)

      cond do
        NaiveDateTime.diff(NaiveDateTime.utc_now(), expired_at) > 0 ->
          {:error, :expired}

        true ->
          {:ok, elem(rs, 1)}
      end
    end
  end

  def delete(key) do
    GenServer.cast(__MODULE__, {:delete, key})
  end

  # Server callbacks
  # Server (callbacks)

  @impl true
  def init(state) do
    Ets.new(:simple_cache, [:set, :protected, :named_table, read_concurrency: true])
    {:ok, state}
  end

  @doc """
  Default TTL 
  """
  def handle_cast({:set, key, val}, state) do
    expired_at =
      NaiveDateTime.utc_now()
      |> NaiveDateTime.add(@expired_after, :second)

    Ets.insert(:simple_cache, {key, val, expired_at})
    {:noreply, state}
  end

  @doc """
  Custom TTL
  """
  def handle_cast({:set, key, val, ttl}, state) do
    inserted_at =
      NaiveDateTime.utc_now()
      |> NaiveDateTime.add(ttl, :second)

    Ets.insert(:simple_cache, {key, val, inserted_at})
    {:noreply, state}
  end

  @impl true
  def handle_cast({:delete, key}, state) do
    Ets.delete(:simple_cache, key)
    {:noreply, state}
  end
end

```


### 3. Setup cache

Ta đã tạo xong module cache rồi, nhưng làm sao để cache tự động chạy khi chạy server? 

Thêm worker vào file `phoenix_cache/lib/phoenix_cache/application.ex`

```elixir
children = [
      ...
      worker(PhoenixCache.Bucket, [])
    ]
```

Khi `Supervisor` khởi chạy, nó sẽ start các `children` và quản lý chúng. Để hiểu rõ hơn, đọc thêm tại [https://hexdocs.pm/elixir/Supervisor.html](https://hexdocs.pm/elixir/Supervisor.html)



### 4. Xài cache

Olala, ta đã tạo module cache và thiết lập để chạy cùng với server, bây giờ tới lúc xài nó rồi.

Thử dùng cache cho chức năng xem bài viết:

```elixir
def show(conn, %{"id" => id}) do
    post =
      # lấy nội dung post từ cache
      case PhoenixCache.Bucket.get("posts-#{id}") do
      	# Nếu có ròi thì khỏi cần đọc DB
        {:ok, post} ->
          IO.puts("HIT")
          post

        {:error, _} ->
          IO.puts("MISS")
          # Chưa cache thì đọc từ DB
          post = Posts.get_post!(id)

          # cache bài viết 60s
          PhoenixCache.Bucket.set("posts-#{id}", post, 60)
          post
      end

    render(conn, "show.html", post: post)
  end

```



Kết quả request:

```shell
[info] GET /posts/1
MISS
...
[info] GET /posts/1
HIT
...
```

Lần request đầu tiên, bài viết chưa được cache nên phải truy xuất database và cache lại, lần thứ 2 thì đã có trong cache nên không cần phải đọc từ database nữa.

Ở ví dụ này có thể bạn sẽ chưa thấy sự khác biệt lắm về tốc độ response, nhưng nếu như thay vì load 1 bài viết bằng việc xử lý thống kê dữ liệu thì sự khác biệt sẽ rất lớn.



### 5. Plug cache

Nếu cứ mỗi chức năng đều phải thêm code để kiểm tra cache  thì sẽ lặp lại rất nhiều. Để phát huy cái sự lười biếng thì ta sẽ tạo một plug đơn giản để khỏi phải code nhiều lần.

```elixir
defmodule PhoenixCache.Plug.Cache do
  import Plug.Conn

  # 6 minute
  @default_ttl 6 * 60

  def init(ttl \\ nil), do: ttl

  def call(conn, ttl \\ nil) do
    ttl = ttl || @default_ttl

    # Chỉ cache với GET request
    if conn.method == "GET" do
      # tạo key từ request path và query param, thông thường
      # thì cùng path và cùng param thì kết quả là giống nhau
      key = "#{conn.request_path}-#{conn.query_string}"

      case PhoenixCache.Bucket.get(key) do
        {:ok, body} ->
          IO.puts("PLUG HIT")
		  
		  # nếu đã cache thì trả về ngay
          conn
          |> send_resp(200, body)
          |> halt

        _ ->
          IO.puts("PLUG MISS")
		  # nếu chưa cache thì xử lý như bình thường
          conn
          |> assign(:ttl, ttl)
          |> register_before_send(&cache_before_send/1) # gọi hàm này trước khi trả về
      end
    else
      conn
    end
  end

  def cache_before_send(conn) do
    # nếu request đuợc xử lý thành công thì cache
    if conn.status == 200 do
      key = "#{conn.request_path}-#{conn.query_string}"
      data = conn.resp_body
      PhoenixCache.Bucket.set(key, data, conn.assigns[:ttl] || @default_ttl)
      conn
      
    else
      # không thì kệ chúng mày
      conn
    end
  end
end

```

Đây chỉ là một plug đơn giản, bạn có thể viết lại theo nhu cầu.

Sử dụng Plug: `plug(PhoenixCache.Plug.Cache, TTL )`

```elixir
pipeline :browser do
    ...
    plug(PhoenixCache.Plug.Cache, 100) # cache 100s
 end
```

### 6. Kết luận

Vậy là bạn đã có thể sử dụng ETS như là bộ nhớ cache cho ứng dụng Phoenix của mình mà không cần phải cài thêm phần mềm/dịch vụ khác.

Hi vọng sẽ giúp ích cho các bạn

Source code project [https://github.com/bluzky/phoenix_ets_cache_example](https://github.com/bluzky/phoenix_ets_cache_example)

