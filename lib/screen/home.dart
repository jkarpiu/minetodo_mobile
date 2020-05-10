import 'dart:convert';
import 'package:flutter/material.dart';
import './login.dart';
import '../network_utils/api.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final addTodoController = TextEditingController();
  String name;
  int userId;
  var todoData;
  @override
  void initState() {
    _loadUserData();
    _loadmyTodoData();
    super.initState();
  }

  _loadUserData() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var user = jsonDecode(localStorage.getString('user'));
    print(user['id']);
    if (user != null) {
      setState(() {
        name = user['fname'];
        userId = user['id'];
      });
    }
  }
  

  _loadmyTodoData() async {
    var data = await Network().getTodoData('/show');
    if (data != null) {
      setState(() {
        todoData = jsonDecode(data);
      });
    }
  }

  _todoDone(int id, int userId, String adress) async{
    await Network().sendSignalTodo(id, userId, adress);
    _loadmyTodoData();
  }

  _sendTodo(context, todoTitleFinal, userId) async {
    if (addTodoController.text != "" || addTodoController.text != null || addTodoController.text != " " ) {
      
      await Network().addTodo(todoTitleFinal, userId);
      _loadmyTodoData();
    }
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      
        appBar: AppBar(
            iconTheme: IconThemeData(
              color: Colors.white, //change your color here
            ),
            title: Text('Minetodo', style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.black,
            actions: <Widget>[
              IconButton(icon: Icon(Icons.refresh), onPressed: () {_loadmyTodoData();}),
              IconButton(
                onPressed: () {
                  logout();
                },
                icon: Icon(Icons.exit_to_app),
              )
            ]),
        body: Column(children: <Widget>[
          Container(
              child: Card(
                  child: Form(
                      child: ListTile(
                        
                        title: TextFormField(
                          
                          controller: addTodoController,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            hintText: "Zadanie...",
                            hintStyle: TextStyle(
                                color: Color(0xFF9b9b9b),
                                fontSize: 15,
                                fontWeight: FontWeight.normal),
                          ),
                          validator: (String todoTitle) {
                            if (todoTitle.isEmpty || todoTitle == null) {
                              return 'Wpisz jakieś zadanie';
                            }else {
                            return null;}
                          },
                          onEditingComplete: () {
                            _sendTodo(context, addTodoController.text, userId);
                          },
                        ),
                        trailing: IconButton(
                            icon: Icon(Icons.add),
                            color: Colors.orange,
                            onPressed: () {
                              print(addTodoController.text);
                              _sendTodo(context, addTodoController.text, userId);
                            }),
                      )))),
          SingleChildScrollView(
            child: Container(
              height: MediaQuery.of(context).size.height - 160,
              child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: todoData != null ? todoData.length : 0,
                  itemBuilder: (context, i) {
                    final _item = todoData[i];
                    //  bool _doneOrNot = _item['completed'];
                    return Card(
                      child: ListTile(
                        leading: IconButton(
                          icon: Icon(Icons.check),
                          color: _item['completed'] == true
                              ? Colors.black
                              : Colors.green,
                          onPressed: () async {
                            _todoDone(await _item['id'], await _item['userId'],
                                "/done");
                          },
                        ),
                        title: Text(_item['title'],
                            style: _item['completed'] == true
                                ? TextStyle(
                                    decoration: TextDecoration.lineThrough)
                                : null),
                        trailing: IconButton(
                            icon: Icon(Icons.delete),
                            color: Colors.red,
                            onPressed: () async {
                              _todoDone(await _item['id'],
                                  await _item['userId'], "/del");
                                  print(addTodoController.text);
                            }),
                      ),
                    );
                  }),
            ),
          )
        ]));
  }

  void logout() async {
    var res = await Network().getData('/logout');
    var body = json.decode(res.body);
    if (body['success']) {
      SharedPreferences localStorage = await SharedPreferences.getInstance();
      localStorage.remove('user');
      localStorage.remove('token');
      Navigator.push(context, MaterialPageRoute(builder: (context) => Login()));
    }
  }
}
