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

#ifndef ANI_SETTINGS_H
#define ANI_SETTINGS_H

#include <vector>
#include <ani.h>
#include "uri.h"
#include "data_ability_helper.h"
#include "data_ability_predicates.h"
#include "datashare_helper.h"
#include "datashare_predicates.h"

#define ARGS_ONE 1
#define ARGS_TWO 2
#define ARGS_THREE 3
#define ARGS_FOUR 4
#define ARGS_FIVE 5

#define PARAM0 0
#define PARAM1 1
#define PARAM2 2
#define PARAM3 3
#define PARAM4 4

enum CallType {
    INVALID_CALL,
    STAGE_SYNC,
    STAGE_CALLBACK,
    STAGE_CALLBACK_SPECIFIC,
    STAGE_PROMISE,
    STAGE_PROMISE_SPECIFIC,
    FA_SYNC,
    FA_CALLBACK,
    FA_PROMISE
};

struct AsyncCallbackInfo {
    ani_env *env;
    ani_ref callbackRef;
    std::shared_ptr<OHOS::AppExecFwk::DataAbilityHelper> dataAbilityHelper;
    std::string key;
    std::string value;
    std::string uri;
    CallType callType;
    std::string tableName;
    int status;
    std::shared_ptr<OHOS::DataShare::DataShareHelper> dataShareHelper = nullptr;
    bool useSilent;
    ani_vm *vm;
};

namespace OHOS {
namespace Settings {
void ThrowExistingError(ani_env *env, int errorCode, std::string errorMessage);
bool ThrowError(ani_env *env, int status);
ani_ref wrap_void_to_js(ani_env *env);
ani_string wrap_string_to_js(ani_env *env, const std::string &value);
std::string unwrap_string_from_js(ani_env *env, ani_string param);
ani_string ani_get_value(ani_env *env, ani_object context, ani_string name, ani_string domainName);
ani_string ani_get_value_ext(ani_env *env, ani_object context, ani_string name, ani_string domainName);
ani_boolean ani_set_value(ani_env *env, ani_object context, ani_string name, ani_string value, ani_string domainName);
ani_boolean ani_set_value_ext(
    ani_env *env, ani_object context, ani_string name, ani_string value, ani_string domainName);
void ani_enable_airplane_mode(ani_env *env, ani_boolean enable);
ani_boolean ani_can_show_floating(ani_env *env);
ani_string ani_get_value_sync(
    ani_env *env, ani_object context, ani_string key, ani_string defaultValue, ani_string domainName);
std::string GetStageUriStr(std::string tableName, std::string idStr, std::string keyStr);
std::string GetProxyUriStr(std::string tableName, std::string idStr);
bool IsTableNameInvalid(std::string tableName);
std::shared_ptr<DataShare::DataShareHelper> getDataShareHelper(
    ani_env *env, const ani_object context, std::string tableName = "global", AsyncCallbackInfo *data = nullptr);
ani_string ani_get_value_sync_ext(
    ani_env *env, ani_object context, ani_string key, ani_string defaultValue, ani_string domainName);
ani_boolean ani_set_value_sync(
    ani_env *env, ani_object context, ani_string key, ani_string value, ani_string domainName);
ani_boolean ani_set_value_sync_ext(
    ani_env *env, ani_object context, ani_string key, ani_string value, ani_string domainName);
void SetValueExecuteExt(ani_env *env, void *data, const std::string setValue);
ani_string ani_get_uri_sync(ani_env *env, ani_string key);
ani_boolean ani_register_key_observer(
    ani_env *env, ani_object context, ani_string name, ani_string domainName, ani_object observer);
ani_boolean ani_unregister_key_observer(ani_env *env, ani_object context, ani_string name, ani_string domainName);
}  // namespace Settings
}  // namespace OHOS
#endif  //  ANI_SETTINGS_H