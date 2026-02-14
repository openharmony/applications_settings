/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
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

#include "napi/native_api.h"
#include <cstring>
#include <sys/utsname.h>
#include <thread>
#include "hilog/log.h"

#undef LOG_DOMAIN
#undef LOG_TAG
#define LOG_DOMAIN 0x0500
#define LOG_TAG "Native"

const static int64_t KERNEL_RELEASE = 1;
const static int64_t KERNEL_SYS_NAME = 2;
const static int64_t KERNEL_NODE_NAME = 3;
const static int64_t KERNEL_VERSION = 4;

static napi_value GetKernelInfo(napi_env env, napi_callback_info info)
{
    struct utsname unameResult = {0};
    uname(&unameResult);
    
    size_t argc = 1;
    napi_value args[1] = {nullptr};

    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    
    int64_t param;
    napi_get_value_int64(env, args[0], &param);
    
    napi_value kernel_info;
    switch (param) {
        case KERNEL_RELEASE:
            napi_create_string_utf8(env, unameResult.release, strlen(unameResult.release), &kernel_info);
            break;
        case KERNEL_SYS_NAME:
            napi_create_string_utf8(env, unameResult.sysname, strlen(unameResult.sysname), &kernel_info);
            break;
        case KERNEL_NODE_NAME:
            napi_create_string_utf8(env, unameResult.nodename, strlen(unameResult.nodename), &kernel_info);
            break;
        case KERNEL_VERSION:
            napi_create_string_utf8(env, unameResult.version, strlen(unameResult.version), &kernel_info);
            break;
        default:
            napi_create_string_utf8(env, unameResult.sysname, strlen(unameResult.sysname), &kernel_info);
            break;
    }
    return kernel_info;
}

static napi_value NAPI_sleep(napi_env env, napi_callback_info info)
{
    size_t argc = 1;
    napi_value args[1] = {nullptr};

    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    if (argc != 1) {
        OH_LOG_ERROR(LOG_APP, "NAPI_sleep invalid param.");
        return nullptr;
    }
    
    int64_t time = 0;
    napi_get_value_int64(env, args[0], &time);
    OH_LOG_INFO(LOG_APP, "NAPI_sleep %{public}d ms begin.", time);
    std::this_thread::sleep_for(std::chrono::milliseconds(time));
    OH_LOG_INFO(LOG_APP, "NAPI_sleep %{public}d ms over.", time);
    return nullptr;
}

EXTERN_C_START
static napi_value Init(napi_env env, napi_value exports)
{
    napi_property_descriptor desc[] = {
        { "getKernelInfo", nullptr, GetKernelInfo, nullptr, nullptr, nullptr, napi_default, nullptr },
        { "sleep", nullptr, NAPI_sleep, nullptr, nullptr, nullptr, napi_default, nullptr }
    };
    napi_define_properties(env, exports, sizeof(desc) / sizeof(desc[0]), desc);
    return exports;
}
EXTERN_C_END

static napi_module kernelModule = {
    .nm_version = 1,
    .nm_flags = 0,
    .nm_filename = nullptr,
    .nm_register_func = Init,
    .nm_modname = "native",
    .nm_priv = ((void*)0),
    .reserved = { 0 },
};

extern "C" __attribute__((constructor)) void RegisterNativeModule(void)
{
    napi_module_register(&kernelModule);
}
