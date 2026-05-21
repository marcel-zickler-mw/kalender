import 'package:flutter_test/flutter_test.dart';
import 'package:kalender/kalender.dart';

void main() {
  group('ResourceConfig', () {
    test('stores the id', () {
      const config = ResourceConfig(id: 'alice');
      expect(config.id, 'alice');
    });

    test('equality is id-based', () {
      const a1 = ResourceConfig(id: 'alice');
      const a2 = ResourceConfig(id: 'alice');
      const b = ResourceConfig(id: 'bob');
      expect(a1, equals(a2));
      expect(a1, isNot(equals(b)));
    });

    test('hashCode tracks id', () {
      const a1 = ResourceConfig(id: 'alice');
      const a2 = ResourceConfig(id: 'alice');
      expect(a1.hashCode, equals(a2.hashCode));
    });

    test('toString contains the id', () {
      const config = ResourceConfig(id: 'alice');
      expect(config.toString(), contains('alice'));
    });
  });
}
