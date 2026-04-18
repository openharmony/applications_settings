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
import pointer from '@ohos.multimodalInput.pointer';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import { MouseAppStorageName, MouseConstants, MousePointColor, MousePointColorIndex } from './utils/Constants';
import { Utils } from './utils/Utils';
import { HiSysMouseEventGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';

const CHANGE_POINTER_COLOR_FAULT = 'report change pointer color fault.';

export class MouseSettingsManager {
  private static mouseSettingsManager: MouseSettingsManager | undefined = undefined;
  private tag: string = 'MouseSettingsManager: ';
  private isEnableMagicCursor: boolean = Utils.isEnableMagicCursor();
  private mousePointerSpeed: number = MouseAppStorageName.MOUSE_POINTER_SPEED_DEFAULT_VALUE;
  private mousePointSize: number = MouseAppStorageName.MOUSE_POINT_SIZE_DEFAULT_VALUE;
  private mousePointerStyle: pointer.PointerStyle = this.isEnableMagicCursor ? pointer.PointerStyle.CURSOR_CIRCLE
    : pointer.PointerStyle.DEFAULT;
  private currentColorIndex: number = 0;

  public static getInstance(): MouseSettingsManager {
    if (MouseSettingsManager.mouseSettingsManager) {
      return MouseSettingsManager.mouseSettingsManager;
    }
    MouseSettingsManager.mouseSettingsManager = new MouseSettingsManager();
    return MouseSettingsManager.mouseSettingsManager;
  }

  public getColorFromIndex(index: number): number {
    let colorData: number = MousePointColor.MOUSE_POINT_BLACK;
    switch (index) {
      case MousePointColorIndex.MOUSE_POINT_RED_INDEX:
        colorData = MousePointColor.MOUSE_POINT_RED;
        break;
      case MousePointColorIndex.MOUSE_POINT_YELLOW_INDEX:
        colorData = MousePointColor.MOUSE_POINT_YELLOW;
        break;
      case MousePointColorIndex.MOUSE_POINT_GREEN_INDEX:
        colorData = MousePointColor.MOUSE_POINT_GREEN;
        break;
      case MousePointColorIndex.MOUSE_POINT_CYAN_INDEX:
        colorData = MousePointColor.MOUSE_POINT_CYAN;
        break;
      case MousePointColorIndex.MOUSE_POINT_BLUE_INDEX:
        colorData = MousePointColor.MOUSE_POINT_BLUE;
        break;
      case MousePointColorIndex.MOUSE_POINT_PURPLE_INDEX:
        colorData = MousePointColor.MOUSE_POINT_PURPLE;
        break;
      case MousePointColorIndex.MOUSE_POINT_WHITE_INDEX:
        colorData = MousePointColor.MOUSE_POINT_WHITE;
        break;
      case MousePointColorIndex.MOUSE_POINT_BLACK_INDEX:
        colorData = MousePointColor.MOUSE_POINT_BLACK;
        break;
      default:
        colorData = MousePointColor.MOUSE_POINT_BLACK;
        break;
    }
    LogUtil.info(`${this.tag}, getColorFromIndex, index = : ${index}, Color = : ${colorData}`);
    return colorData;
  }

  public getIndexFromColor(color: number): number {
    let index: number = MousePointColorIndex.MOUSE_POINT_BLACK_INDEX;
    switch (color) {
      case MousePointColor.MOUSE_POINT_RED:
        index = MousePointColorIndex.MOUSE_POINT_RED_INDEX;
        break;
      case MousePointColor.MOUSE_POINT_YELLOW:
        index = MousePointColorIndex.MOUSE_POINT_YELLOW_INDEX;
        break;
      case MousePointColor.MOUSE_POINT_GREEN:
        index = MousePointColorIndex.MOUSE_POINT_GREEN_INDEX;
        break;
      case MousePointColor.MOUSE_POINT_CYAN:
        index = MousePointColorIndex.MOUSE_POINT_CYAN_INDEX;
        break;
      case MousePointColor.MOUSE_POINT_BLUE:
        index = MousePointColorIndex.MOUSE_POINT_BLUE_INDEX;
        break;
      case MousePointColor.MOUSE_POINT_PURPLE:
        index = MousePointColorIndex.MOUSE_POINT_PURPLE_INDEX;
        break;
      case MousePointColor.MOUSE_POINT_WHITE:
        index = MousePointColorIndex.MOUSE_POINT_WHITE_INDEX;
        break;
      case MousePointColor.MOUSE_POINT_BLACK:
        index = MousePointColorIndex.MOUSE_POINT_BLACK_INDEX;
        break;
      default:
        index = MousePointColorIndex.MOUSE_POINT_BLACK_INDEX;
        break;
    }
    return index;
  }

  public setMousePointColor(index: number): void {
    let colorData: number = this.getColorFromIndex(index);
    try {
      LogUtil.info(`${this.tag}, Set pointer Color success. color ${colorData}`);
      pointer.setPointerColor(colorData);
      HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysMouseEventGroup.MOUSE_CURRENT_COLOR, index.toString());
    } catch {
      LogUtil.error(`${this.tag}, Set pointer Color failed`);
      HiSysEventUtil.reportDefaultFaultEvent(HiSysMouseEventGroup.MOUSE_CURRENT_COLOR_FAULT,
        CHANGE_POINTER_COLOR_FAULT, colorData.toString());
    }
  }

  public getMousePointColor(): number {
    try {
      let color: number = pointer.getPointerColorSync();
      LogUtil.info(`${this.tag}, get pointer color: ${color}`);
      this.currentColorIndex = this.getIndexFromColor(color);
      LogUtil.info(`${this.tag}, get pointer color index: ${this.currentColorIndex}`);
    } catch {
      LogUtil.error(`${this.tag}, get pointer color error.`);
    }
    return this.currentColorIndex;
  }

  public setPointerSpeed(value: number): void {
    try {
      pointer.setPointerSpeedSync(value);
      this.mousePointerSpeed = value;
      HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysMouseEventGroup.MOUSE_POINT_SPEED, value.toString());
      LogUtil.info(`${this.tag}, set pointer speed success: ${this.mousePointerSpeed}`);
    } catch {
      LogUtil.error(`${this.tag}, set pointer speed error.`);
    }
  }

  public getPointerSpeed(): number {
    try {
      this.mousePointerSpeed = pointer.getPointerSpeedSync();
      LogUtil.info(`${this.tag}, get pointer speed: ${this.mousePointerSpeed}`);
    } catch {
      LogUtil.error(`${this.tag}, get pointer speed error.`);
    }
    return this.mousePointerSpeed;
  }

  public setMousePointSize(pointSize: number): void {
    try {
      pointer.setPointerSizeSync(pointSize);
      this.mousePointSize = pointSize;
      HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysMouseEventGroup.MOUSE_POINT_SIZE, pointSize.toString());
      LogUtil.info(`${this.tag}, set pointer size success: ${this.mousePointerSpeed}`);
    } catch {
      LogUtil.error(`${this.tag}, set pointer size error.`);
    }
  }

  public getMousePointSize(): number {
    try {
      this.mousePointSize = pointer.getPointerSizeSync();
      LogUtil.info(`${this.tag}, get pointer size: ${this.mousePointSize}`);
    } catch {
      LogUtil.error(`${this.tag}, get pointer size error.`);
    }
    return this.mousePointSize;
  }

  public setInputMouseStyle(isCircleCursor: boolean): void {
    let pointerStyle: pointer.PointerStyle = isCircleCursor ? pointer.PointerStyle.CURSOR_CIRCLE
      : pointer.PointerStyle.DEFAULT;
    let windowId: number = -1;
    try {
      pointer.setPointerStyleSync(windowId, pointerStyle);
      this.mousePointerStyle = pointerStyle;
      HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysMouseEventGroup.MOUSE_STYLE_CURSOR, isCircleCursor.toString());
      LogUtil.info(`${this.tag}, set pointer style success: ${this.mousePointerSpeed}`);
    } catch {
      LogUtil.error(`${this.tag}, set pointer style error.`);
    }
  }

  public setMouseStyle(isCircleCursor: boolean): void {
    LogUtil.info(`${this.tag}, set mouse pointer isCircleCursor: ${isCircleCursor}`);
    let pointerStyle: pointer.PointerStyle = isCircleCursor ? pointer.PointerStyle.CURSOR_CIRCLE
      : pointer.PointerStyle.DEFAULT;
    if (!this.isEnableMagicCursor) {
      this.setInputMouseStyle(isCircleCursor);
      SettingsDataUtils.setSettingsData(MouseConstants.MOUSE_MAGIC_CURSOR, 'false');
    } else {
      this.mousePointerStyle = pointerStyle;
      SettingsDataUtils.setSettingsData(MouseConstants.MOUSE_MAGIC_CURSOR, isCircleCursor ? 'true' : 'false');
      HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysMouseEventGroup.MOUSE_STYLE_CURSOR, isCircleCursor.toString());
    }
  }

  public isCircleStyle(): boolean {
    if (!this.isEnableMagicCursor) {
      try {
        let windowId: number = -1;
        this.mousePointerStyle = pointer.getPointerStyleSync(windowId);
        LogUtil.info(`${this.tag}, get mouse pointer style: ${this.mousePointerStyle}`);
      } catch {
        LogUtil.error(`${this.tag}, get pointer style failed, error.`);
      }
    } else {
      let isCursor: string = SettingsDataUtils.getSettingsData(MouseConstants.MOUSE_MAGIC_CURSOR, 'false');
      this.mousePointerStyle = pointer.PointerStyle.DEFAULT;
      if (isCursor === 'true') {
        this.mousePointerStyle = pointer.PointerStyle.CURSOR_CIRCLE;
      }
      LogUtil.info(`${this.tag}, get mouse pointer style: ${this.mousePointerStyle}`);
    }
    return this.mousePointerStyle === pointer.PointerStyle.CURSOR_CIRCLE;
  }

  public refreshPointerStyle(): void {
    if (this.isEnableMagicCursor) {
      try {
        let windowId: number = -1;
        let style: pointer.PointerStyle = pointer.getPointerStyleSync(windowId);
        LogUtil.info(`${this.tag}, getPointerStyle: ${style}`);
        if (style === pointer.PointerStyle.CURSOR_CIRCLE) {
          this.setInputMouseStyle(false);
          LogUtil.info(`${this.tag}, refreshPointerStyle`);
        }
      } catch {
        LogUtil.error(`${this.tag}, refresh pointer style error, set style to default.`);
      }
    } else {
      let isMagicCursor: string = SettingsDataUtils.getSettingsData(MouseConstants.MOUSE_MAGIC_CURSOR, 'false');
      LogUtil.info(`${this.tag}, getMouseStyle isMagicCursor : ${isMagicCursor}`);
      if (isMagicCursor === 'true') {
        SettingsDataUtils.setSettingsData(MouseConstants.MOUSE_MAGIC_CURSOR, 'false');
      }
    }
  }
}