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
import { describe, expect, it } from '@ohos/hypium';
import { SoftwareUpdateBadgeListenerManager } from '@ohos/settings.systemUpdate';
import {
  SoftwareUpdateBadgeChangeListener
} from '@ohos/settings.systemUpdate/src/main/ets/listener/SoftwareUpdateBadgeListener';

class parListener implements SoftwareUpdateBadgeChangeListener {
  public name: string = '';
  getListenName(): string {
    if (this.name === '') {
      this.name = Math.random().toString();
    }
    return this.name;
  }
  onSoftwareUpdateBadgeChange(): void {
    console.log('All scene update badge changed.');
  }
}

let item: SoftwareUpdateBadgeChangeListener = new parListener();

export default function SoftwareUpdateBadgeListenerTest() {
  let listener: SoftwareUpdateBadgeChangeListener =
    AppStorage.get<SoftwareUpdateBadgeChangeListener>('null') as SoftwareUpdateBadgeChangeListener;

  describe('SoftwareUpdateBadgeListenerTest', () => {
    let SoftwareUpdateBadgeListener = SoftwareUpdateBadgeListenerManager.getInstance();
    it('test_getInstance', 0, (): void => {
      let resA = SoftwareUpdateBadgeListenerManager.getInstance();
      expect(resA === null).assertFalse();
      let resB = SoftwareUpdateBadgeListenerManager.getInstance();
      expect(resB === null).assertFalse();
    })

    it('test_registerHwNewSystemUpdateDataChange', 0, (): void => {
      let resA: Object = (SoftwareUpdateBadgeListener as object)['registerHwNewSystemUpdateDataChange']();
      expect(resA === null).assertFalse();
    })

    it('test_unRegisterHwNewSystemUpdateDataChange', 0, (): void => {
      let resA: Object = (SoftwareUpdateBadgeListener as object)['unRegisterHwNewSystemUpdateDataChange']();
      expect(resA === null).assertFalse();
    })

    it('test_registerSoftwareUpdateBadgeChangeListener', 0, (): void => {
      let resA = SoftwareUpdateBadgeListener.registerSoftwareUpdateBadgeChangeListener(listener);
      expect(resA === null).assertFalse();
      listener = new parListener();
      let resB = SoftwareUpdateBadgeListener.registerSoftwareUpdateBadgeChangeListener(listener);
      expect(resB === null).assertFalse();
      let arr: SoftwareUpdateBadgeChangeListener[] = [];
      (SoftwareUpdateBadgeListener as object)["isRegisterHwNewSystemUpdateDataChange"] = true;
      (SoftwareUpdateBadgeListener as object)["softwareUpdateBadgeChangeListeners"] = arr;
      let resC = SoftwareUpdateBadgeListener.registerSoftwareUpdateBadgeChangeListener(listener);
      expect(resC === null).assertFalse();
      arr.push(item);
      arr.push(listener);
      (SoftwareUpdateBadgeListener as object)["softwareUpdateBadgeChangeListeners"] = arr;
      (SoftwareUpdateBadgeListener as object)["isRegisterHwNewSystemUpdateDataChange"] = false;
      let resD = SoftwareUpdateBadgeListener.registerSoftwareUpdateBadgeChangeListener(listener);
      expect(resD === null).assertFalse();
    })

    it('test_unRegisterSoftwareUpdateBadgeChangeListener', 0, (): void => {
      listener =
        AppStorage.get<SoftwareUpdateBadgeChangeListener>('null') as SoftwareUpdateBadgeChangeListener;
      let resA = SoftwareUpdateBadgeListener.unRegisterSoftwareUpdateBadgeChangeListener(listener);
      expect(resA === null).assertFalse();
      listener = new parListener();
      let resB = SoftwareUpdateBadgeListener.unRegisterSoftwareUpdateBadgeChangeListener(listener);
      expect(resB === null).assertFalse();
      let arr: SoftwareUpdateBadgeChangeListener[] = [];
      (SoftwareUpdateBadgeListener as object)["isRegisterHwNewSystemUpdateDataChange"] = true;
      (SoftwareUpdateBadgeListener as object)["softwareUpdateBadgeChangeListeners"] = arr;
      let resC = SoftwareUpdateBadgeListener.unRegisterSoftwareUpdateBadgeChangeListener(listener);
      expect(resC === null).assertFalse();
      arr.push(item);
      arr.push(listener);
      (SoftwareUpdateBadgeListener as object)["softwareUpdateBadgeChangeListeners"] = arr;
      (SoftwareUpdateBadgeListener as object)["isRegisterHwNewSystemUpdateDataChange"] = false;
      let resD = SoftwareUpdateBadgeListener.unRegisterSoftwareUpdateBadgeChangeListener(listener);
      expect(resD === null).assertFalse();
    })

  });
}


