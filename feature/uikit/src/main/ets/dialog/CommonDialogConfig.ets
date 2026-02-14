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

import { DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';

interface CustomDialogControllerOptionsAlt {
  cancel?: () => void;
  autoCancel?: boolean;
  alignment?: DialogAlignment;
  offset?: Offset;
  customStyle?: boolean;
  gridCount?: number;
  maskColor?: ResourceColor;
  maskRect?: Rectangle;
  openAnimation?: AnimateParam;
  closeAnimation?: AnimateParam;
  showInSubWindow?: boolean;
  backgroundColor?: ResourceColor;
  cornerRadius?: Dimension | BorderRadiuses;
}

/**
 * 通用Dialog配置
 *
 * since 2023-08-14
 */
export class CommonDialogConfig {
  /**
   * 通用Dialog配置项
   *
   * @return 配置项
   */
  static getCommonDialogConfig(): CustomDialogControllerOptionsAlt {
    let config: CustomDialogControllerOptionsAlt = {
      autoCancel: true,
      alignment: DialogAlignment.Center,
      // 手机全部用系统弹框提供的样式 能自动适配 多产品 分屏 小屏场景
      customStyle: DeviceUtil.isDevicePc(),
    };
    return config;
  }
}