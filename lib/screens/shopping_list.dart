import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:selfcheckoutapp/constants.dart';
import 'package:selfcheckoutapp/screens/adding_new_item.dart';
import 'package:selfcheckoutapp/services/shopping_list_services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ShoppingListPage extends StatefulWidget {
  @override
  _ShoppingListPageState createState() => _ShoppingListPageState();
}

class _ShoppingListPageState extends State<ShoppingListPage> {
  List<ToDo> list = List<ToDo>();
  SharedPreferences sharedPreferences;

  @override
  void initState() {
    initSharedPreferences();
    super.initState();
  }

  initSharedPreferences() async {
    sharedPreferences = await SharedPreferences.getInstance();
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Shopping List",
          style: Constants.boldHeadingAppBar,
        ),
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      body: SafeArea(
        child: list.isNotEmpty ? buildBody() : buildEmptyBody(),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        child: Icon(Icons.add_rounded),
        onPressed: () => goToNewItemAdd(),
      ),
    );
  }

  Widget buildBody() {
    return ListView.builder(
      itemCount: list.length,
      itemBuilder: (context, index) {
        return buildItem(list[index]);
      },
    );
  }

  Widget buildItem(ToDo item) {
    return Card(
      shadowColor: Colors.black,
      child: Dismissible(
        key: Key(item.hashCode.toString()),
        //HAS TO GIVE A UNIQUE KEY TO IDENTIFY THE DISMISS TILE
        onDismissed: (direction) => removeItem(item),
        direction: DismissDirection.startToEnd,
        background: Container(
          color: Color(0xffD50000),
          child: Icon(Icons.delete_rounded, color: Colors.white),
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.only(left: 15.0),
        ),
        child: ListTile(
          title: Text(item.title),
          //leading: Checkbox(tristate: true, value: item.complete, onChanged: null),
          leading: Icon(Icons.assignment_turned_in_rounded),
          onTap: () => setComplete(item),
          onLongPress: () => goToEditItemView(item),
        ),
      ),
    );
  }

  Widget buildEmptyBody() {
    return Center(
      child: Text("No items added"),
    );
  }

  void setComplete(ToDo item) {
    setState(() {
      item.complete = !item.complete;
      saveDataList();
    });
  }

  //FUNCTION TO REMOVE ITEMS FROM THE LIST
  void removeItem(ToDo item) {
    setState(() {
      list.remove(item);
      saveDataList();
    });
  }

  //ADDING NEW ITEMS TO LIST - NEW PAGE
  void goToNewItemAdd() {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return NewItemView();
    })).then((title) {
      if (title != null) {
        addToDo(ToDo(title: title));
        saveDataList();
      }
    });
  }

  void addToDo(ToDo item) {
    setState(() {
      list.add(item);
      saveDataList();
    });
  }

  void goToEditItemView(ToDo item) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return NewItemView(
        title: item.title,
      );
    })).then((title) {
      if (title != null) {
        editToDo(item, title);
        saveDataList();
      }
    });
  }

  void editToDo(ToDo item, String title) {
    setState(() {
      item.title = title;
      saveDataList();
    });
  }

  void saveDataList() {
    List<String> spList =
        list.map((item) => json.encode(item.toMap())).toList();
    sharedPreferences.setStringList('list', spList);
  }

  void loadData() {
    List<String> spList = sharedPreferences.getStringList('list');
    list = spList.map((item) => ToDo.fromMap(json.decode(item))).toList();
    setState(() {});
  }
}