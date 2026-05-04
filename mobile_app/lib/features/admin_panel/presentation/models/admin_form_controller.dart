/*
  -----------------------------------------------------------------------------
  Proyecto: RuteX Go
  Desarrollado por: TurisTechTeam
  Descripción: Esta aplicación y su código fuente son propiedad intelectual de
  TurisTechTeam. Queda prohibida su copia, distribución o uso no autorizado.
  Año: 2026
  -----------------------------------------------------------------------------
*/import 'package:flutter/foundation.dart';

class AdminFormController extends ChangeNotifier {
  bool _hasChanges = false;
  bool _isSaving = false;
  Object? _saveToken;
  Future<void> Function()? _saveAction;

  bool get hasChanges => _hasChanges;
  bool get isSaving => _isSaving;
  bool get canSave => _hasChanges && !_isSaving && _saveAction != null;

  Object registerSaveAction(Future<void> Function() saveAction) {
    final token = Object();
    _saveToken = token;
    _saveAction = saveAction;
    notifyListeners();
    return token;
  }

  void unregisterSaveAction(Object token) {
    if (_saveToken != token) return;

    _saveToken = null;
    _saveAction = null;
    _hasChanges = false;
    notifyListeners();
  }

  void markChanged() {
    if (_hasChanges) return;

    _hasChanges = true;
    notifyListeners();
  }

  void markClean() {
    if (!_hasChanges) return;

    _hasChanges = false;
    notifyListeners();
  }

  void reset() {
    _hasChanges = false;
    _isSaving = false;
    _saveToken = null;
    _saveAction = null;
    notifyListeners();
  }

  Future<void> save() async {
    final saveAction = _saveAction;
    if (!canSave || saveAction == null) return;

    _isSaving = true;
    notifyListeners();

    try {
      await saveAction();
      _hasChanges = false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }
}
