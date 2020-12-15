# 本地部署
1. 下载Railschatbot
2. 下载MyLita，将MyLita移入Railschatbot文件夹中
3. 在
4. 在MyLita目录下执行`lita -d`
5. 在

# 由Rails构建前端交互界面

目标：用Rails构建一个与Chatbot交互的网络应用框架，在形式上与聊天室类似

实现：
- 登陆模块
- 借助聊天室的模式实现聊天界面，借助数据库实现与chatbot的通信

测试：
- 打开网页，进入登陆界面
- 输入用户名、密码（默认user1，password），点击登陆，进入聊天页面
- 在聊天界面输入的`double 2`
- 聊天界面回复`2+2=4`

环境
```
ruby 2.6.5
rails 6.0.3.4
```
## 适配器
利用了 元编程

## 数据库的设计

## 界面设计与美化
参考 https://codepen.io/sajadhsm/pen/odaBdd
1. 利用CSS美化页面
2. 使用`form_with`方法


修改数据库
user@test.com
qwer12321
