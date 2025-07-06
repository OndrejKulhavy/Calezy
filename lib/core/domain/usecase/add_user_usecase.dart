import 'package:calezy/core/data/repository/user_repository.dart';
import 'package:calezy/core/domain/entity/user_entity.dart';

class AddUserUsecase {
  final UserRepository _userRepository;

  AddUserUsecase(this._userRepository);

  Future<void> addUser(UserEntity userEntity) async {
    return await _userRepository.updateUserData(userEntity);
  }
}
