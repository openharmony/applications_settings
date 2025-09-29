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

#ifndef ANI_SETTINGS_LOG_H
#define ANI_SETTINGS_LOG_H

#ifndef LOG_TAG
#define LOG_TAG
#endif

#include "hilog/log.h"

namespace OHOS::Settings {
const OHOS::HiviewDFX::HiLogLabel SETTINGS_LABEL = { LOG_CORE, 0xD000501, "Settings" };

#define FILENAME (__builtin_strrchr(__FILE__, '/') ? __builtin_strrchr(__FILE__, '/') + 1 : __FILE__)

#define SETTING_LOG_DEBUG(fmt, ...) \
    HiLogDebug(SETTINGS_LABEL, \
    "[%{public}s(%{public}s:%{public}d)]" fmt, FILENAME, __FUNCTION__, __LINE__, ##__VA_ARGS__)
#define SETTING_LOG_INFO(fmt, ...) \
    HiLogInfo(SETTINGS_LABEL, \
    "[%{public}s(%{public}s:%{public}d)]" fmt, FILENAME, __FUNCTION__, __LINE__, ##__VA_ARGS__)
#define SETTING_LOG_WARN(fmt, ...) \
    HiLogWarn(SETTINGS_LABEL, \
    "[%{public}s(%{public}s:%{public}d)]" fmt, FILENAME, __FUNCTION__, __LINE__, ##__VA_ARGS__)
#define SETTING_LOG_ERROR(fmt, ...) \
    HiLogError(SETTINGS_LABEL, \
    "[%{public}s(%{public}s:%{public}d)]" fmt, FILENAME, __FUNCTION__, __LINE__, ##__VA_ARGS__)
#define SETTING_LOG_FATAL(fmt, ...) \
    HiLogFatal(SETTINGS_LABEL, \
    "[%{public}s(%{public}s:%{public}d)]" fmt, FILENAME, __FUNCTION__, __LINE__, ##__VA_ARGS__)
} // namespace OHOS::Settings
#endif