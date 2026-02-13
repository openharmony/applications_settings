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

import { HiSysEventUtil } from '../systemEvent/HiSysEventUtil';
import { LogUtil } from '../utils/LogUtil';

const TAG = 'PerformanceReporter';

export const PERFORMANCE_DOMIN: string = 'PERFORMANCE';

export const PERFORMANCE_CPU: string = 'CPU_SCENE_ENTRY';

export const PERFORMANCE_MEM: string = 'MEM_SCENE_ENTRY';

/**
 * 需要上报内存大数据打点场景定义
 * 最大值: 1 << 30
 */
export enum CurrentMemScene {
  // 空场景
  FREE = 0,

  // 冷启动
  START_SETTINGS = 1 << 0,

  // 应用与元服务
  START_APPLICATION = 1 << 1,

  // 电池
  START_BATTERY = 1 << 2,

  // 存储
  START_STORAGE = 1 << 3,

  // 指纹
  START_FINGER = 1 << 4,
}

/**
 * 需要上报cpu大数据打点场景定义
 */
export enum CurrentCpuScene {
  // 空场景
  FREE = 0,

  // 冷启动
  START_SETTINGS = 1 << 0,
}

/**
 * 性能大数据打点上报参数
 */
export class PerformanceReporterParams {
  public PACKAGE_NAME?: string;
  public SCENE_ID?: number;
  public HAPPEN_TIME?: number;
}

/**
 * 性能大数据打点上报工具
 *
 * @since 2024-07-30
 */
export class PerformanceReporter {
  private currentMemScene: CurrentMemScene = CurrentMemScene.FREE;

  private currentCpuScene: CurrentCpuScene = CurrentCpuScene.FREE;

  /**
   * 获取性能大数据上报单例
   *
   * @return 单例实例
   */
  static getInstance(): PerformanceReporter {
    if (globalThis.PerformanceReporterInstance == null) {
      globalThis.PerformanceReporterInstance = new PerformanceReporter();
    }
    return globalThis.PerformanceReporterInstance;
  }

  /**
   * 上报cpu进入场景大数据打点
   * @param scene
   */
  public reportEnterCpuScene(scene: CurrentCpuScene): void {
    let cpuScene = this.currentCpuScene;
    this.currentCpuScene |= scene;
    this.reportCpuScene('Enter', scene, cpuScene);
  }

  /**
   * 上报cpu退出场景,将场景标识还原
   * @param scene
   */
  public reportExitCpuScene(scene: CurrentCpuScene): void {
    this.currentCpuScene &= ~scene;
  }

  private reportCpuScene(tag:string, calledScene: CurrentCpuScene, olderScene: CurrentCpuScene): void {
    if (olderScene === this.currentCpuScene) {
      if (calledScene !== CurrentCpuScene.FREE) {
        LogUtil.showInfo('%{public}s calledScene:%{public}d, currentScene is not changed.', tag, calledScene);
      }
      return;
    }
    let msg: PerformanceReporterParams = {
      'PACKAGE_NAME': HiSysEventUtil.PACKAGE_NAME,
      'SCENE_ID': this.currentCpuScene,
      'HAPPEN_TIME': new Date().getTime()
    };
    LogUtil.showInfo('%{public}s calledScene:%{public}d, currentCpuScene:%{public}d', tag, calledScene, this.currentCpuScene);
    HiSysEventUtil.reportBehaviorEventEx(PERFORMANCE_CPU, msg, 'reportCpuScene', PERFORMANCE_DOMIN);
  }

  /**
   * 上报内存进入场景大数据打点
   * @param scene
   */
  public reportEnterMemScene(scene: CurrentMemScene): void {
    let olderScene = this.currentMemScene;
    this.currentMemScene |= scene;
    this.reportMemScene('Enter', scene, olderScene);
  }

  /**
   * 上报内存退出场景,将场景标识还原
   * @param scene
   */
  public reportExitMemScene(scene: CurrentMemScene): void {
    this.currentMemScene &= ~scene;
  }

  private reportMemScene(tag:string, calledScene: CurrentMemScene, olderScene: CurrentMemScene): void {
    if (olderScene === this.currentMemScene) {
      if (calledScene !== CurrentMemScene.FREE) {
        LogUtil.showInfo('%{public}s calledScene:%{public}d, currentScene is not changed.', tag, calledScene);
      }
      return;
    }
    let msg: PerformanceReporterParams = {
      'PACKAGE_NAME': HiSysEventUtil.PACKAGE_NAME,
      'SCENE_ID': this.currentMemScene,
      'HAPPEN_TIME': new Date().getTime()
    };
    LogUtil.showInfo('%{public}s calledScene:%{public}d, currentMemScene:%{public}d', tag, calledScene, this.currentMemScene);
    HiSysEventUtil.reportBehaviorEventEx(PERFORMANCE_MEM, msg, 'reportMemScene', PERFORMANCE_DOMIN);
  }
}