import 'package:flutter/material.dart';
import '../../domain/entities/faq_entity.dart';
import '../../domain/usecases/faq_read_usecases.dart';
import '../../domain/usecases/faq_write_usecases.dart';

class FaqNotifier extends ChangeNotifier {
  final GetFaqs _getFaqs;
  final GetFaqsByCategory _getFaqsByCategory;
  final GetFaqsBySystem _getFaqsBySystem;
  final GetFaqById _getFaqById;
  final SearchFaqs _searchFaqs;
  final CreateFaq _createFaq;
  final UpdateFaq _updateFaq;
  final DeleteFaq _deleteFaq;
  final ToggleFaqHelpful _toggleFaqHelpful;

  bool _isLoading = false;
  String? _error;

  FaqNotifier({
    required GetFaqs getFaqs,
    required GetFaqsByCategory getFaqsByCategory,
    required GetFaqsBySystem getFaqsBySystem,
    required GetFaqById getFaqById,
    required SearchFaqs searchFaqs,
    required CreateFaq createFaq,
    required UpdateFaq updateFaq,
    required DeleteFaq deleteFaq,
    required ToggleFaqHelpful toggleFaqHelpful,
  })  : _getFaqs = getFaqs,
        _getFaqsByCategory = getFaqsByCategory,
        _getFaqsBySystem = getFaqsBySystem,
        _getFaqById = getFaqById,
        _searchFaqs = searchFaqs,
        _createFaq = createFaq,
        _updateFaq = updateFaq,
        _deleteFaq = deleteFaq,
        _toggleFaqHelpful = toggleFaqHelpful;

  bool get isLoading => _isLoading;
  String? get error => _error;

  Stream<List<FaqEntity>> get faqsStream => _getFaqs();
  Stream<List<FaqEntity>> getFaqsByCategory(FaqCategory category) => 
      _getFaqsByCategory(category);
  Stream<List<FaqEntity>> getFaqsBySystem(String systemId) => 
      _getFaqsBySystem(systemId);

  Future<FaqEntity?> getFaqById(String id) async {
    try {
      return await _getFaqById(id);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<List<FaqEntity>> search(String query) async {
    _isLoading = true;
    notifyListeners();
    try {
      final results = await _searchFaqs(query);
      _isLoading = false;
      notifyListeners();
      return results;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return [];
    }
  }

  Future<void> createFaq(FaqEntity faq) async {
    try {
      _isLoading = true;
      notifyListeners();
      await _createFaq(faq);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateFaq(FaqEntity faq) async {
    try {
      _isLoading = true;
      notifyListeners();
      await _updateFaq(faq);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteFaq(String id) async {
    try {
      _isLoading = true;
      notifyListeners();
      await _deleteFaq(id);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> markAsHelpful(String id) async {
    try {
      await _toggleFaqHelpful.increment(id);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> unmarkAsHelpful(String id) async {
    try {
      await _toggleFaqHelpful.decrement(id);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}
