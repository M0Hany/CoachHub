import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../providers/auth_provider.dart';
import '../../models/user_model.dart';
import 'package:go_router/go_router.dart';

class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _bioController = TextEditingController();
  final FocusNode _fullNameFocusNode = FocusNode();
  final FocusNode _bioFocusNode = FocusNode();
  Gender? _selectedGender;
  UserType? _selectedUserType;
  bool _isLoading = false;
  File? _profileImage;
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _fullNameFocusNode.addListener(_onFocusChange);
    _bioFocusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    setState(() {});
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _bioController.dispose();
    _fullNameFocusNode.dispose();
    _bioFocusNode.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _profileImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorPickingImage),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _completeProfile() async {
    if (_formKey.currentState!.validate() &&
        _selectedGender != null &&
        _selectedUserType != null) {
      setState(() => _isLoading = true);

      try {
        final success = await context.read<AuthProvider>().storeBasicProfile(
              fullName: _fullNameController.text,
              gender: _selectedGender!,
              type: _selectedUserType!,
              imageFile: _profileImage,
              bio: _bioController.text,
            );

        if (success && context.mounted) {
          if (_selectedUserType == UserType.trainee) {
            context.push('/trainee/health-data');
          } else {
            context.push('/coach/expertise');
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString())),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    } else {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.fillAllFields),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String? _validateField(String? value) {
    final l10n = AppLocalizations.of(context)!;
    if (value == null || value.isEmpty) {
      return l10n.validation_required;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0D122A)),
          onPressed: () => context.go('/login'),
        ),
        title: Text(
          l10n.fillProfile,
          style: AppTheme.headerMedium,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 30),
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Stack(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          shape: BoxShape.circle,
                          image: _profileImage != null
                              ? DecorationImage(
                                  image: FileImage(_profileImage!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: _profileImage == null
                            ? const Icon(
                                Icons.person,
                                size: 50,
                                color: Colors.grey,
                              )
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Color(0xFF0D122A),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            size: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              TextFormField(
                controller: _fullNameController,
                focusNode: _fullNameFocusNode,
                style: const TextStyle(color: Color(0xFF0D122A)),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: _fullNameFocusNode.hasFocus || _fullNameController.text.isNotEmpty
                      ? Colors.white
                      : const Color(0xFFB5B7BE),
                  hintText: l10n.enterFullName,
                  hintStyle: TextStyle(
                    color: _fullNameFocusNode.hasFocus || _fullNameController.text.isNotEmpty
                        ? AppTheme.accent
                        : Colors.grey[600],
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(
                      color: _fullNameFocusNode.hasFocus || _fullNameController.text.isNotEmpty
                          ? AppTheme.accent
                          : Colors.transparent,
                      width: _fullNameFocusNode.hasFocus || _fullNameController.text.isNotEmpty ? 2 : 0,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(
                      color: AppTheme.accent,
                      width: 2,
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(
                      color: _fullNameFocusNode.hasFocus || _fullNameController.text.isNotEmpty
                          ? AppTheme.accent
                          : Colors.transparent,
                      width: _fullNameFocusNode.hasFocus || _fullNameController.text.isNotEmpty ? 2 : 0,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
                validator: _validateField,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _bioController,
                focusNode: _bioFocusNode,
                style: const TextStyle(color: Color(0xFF0D122A)),
                maxLines: 3,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: _bioFocusNode.hasFocus || _bioController.text.isNotEmpty
                      ? Colors.white
                      : const Color(0xFFB5B7BE),
                  hintText: l10n.enterBio,
                  hintStyle: TextStyle(
                    color: _bioFocusNode.hasFocus || _bioController.text.isNotEmpty
                        ? AppTheme.accent
                        : Colors.grey[600],
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(
                      color: _bioFocusNode.hasFocus || _bioController.text.isNotEmpty
                          ? AppTheme.accent
                          : Colors.transparent,
                      width: _bioFocusNode.hasFocus || _bioController.text.isNotEmpty ? 2 : 0,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(
                      color: AppTheme.accent,
                      width: 2,
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(
                      color: _bioFocusNode.hasFocus || _bioController.text.isNotEmpty
                          ? AppTheme.accent
                          : Colors.transparent,
                      width: _bioFocusNode.hasFocus || _bioController.text.isNotEmpty ? 2 : 0,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
                validator: _validateField,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 24),
              Text(
                l10n.gender,
                style: AppTheme.bodyMedium,
              ),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<Gender>(
                      contentPadding: EdgeInsets.zero,
                      visualDensity: VisualDensity(horizontal: -4, vertical: -4),
                      title: Padding(
                        padding: const EdgeInsets.only(left: 1.0, right: 1.0),
                        child: Text(
                          l10n.male,
                          style: AppTheme.bodyMedium.copyWith(
                            color: _selectedGender == Gender.male ? AppTheme.accent : Colors.grey[600],
                          ),
                        ),
                      ),
                      value: Gender.male,
                      groupValue: _selectedGender,
                      activeColor: AppTheme.accent,
                      onChanged: (Gender? value) {
                        setState(() {
                          _selectedGender = value;
                        });
                      },
                      controlAffinity: ListTileControlAffinity.leading,
                      splashRadius: 0.0,
                      tileColor: Colors.transparent,
                      selectedTileColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      overlayColor: MaterialStateProperty.all(Colors.transparent),
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<Gender>(
                      contentPadding: EdgeInsets.zero,
                      visualDensity: VisualDensity(horizontal: -4, vertical: -4),
                      title: Padding(
                        padding: const EdgeInsets.only(left: 1.0, right: 1.0),
                        child: Text(
                          l10n.female,
                          style: AppTheme.bodyMedium.copyWith(
                            color: _selectedGender == Gender.female ? AppTheme.accent : Colors.grey[600],
                          ),
                        ),
                      ),
                      value: Gender.female,
                      groupValue: _selectedGender,
                      activeColor: AppTheme.accent,
                      onChanged: (Gender? value) {
                        setState(() {
                          _selectedGender = value;
                        });
                      },
                      controlAffinity: ListTileControlAffinity.leading,
                      splashRadius: 0.0,
                      tileColor: Colors.transparent,
                      selectedTileColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      overlayColor: MaterialStateProperty.all(Colors.transparent),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                l10n.userType,
                style: AppTheme.bodyMedium,
              ),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<UserType>(
                      contentPadding: EdgeInsets.zero,
                      visualDensity: VisualDensity(horizontal: -4, vertical: -4),
                      title: Padding(
                        padding: const EdgeInsets.only(left: 1.0, right: 1.0),
                        child: Text(
                          l10n.coach,
                          style: AppTheme.bodyMedium.copyWith(
                            color: _selectedUserType == UserType.coach ? AppTheme.accent : Colors.grey[600],
                          ),
                        ),
                      ),
                      value: UserType.coach,
                      groupValue: _selectedUserType,
                      activeColor: AppTheme.accent,
                      onChanged: (UserType? value) {
                        setState(() {
                          _selectedUserType = value;
                        });
                      },
                      controlAffinity: ListTileControlAffinity.leading,
                      splashRadius: 0.0,
                      tileColor: Colors.transparent,
                      selectedTileColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      overlayColor: MaterialStateProperty.all(Colors.transparent),
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<UserType>(
                      contentPadding: EdgeInsets.zero,
                      visualDensity: VisualDensity(horizontal: -4, vertical: -4),
                      title: Padding(
                        padding: const EdgeInsets.only(left: 1.0, right: 1.0),
                        child: Text(
                          l10n.trainee,
                          style: AppTheme.bodyMedium.copyWith(
                            color: _selectedUserType == UserType.trainee ? AppTheme.accent : Colors.grey[600],
                          ),
                        ),
                      ),
                      value: UserType.trainee,
                      groupValue: _selectedUserType,
                      activeColor: AppTheme.accent,
                      onChanged: (UserType? value) {
                        setState(() {
                          _selectedUserType = value;
                        });
                      },
                      controlAffinity: ListTileControlAffinity.leading,
                      splashRadius: 0.0,
                      tileColor: Colors.transparent,
                      selectedTileColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      overlayColor: MaterialStateProperty.all(Colors.transparent),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _completeProfile,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D122A),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isLoading
                ? const CircularProgressIndicator(
                    color: Colors.white,
                  )
                : Text(
                    l10n.next,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
