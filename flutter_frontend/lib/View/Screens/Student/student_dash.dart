import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_frontend/View/Components/google_fonts.dart';
import 'package:flutter_frontend/View/Components/student_side_nav.dart';
import 'package:flutter_frontend/services/firebase_services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logger/logger.dart';

final houseListProvider = StateProvider<List<Map<String, dynamic>>>((ref) => []);
final lastHouseDocsProvider = StateProvider<Map<String, DocumentSnapshot>>((ref) => {});
final lastLandlordDocProvider = StateProvider<DocumentSnapshot?>((ref) => null);
final isLoadingProvider = StateProvider<bool>((ref) => false);

class StudentDashboard extends HookConsumerWidget {
  const StudentDashboard({super.key});

  Future fetchInitialHouses(WidgetRef ref) async{
    ref.read(isLoadingProvider.notifier).state = true;

    Map<String,dynamic> result = await FirebaseServices().getAllHouses();

    List<Map<String,dynamic>> newHouses = result['houses'];

    if(newHouses.isNotEmpty){
      ref.read(houseListProvider.notifier).state = newHouses;
      ref.read(lastLandlordDocProvider.notifier).state = result['lastLandlordDoc'];
      ref.read(lastHouseDocsProvider.notifier).state = result['lastHouseDocs'];
    }
    ref.read(isLoadingProvider.notifier).state = false;
  }

  void fetchMoreHouses(WidgetRef ref) async{
    if(ref.read(isLoadingProvider)) return;
    ref.read(isLoadingProvider.notifier).state = true;

    DocumentSnapshot? lastLandlordDoc = ref.read(lastLandlordDocProvider);
    Map<String,DocumentSnapshot> lastHouses = ref.read(lastHouseDocsProvider);

      Map<String,dynamic> result = await FirebaseServices().getAllHouses(
        lastLandlordDoc:  lastLandlordDoc,
        lastHouseDocs: lastHouses,
      );

      List<Map<String,dynamic>> newHouses = result['houses'];

      if(newHouses.isNotEmpty){

        ref.read(lastLandlordDocProvider.notifier).state = result['lastLandlordDoc'];
        ref.read(lastHouseDocsProvider.notifier).state = result['lastHouseDocs'];
        ref.read(houseListProvider.notifier).state = [
          ...ref.read(houseListProvider),
          ...newHouses
        ];

      }

    ref.read(isLoadingProvider.notifier).state = false;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Logger logger = Logger();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    useEffect((){
      Future.microtask(() async => await fetchInitialHouses(ref));
      return null;
    },[]);

    final houses = ref.watch(houseListProvider);
    final isLoading = ref.watch(isLoadingProvider);

    logger.i('Initial fetch: $houses');

    useEffect((){
      logger.i('Updated Houses: $houses');
      return null;
    },[houses]);


    return SafeArea(
        child: Scaffold(
      drawer: StudentSideNav(),
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              pinned: true,
              elevation: 5.0,
              shadowColor: isDark? Colors.white : Colors.black,
              iconTheme: IconThemeData(
                size: 30.0
              ),
              expandedHeight: 350.0,
              flexibleSpace: FlexibleSpaceBar(
                background: Column(
                  spacing: 14.0,
                  children: [
                    UseFont(
                        text: 'Find your perfect house',
                        myFont: 'Open Sans',
                        size: 20.0),
                    GestureDetector(
                      onTap: () {
                        logger.i('Navigate to search page');
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Container(
                          width: 300.0,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0),
                              border: Border.all(
                                color: isDark ? Colors.white : Colors.black54,
                              )),
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Row(
                              spacing: 10.0,
                              children: [
                                Icon(Icons.search),
                                Text('Search...'),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ];
        },
        body: SingleChildScrollView(),
      ),
    ),
    );
  }
}
