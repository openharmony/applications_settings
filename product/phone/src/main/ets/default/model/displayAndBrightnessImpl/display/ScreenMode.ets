//@ts-nocheck
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
import ScreenManager from '@ohos.screen';

/**
 * Screen Mode setting
 */
export class ScreenModeModel extends BaseModel{
  private supportedScreenModes;
  private sysScreenMode;
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
    ScreenManager.getAllScreen().then((screens) => {
      LogUtil.info(`${this.TAG} sysScreenMode AllScreen: ${JSON.stringify(screens)}.`)
      this.supportedScreenModes = screens[0].supportedModeInfo;
      this.sysScreenMode = screens[0].supportedModeInfo[screens[0].activeModeIndex]
      LogUtil.info(`${this.TAG} sysScreenMode: ${JSON.stringify(this.sysScreenMode)}.`)
    }, (err) => {
      LogUtil.info(`${this.TAG} setScreenActiveMode error: ${JSON.stringify(err)}.`)
    })
    return;
  }

  /**
   * get supported screenModes
   */
  @Log
  public getSupportedScreenModes(){
    return this.supportedScreenModes;
  }

  /**
   * get sysScreenMode
   */
  @Log
  public getSysScreenMode(){
    return this.sysScreenMode;
  }


  /**
   * Set sysScreenMode
   */
  @Log
  public setSysScreenMode(index:number): void{
    ScreenManager.getAllScreen().then((screens) => {
      screens[0].setScreenActiveMode(index).then((ret) => {
        if (ret) {
          LogUtil.info(`${this.TAG} setScreenActiveMode ret: ${JSON.stringify(ret)}.`)
        }
      })
    }, (err) => {
      LogUtil.info(`${this.TAG} setScreenActiveMode error: ${JSON.stringify(err)}.`)
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
    return '';
  }

  /**
   * Register observer
   */
  @Log
  public registerObserver(){
    LogUtil.info(`${this.TAG} registerObserver.`);
    ScreenManager.on('screenChangeEvent', (ScreenEvent) => {
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
    ScreenManager.off('screenChangeEvent', (ScreenEvent) => {
      LogUtil.info(`${this.TAG} unregisterObserver success.`);
    })
    return;
  }
}