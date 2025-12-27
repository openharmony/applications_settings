/**
 * Copyright (c) 2025 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#ifndef ANI_INTELLIGENT_SCENE_IS_DO_NOT_DISTURB_ENABLED
#define ANI_INTELLIGENT_SCENE_IS_DO_NOT_DISTURB_ENABLED

#include <ani.h>

namespace OHOS {
namespace IntelligentScene {
ani_boolean ani_is_do_not_disturb_enabled(ani_env *env);

ani_boolean ani_is_notify_allowed(ani_env *env);
} // namespace IntelligentScene
} // namespace OHOS
#endif  //  ANI_INTELLIGENT_SCENE_IS_DO_NOT_DISTURB_ENABLED