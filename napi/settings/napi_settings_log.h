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
#include "hilog/log.h"

#ifdef SETTINGS_LABEL
#undef SETTINGS_LABEL
#endif

#ifdef LOG_DEBUG
#undef LOG_DEBUG
#endif

#ifdef LOG_INFO
#undef LOG_INFO
#endif

#ifdef LOG_WARN
#undef LOG_WARN
#endif

#ifdef LOG_FATAL
#undef LOG_FATAL
#endif

#ifdef LOG_ERROR
#undef LOG_ERROR
#endif

namespace ohos {
namespace settings {
    static constexpr OHOS::HiviewDFX::HiLogLabel SETTINGS_LABEL = {LOG_CORE,0xd01900,"Settings"};
    #define__FILENAME__(__builtin_strrchr(__FILE__,'/')?__builtin_strrchr(__FILE__,'/')+1:__FILE__) 
    #define LOG_DEBUG(fmt,...)\
    (void)OHOS::HiviewDFX::HiLog::Debug(\
    SETTINGS_LABEL,"[%{public}s(%{public}s:%{public}d)]" fmt,__FILENAME__,__FUNCTION__,__LINE__,##__VA_ARGS__)
    #define LOG_INFO(fmt,...)\
    (void)OHOS::HiviewDFX::HiLog::Info(\
    SETTINGS_LABEL,"[%{public}s(%{public}s:%{public}d)]" fmt,__FILENAME__,__FUNCTION__,__LINE__,##__VA_ARGS__)
    #define LOG_WARN(fmt,...)\
    (void)OHOS::HiviewDFX::HiLog::Warn(\
    SETTINGS_LABEL,"[%{public}s(%{public}s:%{public}d)]" fmt,__FILENAME__,__FUNCTION__,__LINE__,##__VA_ARGS__)
    #define LOG_FATAL(fmt,...)\
    (void)OHOS::HiviewDFX::HiLog::Fatal(\
    SETTINGS_LABEL,"[%{public}s(%{public}s:%{public}d)]" fmt,__FILENAME__,__FUNCTION__,__LINE__,##__VA_ARGS__)
    #define LOG_ERROR(fmt,...)\
    (void)OHOS::HiviewDFX::HiLog::Error(\
    SETTINGS_LABEL,"[%{public}s(%{public}s:%{public}d)]" fmt,__FILENAME__,__FUNCTION__,__LINE__,##__VA_ARGS__)
}  // namespace Settings
}  // namespace OHOS
#endif  //  NAPI_SETTINGS_LOG_H
