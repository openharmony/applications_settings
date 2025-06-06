/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#ifndef OHOS_CJ_SETTINGS_LOG_H
#define OHOS_CJ_SETTINGS_LOG_H

#include "hilog/log.h"

#ifdef LOG_DOMAIN
#undef LOG_DOMAIN
#endif
#ifdef LOG_TAG
#undef LOG_TAG
#endif

#define LOG_DOMAIN 0x0500
#define LOG_TAG "CJ-SETTINGS"

#define LOGD(...)                                           \
if (HiLogIsLoggable(LOG_DOMAIN, LOG_TAG, LOG_DEBUG)) {      \
    HILOG_DEBUG(LOG_CORE, ##__VA_ARGS__);                   \
}

#define LOGI(...)                                           \
if (HiLogIsLoggable(LOG_DOMAIN, LOG_TAG, LOG_INFO)) {       \
    HILOG_INFO(LOG_CORE, ##__VA_ARGS__);                    \
}

#define LOGE(...)                                           \
if (HiLogIsLoggable(LOG_DOMAIN, LOG_TAG, LOG_ERROR)) {      \
    HILOG_ERROR(LOG_CORE, ##__VA_ARGS__);                   \
}

#endif // OHOS_CJ_SETTINGS_LOG_H