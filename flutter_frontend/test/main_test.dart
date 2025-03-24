import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_frontend/main.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart';
import 'package:flutter_frontend/firebase_options.dart';

void main(){
    setUpAll (() async {
        // Initialize Firebase
        TestWidgetsFlutterBinding.ensureInitialized();
        await Firebase.initializeApp(
            options: DefaultFirebaseOptions.currentPlatform,
        );
    });
    
    testWidgets('App initializes correctly', (WidgetTester tester) async{
        // Build the app and trigger a frame
        await tester.pumpWidget(ProviderScope(child: ResidentialTrackerAndBooking()));

        // verify app initialises and displays login page
        expect(find.text('Login'), findsOneWidget);
    });
}
void setupFirebaseAuthMocks(){
    // Register the default instance of FirebaseAuthPlatform
    FirebaseAuthPlatform.instance = FakeFirebaseAuthPlatform();
}

class FakeFirebaseAuthPlatform extends FirebaseAuthPlatform{
    FakeFirebaseAuthPlatform() : super();

    @override
    FirebaseAuthPlatform delegateFor({required FirebaseApp app}) {
        return this;
    }

    @override
    FirebaseAuthPlatform setInitialValues({
        PigeonUserDetails? currentUser,
        bool? isSignWithEmailLink,
    }){
        return this;
    }
}
// firebase based issue