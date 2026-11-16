import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:turkiye_kan_agi/core/mock/mock_data.dart';
import 'package:turkiye_kan_agi/core/services/remote_config_service.dart';
import 'package:turkiye_kan_agi/features/donation/data/firestore_donation_repository.dart';
import 'package:turkiye_kan_agi/features/donation/domain/donation_repository.dart';
import 'package:turkiye_kan_agi/features/notifications/data/firestore_notification_repository.dart';
import 'package:turkiye_kan_agi/features/notifications/domain/app_notification.dart';
import 'package:turkiye_kan_agi/features/profile/data/firestore_profile_repository.dart';
import 'package:turkiye_kan_agi/features/profile/domain/profile_repository.dart';
import 'package:turkiye_kan_agi/features/requests/data/firestore_blood_request_repository.dart';
import 'package:turkiye_kan_agi/features/requests/domain/blood_request_repository.dart';

/// Aşama 1.F uyumluluk takma adları ve Fake Repository sınıfları.
typedef RequestRepository = BloodRequestRepository;

class FakeRequestRepository extends FirestoreBloodRequestRepository {
  FakeRequestRepository({required super.remoteConfig})
      : super(seedRequests: MockData.requests);
}

class FakeDonationRepository extends FirestoreDonationRepository {
  FakeDonationRepository() : super();
}

class FakeProfileRepository extends FirestoreProfileRepository {
  FakeProfileRepository() : super();
}

abstract class NotificationRepository {
  List<AppNotification> getNotifications();
  void markAsRead(String id);
  void markAllAsRead();
  void removeNotification(String id);
}

class FakeNotificationRepository implements NotificationRepository {
  FakeNotificationRepository(this._notifier);

  final NotificationCenterNotifier _notifier;

  @override
  List<AppNotification> getNotifications() => _notifier.currentItems;

  @override
  void markAsRead(String id) => _notifier.markAsRead(id);

  @override
  void markAllAsRead() => _notifier.markAllAsRead();

  @override
  void removeNotification(String id) => _notifier.removeNotification(id);
}

final requestRepositoryInterfaceProvider = Provider<RequestRepository>((ref) {
  final rc = ref.watch(remoteConfigServiceProvider);
  return FakeRequestRepository(remoteConfig: rc);
});

final donationRepositoryInterfaceProvider = Provider<DonationRepository>((ref) {
  return ref.watch(donationRepositoryProvider);
});

final profileRepositoryInterfaceProvider = Provider<ProfileRepository>((ref) {
  return ref.watch(profileRepositoryProvider);
});
