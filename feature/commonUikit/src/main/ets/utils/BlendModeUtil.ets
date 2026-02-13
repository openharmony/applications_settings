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

import uiAppearance from '@ohos.uiAppearance';
import uiEffect from '@ohos.graphics.uiEffect';
/* instrument ignore file */
const TAG = 'BlendModeUtil';
const COLOR_MODE_DARK: number = 0;

/**
 * BlendModeUtil class
 */
export default class BlendModeUtil {
  /**
   * 前景文字和图标浅色模式参数
   */
  public static blender: uiEffect.BrightnessBlender = uiEffect.createBrightnessBlender({
    cubicRate: 0,
    quadraticRate: 0,
    linearRate: 0.4,
    degree: -30 / 255,
    saturation: 1.8,
    positiveCoefficient: [1.9, 3.8, 1.3],
    negativeCoefficient: [0.5, 0.67, 1.3],
    fraction: 0
  });
  /**
   * 控制中心参数
   */
  public static blenderCenter: uiEffect.BrightnessBlender = uiEffect.createBrightnessBlender({
    cubicRate: 0,
    quadraticRate: 0,
    linearRate: 0.4,
    degree: -0.098,
    saturation: 1.5,
    positiveCoefficient: [1.9, 3.8, 1.3],
    negativeCoefficient: [0.5, 0.67, 1.3],
    fraction: 0
  });

  public static blenderCenterDark: uiEffect.BrightnessBlender = uiEffect.createBrightnessBlender({
    cubicRate: 0,
    quadraticRate: 0,
    linearRate: 0.1239,
    degree: 229.5 / 255,
    saturation: 2,
    positiveCoefficient: [1.6, 3, 1.5],
    negativeCoefficient: [1.2, 1.2, 1],
    fraction: 0.6
  });

  /**
   * 根据主题模式来获取前景模式
   * @returns
   */
  public static getCenterBlender(): uiEffect.BrightnessBlender {
    if (uiAppearance.getDarkMode() === COLOR_MODE_DARK) {
      return BlendModeUtil.blenderCenterDark;
    }
    return BlendModeUtil.blenderCenter;
  }

  /**
   * 前景文字和图标深色模式参数
   */
  public static blenderDark: uiEffect.BrightnessBlender = uiEffect.createBrightnessBlender({
    cubicRate: 0,
    quadraticRate: 0,
    linearRate: 1,
    degree: 133 / 255,
    saturation: 1.1,
    positiveCoefficient: [1, 1.2, 1],
    negativeCoefficient: [0.5, 1, 0.5],
    fraction: 0
  });
  /**
   * 列表辅助文字浅色模式参数
   */
  public static blenderTertiary: uiEffect.BrightnessBlender = uiEffect.createBrightnessBlender({
    cubicRate: 0,
    quadraticRate: 0,
    linearRate: 0.6539,
    degree: -0.1441,
    saturation: 1.5,
    positiveCoefficient: [1.3, 3.2, 1],
    negativeCoefficient: [0.25, 0.5, 0.67],
    fraction: 0
  });
  /**
   * 列表辅助文字深色模式参数
   */
  public static blenderTertiaryDark: uiEffect.BrightnessBlender = uiEffect.createBrightnessBlender({
    cubicRate: 0,
    quadraticRate: 0,
    linearRate: 0.9894,
    degree: 0.4005,
    saturation: 1.3,
    positiveCoefficient: [-0.1, 0.2, 0.2],
    negativeCoefficient: [1.2, 0.2, 2],
    fraction: 0
  });

  /**
   * 获取前景文字和图标参数
   */
  public static getBlender(): uiEffect.BrightnessBlender {
    if (uiAppearance.getDarkMode() === COLOR_MODE_DARK) {
      return BlendModeUtil.blenderDark;
    }
    return BlendModeUtil.blender;
  }

  /**
   * 获取列表辅助文字参数
   */
  public static getBlenderTertiary(): uiEffect.BrightnessBlender {
    if (uiAppearance.getDarkMode() === COLOR_MODE_DARK) {
      return BlendModeUtil.blenderTertiaryDark;
    }
    return BlendModeUtil.blenderTertiary;
  }
}