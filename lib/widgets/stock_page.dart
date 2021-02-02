import 'package:flutter/material.dart';
import '../common/my_class.dart';
import 'dart:convert';

class StockPage extends RedditPage {
  StockPage({this.data});

  final ValueNotifierData data;
  Map<String, dynamic> botdata = {};
  bool active = false;

  @override
  _StockPageState createState() => _StockPageState();
}

class _StockPageState extends State<StockPage> {
  double topMargin = 200;
  double offset = 0;
  double blur = 200;

  //库存信息页面参数
  String _warehouse = "注册后默认仓库"; //仓库描述
  String _storerKey = '无'; //货主编号
  int _skuNum = 0; //物料种类
  double _qtytotal = 0.0; //库存总量
  String _sku = '无'; //物料名称
  String _loc = '无'; //库位
  double _skuqty = 0.0; //库存量
  double _qtypick = 0.0; //拣货量
  double _qtyavailable = 0.0; //可用量
  String _skulpn = '无'; //箱号

  @override
  void initState() {
    widget.data.addListener(() {
      if (mounted) {
        setState(() {
          refreshPage(widget.active);
          refreshData(widget.botdata);
        });
      }
    });
    super.initState();
  }

  Expanded _buildStatCart(String title, String count, MaterialColor color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(8.0),
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                count,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ]),
      ),
    );
  }

  _buildWarePage(context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOutQuint,
      margin: EdgeInsets.only(top: topMargin, bottom: 20, right: 15),
      child: Column(
        children: <Widget>[
          Container(
            height: 40.0,
            child: Center(
                child: Text(
              '库存信息',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15.0, color: Colors.white),
            )),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20.0),
                    topRight: Radius.circular(20.0)),
                color: Colors.black.withAlpha(100)),
          ),
          Container(
            height: MediaQuery.of(context).size.height * 0.6,
            color: Colors.blue,
            child: Column(
              children: <Widget>[
                Flexible(
                  child: Row(
                    children: <Widget>[
                      _buildStatCart('仓库名称', '$_warehouse', Colors.orange),
                      _buildStatCart('货主', '$_storerKey', Colors.red),
                    ],
                  ),
                ),
                Flexible(
                  child: Row(
                    children: <Widget>[
                      _buildStatCart('物料种类', '$_skuNum', Colors.green),
                      _buildStatCart('总库存量', '$_qtytotal', Colors.purple),
                    ],
                  ),
                ),
                Flexible(
                  child: Row(
                    children: <Widget>[
                      _buildStatCart('物料名称', '$_sku', Colors.orange),
                      _buildStatCart('库位', '$_loc', Colors.lightBlue),
                      _buildStatCart('库存量', '$_skuqty', Colors.purple),
                    ],
                  ),
                ),
                Flexible(
                  child: Row(
                    children: <Widget>[
                      _buildStatCart('拣货量', '$_qtypick', Colors.lightGreen),
                      _buildStatCart('可用量', '$_qtyavailable', Colors.lightBlue),
                      _buildStatCart('箱号', '$_skulpn', Colors.red),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(20.0)),
          color: Colors.blue,
          //image: DecorationImage(image: NetworkImage(post.imgUrl),fit: BoxFit.cover),
          boxShadow: [
            BoxShadow(
                color: Colors.black87,
                offset: Offset(offset, offset),
                blurRadius: blur)
          ]),
    );
  }

  //刷新页面数据
  refreshData(Map<String, dynamic> botreturndata) {
    print("stock.refreshData");
    print(botreturndata);
    if (botreturndata.isNotEmpty) {
      //处理状态
      String dialogStatus = botreturndata['DialogStatus'];
      print('dialogStatus:$dialogStatus');

      //对话意图
      String intentName = botreturndata['IntentName'];
      print(intentName);

      //自定义服务返回数据
      String sessionattstr = botreturndata['SessionAttributes'];
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
        //如果注册用户或者登录用户，需要跟新主页用户和仓库信息
        if (
            //(intentName == 'createUser' || intentName == 'loginUser') &&
            dialogStatus == 'COMPLETE') {
          if (sessionatt['Status'] == 'complete') {
            Map<String, dynamic> body = sessionatt['Body'];
            _warehouse = body['warehouse'];

            _storerKey =
                body.containsKey('storerKey') ? body['storerKey'] : '无'; //货主编号
            _skuNum = body.containsKey('skuNum') ? body['skuNum'] : 0; //物料种类
            _qtytotal = body.containsKey('qtyTotal')
                ? body['qtyTotal'].toDouble()
                : 0.0; //库存总量
          }
        }

        //如果是收货或者物料查询，需要跟新货品数据
        if ((intentName == 'queryStockBySku' ||
                intentName == 'receiveBySku' ||
                intentName == 'deliveryBySku') &&
            dialogStatus == 'COMPLETE') {
          if (sessionatt['Status'] == 'complete') {
            Map<String, dynamic> body = sessionatt['Body'];
            _sku = body.containsKey('sku') ? body['sku'] : '无'; //物料名称
            _loc = body.containsKey('loc') ? body['loc'] : '无'; //库位
            _skuqty = body.containsKey('skuqty')
                ? body['skuqty'].toDouble()
                : 0.0; //库存量
            print(body.containsKey('skuqty'));
            print(_skuqty);
            _qtypick = body.containsKey('qtypick')
                ? body['qtypick'].toDouble()
                : 0.0; //拣货量
            _qtyavailable = body.containsKey('qtyavailable')
                ? body['qtyavailable'].toDouble()
                : 0.0; //可用量
            _skulpn = body.containsKey('skulpn') ? body['skulpn'] : '无'; //箱号
          }
        }
      });
    }
  }

  //刷新页面格式
  refreshPage(bool _active) {
    topMargin = _active ? 100 : 200;
    offset = _active ? 20 : 0;
    blur = _active ? 100 : 200;
  }

  @override
  Widget build(BuildContext context) {
    return _buildWarePage(context);
  }
}
