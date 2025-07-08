import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/bottom_nav_bar.dart';
import '../../../../core/widgets/subscription_request_bubble.dart';
import '../../../../core/constants/enums.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/network/http_client.dart';

class CoachSubscriptionRequestsScreen extends StatefulWidget {
  const CoachSubscriptionRequestsScreen({super.key});

  @override
  State<CoachSubscriptionRequestsScreen> createState() => _CoachSubscriptionRequestsScreenState();
}

class _CoachSubscriptionRequestsScreenState extends State<CoachSubscriptionRequestsScreen> {
  bool _isLoading = true;
  String? _error;
  List<Map<String, dynamic>> _requests = [];
  int _totalRequests = 0;

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    try {
      final httpClient = HttpClient();
      final response = await httpClient.get<Map<String, dynamic>>(
        '/api/subscription/requests',
      );

      if (response.data?['status'] == 'success') {
        final requestsData = response.data!['data'];
        _totalRequests = requestsData['total'] as int;
        if (_totalRequests > 0) {
          _requests = (requestsData['requests'] as List)
              .map((request) => request as Map<String, dynamic>)
              .toList();
        }
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _showConfirmationDialog(int requestId, bool isAccepting, String traineeName) async {
    final l10n = AppLocalizations.of(context)!;
    
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            isAccepting ? l10n.acceptSubscriptionConfirmTitle : l10n.rejectSubscriptionConfirmTitle,
            style: AppTheme.bodyLarge,
          ),
          content: Text(
            isAccepting 
              ? l10n.acceptSubscriptionConfirmMessage(traineeName)
              : l10n.rejectSubscriptionConfirmMessage(traineeName),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(l10n.cancel),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(l10n.confirm),
              onPressed: () {
                Navigator.of(context).pop();
                _handleRequest(requestId, isAccepting);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showResultDialog(String message) async {
    final l10n = AppLocalizations.of(context)!;
    
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text(l10n.close),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleRequest(int requestId, bool accept) async {
    try {
      final httpClient = HttpClient();
      final response = await httpClient.post<Map<String, dynamic>>(
        '/api/subscription/handle/$requestId',
        data: {
          'status': accept ? 'accepted' : 'rejected',
        },
      );

      if (response.data?['status'] == 'success') {
        // Show success message
        if (mounted) {
          final l10n = AppLocalizations.of(context)!;
          await _showResultDialog(l10n.subscriptionRequestAcceptedSuccess);
        }
        // Reload requests after action
        _loadRequests();
      }
    } catch (e) {
      // Show error dialog
      if (mounted) {
        await _showResultDialog('Error: ${e.toString()}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Text('Error: $_error'),
        ),
      );
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: AppColors.primary,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Stack(
          children: [
            Column(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(50),
                    ),
                  ),
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + 32,
                    bottom: 24,
                    left: 24,
                    right: 24,
                  ),
                  child: Center(
                    child: Text(
                      l10n.subscriptionRequestsTitle,
                      style: AppTheme.screenTitle,
                    ),
                  ),
                ),
                Expanded(
                  child: _totalRequests == 0
                      ? Center(
                          child: Text(
                            l10n.noSubscriptionRequests,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.only(bottom: 80),
                          itemCount: _requests.length,
                          itemBuilder: (context, index) {
                            final request = _requests[index];
                            final traineeName = request['trainee']['full_name'] as String;
                            return SubscriptionRequestBubble(
                              name: traineeName,
                              imageUrl: request['trainee']['image_url'] as String?,
                              onAccept: () => _showConfirmationDialog(
                                request['id'] as int,
                                true,
                                traineeName,
                              ),
                              onReject: () => _showConfirmationDialog(
                                request['id'] as int,
                                false,
                                traineeName,
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
            const Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: BottomNavBar(
                role: UserRole.coach,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 