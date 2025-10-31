import 'package:mocktail/mocktail.dart';

// Initializes mocktail with any common fallback values
void initMocktail() {
  // Place registerFallbackValue() calls here or call registerCommonFallbacks()
}

// Quick utility to stub async method
void stubAsync<T>(When whenCall, Future<T> value) {
  whenCall.thenAnswer((_) async => value);
}

// Quick utility to stub sync method
void stubSync<T>(When whenCall, T value) {
  whenCall.thenReturn(value);
}
