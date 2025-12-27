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

#ifndef NAPI_INTELLIGENT_SCENE_LOG_H
#define NAPI_INTELLIGENT_SCENE_LOG_H

#ifndef INTELLIGENT_LOG_TAG
#define INTELLIGENT_LOG_TAG
#endif

#include "hilog/log.h"

namespace OHOS::IntelligentScene {
const OHOS::HiviewDFX::HiLogLabel LABEL = { LOG_CORE, 0xD000501, "IntelligentScene" };

#define INTELLIGENT_SCENE_LOG_DEBUG(fmt, ...) \
    HiLogDebug(LABEL, fmt, ##__VA_ARGS__)
#define INTELLIGENT_SCENE_LOG_INFO(fmt, ...) \
    HiLogInfo(LABEL, fmt,  ##__VA_ARGS__)
#define INTELLIGENT_SCENE_LOG_WARN(fmt, ...) \
    HiLogWarn(LABEL, fmt,  ##__VA_ARGS__)
#define INTELLIGENT_SCENE_LOG_ERROR(fmt, ...) \
    HiLogError(LABEL, fmt, ##__VA_ARGS__)
#define INTELLIGENT_SCENE_LOG_FATAL(fmt, ...) \
    HiLogFatal(LABEL, fmt, ##__VA_ARGS__)
} // namespace OHOS::IntelligentScene
#endif