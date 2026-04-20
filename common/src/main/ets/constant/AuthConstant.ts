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
 * 安全认证常量定义
 */
export class AuthConstant {
  // challenge值
  public static readonly CHALLENGE: string = 'challenge';

  // session开启状态
  public static readonly HAS_SESSION: string = 'hasSession';

  // isShowDialog值,是否拉起弹框
  public static readonly isDialogShowInSubWindow: string = 'isDialogShowInSubWindow';

  // 来源类型值
  public static readonly SOURCE_FROM: string = 'from';

  // 认证成功
  public static readonly CREATE_PSD_SUCCESS: number = 0;

  //认证失败
  public static readonly CREATE_PSD_FAIL: number = -1;

  // 设置密码界面点右上角X关闭
  public static readonly CREATE_PSD_CLOSE: number = -2;

  // UIExtension来源类型
  public static readonly FROM_UIEXTENSION: string = 'UIExtension';

  // token值
  public static readonly TOKEN: string = 'token';

  // 用户id
  public static readonly USER_ID: string = 'userId';

  // 创建指纹成功
  public static readonly CREATE_FINGERPRINT_SUCCESS: number = 0;

  //创建指纹失败
  public static readonly CREATE_FINGERPRINT_FAIL: number = -1;
}