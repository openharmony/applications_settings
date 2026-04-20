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

import taskpool from '@ohos.taskpool';
import { PreferencesUtil } from '@ohos/settings.common/src/main/ets/utils/PreferencesUtil';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';

const TAG: string = 'DisplayPreferencesUtils:';

export const SUPPORT_NATURE_SWITCH: string = 'settings.display.naturalColorTemperature';

/** 屏幕休眠时间首选项 key，用于开机后恢复用户设置（数据库可能与首选项不一致时以首选项为准） */
export const SCREEN_OFF_TIMEOUT_PREF: string = 'settings.display.screen_off_timeout.pref';

export class DisplayPreferencesUtils {
  /*
   * 显示和亮度页面的设备是否支持自动亮度、护眼模式、色彩色温控制开关状态获取存入缓存
   */
  public static async displayPreferences(): Promise<void> {
    let displayTask: taskpool.Task = new taskpool.Task(taskDisPlaySwitch);
    let result: Record<string, boolean> =
      await taskpool.execute(displayTask, taskpool.Priority.MEDIUM) as Record<string, boolean>;
    Object.keys(result)?.forEach(key => {
      LogUtil.info(`${TAG} PreferencesUtil.putSync. key:${key} value:${result[key]}`);
      PreferencesUtil.putSync(key, result[key]);
    });
  }

  public static isSupportNatureSwitch(): boolean {
    return PreferencesUtil.getSync(SUPPORT_NATURE_SWITCH, false) as boolean;
  }
}

@Concurrent
async function taskDisPlaySwitch(): Promise<Record<string, boolean>> {
  const TAG: string = 'DisplayPreferencesUtils:';
  const result: Record<string, boolean> = {};
  try {
    LogUtil.info(`${TAG} import @ohos.displayengine.displayengine_napi.`);
    // await import('@ohos.displayengine.displayengine_napi').then(async (displayengineNapi) => {
    //   // 10(阳光下可读性提升)|11(色彩调节)|18(色温调节_不包含自然色温)|23(自然色温)|29(护眼模式)|32(低频刷新)|34(电子书模式)|51(HDR显示)
    //   const arrParam = [10, 11, 18, 23, 29, 32, 34, 51, 50];
    //   LogUtil.info(`${TAG} displayengineNapi.default.getSupported start. arrParam:${arrParam}`);
    //   const supportedCodeArr: number[] = displayengineNapi.default.getSupported(arrParam);
    //   LogUtil.info(`${TAG} displayengineNapi.default.getSupported success. supportedCodeArr:${supportedCodeArr}`);
    //   result['settings.display.naturalLightSwitch'] = supportedCodeArr[0] === 1;
    //   result['settings.display.colorTemperatureSwitch'] = supportedCodeArr[1] === 1;
    //   result['settings.display.colorTemperatureAdjustment'] = supportedCodeArr[2] === 1;
    //   result['settings.display.naturalColorTemperature'] = supportedCodeArr[3] === 1;
    //   result['settings.display.eyeProtectSwitch'] = supportedCodeArr[4] === 1;
    //   result['settings.display.lowFrequencyFlashSwitch'] = supportedCodeArr[5] === 1;
    //   result['settings.display.EbookSwitch'] = [1, 2].includes(supportedCodeArr[6]);
    //   result['settings.display.EbookColorSwitch'] = supportedCodeArr[6] === 2;
    //   result['settings.display.supportHdr'] = supportedCodeArr[7] === 1;
    //   result['settings.display.supportSwingEye'] = supportedCodeArr[8] !== 0;
    // });
    LogUtil.info(`${TAG} import @ohos.sensor.`);
    await import('@ohos.sensor').then(async (sensorNapi) => {
      LogUtil.info(`${TAG} sensorNapi.default.getSingleSensor start.`);
      let data = await sensorNapi.default.getSingleSensor(sensorNapi.default.SensorId.AMBIENT_LIGHT);
      LogUtil.info(`${TAG} sensorNapi.default.getSingleSensor success. sensorName:${data?.sensorName}`);
      result['settings.display.AutoAdjustSwitch'] = data?.sensorName ? true : false;
    });
  } catch (err) {
    LogUtil.error(`${TAG} taskDisPlaySwitch catch error. code:${err?.code} message:${err?.message}`);
  }
  return result;
}