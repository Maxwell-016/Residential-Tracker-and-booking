import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';



final hasNameProvider = StateProvider<bool>((ref) => false);

final toggleMenu = StateProvider<bool>((ref) => true);

final counterProvider = StateProvider<int>((ref) => 0);

final rateus = StateProvider<int>((ref)=>0);

final optionString = StateProvider<String>((ref)=>"");



final searchedPlacesProvider = StateNotifierProvider<SearchedPlacesNotifier, List<String>>((ref) {
  return SearchedPlacesNotifier();
});

class SearchedPlacesNotifier extends StateNotifier<List<String>> {
  SearchedPlacesNotifier() : super([]) {
    _loadSearchedPlaces();
    _listenForNewHouses();
  }

  Future<void> _loadSearchedPlaces() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getStringList('searched_places') ?? [];
  }

  Future<void> addSearchedPlace(String place) async {
    if (!state.contains(place)) {
      state = [...state, place];
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('searched_places', state);
    }
  }

  Future<void> _listenForNewHouses() async {
    FirebaseFirestore.instance.collection('houses').snapshots().listen((snapshot) {
      for (var doc in snapshot.docs) {
        String location = doc['location'];
        if (state.contains(location)) {

          _notifyUser(location);
        }
      }
    });
  }

  void _notifyUser(String location) {

    print("House added in $location! Check it out.");
  }
}

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError();
});