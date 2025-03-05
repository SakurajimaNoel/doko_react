import 'package:uuid/uuid.dart';

const uuid = Uuid();

String generateUniqueString() {
  return uuid.v4();
}

String generateTimeBasedUniqueString() {
  return uuid.v7();
}
