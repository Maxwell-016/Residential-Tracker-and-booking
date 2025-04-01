import 'package:flutter_riverpod/flutter_riverpod.dart';

final hasNameProvider = StateProvider<bool>((ref) => false);

final toggleMenu = StateProvider<bool>((ref) => false);

final counterProvider = StateProvider<int>((ref) => 0);