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

#ifndef NAPI_INTELLIGENT_SCENE_IS_DO_NOT_DISTURB_ENABLED
#define NAPI_INTELLIGENT_SCENE_IS_DO_NOT_DISTURB_ENABLED

#include "napi/native_api.h"
#include "common/common.h"

namespace OHOS {
namespace IntelligentScene {
struct NotDisturbEnabledCallback {
    napi_env env = nullptr;
    napi_async_work asyncWork = nullptr;
    napi_ref callback = nullptr;
    bool isDoNotDisturbEnabled = false;
    CallbackPromiseInfo info;
};

struct NotifyAllowedCallback {
    napi_env env = nullptr;
    napi_async_work asyncWork = nullptr;
    napi_ref callback = nullptr;
    bool isNotifyAllowedInDoNotDisturb = false;
    CallbackPromiseInfo info;
};

napi_value napi_is_do_not_disturb_enabled(napi_env env, napi_callback_info info);

napi_value napi_is_notify_allowed(napi_env env, napi_callback_info info);
} // namespace IntelligentScene
} // namespace OHOS
#endif  //  NAPI_INTELLIGENT_SCENE_IS_DO_NOT_DISTURB_ENABLED