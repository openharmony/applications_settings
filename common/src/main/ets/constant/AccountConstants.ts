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


/**
 * 多用户相关常量
 */
export class AccountConstants {

  public static INVALID_PRIVATE_SPACE_USER_ID: number = -1;

  public static INVALID_USER_ID: number = -2;

  public static SILENT_AUTH: number = 2;

  public static MAIN_USER: number = 100;

  public static PASSWORD_PROTECT_KEY: string = 'privacy_user_pwd_protect';

  public static ALREADY_SET_PRIVATE_PASSWORD_PROTECT: string = '1';

  public static NOT_SET_PRIVATE_PASSWORD_PROTECT: string = '-1';
}