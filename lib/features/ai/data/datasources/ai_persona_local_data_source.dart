import 'package:apphoctienganh/features/ai/domain/ai_persona.dart';
import 'package:hive/hive.dart';

class AiPersonaLocalDataSource {
  static const String boxName = 'ai_personas';

  Box<AiPersonal> get _box => Hive.box<AiPersonal>(boxName);

  Future<void> savePersonas(List<AiPersonal> personas) async {
    await _box.clear();

    for (final persona in personas) {
      await _box.put(persona.id, persona);
    }
  }

  List<AiPersonal> getPersonas() {
    return _box.values.toList();
  }

  Future<void> saveSelectedPersona(AiPersonal persona) async {
    await _box.put('selected_${persona.id}', persona);
  }

  AiPersonal? getSelectedPersona(String id) {
    return _box.get('selected_$id');
  }
}
