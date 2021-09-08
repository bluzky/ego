---
title: "Tìm hiểu về công nghệ Blockchain"
date: 2018-04-11T20:53:06+07:00
draft: false
tags: ["others", "tech", "blockchain"]
author: Dung Nguyen
image: "/img/blockchain.jpg"
---

> Từ cơn sốt tiền ảo, công nghệ Blockchain được tung hô và được xem như là công nghệ sẽ làm thay đổi tương lại, thậm chí đến cả công ty thực phẩm thêm chữ Blockchain vào tên sản phẩm cũng đủ làm giá cổ phiếu tăng mấy chục lần. 
> Vậy Blockchain là gì và nó có thực sự là thứ sẽ làm thay đổi tương lai công nghệ? 
> Để trả lời thắc mắc của chính mình, tôi đã dành thời gian để tìm hiểu về Blockchain. Có thể có một số sai sót không tránh khỏi. Rất mong nhận được sự góp ý.

## I. Blockchain là gì?

### 1. Định nghĩa

Khó có thể đưa ra một định nghĩa chính xác cho `Blockchain`

`Blockchain` là một công nghệ xác thực, xử lý và lưu trữ các giao dịch trên mạng internet dựa trên hệ thống phân tán.

Nguồn gốc tên gọi `Blockchain` xuất phát từ công nghệ lưu trữ dữ liệu thành các khối `block`, sau đó các khối này được kết nối lại với nhau thành một chuỗi `chain`.

### 2. Cách tổ chức dữ liệu

Tất cả dữ liệu trong hệ thống `Blockchain` sẽ được đóng gói thành các khối, các khối này liên kết với nhau tạo thành một chuỗi duy nhất và thống nhất trên toàn bộ hệ thống.

Mỗi block chứa nhiều giao dịch (`transaction`) khác nhau và Mỗi block có chứa mã hash của `block` trước nó. Mã hash được tạo ra nhờ các thuật toán phức tạp như SHA256, MD5, … giá trị của mã hash là khác nhau cho các dữ liệu khác nhau. Chỉ cần một sự thay đổi nhỏ trong dữ liệu cũng sẽ làm thay đổi giá trị của mã hash. Nhờ mã hash này mà việc thay đổi giá trị của một block sẽ khiến mã hash nó thay đổi và không còn trùng với mã hash được lưu ở `block` sau nó. Nhờ mã hash mà hệ thống có thể kiểm tra và loại bỏ những thông tin bị cố tình thay đổi.

`Transaction` là thông tin của các giao dịch. Giao dịch ở đây không giới hạn trong chuyển tiền, `transaction` có thể chứa bất cứ thông tin gì như hình ảnh, âm thanh, ….



### 3. Blockchain network

Để hiện thực công nghệ blockchain cần có một hệ thống các máy tính kết nối với mạng internet và chạy một ứng dụng khách `client`. 

Mỗi máy tính trong network được gọi là `node`. Mỗi node có thể chứa bản sao (hoặc một phần) dữ liệu của hệ thống `blockchain`. Điều này giúp tránh việt mất mát dữ liệu và đảm bảo an toàn cho hệ thống.



### 4. Lưu trữ dữ liệu

`Blockchain` sử dụng công nghệ lưu trữ dữ liệu gọi là `sổ cái phân tán` (`distributed ledger`). Trong đó dữ liệu sẽ được lưu trên tất cả các node trong network, mỗi node sẽ chứa bản sao của `blockchain`. Khi có một thay đổi trên `blockchain`, thay đổi này sẽ được đồng bộ hoá trong toàn bộ hệ thống. Sau 1 thời gian thì toàn bộ các node trên hệ thống sẽ đồng bộ trở lại và toàn bộ các bản sao trong hệ thống sẽ hoàn toàn giống nhau.

### 5. Đặc điểm của hệ thống Blockchain

- Dữ liệu một khi đã lưu trữ thì hầu như không thể sửa đổi được
- Luôn có thể truy vết nguồn gốc của dữ liệu qua tất cả các giao dịch trước đó
- Dữ liệu trên toàn bộ hệ thống thống nhất với nhau
- Phi tập trung: việc xác nhận và thực thi các giao dịch không cần phụ thuộc vào một bên trung gian thứ 3 cụ thể, mà được xác nhận bởi toàn bộ hệ thống.
- Dữ liệu được lưu trữ phân tán trên toàn bộ hệ thống
- Sử dụng các cơ chế đồng thuận để xác nhận giao dịch
- Mỗi giao dịch cần có sự tham gia của toàn bộ hệ thống



