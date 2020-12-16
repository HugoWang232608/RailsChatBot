# 讲座助手聊天机器人

## 小组成员与分工

- 吴昊：前端交互界面设计，设配器的实现
- 马小涵： 讲座信息搜集以及相关功能的实现
- 汪增辉： 测试与部署

## 选题背景

国科大总是有各种精彩纷呈的讲座，高峰时期一天能有十几场讲座，获取讲座信息需要学子们登录教育云客户网站，逐条查询记录，由于学子们往往还有各种课程，以及种类繁多的课外活动，多重信息下，时间管理繁琐复杂，让人不胜其烦，所以本项目拟通过机器人自动爬取教育云网站上的讲座信息，只需一条交流式的指令，和网站的用户名密码，就能获得简要的讲座信息，并快速查询是否与已有的安排冲突，将心仪的讲座插入自己的任务序列中。

## 应用场景


# 前端交互的设计

主要分为下面几个部分内容
- 用Rails搭建网页、交互界面
- 数据库的设计
- 适配器的设计

任务目标：用Rails构建一个与Lita交互的网络应用框架，形式上与聊天室类似。每个用户登陆后可以分别与Lita进行一对一的交互。

测试样例：
- 打开网页，进入登陆界面
- 输入用户名、密码（默认user1，password），点击登陆，进入聊天页面
- 在聊天界面输入的`double 2` （这里选择最简单的功能）
- 聊天界面回复`2+2=4`

## 由Rails构建聊天室

设计了5个控制器，其对应的功能分别是

controller | function
------------ | -------------
welcome | 展示首页，导航至登陆模块
applicants | 处理用户的创建（注册）
sessions | 登陆
chatrooms | 聊天界面
messages | 聊天的消息

设计了两种资源（resources）分别是用户users与消息messages，它们的结构如下面代码所示。对于每一条消息，我们通过`reference`找到对应的用户（一定是消息的发送方或者接受方）

```ruby
  create_table "messages", force: :cascade do |t|
    t.string "body"
    t.boolean "from_bot"
    t.integer "user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_messages_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "username"
    t.string "password"
    t.string "password_digest"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end
```

需要注意的是，我采用的方式是把所有的用户与聊天机器人交互的消息都存在一起，在展示的时候我通过`user_id`确定发送的用户是谁，从而决定是否展示。在展示界面中，我再通过`from_bot`确定发送方是用户还是机器人，决定消息显示的位置。

Rails的视图是`html.erb`文件，嵌入式的使用了ruby,并且有对应的`form_with`方法完成相应的读取操作，而更常见的从页面读取表单的方式是json。在这里我还是考虑使用Rails原生的`form_with`展示数据和接受输入，了解了CSS与HTML的相关知识，最终实现了如下所示的聊天界面。

