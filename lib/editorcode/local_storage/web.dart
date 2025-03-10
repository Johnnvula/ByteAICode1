
import 'package:web/web.dart' as web;

import '../local_storage.dart';
import '../utils.dart';

const _userInputKey = 'user_';
const _userKeybindingKey = 'user_keybinding_';

class LocalStorageImpl extends LocalStorage {
  @override
  void saveUserCode(String code) =>
      web.window.localStorage.setItem(_userInputKey, code);

  @override
  String? getUserCode() =>
      web.window.localStorage.getItem(_userInputKey)?.nullIfEmpty;

  @override
  void saveUserKeybinding(String keybinding) =>
      web.window.localStorage.setItem(_userKeybindingKey, keybinding);

  @override
  String? getUserKeybinding() =>
      web.window.localStorage.getItem(_userKeybindingKey)?.nullIfEmpty;
}
