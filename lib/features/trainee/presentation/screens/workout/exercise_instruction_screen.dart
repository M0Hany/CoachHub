import 'package:flutter/material.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/network/http_client.dart';
import 'dart:developer' as developer;
import 'package:lottie/lottie.dart';
import '../../../../../core/widgets/bottom_nav_bar.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../../core/constants/enums.dart';

class ExerciseInstructionScreen extends StatefulWidget {
  final String exerciseName;
  final String animationPath;
  final int? workoutId;
  final int? dayNumber;
  final int? exerciseId;

  const ExerciseInstructionScreen({
    super.key,
    required this.exerciseName,
    required this.animationPath,
    this.workoutId,
    this.dayNumber,
    this.exerciseId,
  });

  @override
  State<ExerciseInstructionScreen> createState() => _ExerciseInstructionScreenState();
}

class _ExerciseInstructionScreenState extends State<ExerciseInstructionScreen> {
  final _setsController = TextEditingController(text: '3');
  final _repsController = TextEditingController(text: '12');
  final _restTimeController = TextEditingController(text: '60');
  final _notesController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _setsController.dispose();
    _repsController.dispose();
    _restTimeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveExercise() async {
    if (_isSaving) return;

    // If we don't have the required IDs, just pop back
    if (widget.workoutId == null || widget.dayNumber == null || widget.exerciseId == null) {
      Navigator.pop(context);
      return;
    }

    setState(() => _isSaving = true);

    try {
      final httpClient = HttpClient();
      final response = await httpClient.put<Map<String, dynamic>>(
        '/api/plans/workout/${widget.workoutId}',
        data: {
          'days': [
            {
              'day_number': widget.dayNumber,
              'add_exercises': [
                {
                  'exercise_id': widget.exerciseId,
                  'sets': int.parse(_setsController.text),
                  'reps': int.parse(_repsController.text),
                  'rest_time': int.parse(_restTimeController.text),
                  'notes': _notesController.text,
                  'video_url': null,
                }
              ],
              'remove_exercise_ids': [],
              'update_exercises': [],
            }
          ],
        },
      );

      if (response.data?['status'] == 'success') {
        if (mounted) {
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving exercise: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(l10n.workoutPlansTitle),
        centerTitle: true,
        backgroundColor: const Color(0xFFF5F5F5),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _saveExercise,
            child: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Exercise Animation
                  Container(
                    height: 300,
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: widget.animationPath.startsWith('http')
                          ? Lottie.network(
                              widget.animationPath,
                              fit: BoxFit.contain,
                            )
                          : Lottie.asset(
                              widget.animationPath,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),

                  // Exercise Name
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      widget.exerciseName,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Sets
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      children: [
                        Text(
                          l10n.sets,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _setsController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: const Color(0xFF0FF789),
                              border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide.none,
                          ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Reps
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      children: [
                        Text(
                          l10n.reps,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _repsController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: const Color(0xFF0FF789),
                              border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide.none,
                          ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Rest Time
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      children: [
                        Text(
                          l10n.restTime,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _restTimeController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: const Color(0xFF0FF789),
                              border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide.none,
                          ),
                              suffixText: 'seconds',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Coach Note
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.noteFromCoach,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _notesController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            hintText: l10n.exerciseNote,
                            border: InputBorder.none,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const BottomNavBar(role: UserRole.trainee, currentIndex: 2),
        ],
      ),
    );
  }
} 