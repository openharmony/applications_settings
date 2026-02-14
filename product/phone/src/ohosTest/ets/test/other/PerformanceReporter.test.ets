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
import { describe, beforeAll, beforeEach, afterEach, afterAll, it, expect } from '@ohos/hypium'
import { PerformanceReporter } from '@ohos/settings.common'
import { CurrentCpuScene, CurrentMemScene } from '@ohos/settings.common/src/main/ets/memery/PerformanceReporter';

export default function PerformanceReporterTest() {
  describe('PerformanceReporterTest', () => {
    let performanceReporterInstance = new PerformanceReporter;

    it('PerformanceReporterTest_01', 0, () => {
      let result = PerformanceReporter.getInstance();
      expect(result !== null).assertTrue();
    })

    it('PerformanceReporterTest_02', 0, () => {
      let result = performanceReporterInstance.reportEnterCpuScene(CurrentCpuScene.FREE)
      expect(result !== null).assertTrue();
    })

    it('PerformanceReporterTest_03', 0, () => {
      let result = performanceReporterInstance.reportExitCpuScene(CurrentCpuScene.FREE)
      expect(result !== null).assertTrue();
    })

    it('PerformanceReporterTest_04', 0, () => {
      let result = performanceReporterInstance.reportEnterMemScene(CurrentMemScene.FREE)
      expect(result !== null).assertTrue();
    })

    it('PerformanceReporterTest_041', 0, () => {
      let result = performanceReporterInstance.reportExitMemScene(CurrentMemScene.FREE)
      expect(result !== null).assertTrue();
    })

    it('PerformanceReporterTest_05', 0, () => {
      (performanceReporterInstance as object)['reportMemScene']('Enter',CurrentMemScene.START_SETTINGS,CurrentMemScene.FREE)
    })

    it('PerformanceReporterTest_06', 0, () => {
      (performanceReporterInstance as object)['reportMemScene']('Enter',CurrentMemScene.FREE,CurrentMemScene.START_SETTINGS)
    })

    it('PerformanceReporterTest_07', 0, () => {
      (performanceReporterInstance as object)['reportCpuScene']('Enter',CurrentMemScene.START_SETTINGS,CurrentMemScene.FREE)
    })

    it('PerformanceReporterTest_08', 0, () => {
      (performanceReporterInstance as object)['reportCpuScene']('Enter',CurrentMemScene.FREE,CurrentMemScene.START_SETTINGS)
    })

  })
}