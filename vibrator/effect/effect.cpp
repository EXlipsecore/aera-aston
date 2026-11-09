#include <cstdint>
#include "effect.h"
#include <VibrationEffectConfig.h>
const struct effect_stream* get_effect_stream(uint32_t effect_id) {
  for (const auto& v : effects) {
    if (v.effect_id == effect_id) return &v;
  }
  return nullptr;
}
