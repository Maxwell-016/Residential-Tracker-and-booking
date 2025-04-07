import 'package:shared_preferences/shared_preferences.dart';

Future<void> saveCurrentPage(String route) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('last_visited_page', route);
}


Future<String> getLastVisitedPage() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('last_visited_page') ?? '/login';
}
