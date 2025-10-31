import 'package:custom_lint_builder/custom_lint_builder.dart';

import 'src/avoid_animation_repeat.dart';
import 'src/avoid_await_future_constructor.dart';
import 'src/avoid_pump_and_settle.dart';
import 'src/avoid_network_image_in_tests.dart';
import 'src/prefer_keys_over_text_finders.dart';

// Comprehensive timing-related lint rules
import 'src/direct_timing_operation.dart';
import 'src/third_party_timing_operation.dart';
import 'src/timing_extension_method.dart';
import 'src/completer_timer_pattern.dart';
import 'src/hardcoded_timing_duration.dart';
import 'src/animation_without_config.dart';
import 'src/service_missing_config_injection.dart';

PluginBase createPlugin() => _TestQualityLintPlugin();

class _TestQualityLintPlugin extends PluginBase {
  @override
  List<LintRule> getLintRules(CustomLintConfigs configs) => [
        // Test quality rules
        const AvoidPumpAndSettle(),
        const PreferKeysOverTextFinders(),
        const AvoidAnimationRepeat(),
        const AvoidAwaitFutureConstructor(),
        const AvoidNetworkImageInTests(),           // Rule 8: ERROR

        // Timing-related rules (updated per DI plan)
        const DirectTimingOperation(),              // ERROR
        const ThirdPartyTimingOperation(),          // ERROR
        const TimingExtensionMethod(),              // ERROR
        const CompleterTimerPattern(),              // WARNING
        const HardcodedTimingDuration(),            // ERROR
        const AnimationWithoutConfig(),             // ERROR
        const ServiceMissingConfigInjection(),      // ERROR
      ];
}
