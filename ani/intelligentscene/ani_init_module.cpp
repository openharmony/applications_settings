/**
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

#include <array>
#include <ani.h>
#include "ani_intelligent_scene_log.h"
#include "ani_nodisturb.h"

static ani_boolean BindMethods(ani_env *env)
{
    using namespace OHOS::IntelligentScene;
    const char *spaceName = "@ohos.intelligentscene.intelligentscene";
    ani_namespace spc;
    ani_status ret = env->FindNamespace(spaceName, &spc);
    if (ret != ANI_OK) {
        INTELLIGENTSCENE_LOG_ERROR("Not found %{public}s, ret = %{public}d", spaceName, ret);
        return ANI_NOT_FOUND;
    }
    std::array methods = {
        ani_native_function{"isDoNotDisturbEnabled_inner",
            nullptr, reinterpret_cast<void *>(ani_is_do_not_disturb_enabled)},
        ani_native_function{"isNotifyAllowedInDoNotDisturb_inner",
            nullptr, reinterpret_cast<void *>(ani_is_notify_allowed)},
    };
    if (env->Namespace_BindNativeFunctions(spc, methods.data(), methods.size()) != ANI_OK) {
        INTELLIGENTSCENE_LOG_ERROR("Cannot bind native methods to %{public}s ", spaceName);
        return ANI_ERROR;
    }
    return ANI_OK;
}

extern "C" {
ANI_EXPORT ani_status ANI_Constructor(ani_vm *vm, uint32_t *result)
{
    using namespace OHOS::IntelligentScene;
    INTELLIGENTSCENE_LOG_INFO("Call");
    if (vm == nullptr || result == nullptr) {
        INTELLIGENTSCENE_LOG_ERROR("vm or result is nullptr");
        return ANI_ERROR;
    }

    ani_env *env = nullptr;
    if (vm->GetEnv(ANI_VERSION_1, &env) != ANI_OK) {
        INTELLIGENTSCENE_LOG_ERROR("Unsupported ANI_VERSION_1");
        return ANI_OUT_OF_REF;
    }

    if (env == nullptr) {
        INTELLIGENTSCENE_LOG_ERROR("env is nullptr");
        return ANI_ERROR;
    }

    if (BindMethods(env) != ANI_OK) {
        return ANI_ERROR;
    }

    *result = ANI_VERSION_1;
    INTELLIGENTSCENE_LOG_INFO("End");
    return ANI_OK;
}
}