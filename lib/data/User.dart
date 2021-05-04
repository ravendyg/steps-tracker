class UserInfo {
  String name;
  bool status;
  String phone;
  String registerDate;
  String terminationDate;

  UserInfo(this.name, this.status, this.phone, this.registerDate,
      this.terminationDate);
}

class User {
  List<UserInfo> userInfo = [];

  void initData(int size) {
    userInfo = [];
    addData(size);
  }

  void addData(int size) {
    for (int i = 0; i < size; i++) {
      var index = userInfo.length + 1;
      userInfo.add(UserInfo(
          "User_$index", i % 3 == 0, '+001 9999 9999', '2019-01-01', 'N/A'));
    }
  }
}
