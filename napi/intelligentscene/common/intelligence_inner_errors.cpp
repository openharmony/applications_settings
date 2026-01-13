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

#include "intelligence_inner_errors.h"
#include "napi_intelligent_scene_log.h"

namespace OHOS {
namespace IntelligentScene {
static const std::unordered_map<int32_t, std::string> INTELLIGENCE_ERROR_CODE_MESSAGE_MAP = {
    {ERROR_PERMISSION_DENIED, "Permission denied."},
    {ERROR_SYSTEM_CAP_ERROR, "Capability not supported."},
    {ERROR_INTERNAL_ERROR, "Internal error."},
    {ERROR_IPC_ERROR, "Marshalling or unmarshalling error."},
    {ERROR_SERVICE_CONNECT_ERROR, "Failed to connect to the service."},
};

static std::vector<std::pair<int32_t, int32_t>> ERRORS_CONVERT = {
    {ERROR_PERMISSION_DENIED, ERROR_PERMISSION_DENIED},
    {ERROR_SYSTEM_CAP_ERROR, ERROR_SYSTEM_CAP_ERROR},
    {ERROR_INTERNAL_ERROR, ERROR_INTERNAL_ERROR},
    {ERROR_IPC_ERROR, ERROR_IPC_ERROR},
    {ERROR_SERVICE_CONNECT_ERROR, ERROR_SERVICE_CONNECT_ERROR},
};

std::string GetIntelligenceErrMessage(uint32_t errCode, std::string defaultMsg)
{
    auto iter = INTELLIGENCE_ERROR_CODE_MESSAGE_MAP.find(errCode);
    return iter != INTELLIGENCE_ERROR_CODE_MESSAGE_MAP.end() ? iter->second : defaultMsg;
}
}  // namespace IntelligentScene
}  // namespace OHOS