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

#ifndef NAPI_SETTINGS_LOG_H
#define NAPI_SETTINGS_LOG_H

#ifndef LOG_TAG
#define LOG_TAG
#endif

#include "hilog/log.h"

namespace OHOS::Settings {
const OHOS::HiviewDFX::HiLogLabel SETTINGS_LABEL = { LOG_CORE, 0xD000501, "Settings" };

#define SETTING_LOG_DEBUG(fmt, ...) \
    HILOG_IMPL(SETTINGS_LABEL.type, LOG_DEBUG, SETTINGS_LABEL.domain, SETTINGS_LABEL.tag, fmt, ##__VA_ARGS__)
#define SETTING_LOG_INFO(fmt, ...) \
    HILOG_IMPL(SETTINGS_LABEL.type, LOG_INFO, SETTINGS_LABEL.domain, SETTINGS_LABEL.tag, fmt, ##__VA_ARGS__)
#define SETTING_LOG_WARN(fmt, ...) \
    HILOG_IMPL(SETTINGS_LABEL.type, LOG_WARN, SETTINGS_LABEL.domain, SETTINGS_LABEL.tag, fmt, ##__VA_ARGS__)
#define SETTING_LOG_ERROR(fmt, ...) \
    HILOG_IMPL(SETTINGS_LABEL.type, LOG_ERROR, SETTINGS_LABEL.domain, SETTINGS_LABEL.tag, fmt, ##__VA_ARGS__)
#define SETTING_LOG_FATAL(fmt, ...) \
    HILOG_IMPL(SETTINGS_LABEL.type, LOG_FATAL, SETTINGS_LABEL.domain, SETTINGS_LABEL.tag, fmt, ##__VA_ARGS__)
} // namespace OHOS::Settings
#endif