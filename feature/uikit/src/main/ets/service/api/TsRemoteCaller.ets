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

import { common } from '@kit.AbilityKit';
import { RemoteCaller } from './RemoteCaller';
/* instrument ignore file */
export class TsRemoteCaller {
  private readonly remoteCaller: RemoteCaller;

  constructor(context: common.UIAbilityContext | common.ServiceExtensionContext) {
    this.remoteCaller = new RemoteCaller(context, {
      bundleName: 'com.ohos.sceneboard',
      abilityName: 'ThemeServiceAbility',
    });
  }

  applyIcons(iconResource: string): Promise<boolean> {
    return this.remoteCaller.request('applyIcons', iconResource);
  }

  applyFont(id: string, ttfFile: string): Promise<number> {
    return this.remoteCaller.request(`applyFontV2`, id, ttfFile, 'preset');
  }

  /*
   * 应用主题图标
   * @param themeDir 主题资源包的根路径
   *
   * @returns 是否应用成功
   */
  activateThemeIcon(themeDir: string): Promise<boolean> {
    return this.remoteCaller.request('activateTheme', themeDir, ThemeOptions.getInstance().enableIcons());
  }

  getFontWeightInfo():Promise<FontWeightInfo> {
    return this.remoteCaller.request('getCurrentFont');
  }
}

export class FontWeightInfo {
  public id: string = '';
  public multiWeight: boolean = true;
}

/**
 * 主题参数
 */
class ThemeOptions {
  public static instance: ThemeOptions;
  public static readonly ENABLE: string = '1';
  public home?: string;
  public lock?: string;
  public aod?: string;
  public icons?: string;
  public skin?: string;
  public fonts?: string;
  public subScreen?: string;
  public fa?: string;
  public contentsSwitch?: string;
  public notify?: string;
  public longTake?: string;

  public enableLongTake(): ThemeOptions {
    this.longTake = ThemeOptions.ENABLE;
    return this;
  }

  public enableHome(): ThemeOptions {
    this.home = ThemeOptions.ENABLE;
    return this;
  }

  public enableFont(): ThemeOptions {
    this.fonts = ThemeOptions.ENABLE;
    return this;
  }

  public enableLock(): ThemeOptions {
    this.lock = ThemeOptions.ENABLE;
    return this;
  }

  public enableAod(): ThemeOptions {
    this.aod = ThemeOptions.ENABLE;
    return this;
  }

  public enableIcons(): ThemeOptions {
    this.icons = ThemeOptions.ENABLE;
    return this;
  }

  public enableSkin(): ThemeOptions {
    this.skin = ThemeOptions.ENABLE;
    return this;
  }

  public enableScbScreen(): ThemeOptions {
    this.subScreen = ThemeOptions.ENABLE;
    return this;
  }

  public enableFa(): ThemeOptions {
    this.fa = ThemeOptions.ENABLE;
    return this;
  }

  public disableContentSwitch(): ThemeOptions {
    this.contentsSwitch = '0';
    return this;
  }

  public disableNotify(): ThemeOptions {
    this.notify = '0';
    return this;
  }

  public static getInstance(): ThemeOptions {
    if (!ThemeOptions.instance) {
      ThemeOptions.instance = new ThemeOptions();
    }
    return ThemeOptions.instance;
  }
}