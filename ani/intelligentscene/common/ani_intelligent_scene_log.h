/*
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

#ifndef ANI_INTELLIGENTSCENE_LOG_H
#define ANI_INTELLIGENTSCENE_LOG_H

#ifndef LOG_TAG
#define LOG_TAG
#endif

#include "hilog/log.h"

namespace OHOS::IntelligentScene {
const OHOS::HiviewDFX::HiLogLabel INTELLIGENTSCENE_LABEL = { LOG_CORE, 0xD000501, "IntelligentScene" };

#define FILENAME (__builtin_strrchr(__FILE__, '/') ? __builtin_strrchr(__FILE__, '/') + 1 : __FILE__)

#define INTELLIGENTSCENE_LOG_DEBUG(fmt, ...) \
    HiLogDebug(INTELLIGENTSCENE_LABEL, \
    "[%{public}s(%{public}s:%{public}d)]" fmt, FILENAME, __FUNCTION__, __LINE__, ##__VA_ARGS__)
#define INTELLIGENTSCENE_LOG_INFO(fmt, ...) \
    HiLogInfo(INTELLIGENTSCENE_LABEL, \
    "[%{public}s(%{public}s:%{public}d)]" fmt, FILENAME, __FUNCTION__, __LINE__, ##__VA_ARGS__)
#define INTELLIGENTSCENE_LOG_WARN(fmt, ...) \
    HiLogWarn(INTELLIGENTSCENE_LABEL, \
    "[%{public}s(%{public}s:%{public}d)]" fmt, FILENAME, __FUNCTION__, __LINE__, ##__VA_ARGS__)
#define INTELLIGENTSCENE_LOG_ERROR(fmt, ...) \
    HiLogError(INTELLIGENTSCENE_LABEL, \
    "[%{public}s(%{public}s:%{public}d)]" fmt, FILENAME, __FUNCTION__, __LINE__, ##__VA_ARGS__)
#define INTELLIGENTSCENE_LOG_FATAL(fmt, ...) \
    HiLogFatal(INTELLIGENTSCENE_LABEL, \
    "[%{public}s(%{public}s:%{public}d)]" fmt, FILENAME, __FUNCTION__, __LINE__, ##__VA_ARGS__)
} // namespace OHOS::IntelligentScene
#endif