import 'package:flutter/foundation.dart';

import 'api.dart';
import 'models.dart';

class AppState extends ChangeNotifier {
  AppState(this._api);

  final ApiClient _api;
  List<Company> companies = const [];
  bool isLoading = false;
  String? errorMessage;

  Future<void> loadCompanies() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      companies = await _api.fetchCompanies();
    } catch (error) {
      errorMessage = error.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addCompany({
    required String name,
    required String registrationNumber,
  }) async {
    await _api.createCompany(
      name: name,
      registrationNumber: registrationNumber,
    );
    await loadCompanies();
  }

  Future<void> addService({
    required String companyId,
    required String name,
    required String description,
    required double price,
  }) async {
    await _api.createService(
      companyId: companyId,
      name: name,
      description: description,
      price: price,
    );
    await loadCompanies();
  }
}
