import 'package:cloudbase_function/cloudbase_function.dart';
import 'package:flutter/material.dart';
import 'package:cloudbase_core/cloudbase_core.dart';
import 'package:cloudbase_auth/cloudbase_auth.dart';
import 'dart:convert';
import 'widgets/widgets.dart';
import 'common/common.dart';

final _envId = 'huangtao-4ghjf9gi85523bb2'; //开发环境ID
final _appAccesskey = '0d320aed74bc9a675a22fb492106cfc4'; //登录应用授权号
final _function = 'wxtbp'; //云开发环境被调用的云函数，因为flutter没办法直接调用回话机器人，所有通过云函数中转
final _botId = '152d9b18-7e5e-41f3-9296-4a4534d87705'; //对话机器人ID

void main() {
  runApp(MaterialApp(home: MyApp()));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'ShengyunWMS',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: new Scaffold(body: RedditSlider()),
    );
  }
}

class RedditSlider extends StatefulWidget {
  RedditSlider({Key key}) : super(key: key);

  @override
  _RedditSliderState createState() => _RedditSliderState();
}

class _RedditSliderState extends State<RedditSlider> {
  ValueNotifierData vd = ValueNotifierData(0);
  final PageController ctrl = PageController(viewportFraction: 0.80);
  TextEditingController mControll1 = TextEditingController();
  String _userId = "游侠"; //用户ID
  String _warehouse = "注册后默认仓库"; //仓库描述
  String _isLogin = 'NO'; //是否登录
  String _stdintitle = "标准输入";
  String _stdin;
  String _output = '运行结果将会显示在这里';
  String _intentNameTitle = ''; //意图标题
  String _intentName = ''; //当前意图
  String _ilotNameTitle = ''; //槽位标题
  String _ilotName = ''; //当前槽位
  Stream slides;

  String preIntentName; //上次意图的开始问话
  Map<String, dynamic> botreturndata = {}; //意图返回的数据

  int currentPage = 0;
  String activeSubreddit = 'earthporn';
  List<StatefulWidget> slideList = [];

  _fetchImages() async {
    List<StatefulWidget> list = [];

    RedditPage stock = new StockPage(data: vd);
    list.add(stock);

    RedditPage documents = new DocumentsPage(data: vd);
    list.add(documents);

    setState(() {
      slideList = list;
    });
  }

  @override
  void initState() {
    _fetchImages();
    ctrl.addListener(() {
      int next = ctrl.page.round();

      if (currentPage != next) {
        print('next:$next');

        for (int i = 0; i < slideList.length; i++) {
          RedditPage redditPage = slideList[i];
          redditPage.active = false;
          redditPage.botdata = {};
          if (next == i + 1) {
            redditPage.active = true;
            redditPage.botdata = botreturndata;
          }
        }

        vd.value = next;
        currentPage = next;
      }
    });
    super.initState();
  }

  //链接云开发环境
  _connectCloud() async {
    CloudBaseCore core = CloudBaseCore.init({
      'env': _envId,
      'appAccess': {'key': _appAccesskey, 'version': '1'}
    });

    // 获取登录状态
    CloudBaseAuth auth = CloudBaseAuth(core);

    CloudBaseAuthState authState = await auth.getAuthState();

    // 唤起匿名登录
    if (authState == null) {
      await auth.signInAnonymously().then((success) {
        // 登录成功
        print(success);
      }).catchError((err) {
        // 登录失败
        print(err);
      });
    }

    CloudBaseFunction cloudbase = CloudBaseFunction(core);
    return cloudbase;
  }

