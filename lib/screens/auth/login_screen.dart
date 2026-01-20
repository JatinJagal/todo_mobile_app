import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:todo_app/providers/login_cubit/login_cubit.dart';
import 'package:todo_app/providers/login_cubit/login_state.dart';
import 'package:todo_app/routes/app_router.dart';
import 'package:todo_app/routes/app_router.gr.dart';
import 'package:todo_app/screens/auth/register_screen.dart';
import 'package:todo_app/utils/colors.dart';
import 'package:todo_app/utils/global.dart';
import 'package:todo_app/widgets/custom_button.dart';
import 'package:todo_app/widgets/custom_textfield.dart';

@RoutePage()
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email address';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kWhite,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 60.h),
                // Logo or App Title
                Icon(
                  Icons.check_circle_outline,
                  size: 80.sp,
                  color: kPrimaryColor,
                ),
                SizedBox(height: 24.h),
                Text(
                  'Welcome Back',
                  style: TextStyle(
                    fontSize: 32.sp,
                    fontWeight: FontWeight.bold,
                    color: kBlack,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8.h),
                Text(
                  'Sign in to continue',
                  style: TextStyle(fontSize: 16.sp, color: kGrey),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 48.h),
                // Email Field
                CustomTextField(
                  labelText: 'Email Address',
                  hintText: 'Enter your email',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: _validateEmail,
                  prefixIcon: Icon(
                    Icons.email_outlined,
                    color: kGrey,
                    size: 20.sp,
                  ),
                  focusNode: _emailFocusNode,
                  onSubmitted: (_) {
                    _passwordFocusNode.requestFocus();
                  },
                ),
                SizedBox(height: 24.h),
                // Password Field
                CustomTextField(
                  labelText: 'Password',
                  hintText: 'Enter your password',
                  controller: _passwordController,
                  obscureText: true,
                  validator: _validatePassword,
                  prefixIcon: Icon(
                    Icons.lock_outline,
                    color: kGrey,
                    size: 20.sp,
                  ),
                  focusNode: _passwordFocusNode,
                  onSubmitted: (_) {
                    // _handleLogin();
                  },
                ),
                SizedBox(height: 16.h),
                // Forgot Password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      // TODO: Implement forgot password
                    },
                    child: Text(
                      'Forgot Password?',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: kPrimaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 32.h),

                // Login Button
                BlocConsumer<LoginCubit, LoginState>(
                  builder: (context, state) {
                    if (state is LoginLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return CustomButton(
                      text: 'Login',
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          context.read<LoginCubit>().login(
                            _emailController.text.trim(),
                            _passwordController.text,
                          );
                        }
                      },
                      // isLoading: _isLoading,
                      icon: Icon(Icons.login, color: kWhite, size: 20.sp),
                    );
                  },
                  listener: (context, state) {
                    if (state is LoginSuccess) {
                      // Navigator.pushAndRemoveUntil(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) => const BottomNavScreen(),
                      //   ),
                      //   (route) => false,
                      // );
                      getIt<AppRouter>().pushAndPopUntil(
                        const BottomNavRoute(),
                        predicate: (route) => false,
                      );
                    } else if (state is LoginFailure) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(state.error)));
                    }
                  },
                ),
                /*
               
               */
                SizedBox(height: 24.h),
                // ElevatedButton(
                //   onPressed: () {
                //     Navigator.push(
                //       context,
                //       MaterialPageRoute(
                //         builder: (context) => FaceDetectionScreen(),
                //       ),
                //     );
                //   },
                //   child: Text("Login with face scan"),
                // ),
                // Sign Up Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: TextStyle(fontSize: 14.sp, color: kGrey),
                    ),
                    TextButton(
                      onPressed: () {
                        // TODO: Navigate to register screen
                        // context.router.push(const RegisterRoute());
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegisterScreen(),
                          ),
                        );
                        // getIt<AppRouter>().push(const RegisterRoute());
                      },
                      child: Text(
                        'Sign Up',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: kPrimaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
