import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../core/services/storage_service.dart';
import '../models/pet.dart';

class PetProvider extends ChangeNotifier {
  static const _petsKey = 'pcn_pets';
  static const _activePetKey = 'pcn_active_pet';

  final _uuid = const Uuid();
  List<Pet> _pets = [];
  String? _activePetId;

  List<Pet> get pets => List.unmodifiable(_pets);
  Pet? get activePet {
    if (_pets.isEmpty) return null;
    if (_activePetId != null) {
      return _pets.where((p) => p.id == _activePetId).firstOrNull ?? _pets.first;
    }
    return _pets.first;
  }

  bool get hasPets => _pets.isNotEmpty;

  Future<void> init() async {
    await _load();
    notifyListeners();
  }

  Future<void> _load() async {
    final raw = await StorageService.instance.getString(_petsKey);
    if (raw != null && raw.isNotEmpty) {
      _pets = StorageService.decodeList(raw).map(Pet.fromJson).toList();
    }
    _activePetId = await StorageService.instance.getString(_activePetKey);
  }

  Future<void> _save() async {
    await StorageService.instance.saveString(
      _petsKey,
      StorageService.encodeList(_pets.map((p) => p.toJson()).toList()),
    );
    if (_activePetId != null) {
      await StorageService.instance.saveString(_activePetKey, _activePetId!);
    }
  }

  Future<Pet> addPet({
    required String name,
    required DateTime birthDate,
    String species = 'dog',
    String breed = '',
    String? photoPath,
    String furColor = '',
    String gender = 'unknown',
  }) async {
    final pet = Pet(
      id: _uuid.v4(),
      name: name,
      birthDate: birthDate,
      species: species,
      breed: breed,
      photoPath: photoPath,
      furColor: furColor,
      gender: gender,
    );
    _pets.add(pet);
    _activePetId = pet.id;
    await _save();
    notifyListeners();
    return pet;
  }

  Future<void> updatePet(Pet pet) async {
    final i = _pets.indexWhere((p) => p.id == pet.id);
    if (i >= 0) {
      _pets[i] = pet;
      await _save();
      notifyListeners();
    }
  }

  Future<void> deletePet(String id) async {
    _pets.removeWhere((p) => p.id == id);
    if (_activePetId == id) {
      _activePetId = _pets.isNotEmpty ? _pets.first.id : null;
    }
    await _save();
    notifyListeners();
  }

  void selectPet(String id) {
    if (_pets.any((p) => p.id == id)) {
      _activePetId = id;
      _save();
      notifyListeners();
    }
  }
}

extension _FirstOrNull<E> on Iterable<E> {
  E? get firstOrNull {
    final it = iterator;
    return it.moveNext() ? it.current : null;
  }
}
