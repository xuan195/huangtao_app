import 'dart:io';

import 'package:flutter/material.dart';

import 'package:cloudbase_core/cloudbase_core.dart';

import 'package:cloudbase_auth/cloudbase_auth.dart';

import 'package:cloudbase_function/cloudbase_function.dart';

import 'package:cloudbase_storage/cloudbase_storage.dart';

import 'package:cloudbase_database/cloudbase_database.dart';

import 'package:path_provider/path_provider.dart';

final _envId ='huangtao-4ghjf9gi85523bb2';
final _function = 'glot';
final _collection = 'users'; //填入您的云数据库集合名称
final _fileId = 'cloud://uploads'; //填入您上传到云存储的文件地址

void main() {

  runApp(MaterialApp(home: MyApp()));

}



class MyApp extends StatefulWidget {

  @override

  _MyAppState createState() => new _MyAppState();

}



class _MyAppState extends State<MyApp> {

  String _code;

  String _stdin;

  String _output = '运行结果将会显示在这里';



  TextEditingController selectionController = new TextEditingController();

  GlobalKey<FormState> _formKey = new GlobalKey<FormState>();



  _formSubmitted() async {

    var _form = _formKey.currentState;



    if (_form.validate()) {

      _form.save();

      await _cloudFunction();

      _cloudDatabase();

    }

  }



  _cloudFunction() async {

    CloudBaseCore core = CloudBaseCore.init({
      'env': _envId,
      'appAccess': {
        'key': 'f0c7379a426200047f2dde1f28e0f48b',
        'version': '1'
      }
      
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

    Map<String, dynamic> data = {'code': _code, 'stdin': _stdin};

    CloudBaseResponse res = await cloudbase.callFunction(_function, data);

    setState(() {

      _output = res.data;

    });

  }



// 获取 flutter Document 路径

// 参考文档：https://flutter.cn/docs/cookbook/persistence/reading-writing-files

  _getDocumentsPath() async {

    final directory = await getApplicationDocumentsDirectory();

    String path = directory.path;

    return path;

  }



  _cloudStorage() async {

    String docPath = await _getDocumentsPath();

    String _savePath = '$docPath/code.txt';

    CloudBaseCore core = CloudBaseCore.init({
      'env': _envId,
      'appAccess': {
        'key': 'f0c7379a426200047f2dde1f28e0f48b',
        'version': '1'
      }
      
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

    CloudBaseStorage storage = CloudBaseStorage(core);



    await storage.downloadFile(fileId: _fileId, savePath: _savePath);

    final File file = new File(_savePath);

    selectionController.text = file.readAsStringSync();

  }



  _cloudDatabase() async {

    CloudBaseCore core = CloudBaseCore.init({'env': _envId});

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

    CloudBaseDatabase db = CloudBaseDatabase(core);



    Collection collection = db.collection(_collection);



    collection

        .add({'code': _code, 'stdin': _stdin, 'output': _output})

        .then((res) {})

        .catchError((e) {});

  }



  @override

  Widget build(BuildContext context) {

    return new MaterialApp(

      home: new Scaffold(

        appBar: new AppBar(

          title: new Text('云开发Flutter'),

        ),

        floatingActionButton: new FloatingActionButton(

          onPressed: _formSubmitted,

          child: new Text('提交'),

        ),

        body: new SingleChildScrollView(

          padding: EdgeInsets.all(20.0),

          child: new Form(

            key: _formKey,

            child: new Column(children: <Widget>[

              new TextFormField(

                controller: selectionController,

                maxLines: null,

                decoration: new InputDecoration(

                  labelText: '代码',

                ),

                onSaved: (val) {

                  _code = val;

                },

              ),

              new TextFormField(

                maxLines: null,

                decoration: new InputDecoration(

                  labelText: '标准输入',

                ),

                onSaved: (val) {

                  _stdin = val;

                },

              ),

              new Text('$_output'),

              new MaterialButton(

                color: Colors.blue,

                onPressed: _cloudStorage,

                child: new Text('下载代码'),

              )

            ]),

          ),

        ),

      ),

    );

  }

}