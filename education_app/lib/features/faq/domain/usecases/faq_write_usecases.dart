import '../entities/faq_entity.dart';
import '../repositories/faq_repository.dart';

class CreateFaq {
  final FaqRepository repository;
  CreateFaq(this.repository);

  Future<String?> call(FaqEntity faq) => repository.createFaq(faq);
}

class UpdateFaq {
  final FaqRepository repository;
  UpdateFaq(this.repository);

  Future<void> call(FaqEntity faq) => repository.updateFaq(faq);
}

class DeleteFaq {
  final FaqRepository repository;
  DeleteFaq(this.repository);

  Future<void> call(String id) => repository.deleteFaq(id);
}

class IncrementFaqView {
  final FaqRepository repository;
  IncrementFaqView(this.repository);

  Future<void> call(String id) => repository.incrementViewCount(id);
}

class ToggleFaqHelpful {
  final FaqRepository repository;
  ToggleFaqHelpful(this.repository);

  Future<void> increment(String id) => repository.incrementHelpfulCount(id);
  Future<void> decrement(String id) => repository.decrementHelpfulCount(id);
}