  _cloudFunction() async {
    if (_stdin == '') {
      return;
    }
    print(_stdin);
    try {
      CloudBaseFunction cloudbase = await _connectCloud();

      String terminalId = _userId == "游侠" ? '123456789' : _userId;
      String _botparams =
          '{\"BotId\":\"$_botId\",\"BotEnv\":\"release\",\"TerminalId\":\"$terminalId\",\"InputText\":\"$_stdin\"}';
      Map<String, dynamic> data = {'botparams': _botparams};
      print(data);

      CloudBaseResponse res = await cloudbase.callFunction(_function, data);

      print('调用服务结束');
      Map<String, dynamic> resdata = json.decode(res.data);
      print('res.data');
      print(res.data);

      //处理状态
      String dialogStatus = resdata['DialogStatus'];
      print('dialogStatus:$dialogStatus');

      //返回对话内容
      String resContent = resdata['ResponseMessage']['GroupList'][0]['Content'];
      print(resContent);
      //对话意图
      String intentName = resdata['IntentName'];
      _intentName = intentName;
      print(intentName);

      //如果没有意图，意图标题隐藏
      if (_intentName != '') {
        _intentNameTitle = '方法：';
      } else {
        _intentNameTitle = '';
      }

      //获取槽位信息
      List slotInfoList = resdata['SlotInfoList'];
      _ilotName = '';
      for (int i = 0; i < slotInfoList.length; i++) {
        String slotName = slotInfoList[i]['SlotName'];
        String slotValue = slotInfoList[i]['SlotValue'];
        _ilotName = slotName + ' : ' + slotValue + '\n' + _ilotName;
        print(_ilotName);
      }

      //如果没有槽位信息，槽位标题隐藏
      if (_ilotName != '') {
        _ilotNameTitle = '参数：';
      } else {
        _ilotNameTitle = '';
      }

      //自定义服务返回数据
      String sessionattstr = resdata['SessionAttributes'];
      print(sessionattstr);
      Map<String, dynamic> sessionatt = {
        'Status': 'error',
        'Body': {},
        'Content': ''
      };
      if (sessionattstr != '') {
        sessionatt = json.decode(sessionattstr);
      }
      print(sessionatt);

      setState(() {
        //刷新主页面文本框标题值和输出框值
        if (dialogStatus == '') {
          _stdintitle = "标准输入";
          _output = resContent;
        } else if (dialogStatus == 'COMPLETE') {
          _stdintitle = "标准输入";
          _output = resContent;
        } else {
          _stdintitle = resContent;
          _output = '';
        }

        //如果注册用户或者登录用户，需要跟新主页用户和仓库信息
        if ((intentName == 'createUser' || intentName == 'loginUser') &&
            dialogStatus == 'COMPLETE') {
          if (sessionatt['Status'] == 'complete') {
            Map<String, dynamic> body = sessionatt['Body'];
            _userId = body['userId'];
            _warehouse = body['warehouse'];

            _isLogin = 'OK';
          }
        }

        //意图结束后更新意图返回信息，用来刷新功能页面数据
        if (dialogStatus == 'COMPLETE') {
          botreturndata = resdata;
        }

        //实现功能：一个意图结束后，如果需要重复相同意图，用户在页面不需要输入任何值直接空文本回车
        if (dialogStatus == 'START') {
          //如果是意图开始，记住此意图的用户说法
          preIntentName = _stdin;
        } else if (dialogStatus == 'COMPLETE') {
          //如果是意图结束，将上一个意图用户说法赋值给输入参数
          _stdin = preIntentName;
        } else {
          //过程中，清空输入参数
          _stdin = "";
        }

        //清楚输入文本框内容
        mControll1.clear();
      });
    } on Exception catch (e) {
      setState(() {
        _stdintitle = "异常";
        _output = e.toString();
        print(e.toString());
      });
    } catch (e) {}
  }

  _buildSubredditPage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          '欢迎-$_userId',
          style: TextStyle(fontSize: 40.0, fontWeight: FontWeight.bold),
        ),
        Text(
          '$_warehouse',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        new TextField(
          controller: mControll1,
          autofocus: true,
          maxLines: 1,
          maxLength: 50, //允许输入的字符长度/
          maxLengthEnforced: true,
          style: new TextStyle(fontSize: 20.0),
          decoration: new InputDecoration(
            labelText: '$_stdintitle',
          ),
          onChanged: (val) {
            _stdin = val;
          },
          onEditingComplete: _cloudFunction,
        ),
        new Text('$_output', style: new TextStyle(fontSize: 15.0)),
        new Text('', style: new TextStyle(fontSize: 15.0)),
        new Text('$_intentNameTitle', style: new TextStyle(fontSize: 15.0)),
        new Text('$_intentName', style: new TextStyle(fontSize: 15.0)),
        new Text('', style: new TextStyle(fontSize: 15.0)),
        new Text('$_ilotNameTitle', style: new TextStyle(fontSize: 15.0)),
        new Text('$_ilotName', style: new TextStyle(fontSize: 15.0)),
      ],
    );
  }

  _buildPicPage(int currentIndex) {
    return slideList[currentIndex - 1];
  }

  @override
  Widget build(BuildContext context) {
    print('主页面build');
    return Container(
      decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [Theme.of(context).primaryColor, Colors.white],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter)),
      child: PageView.builder(
          controller: ctrl,
          itemCount: slideList.length + 1,
          itemBuilder: (context, int currentIndex) {
            if (currentIndex == 0) {
              return _buildSubredditPage();
            } else {
              return _buildPicPage(currentIndex);
            }
          }),
    );
  }
}
