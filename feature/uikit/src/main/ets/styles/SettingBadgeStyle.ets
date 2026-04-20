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

import { CommonBadgeStyle } from '@ohos/settings.common/src/main/ets/core/model/menu/ComponetStyle';

/**
 * 角标样式
 *
 * @since 2024-5-22
 */
export class SettingBadgeStyle extends CommonBadgeStyle {
  public badgeStyle: BadgeStyle = {
    badgeSize: '16vp',
    color: $r('sys.color.ohos_id_color_text_primary_contrary'),
  };

  public margin: Margin = {
    right: '0vp'
  }

  public padding: Padding = {
    right: '0vp'
  }

  private readonly marginRightOneDigit: string = '16vp';
  private readonly marginRightTwoDigits: string = '23.5vp';
  private readonly marginRightThreeDigits: string = '29.5vp';
  private readonly paddingRightOneDigit: string = '24vp';
  private readonly paddingRightTwoDigits: string = '31.5vp';
  private readonly paddingRightThreeDigits: string = '37.5vp';

  public setMarginRight: (badgeCount: number) => void = (badgeCount: number) => {
    let marginRight: string = badgeCount > 9 ?
      (badgeCount > 99 ? this.marginRightThreeDigits : this.marginRightTwoDigits) : this.marginRightOneDigit;
    this.margin.right = marginRight;
  };

  public setPaddingRight: (badgeCount: number) => void = (badgeCount: number) => {
    let paddingRight: string = badgeCount > 9 ?
      (badgeCount > 99 ? this.paddingRightThreeDigits : this.paddingRightTwoDigits) : this.paddingRightOneDigit;
    this.padding.right = paddingRight;
  };
}