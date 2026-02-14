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
 * 密码相关常量
 */
export class PasswordConstant {
  // 4位数密码长度
  public static readonly FOUR_PIN_PASSWORD_TYPE_STR_LENGTH: string = '4';

  // 4位数密码长度
  public static readonly FOUR_PIN_LENGTH: number = 4;

  // 密码类型
  public static readonly PIN_AUTH_SUB_TYPE: string = 'pinAuthSubType';

  // 6位数密码长度
  public static readonly SIX_PIN_LENGTH: number = 6;

  // 数字密码、混合密码最大长度
  public static readonly MIXED_OR_NUMBER_PSD_MAX_LENGTH: number = 32;
}