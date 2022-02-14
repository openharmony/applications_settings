/**
 * Copyright (c) 2021 Huawei Device Co., Ltd.
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

import BaseModel from '../../../../../../../../../common/utils/src/main/ets/default/model/BaseModel.ets';
import ConfigData from '../../../../../../../../../common/utils/src/main/ets/default/baseUtil/ConfigData.ets';
import LogUtil from '../../../../../../../../../common/utils/src/main/ets/default/baseUtil/LogUtil.ets';
import Log from '../../../../../../../../../common/utils/src/main/ets/default/baseUtil/LogDecorator.ets';
import Screen from "@ohos.screen";

/**
 * Screen Mode setting
 */
export class ScreenModeModel extends BaseModel{
  private supportedScreenModes: Array<Screen.ScreenModeInfo> = [{width:3120, height:1440}];
  private sysScreenMode: Screen.ScreenModeInfo;
  private TAG = ConfigData.TAG + ' ScreenModeModel ';
  private screenLevel: string;

  constructor() {
    super();
    this.init();
  }

  /**
   * init the sysScreenMode
   */
  @Log
  public init(): void{
    this.sysScreenMode = this.supportedScreenModes[0]//Screen.supportedModeInfo[0];//because the array only has one element
    return;
  }

  /**
   * get supported screenModes
   */
  @Log
  public getSupportedScreenModes(): Array<Screen.ScreenModeInfo>{
    return this.supportedScreenModes;
  }

  /**
   * get sysScreenMode
   */
  @Log
  public getSysScreenMode(): Screen.ScreenModeInfo{
    return this.sysScreenMode;
  }

  /**
   * Set sysScreenMode
   */
  @Log
  public setSysScreenMode(index:number): void{
    Screen.setScreenActiveMode(index).then((ret) => {
      LogUtil.info(`${this.TAG} setScreenActiveMode ret: ${JSON.stringify(ret)}.`);
    })
    return;
  }

  /**
   * Set sysScreenMode
   */
  @Log
  public getScreenModeWidth(screenModeInfo): string{
    return screenModeInfo.width.toString();
  }

  /**
   * Set sysScreenMode
   */
  @Log
  public getScreenModeHeight(screenModeInfo): string{
    return screenModeInfo.height.toString();
  }

  /**
   * is SysScreenMode
   */
  @Log
  public isSysScreenMode(screenModeInfo): boolean{
    return JSON.stringify(this.sysScreenMode) === JSON.stringify(screenModeInfo);
  }

  /**
   * get Screen Level
   */
  @Log
  public getScreenLevel(screenModeInfo): string{
    return '高';
  }

  /**
   * Register observer
   */
  @Log
  public registerObserver(){
    LogUtil.info(`${this.TAG} registerObserver.`);
    Screen.on('screenChangeEvent', (ScreenEvent) => {
      this.init();
    })
    LogUtil.info(`${this.TAG} registerObserver success.`);
    return;
  }

  /**
   * Unregister observer
   */
  @Log
  public unregisterObserver() {
    LogUtil.info(`${this.TAG} unregisterObserver.`);
    Screen.off('screenChangeEvent', (ScreenEvent) => {
      LogUtil.info(`${this.TAG} unregisterObserver success.`);
    })
    return;
  }
}