### 6. Ưu điểm

- **Ổn định** : Khác với hệ thống tập trung, khi một phần dịch vụ ngưng hoạt động sẽ ảnh hưởng toàn bộ hệ thống. Khi một vài `node` trong hệ thống bị dừng hoặc mất mát dữ liệu, toàn bộ hệ thống vẫn hoạt động bình thường.

- **An toàn dữ liệu**: Một khi dữ liệu đã được lưu vào trong hệ thống thì hầu như không thể thay đổi

- **Bảo mật**: Dữ liệu không thể thay đổi, việc thêm mới dữ liệu cần có sự xác nhận và đồng thuận của toàn bộ hệ thống nên khó để giả mạo thông tin. 

- **Thống nhất**: Dữ liệu được lưu trữ trên các `node` được đồng bộ và thống nhất với nhau.
   **Không cần trung gian/ không cần tin tưởng**: Việc xác nhận các giao dịch do toàn bộ các `node` trong hệ thống thực hiện nên không cần phải thông qua một bên thứ 3 được tin tưởng. Ví dụ: thông thường chuyển tiền qua ngân hàng cần 2 bên tin tưởng tuyệt đối vào ngân hàng. Trong blockchain, các giao dịch được thực hiện trực tiếp 	

- **Giảm bớt chi phí, thời gian**: Các giao dịch không cần khoản phí rất nhỏ do không phải trả cho bên trung gian. Thời gian giao dịch nhanh, không cần đợi xác nhận từ ngân hàng, không phải chờ ngày cuối tuần, ...

- **Hạn chế lỗi phát sinh do con người**: Toàn bộ các hoạt động của blockchain do hệ thống tự vận hành, không có sự can thiệp của con người.

   ​

### 7. Nhược điểm

- **Lãng phí**: việc xử lý tính toán được thực hiện bởi tất cả các `node` trong hệ thống nhưng chỉ kết quả của 1 node được sử dụng, chi phí tính toán của tất cả node còn lại bị lãng phí.
- **Khó mở rộng**: Việc xác nhận các giao dịch và đóng gói dữ liệu được thực hiện bởi toàn bộ các `node` trong hệ thống. Nếu lượng giao dịch quá lớn trong khoảng thời gian ngắn thì hệ thống không thể đáp ứng việc xử lý đồng thời quá nhiều
- **Vấn đề lưu trữ dữ liệu**: Khi hệ thống trở nên lớn hơn thì lượng dữ liệu cần lưu trữ sẽ ngày càng lớn. Như Ethereum mỗi năm dữ liệu tăng khoảng 55GB, nếu tất cả các `node` đều lưu trữ dữ liệu này thì các `node` sẽ cần khả năng xử lý cao hơn và điều này không thực tế. Nếu chỉ có một số `node` lưu trữ full data thì việc tấn công sẽ dễ hơn bởi vì chỉ cần tấn công một số ít `node`.
- **Tích hợp phức tạp**: Blockchain là công nghệ hoàn toàn mới nên việc tích hợp vào các hệ thống cũ sẽ rất khó khăn
- **Chưa hoàn thiện**: Hiện nay công nghệ `blockchain` vẫn đang trong giai đoạn phát triển và chưa có một ứng dụng nào áp dụng công nghệ `blockchain` thành công ngoài lĩnh vực `tiền ảo`



### 8. Các ứng dụng của `blockchain` / Các vấn đề mà `blockchain` có thể xử lý

- Truy xuất nguồn gốc sản phẩm (vật lý hay kỹ thuật số)
- Giảm chi phí trung gian
- Giải quyết vấn đề giao dịch không cần tin tưởng lẫn nhau
- Hợp đồng thông minh `smart contract` tự động thực thi điều khoản hợp đồng khi các điều kiện được đáp ứng, tránh việc chây ỳ, phá hợp đồng.




## II. Smart contract

### 1. Smart contract là gì?

`Smart contract` là một chương trình máy tính được lưu trữ trong `blockchain`, có khả năng thực thi các thoả thuận tự động mà không cần sự can thiệp từ con người.

`Smart contract` nói một cách chính xác hơn là giao dịch có điều kiện `conditional transaction`. Nghĩa là khi 2 bên đồng ý các điều khoản với nhau thì sẽ lập nên một `smart contract`/`transaction` với các điều kiện ràng buộc. Khi các điều kiện này thoả thì sẽ thực hiện giao dịch (transaction)/ hoặc huỷ giao dịch tuỳ điều kiện.

