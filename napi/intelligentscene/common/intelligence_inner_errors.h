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

#ifndef INTELLIGENT_SCENE_STANDARD_INNERKITS_BASE_INCLUDE_INNER_ERRORS_H
#define INTELLIGENT_SCENE_STANDARD_INNERKITS_BASE_INCLUDE_INNER_ERRORS_H

#include <map>
#include <sstream>

namespace OHOS {
namespace IntelligentScene {
    // Common error code
    const int32_t ERROR_PERMISSION_DENIED = 201;          // No permission to call the interface.
    const int32_t ERROR_SYSTEM_CAP_ERROR  = 801;          // The specified SystemCapability names was not found.

    // Intelligence error code
    const int32_t ERROR_INTERNAL_ERROR               = 1600001;    // Internal error.
    const int32_t ERROR_IPC_ERROR                    = 1600002;    // Marshalling or unmarshalling error.
    const int32_t ERROR_SERVICE_CONNECT_ERROR        = 1600003;    // Failed to connect to the service.

    std::string GetIntelligenceErrMessage(uint32_t errCode, std::string defaultMsg = "");

    int32_t ErrorToExternal(uint32_t errCode);
}  // namespace IntelligentScene
}  // namespace OHOS

#endif  // INTELLIGENT_SCENE_STANDARD_INNERKITS_BASE_INCLUDE_INNER_ERRORS_H