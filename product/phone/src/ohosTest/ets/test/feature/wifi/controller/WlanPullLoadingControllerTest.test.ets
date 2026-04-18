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

import { describe, it, expect, TestType } from '@ohos/hypium';
import { WlanPullLoadingController } from '@ohos/settings.wifi/src/main/ets/controller/WlanPullLoadingController';

export default function WlanPullLoadingControllerTest() {
  let wlanPullLoading = new WlanPullLoadingController();
  describe('WlanPullLoadingControllerTest', () => {
    it('test_onReachStart', TestType.FUNCTION, () => {
      (wlanPullLoading as object)["verticalOffset"] = 0;
      let resA = wlanPullLoading.onReachStart();
      expect(resA === null).assertFalse();
      (wlanPullLoading as object)["verticalOffset"] = -64;
      let resB = wlanPullLoading.onReachStart();
      expect(resB === null).assertFalse();
    });

    it('test_onScroll', TestType.FUNCTION, () => {
      (wlanPullLoading as object)["verticalOffset"] = 0;
      (wlanPullLoading as object)["isTop"] = true;
      let resA = wlanPullLoading.onScroll(10, ScrollState.Scroll);
      expect(resA === null).assertFalse();
      (wlanPullLoading as object)["verticalOffset"] = -64;
      (wlanPullLoading as object)["isTop"] = false;
      (wlanPullLoading as object)["loadPull"] = true;
      (wlanPullLoading as object)["verticalOffset"] = 0;
      let resB = wlanPullLoading.onScroll(10, ScrollState.Scroll);
      expect(resB === null).assertFalse();
      (wlanPullLoading as object)["loadPull"] = false;
      (wlanPullLoading as object)["verticalOffset"] = -10000;
      let resC = wlanPullLoading.onScroll(10, ScrollState.Scroll);
      expect(resC === null).assertFalse();
      (wlanPullLoading as object)["isTop"] = true;
      (wlanPullLoading as object)["isReachStart"] = false;
      let resD = wlanPullLoading.onScroll(10, ScrollState.Scroll);
      expect(resD === null).assertFalse();
      (wlanPullLoading as object)["isTop"] = false;
      (wlanPullLoading as object)["isReachStart"] = true;
      let resE = wlanPullLoading.onScroll(10, ScrollState.Scroll);
      expect(resE === null).assertFalse();
    });

    it('test_onPullLoadStateChange', TestType.FUNCTION, () => {
      (wlanPullLoading as object)["isTop"] = true;
      (wlanPullLoading as object)["loadPull"] = true;
      (wlanPullLoading as object)["isReachStart"] = false;
      (wlanPullLoading as object)["isShowingPullBar"] = false;
      let resA = wlanPullLoading.onPullLoadStateChange();
      expect(resA === null).assertFalse();
      (wlanPullLoading as object)["isShowingPullBar"] = true;
      let resB = wlanPullLoading.onPullLoadStateChange();
      expect(resB === null).assertFalse();
      (wlanPullLoading as object)["isTop"] = false;
      (wlanPullLoading as object)["loadPull"] = false;
      (wlanPullLoading as object)["isReachStart"] = true;
      let resC = wlanPullLoading.onPullLoadStateChange();
      expect(resC === null).assertFalse();
      (wlanPullLoading as object)["isShowingPullBar"] = false;
      let resD = wlanPullLoading.onPullLoadStateChange();
      expect(resD === null).assertFalse();
    });

    it('test_changeVisible', TestType.FUNCTION, () => {
      (wlanPullLoading as object)["verticalOffset"] = -64;
      let resA: Object = (wlanPullLoading as object)['changeVisible'](true);
      expect(resA === true).assertFalse();
      (wlanPullLoading as object)["verticalOffset"] = 0;
      let resB: Object = (wlanPullLoading as object)['changeVisible'](false);
      expect(resB === true).assertFalse();
    });
  });
}