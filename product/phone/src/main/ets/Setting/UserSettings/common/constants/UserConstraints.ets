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

/* instrument ignore file */
export const USER_FONT_FAMILY: string = 'HarmonyHeiTi';
export const OS_ACCOUNT_CONFIG_PATH: string = 'etc/os_account/os_account_config.json';

const SPECIAL_CHAR: string = `\/:*?"<>|.`;
const CHINESE_CHAR: string = `\u4e00-\u9fa5`;
const CHINESE_SPECIAL_CHAR: string = `！￥……（）——、【】‘’“”；：《》，。？`;


// 用户表单项输入限制
export class UserConstraints {
  public static readonly USER_MAX_AMOUNT: number = 5;
  public static readonly OS_ACCOUNT_DEFAULT_AMOUNT: number = 999; // 账号子系统默认最大用户数
  public static readonly USER_NAME_MAX_LEN: number = 60;
  public static readonly ACCOUNT_NAME_MAX_LEN: number = 60;
  public static readonly PWD_MIN_LEN: number = 6;
  public static readonly PWD_MAX_LEN: number = 32;
  // 不允许出现特殊字符< > | : " * ? / \且不允许独立出现. ..
  public static readonly ACCOUNT_NAME_REG: RegExp = new RegExp(`^(?!\\.\\.?$)(?!.*[<>|:"*?/\\\\]).*$`);
  // 删除特殊字符< > | : " * ? / \
  public static readonly ACCOUNT_NAME_REPLACE_REG: RegExp = new RegExp(`[<>|:"*?/\\\\]+`, 'g');
  // 英文特殊字符
  public static readonly SPECIAL_CHAR: string = SPECIAL_CHAR;
  // 中文字符
  public static readonly CHINESE_CHAR: string = CHINESE_CHAR;
  // 中文特殊字符
  public static readonly CHINESE_SPECIAL_CHAR: string = CHINESE_SPECIAL_CHAR;
}