![截屏2020-12-16 下午8.34.44.png](http://note.youdao.com/yws/res/5191/WEBRESOURCEbf2b8f155b8ec4a910045522360d691b)

页面中左上角展示了当前的用户，右上角是注销选项。主体部分是聊天的消息展示窗口，最下方是输入栏。

## Lita适配器的设计

我在项目的执行过程中逐渐发现，适配器的设计是一个非常复杂的过程，要考虑的因素很多。

首先，要决定应该把Lita作为一个守护进程（daemon）还是作为嵌入在Rails框架中的一个方法。采用后面一种方法要简单一些，如果只考虑“一来一回”的交互，即对于用户的每一句话，只给出一句回复，那么可以直接用`Lita::Robot.new`创建一个机器人对象，用`Lita::Robot.receive(message)`来接受命令。但这样做的问题是无法处理延时任务的情况，比如`schedule`功能。

其次，要考虑Lita如何读取命令。我这里想到的方法是让Rails前端和后端的Lita守护进程同时与数据库Sqlite3进行交互，在聊天界面发送消息时则在数据库中创建对应的项，Lita则通过一个循环不断检索sqlite3数据库中的message表，看是否有没有读的内容。如果有未处理的来自用户的信息，则读取并处理。

Lita回复的消息直接写入数据库的messages表中，`from_bot`域设置为`1`。这样做的好处在于展示消息时本来就要把用户发送和接受的信息一起读出。在向用户`userx`展示消息记录时，从数据库中读取`ref`域对应`userx`的消息，然后展示即可。

![截屏2020-12-16 下午8.48.31.png](http://note.youdao.com/yws/res/5213/WEBRESOURCEe51e52ddf983c1447793b2368ee28da2)

整体的框架如图所示，左边蓝色的部分是Rails的控制器，中间灰色的部分表示Rails的`Sqlite3`数据库，Lita作为一个守护进程运行在后端，通过检查数据库中的消息表来确认是否有没有处理的信息。

主要的工作是根据Lita的`:shell`适配器改写，主要改写的部分如下

```ruby
# mybot/lita-railschatbot/lib/lita/adapters/railschatbot.rb 
def run_loop
    loop do
        collect_and_send
        sleep(1)
    end
end 


def collect_and_send 
    open_database
    a = read_database(@db, @last_read_id)
    close_database
    
    a.each do |row|
        @uid = row['user_id']
        input = row['body']
        @last_read_id = row['id']
          
        if row['from_bot']==true
            next
        end
        robot.receive(build_message(input, @source))
    end
    record_read_id 
    a       
end

def send_messages(_target, strings)
    strings = Array(strings)
    strings.reject!(&:empty?)
    unless RbConfig::CONFIG["host_os"] =~ /mswin|mingw/ || !$stdout.tty?
      strings.map! { |string| "#{string}" }
    end
        
    open_database
    write_database(@db, strings)
    close_database
end
```

实际在改写之前，先确定需要的测试。在单元测试的部分我对改写的相关函数进行了测试，主要是与数据库操作相关的部分。如
```
describe 'database operations' do 
        it 'open database' do
            db = subject.open_database("development.sqlite3")
            a = db.execute "SELECT * FROM users" 
            
            expect(a[0][0]).to eq 1
            expect(a[0][1]).to eq "user1@test.com"
        end

        it 'close database' do
            db = subject.open_database("development.sqlite3")
            expect(db.closed?).to eq false
            db = subject.close_database
            expect(db.closed?).to eq true
        end
end
```
![截屏2020-12-16 下午9.02.53.png](http://note.youdao.com/yws/res/5244/WEBRESOURCEe188d4749a4b70f59c953f204dddae02)

这一部分的测试覆盖率只有60%，主要是我在重写过程中只对自己改写的函数进行了测试，很多原有的函数没有进行测试。

## 讲座信息收集
采用Lita框架，通过适配器与前端沟通，爬虫利用账户和密码登录教育云网站，收集信息。
在实现的过程中，主要是登录方式存在挑战。
第一版打算利用浏览器控制器 chromedriver 等通过浏览器实现登录，因为这样对于用户而言是采用自己熟悉的方式，学习曲线较为平缓，而且机器人自身不存储用户的私密信息，较为安全。但考虑到 chromedriver 等控制器需要用户根据自己的浏览器版本自行下载安装，更加麻烦，而且多次查询就要一直输入用户名密码。也很麻烦，于是采用了 Lita 记忆账户账户密码的方式。

具体实现上，采用 ruby-mechanize 这一强大的 gem，爬取了主要的讲座信息，并初步实现了对格式不一样的信息的统一。




## 本地部署
环境
```
ruby 2.6.5
rails 6.0.3.4
```
# 应用线上部署
我们选择将应用部署在服务器上，选择的服务器是Heroku。Heroku是一种平台即服务，灵活性极高且支持多种编程语言。若想把程序部署到Heroku上,开发者要使用Git把程序推送到Heroku的Git服务器上。在服务器上,git push命令会自动触发安装、配置和部署程序。

Heroku使用名为Dyno的计算单元衡量用量,并以此为依据收取服务费用。最常用的Dyno类型是Web Dyno,表示一个Web服务器实例。程序可以通过使用更多的Web Dyno以增强其请求处理能力。另一种Dyno类型是Worker Dyno,用来执行后台作业或其他辅助任务。   
具体内容请参考 <https://devcenter.heroku.com/>

这部分内容我们将详细应用的部署流程和注意事项。

## 应用部署常规流程
在heroku上部署应用之前，需要事先注册好账号。
1. 初始化本地仓库  
```
git init
```  
如果是在GitHub上clone的仓库则不需要这一步。  

2. 在heroku服务器上创建一个APP  
```
heroku create railschatbot 
```
可以由用户自己指定用户名，字母必须小写。名称缺省则由服务器随机生成。

3. 在项目的根目录下创建Procfile，选择应用的打开方式，如：
```
web: bundle exec rails server
```
指定以web格式打开应用，并执行```bundle exec rails server```。
文件名必须严格符合要求，不能有后缀。

4. 将本地仓库的代码推到服务器上
```
git add .
git commit -m "some changes"
git push heroku master
```
每次进行代码的更改之后，想把更改上传到服务器上都必须执行这三个步骤。

5. 打开APP
```
heroku open
```
此时终端将自动生成应用网址，打开浏览器输入网址即可。

## 部署Ruby on Rails应用注意事项
1. 如果你在开发过程中使用的数据库是 sqlite的话，上传时将报错，因为heroku不支持 sqlite，因此应该使用PostgreSQL或者修改Gemfile 文件：  
删除
```
gem "sqlite3"
```
加入：
```
group :test, :development do
  gem 'sqlite3'
end
group :production do 
  gem 'pg'
end
```
然后执行
```
bundle install
``` 
确保各依赖项不会产生冲突。

2. 出现 ```Precompiling assets failed```错误，修改方式：  
在```config/application.rb```中加入：
```
config.assets.initialize_on_precompile = false
```
注意该语句应该放在```Rails.application.configure```代码块中，若无该代码块，则应该加入：
```
Rails.application.configure do
  config.assets.initialize_on_precompile = false
end
```

3. 每次对Gemfile进行修改后都应该执行```bundle install```, 如果出现无法解决的依赖项相关问题，可以尝试如下方法：  
   （1）执行 ```bundle update ```   
   （2）删除 ```Gemfile.lock``` 文件后再执行```bundle install```

4. 一些常用的命令，可以在产生错误时帮助定位错误产生的位置或者debug。  
打开生产环境的Rails Console 
```
heroku run rails c
```

查看正在运行的dyno(dyno可视为Procfile中指定的命令的一个轻量级的容器)
```
heroku ps
```

查看日志 
```
heroku logs --tail  
```
查看Heroku config variable 
```
heroku config --app myApp  
```
删除Heroku上的App App
```
heroku apps:destroy --app example   
```
