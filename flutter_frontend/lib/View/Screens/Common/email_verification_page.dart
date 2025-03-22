import 'package:flutter/material.dart';
import 'package:flutter_frontend/View-Model/utils/app_colors.dart';
import 'package:flutter_frontend/services/firebase_services.dart';
import 'package:flutter_frontend/View-Model/view_model.dart';
import 'package:flutter_frontend/View/Components/function_button.dart';
import 'package:flutter_frontend/View/Components/google_fonts.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class EmailVerificationPage extends HookConsumerWidget {
  final double width;
  const EmailVerificationPage({super.key, required this.width});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    final viewModelProvider = ref.watch(viewModel);
    final firebaseServicesProvider = ref.watch(firebaseServices);
    final user = ref.watch(userState);
    bool isVerified = user!.emailVerified;
    useEffect(() {
      Future<void> getRoleAndNavigate() async {
        if (isVerified) {
          String? role = await firebaseServicesProvider.getUserRole();
          if (role != null) {
            switch (role) {
              case 'Student':
                if(!context.mounted)return;
                context.go('/student-dashboard');


                break;
              case 'Landlord':
                if(!context.mounted)return;

                context.go('/landlord-dashboard');


                break;
              case 'Admin':
                if(!context.mounted)return;
                context.go('/admin-dashboard');


                break;
            }
          }
        } else {
          user.reload().then((_) => ref.refresh(userState));
        }
      }
      getRoleAndNavigate();
      return null;
    }, [user, isVerified]);
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              spacing: 20.0,
              children: [
                SizedBox(),
                Card(
                  elevation: 5.0,
                  shadowColor: isDark ? Colors.white : Colors.black54,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      spacing: 50.0,
                      children: [
                        SizedBox(),
                        SizedBox(
                          width: width,
                          child: UseFont(
                              text:
                                  'An email verification link has been sent to your email. If you have not received the link press the button below to resend the link.',
                              myFont: 'Open Sans',
                              size: 17.0),
                        ),
                        SizedBox(
                          child: viewModelProvider.showResendBtn
                              ? FunctionButton(
                                  text: 'Resend',
                                  onPressed: () {
                                    viewModelProvider.startTimer();
                                  },
                                  btnColor: AppColors.deepBlue,
                                  width: width,
                                )
                              : Container(
                                  width: width,
                                  height: 40.0,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Colors.grey,
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Try again after: ${viewModelProvider.timeLeft}s',
                                      style: TextStyle(color: Colors.black),
                                    ),
                                  ),
                                ),
                        ),
                        SizedBox(),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