`Smart contract` được hỗ trợ bởi hầu hết các nền tảng blockchain hiện tại nhưng Ethereum là nền tảng được sử dụng nhiều nhất bởi sự linh hoạt và các tính năng mà nó hỗ trợ.

**Ví dụ:**

Khi A mua hàng sách online tại Shop P, cuốn sách trị giá 200k, A và Shop P lập 1 `smart contract` 

- 200k của A sẽ được lưu trong smart contract
- điều kiện là khi A nhận được cuốn sách từ Shop P -> chuyển 200k vào tài khoản shop P.



### 2. Smart contract hoạt động như thế nào?

[implement smart contract Ethereum](https://codeburst.io/build-your-first-ethereum-smart-contract-with-solidity-tutorial-94171d6b1c4b)

Làm thử rồi hiểu

### 3. Ưu và nhược điểm của Smart contract

**Ưu điểm**:

- Không cần sự can thiệp của con người trong việc thực thi hợp đồng
- Giảm bớt chi phí trung gian: luật sư, phí giao dịch ngân hàng
- Không cần tin tưởng đối tác
- Tự động thực thi



**Nhược điểm:**

- Để kiểm tra điều kiện của `smart contract` thì toàn bộ hệ thống phải truy xuất vào cùng 1 nguồn dữ liệu
  - Việc này giống như tấn công DDOS
  - Không có gì đảm bảo tất cả các kết quả trả về là giống nhau, vd: nguồn ko hoạt động, bị thay đổi


- `Smart contract` không thể cập nhật các điều khoản
- Không thể huỷ bỏ
- Tính chính xác của `smart contract` phụ thuộc vào người thiết lập các điều khoản (thường là lập trình viên)
  - Lập trình viên là con người và có xác suất lỗi
  - Lập trình viên phải hoàn toàn hiểu các điều khoản để chuyển thành chương trình
  - Phải hoàn toàn tin tưởng vào lập trình viên. 👹(they can be evil)
- Nguồn dữ liệu để kiểm tra các điều kiện có thể đến từ thế giới thực (vd xác nhận đã nhận hàng) thì vẫn có thể bị tấn công, giả mạo các thông tin đầu vào, hoặc phụ thuộc vào 1 bên thứ 3 được tin tưởng tuyệt đối

### 4. Ứng dụng của Smart contract

Tất cả những hoạt động giao dịch có điều kiện đều có thể sử dụng smart contract

- Tạo ra các token mới, có thể sử dụng như 1 loại tiền điện tử


- Xổ số
- Mua hàng online
- Bảo hiểm
- Mua nhà
- Giao hàng
- Cá độ
- …..


## III. Fork, Hard fork vs soft fork?

### 1 Fork là gì?

Như đã biết `Blockchain` là một chuỗi các khối liên kết với nhau, và các chuỗi này là giống nhau trên toàn bộ hệ thống. Các `node ` trong hệ thống thông qua một cơ chế đồng thuận ` consensus` để xác định khối nào sẽ được thêm vào `blockchain`.   `Fork ` xảy ra khi một hệ thống không đạt được sự đống thuận trong việc ghi các khối mới  và  `blockchain` bị chia tách thành 2 nhánh khách nhau.



Nguyên nhân của `fork` là do:

- Thêm các tính năng mới để cải tiến chức năng của hệ thống `blockchain` hiện tại.
- Sửa đổi các `rule` (quy định) trong quá trình xác nhận giao dịch và tạo khối (Vd: kích thước của 1 block) 



Do những thay đổi này là `permanent`(lâu dài) nên khi thực hiện `fork` các `node` trong hệ thống cần phải cập nhật ứng dụng client để tích hợp các `rule` mới.



Fork được chia làm 3 loại:

- Soft fork
- Hard fork
- Spin-off coin

### 2 Soft fork

`Soft fork` là những cập nhật phần mềm có `tương thích với phiên bản cũ` , nghĩa là các node không cần cập nhật phần mềm mới vẫn có thể thực hiện việc kiểm tra (validate) và xác nhận(verify) các giao dịch. Để hoàn thành `soft fork` chỉ cần phần lớn các node trong hệ thống cập nhật phiên bản mới, các node cũ vẫn có thể tiếp tục xác nhận các block mới tạo.

`Soft fork` là thực hiện việc cập nhật từ từ và không ảnh hưởng nhiều đến chức năng của hệ thống.

**Ví dụ:**

Thay đổi kích thước `block` từ 1MB lên 2MB, các node chưa cập nhật vẫn có thể tiếp nhận và xử lý các giao dịch, tuy nhiên các `block`  do các node này tạo ra sẽ bị hệ thống bỏ qua, không cho ghi vào `blockchain`, nên công sức xử lý của các node này coi như là bị lãng phí.

### 3 Hard fork

`Hard fork` là những cập nhật phần mềm tạo nên sự không tương thích với các phiên bản cũ. Để hoàn toàn cập nhật, tất cả các node phải cập nhật phần mềm lên phiên bản mới. Những node không cập nhật sẽ vẫn tiếp tục hoạt động theo các `rule` cũ. Các node mới và node cũ sẽ tạo nên 2 phiên bản khác nhau từ 1 `blockchain` ban đầu.

![img](https://masterthecrypto.com/wp-content/uploads/2017/10/wsi-imageoptim-Copy-of-Copy-of-CRYPTOCURRENCY-1-1.jpg)



Việc thực  hiện `Hard fork` có thể là do có kế hoạch trước hoặc là do sự chia rẽ trong cộng đồng sử dụng, bảo trì `blockchain`.



#### 3.1 Hard fork có kế hoạch

- Là những cập nhật trong giao thức đã được lên kế hoạch từ trước và có sự đồng thuận từ toàn bộ cộng đồng.
- Tất cả các node sẽ dần chuyển hoàn toàn qua nhánh mới tách ra.
- Nhánh cũ sẽ bị bỏ đi
- Việc cập nhật sẽ không gây ảnh hưởng tới giá trị của coin

#### 3.2 Hard fork do tranh cãi

- Thông thường là do sự bất đồng ý kiến trong cộng đồng trong việc xác định những thay đổi mà mỗi bên cho là tốt nhất đối với `blockchain` hiện tại.
- Blockchain sẽ chia tách thành 2 phiên bản khác nhau cùng tồn tại song song với nhau.
- Các node trong mạng lưới ban đầu cũng sẽ tách thành 2 mạng lưới khác nhau: mỗi bên sử dụng 1 bản cập nhật khác nhau.
- Các giao dịch trước khi chia tách sẽ tồn tại trong cả 2 blockchain



**Ví dụ**

Việc `hard fork` Bitcoin thành Bitcoin và Bitcoin Cash, do 1 bên muốn giữ kích thước Block 1MB và 1 bên muốn nâng kích thước block lên 8MB để tăng khả năng mở rộng của Bitcoin (thực hiện nhiều giao dịch hơn trong cùng thời gian)



### 4 Spin-off coin

Sử dụng mã nguồn của những coin có sẵn và thay đổi để tạo nên `blockchain` mới với những tính năng mới thêm vào.

**Ví dụ**

Litecoin là một coin dựa trên mã nguồn của Bitcoin với các thay đổi:

- Thời gian xử lý block trung bình là 2.5 phút so với 10 phút của Bitcoin
- Sử dụng thuật toán Scrypt thay vì SHA256
- Giới hạn tổng số coin là 84 triệu so với 21 triệu Bitcoin



## IV. Coin vs Token

### 1. Coin là gì?

`Coin` là một loại tiền mã hoá (crypto currency) được tạo ra và vận hành một cách độc lập dựa trên một nền tảng blockchain của riêng nó.

`Coin` là từ dùng để chỉ chung các loại tiền ảo như : Bitcoin, Ethereum, ...

`Altcoin` dùng để chỉ các loại tiền ảo ngoài Bitcoin

### 2. Token là gì ?

[Tạo token mới từ Ethereum](https://www.ethereum.org/token)

`Token` là các đơn vị có thể được sử dụng để dao dịch như `coin`, tuy nhiên `token` được tạo ra và hoạt động dựa trên cơ chế `Smart contract` mà các nền tảng Blockchain như Ethereum hay Omni cung cấp.

Hiện nay hơn 80% các loại token được tạo ra dựa trên nền tảng Ethereum



### 3. Phân loại token

Không có phân loại cụ thể cho token. Một token có thể sử dụng cho một hoặc nhiều mục đích:

- Sử dụng như đơn vị tiền tệ
- Tài sản số (digital)
- Công cụ kế toán
- Công cụ phân chia cổ phần nắm giữ trong các start-up
- Một phương pháp để chống tấn công
- Một dạng điểm, reward cho user
- ...


