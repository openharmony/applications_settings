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

import { hdsMaterial } from '@hms.hds.hdsMaterial';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';

/* instrument ignore file */
const TAG: string = 'AccessibilityCardMaterialManager: ';

/**
 * 辅助阅读新材质属性管理类
 */
export class AccessibilityCardMaterialManager implements AttributeModifier<ColumnAttribute> {
  // 设备是否支持新材质
  private isNewMaterialSupported: boolean = false;

  constructor() {
    try {
      this.isNewMaterialSupported = hdsMaterial.getSystemMaterialTypes().length > 0;
    } catch (error) {
      LogUtil.error(`${TAG} getSystemMaterialTypes failed. Code: ${error?.code}, message: ${error?.message}`);
    }
  }

  applyNormalAttribute(instance: ColumnAttribute): void {
    LogUtil.info(`${TAG} device support new materials: ${this.isNewMaterialSupported}`);
    if (this.isNewMaterialSupported) {
      instance.systemMaterial(new hdsMaterial.Material({
        backgroundMaterial: {
          type: hdsMaterial.MaterialType.IMMERSIVE,
          scenario: hdsMaterial.ScenarioType.GENERAL,
          level: hdsMaterial.MaterialLevel.ADAPTIVE,
          darkMode: hdsMaterial.DarkMode.ADAPTIVE
        }
      }))
    } else {
      instance.borderColor($r('app.color.card_border_color'))
        .borderWidth(1)
        .borderStyle(BorderStyle.Solid)
        .backdropBlur(150)
        .shadow({
          radius: $r('app.float.width_40'),
          offsetX: 0,
          offsetY: 0,
          color: $r('app.color.card_shadow_color'),
        })
        .backgroundColor($r('app.color.card_bg_color'))
    }
  }
}


/**
 * 辅助阅读返回按钮新材质属性管理类
 */
export class BackButtonMaterialModifierManager implements AttributeModifier<ButtonAttribute> {
  // 设备是否支持新材质
  private isNewMaterialSupported: boolean = false;
  private backgroundColor: ResourceColor;

  constructor(backgroundColor: ResourceColor) {
    this.backgroundColor = backgroundColor;
    try {
      this.isNewMaterialSupported = hdsMaterial.getSystemMaterialTypes().length > 0;
    } catch (error) {
      LogUtil.error(`${TAG} getSystemMaterialTypes failed. Code: ${error?.code}, message: ${error?.message}`);
    }
  }

  applyNormalAttribute(instance: ButtonAttribute): void {
    if (this.isNewMaterialSupported) {
      instance.backgroundColor(Color.Transparent)
        .systemMaterial(new hdsMaterial.Material({
          backgroundMaterial: {
            type: hdsMaterial.MaterialType.IMMERSIVE,
            scenario: hdsMaterial.ScenarioType.ULTRA_THIN,
            level: hdsMaterial.MaterialLevel.EXQUISITE,
            eventAnimation: {
              eventMask: hdsMaterial.MaterialEvent.TOUCH,
              lightOptions: {
                lightColor: $r('app.color.button_pressed_color_light'),
                darkColor: $r('app.color.button_pressed_color_dark')
              }
            }
          }
        }))
        .shadow({
          radius: $r('app.float.border_radius_20'),
          offsetX: $r('app.float.margin_0'),
          offsetY: $r('app.float.margin_0'),
          color: $r('app.color.card_shadow_color'),
        })
    } else {
      instance.backgroundColor(this.backgroundColor)
    }
  }
}