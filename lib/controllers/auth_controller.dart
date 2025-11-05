import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:petshow/screens/eng/login_screen.dart';
import 'package:petshow/screens/eng/otp.dart';
import 'package:petshow/screens/main_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/auth.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService();

  var isLoading = false.obs;
  RxString userName = ''.obs;
  RxString userProfilePicture = ''.obs;

  var userProfile = {}.obs;
  @override
  onReady() async {
    await getProfile();
  }

  Future<void> register(String name, String email, String phone,
      String password, String gender) async {
    var message = '';

    try {
      isLoading.value = true;

      http.Response response = await _authService.registerUser(
          name: name,
          email: email,
          password: password,
          phone: phone,
          gender: gender);

      if (response.statusCode == 200 || response.statusCode == 201) {
        message = 'Success: ${response.body}';
        Get.snackbar('Success', 'Please login to continue',
            backgroundColor: Colors.green, colorText: Colors.white);
        Get.off(() => const LoginScreen());
      } else {
        Get.snackbar('Failed', 'Error: ${response.body}',
            backgroundColor: Colors.red, colorText: Colors.white);
        message = 'Error: ${response.body}';
      }
    } catch (e) {
      message = 'Exception: $e';
    } finally {
      print(message);
      isLoading.value = false;
    }
  }

  Future<void> login(String email, String password) async {
    var message = '';
    try {
      isLoading.value = true;

      http.Response response = await _authService.loginUser(
        email: email,
        password: password,
      );

      if (response.statusCode == 200) {
        message = 'Success: ${response.body}';
        Get.snackbar('Success', 'OTP has been sent to your email address',
            backgroundColor: Colors.green, colorText: Colors.white);
        Get.off(() => OtpVerificationScreen(email: email));
      } else {
        Get.snackbar('Failed', 'Invalid credentials',
            backgroundColor: Colors.red, colorText: Colors.white);
        message = 'Invalid credentials: ${response.body}';
      }
    } catch (e) {
      message = 'Error: $e';
    } finally {
      print(message);
      isLoading.value = false;
    }
  }

  Future<void> verifyOtp(String email, String otp) async {
    var message = '';
    try {
      isLoading.value = true;

      http.Response response = await _authService.verifyOtp(
        email: email,
        otp: otp,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final token = data['token'];
        final tokenType = data['token_type'];
        final user = data['user'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        await prefs.setString('token_type', tokenType);
        await prefs.setString('user', jsonEncode(user));

        message = 'Success: ${response.body}';

        Get.offAll(() => const PetShopApp());
      } else {
        Get.snackbar('Failed', 'Invalid / Expired OTP',
            backgroundColor: Colors.red, colorText: Colors.white);
        message = 'Invalid OTP: ${response.body}';
      }
    } catch (e) {
      message = 'Error: $e';
    } finally {
      print(message);
      isLoading.value = false;
    }
  }

  Future<void> getProfile() async {
    try {
      isLoading(true);
      final result = await _authService.getProfile();

      if (result != null) {
        userProfile.value = result;

        print(userProfile);
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateProfile({
    required String name,
    required String phone,
  }) async {
    var message = '';
    try {
      isLoading.value = true;

      final response = await _authService.updateProfile(
        name: name,
        phone: phone,
      );

      if (response != null && response.statusCode == 200) {
        final data = jsonDecode(response.body);

        userProfile.value = {'user': data['user']};

        Get.snackbar('Success', 'Profile updated successfully',
            backgroundColor: Colors.green, colorText: Colors.white);
        message = 'Profile updated: ${response.body}';
      } else {
        Get.snackbar('Failed', 'Could not update profile',
            backgroundColor: Colors.red, colorText: Colors.white);
        message = 'Failed: ${response?.body}';
      }
    } catch (e) {
      message = 'Error: $e';
      Get.snackbar('Error', 'Something went wrong',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      print(message);
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      isLoading.value = true;

      // Clear SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      // Reset user profile
      userProfile.value = {};

      // Navigate to login screen
      Get.offAll(() => const LoginScreen());

      Get.snackbar('Success', 'Logged out successfully',
          backgroundColor: Colors.green);
    } catch (e) {
      Get.snackbar('Error', 'Failed to logout: $e',
          backgroundColor: Colors.red);
    } finally {
      isLoading.value = false;
    }
  }
}
