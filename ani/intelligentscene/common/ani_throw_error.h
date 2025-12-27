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

#ifndef ANI_INTELLIGENTSCENE_THROW_ERROR_H
#define ANI_INTELLIGENTSCENE_THROW_ERROR_H
#include <ani.h>
#include <string>
#include <map>

struct IntelligentSceneError {
    int errorCode;
    std::string message;
};

namespace OHOS {
namespace IntelligentScene {
constexpr int ERROR_PERMISSION_DENIED = 201;
constexpr int ERROR_SYSTEM_CAP_ERROR = 801;
constexpr int ERROR_INTERNAL_ERROR = 1600001;
constexpr int ERROR_IPC_ERROR = 1600002;
constexpr int ERROR_SERVICE_CONNECT_ERROR = 1600003;
const std::string ERROR_INTERNAL_MSG = "Internal error.";

const std::map<int, std::string> g_errorMap = {
    {ERROR_PERMISSION_DENIED, "Permission denied."},
    {ERROR_SYSTEM_CAP_ERROR, "Capability not supported."},
    {ERROR_INTERNAL_ERROR, "Internal error."},
    {ERROR_IPC_ERROR, "Marshalling or unmarshalling error."},
    {ERROR_SERVICE_CONNECT_ERROR, "Failed to connect to the service."},
};

ani_object CreateError(ani_env *env, int32_t code, const std::string &msg);

void ThrowError(ani_env *env, int32_t errCode);

IntelligentSceneError ReadErrorMessage(int code);

} // namespace IntelligentScene
} // OHOS
#endif