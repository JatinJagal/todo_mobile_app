import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:todo_app/providers/register_cubit/register_cubit.dart';
import 'package:todo_app/providers/register_cubit/register_state.dart';
import 'package:todo_app/routes/app_router.dart';
import 'package:todo_app/routes/app_router.gr.dart';
import 'package:todo_app/utils/colors.dart';
import 'package:todo_app/utils/global.dart';
import 'package:todo_app/widgets/custom_button.dart';
import 'package:todo_app/widgets/custom_textfield.dart';

@RoutePage()
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _usernameFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();
  final ImagePicker _imagePicker = ImagePicker();
  File? _selectedImage;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _usernameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } on PlatformException catch (e) {
      String errorMessage = 'Failed to pick image';
      if (e.code == 'photo_access_denied' || e.code == 'camera_access_denied') {
        errorMessage =
            'Permission denied. Please enable camera/gallery access in settings.';
      } else if (e.code == 'photo_access_restricted') {
        errorMessage = 'Photo access is restricted on this device.';
      } else if (e.code == 'camera_access_restricted') {
        errorMessage = 'Camera access is restricted on this device.';
      } else {
        errorMessage = e.message ?? 'An error occurred while picking the image';
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Image Source'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Camera'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  String? _validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your username';
    }
    if (value.length < 3) {
      return 'Username must be at least 3 characters';
    }
    return null;
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

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  // void _handleSignUp() {
  //   if (_formKey.currentState!.validate()) {
  //     context.read<RegisterCubit>().register(
  //       _usernameController.text.trim(),
  //       _emailController.text.trim(),
  //       _passwordController.text,
  //       _confirmPasswordController.text,
  //     );
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kWhite,
      appBar: AppBar(
        backgroundColor: kWhite,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: kBlack, size: 24.sp),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 20.h),
                // Profile Image Picker
                Center(
                  child: GestureDetector(
                    onTap: _showImageSourceDialog,
                    child: Stack(
                      children: [
                        Container(
                          width: 120.w,
                          height: 120.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [kPrimaryColor, kLightPrimaryColor],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: kPrimaryColor.withOpacity(0.3),
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: _selectedImage != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(120.r),
                                  child: Image.file(
                                    _selectedImage!,
                                    fit: BoxFit.cover,
                                    width: 120.w,
                                    height: 120.w,
                                  ),
                                )
                              : Icon(
                                  Icons.person_add_outlined,
                                  size: 60.sp,
                                  color: kWhite,
                                ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 36.w,
                            height: 36.w,
                            decoration: BoxDecoration(
                              color: kPrimaryColor,
                              shape: BoxShape.circle,
                              border: Border.all(color: kWhite, width: 3),
                            ),
                            child: Icon(
                              Icons.camera_alt,
                              size: 18.sp,
                              color: kWhite,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Tap to upload profile picture',
                  style: TextStyle(fontSize: 12.sp, color: kGrey),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24.h),
                Text(
                  'Create Account',
                  style: TextStyle(
                    fontSize: 32.sp,
                    fontWeight: FontWeight.bold,
                    color: kBlack,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8.h),
                Text(
                  'Sign up to get started',
                  style: TextStyle(fontSize: 16.sp, color: kGrey),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 48.h),
                // Username Field
                CustomTextField(
                  labelText: 'Username',
                  hintText: 'Enter your username',
                  controller: _usernameController,
                  keyboardType: TextInputType.text,
                  validator: _validateUsername,
                  prefixIcon: Icon(
                    Icons.person_outline,
                    color: kGrey,
                    size: 20.sp,
                  ),
                  focusNode: _usernameFocusNode,
                  onSubmitted: (_) {
                    _emailFocusNode.requestFocus();
                  },
                ),
                SizedBox(height: 24.h),
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
                    _confirmPasswordFocusNode.requestFocus();
                  },
                ),
                SizedBox(height: 24.h),
                // Confirm Password Field
                CustomTextField(
                  labelText: 'Confirm Password',
                  hintText: 'Re-enter your password',
                  controller: _confirmPasswordController,
                  obscureText: true,
                  validator: _validateConfirmPassword,
                  prefixIcon: Icon(
                    Icons.lock_outline,
                    color: kGrey,
                    size: 20.sp,
                  ),
                  focusNode: _confirmPasswordFocusNode,
                  onSubmitted: (_) {
                    // _handleSignUp();
                  },
                ),
                SizedBox(height: 32.h),
                // Sign Up Button
                BlocConsumer<RegisterCubit, RegisterState>(
                  builder: (context, state) {
                    if (state is RegisterLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return CustomButton(
                      text: 'Sign Up',
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          context.read<RegisterCubit>().register(
                            _usernameController.text.trim(),
                            _emailController.text.trim(),
                            _passwordController.text,
                            _confirmPasswordController.text,
                            _selectedImage,
                          );
                        }
                      },
                      icon: Icon(Icons.person_add, color: kWhite, size: 20.sp),
                    );
                  },
                  listener: (context, state) {
                    if (state is RegisterSuccess) {
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) => const BottomNavScreen(),
                      //   ),
                      // );
                      getIt<AppRouter>().pushAndPopUntil(
                        const BottomNavRoute(),
                        predicate: (route) => false,
                      );
                      // print("Register Success");
                    } else if (state is RegisterFailure) {
                      // print("Register Failure: ${state.error}");
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(state.error)));
                    }
                  },
                ),
                SizedBox(height: 24.h),
                // Login Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: TextStyle(fontSize: 14.sp, color: kGrey),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Sign In',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: kPrimaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
