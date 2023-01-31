/*
 * Copyright (c) 2022 Huawei Device Co., Ltd.
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


#define CONFIG_HILOG
#ifdef CONFIG_HILOG
#include "hilog/log.h"

#ifdef SETTING_LOG_DEBUG
#undef SETTING_LOG_DEBUG
#endif

#ifdef SETTING_LOG_INFO
#undef SETTING_LOG_INFO
#endif

#ifdef SETTING_LOG_WARN
#undef SETTING_LOG_WARN
#endif

#ifdef SETTING_LOG_FATAL
#undef SETTING_LOG_FATAL
#endif

#ifdef SETTING_LOG_ERROR
#undef SETTING_LOG_ERROR
#endif

#ifdef SETTING_LABEL
#undef SETTING_LABEL
#endif

static constexpr OHOS::HiviewDFX::HiLogLabel SETTING_LABEL = {LOG_CORE,0xD190,"Settings"};
#define __FILENAME__ (__builtin_strrchr(__FILE__,'/') ? __builtin_strrchr (__FILE__,'/')+1:__FILE__) 
#define SETTING_LOG_DEBUG(fmt,...)\
(void)OHOS::HiviewDFX::HiLog::Debug(\
SETTING_LABEL,"[%{public}s(%{public}s:%{public}d)]" fmt,__FILENAME__,__FUNCTION__,__LINE__,##__VA_ARGS__)
#define SETTING_LOG_INFO(fmt,...)\
(void)OHOS::HiviewDFX::HiLog::Info(\
SETTING_LABEL,"[%{public}s(%{public}s:%{public}d)]" fmt,__FILENAME__,__FUNCTION__,__LINE__,##__VA_ARGS__)
#define SETTING_LOG_WARN(fmt,...)\
(void)OHOS::HiviewDFX::HiLog::Warn(\
SETTING_LABEL,"[%{public}s(%{public}s:%{public}d)]" fmt,__FILENAME__,__FUNCTION__,__LINE__,##__VA_ARGS__)
#define SETTING_LOG_FATAL(fmt,...)\
(void)OHOS::HiviewDFX::HiLog::Fatal(\
SETTING_LABEL,"[%{public}s(%{public}s:%{public}d)]" fmt,__FILENAME__,__FUNCTION__,__LINE__,##__VA_ARGS__)
#define SETTING_LOG_ERROR(fmt,...)\
(void)OHOS::HiviewDFX::HiLog::Error(\
SETTING_LABEL,"[%{public}s(%{public}s:%{public}d)]" fmt,__FILENAME__,__FUNCTION__,__LINE__,##__VA_ARGS__)

#else

#define SETTING_LOG_DEBUG(...)
#define SETTING_LOG_INFO(...)
#define SETTING_LOG_WARN(...)
#define SETTING_LOG_FATAL(...)
#define SETTING_LOG_ERROR(...)
#endif //CONFIG_HILOG

#endif //NAPI_SETTINGS_LOG_H


