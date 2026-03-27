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
#include "ani_throw_error.h"
#include "ani_intelligent_scene_log.h"

namespace OHOS {
namespace IntelligentScene {
constexpr const char *BUSINESS_ERROR_CLASS = "@ohos.base.BusinessError";
constexpr const char *ERROR_CLASS_NAME = "escompat.Error";

void ThrowError(ani_env *env, int32_t errCode)
{
    if (env == nullptr) {
        INTELLIGENTSCENE_LOG_ERROR("null env");
        return;
    }
    IntelligentSceneError err = ReadErrorMessage(errCode);
    ani_object error = CreateError(env, err.errorCode, err.message);
    env->ThrowError(static_cast<ani_error>(error));
}

IntelligentSceneError ReadErrorMessage(int code)
{
    for (auto it = g_errorMap.begin(); it != g_errorMap.end(); it++) {
        if (it->first == code) {
            return {.errorCode = code, .message = it->second };
        }
    }
    return {.errorCode = ERROR_INTERNAL_ERROR, .message = ERROR_INTERNAL_MSG };
}

ani_object WrapError(ani_env *env, const std::string &msg)
{
    if (env == nullptr) {
        INTELLIGENTSCENE_LOG_ERROR("null env");
        return nullptr;
    }
    ani_status status = ANI_ERROR;
    ani_string aniMsg = nullptr;
    if ((status = env->String_NewUTF8(msg.c_str(), msg.size(), &aniMsg)) != ANI_OK) {
        INTELLIGENTSCENE_LOG_ERROR("String_NewUTF8 failed %{public}d", status);
        return nullptr;
    }
    ani_ref undefRef;
    if ((status = env->GetUndefined(&undefRef)) != ANI_OK) {
        INTELLIGENTSCENE_LOG_ERROR("GetUndefined failed %{public}d", status);
        return nullptr;
    }
    ani_class cls = nullptr;
    if ((status = env->FindClass(ERROR_CLASS_NAME, &cls)) != ANI_OK) {
        INTELLIGENTSCENE_LOG_ERROR("FindClass failed %{public}d", status);
        return nullptr;
    }
    ani_method method = nullptr;
    if ((status = env->Class_FindMethod(cls, "<ctor>", "C{std.core.String}C{escompat.ErrorOptions}:", &method)) !=
        ANI_OK) {
        INTELLIGENTSCENE_LOG_ERROR("Class_FindMethod failed %{public}d", status);
        return nullptr;
    }
    ani_object obj = nullptr;
    if ((status = env->Object_New(cls, method, &obj, aniMsg, undefRef)) != ANI_OK) {
        INTELLIGENTSCENE_LOG_ERROR("Object_New failed %{public}d", status);
        return nullptr;
    }
    return obj;
}

ani_object CreateError(ani_env *env, ani_int code, const std::string &msg)
{
    if (env == nullptr) {
        INTELLIGENTSCENE_LOG_ERROR("null env");
        return nullptr;
    }
    ani_status status = ANI_ERROR;
    ani_class cls = nullptr;
    if ((status = env->FindClass(BUSINESS_ERROR_CLASS, &cls)) != ANI_OK) {
        INTELLIGENTSCENE_LOG_ERROR("FindClass failed %{public}d", status);
        return nullptr;
    }
    ani_method method = nullptr;
    if ((status = env->Class_FindMethod(cls, "<ctor>", "iC{escompat.Error}:", &method)) != ANI_OK) {
        INTELLIGENTSCENE_LOG_ERROR("Class_FindMethod failed %{public}d", status);
        return nullptr;
    }
    ani_object error = WrapError(env, msg);
    if (error == nullptr) {
        INTELLIGENTSCENE_LOG_ERROR("error null");
        return nullptr;
    }
    ani_object obj = nullptr;
    if ((status = env->Object_New(cls, method, &obj, code, error)) != ANI_OK) {
        INTELLIGENTSCENE_LOG_ERROR("Object_New failed %{public}d", status);
        return nullptr;
    }
    return obj;
}
}
}