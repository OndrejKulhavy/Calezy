import 'package:calezy/core/data/repository/intake_repository.dart';
import 'package:calezy/core/domain/entity/intake_entity.dart';

class UpdateIntakeUsecase {
  final IntakeRepository _intakeRepository;

  UpdateIntakeUsecase(this._intakeRepository);

  Future<IntakeEntity?> updateIntake(
      String intakeId, Map<String, dynamic> intakeFields) async {
    return await _intakeRepository.updateIntake(intakeId, intakeFields);
  }
}
