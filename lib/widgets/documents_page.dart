import 'package:flutter/material.dart';
import '../common/my_class.dart';

class DocumentsPage extends RedditPage {
  DocumentsPage({this.data});

  final ValueNotifierData data;
  Map<String, dynamic> botdata = {};
  bool active = false;

  @override
  _DocumentsPageState createState() => _DocumentsPageState();
}

class _DocumentsPageState extends State<DocumentsPage> {
  //单据信息页面参数
  int _receiptNum = 0; //收货单
  int _orderNum = 0; //出库单
  int _adjNum = 0; //调整单
  int _ccNum = 0; //盘点单
  int _tranNum = 0; //转移单

  double topMargin = 200;
  double offset = 0;
  double blur = 200;

  Map<String, dynamic> botreturndata;

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

  _buildDocumentsPage(context) {
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
              '单据信息',
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
            height: MediaQuery.of(context).size.height * 0.3,
            color: Colors.blue,
            child: Column(
              children: <Widget>[
                Flexible(
                  child: Row(
                    children: <Widget>[
                      _buildStatCart('收货单', '$_receiptNum', Colors.orange),
                      _buildStatCart('出库单', '$_orderNum', Colors.red),
                    ],
                  ),
                ),
                Flexible(
                  child: Row(
                    children: <Widget>[
                      _buildStatCart('调整单', '$_adjNum', Colors.green),
                      _buildStatCart('盘点单', '$_ccNum', Colors.lightBlue),
                      _buildStatCart('转移单', '$_tranNum', Colors.purple),
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
  refreshData(Map<String, dynamic> _botreturndata) {}

  //刷新页面格式
  refreshPage(bool _active) {
    topMargin = _active ? 100 : 200;
    offset = _active ? 20 : 0;
    blur = _active ? 100 : 200;
  }

  @override
  Widget build(BuildContext context) {
    return _buildDocumentsPage(context);
  }
}
