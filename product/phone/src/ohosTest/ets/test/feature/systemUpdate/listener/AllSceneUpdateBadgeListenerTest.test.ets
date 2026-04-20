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
import {
  AllSceneUpdateBadgeChangeListener,
  AllSceneUpdateBadgeListenerManager
} from '@ohos/settings.systemUpdate/src/main/ets/listener/AllSceneUpdateBadgeListener';

class parListener implements AllSceneUpdateBadgeChangeListener {
  public name: string = '';
  getListenName(): string {
    if (this.name === '') {
      this.name = Math.random().toString();
    }
    return this.name;
  }
  onAllSceneUpdateBadgeChange(): void {
    console.log('All scene update badge changed.');
  }
}

let item: AllSceneUpdateBadgeChangeListener = new parListener();

export default function AllSceneUpdateBadgeListenerTest() {
  let listener: AllSceneUpdateBadgeChangeListener =
    AppStorage.get<AllSceneUpdateBadgeChangeListener>('null') as AllSceneUpdateBadgeChangeListener;

  describe('AllSceneUpdateBadgeListenerTest', () => {
    let AllSceneUpdateBadgeListener = AllSceneUpdateBadgeListenerManager.getInstance();
    it('test_getInstance', 0, (): void => {
      let resA = AllSceneUpdateBadgeListenerManager.getInstance();
      expect(resA === null).assertFalse();
      let resB = AllSceneUpdateBadgeListenerManager.getInstance();
      expect(resB === null).assertFalse();
    })

    it('test_registerAllSceneUpdateBadgeChangeListener', 0, (): void => {
      let resA = AllSceneUpdateBadgeListener.registerAllSceneUpdateBadgeChangeListener(listener);
      expect(resA === null).assertFalse();
      listener = new parListener();
      let resB = AllSceneUpdateBadgeListener.registerAllSceneUpdateBadgeChangeListener(listener);
      expect(resB === null).assertFalse();
      let arr: AllSceneUpdateBadgeChangeListener[] = [];
      (AllSceneUpdateBadgeListener as object)["isRegisterAllSceneUpdateDataChange"] = true;
      (AllSceneUpdateBadgeListener as object)["allSceneUpdateBadgeChangeListeners"] = arr;
      (AllSceneUpdateBadgeListener as object)["registerAllSceneUpdateBadgeChange"]();
      let resC = AllSceneUpdateBadgeListener.registerAllSceneUpdateBadgeChangeListener(listener);
      expect(resC === null).assertFalse();
      (AllSceneUpdateBadgeListener as object)["unRegisterAllSceneUpdateBadgeChange"]();
      let resE = AllSceneUpdateBadgeListener.registerAllSceneUpdateBadgeChangeListener(listener);
      expect(resE === null).assertFalse();
      arr.push(item);
      arr.push(listener);
      (AllSceneUpdateBadgeListener as object)["allSceneUpdateBadgeChangeListeners"] = arr;
      let resD = AllSceneUpdateBadgeListener.registerAllSceneUpdateBadgeChangeListener(listener);
      expect(resD === null).assertFalse();
    })

    it('test_unRegisterAllSceneUpdateBadgeChangeListener', 0, (): void => {
      listener =
        AppStorage.get<AllSceneUpdateBadgeChangeListener>('null') as AllSceneUpdateBadgeChangeListener;
      let resA = AllSceneUpdateBadgeListener.unRegisterAllSceneUpdateBadgeChangeListener(listener);
      expect(resA === null).assertFalse();
      listener = new parListener();
      let resB = AllSceneUpdateBadgeListener.unRegisterAllSceneUpdateBadgeChangeListener(listener);
      expect(resB === null).assertFalse();
      let arr: AllSceneUpdateBadgeChangeListener[] = [];
      (AllSceneUpdateBadgeListener as object)["isRegisterAllSceneUpdateDataChange"] = true;
      (AllSceneUpdateBadgeListener as object)["allSceneUpdateBadgeChangeListeners"] = arr;
      let resC = AllSceneUpdateBadgeListener.unRegisterAllSceneUpdateBadgeChangeListener(listener);
      expect(resC === null).assertFalse();
      arr.push(item);
      arr.push(listener);
      (AllSceneUpdateBadgeListener as object)["allSceneUpdateBadgeChangeListeners"] = arr;
      (AllSceneUpdateBadgeListener as object)["isRegisterAllSceneUpdateDataChange"] = false;
      let resD = AllSceneUpdateBadgeListener.unRegisterAllSceneUpdateBadgeChangeListener(listener);
      expect(resD === null).assertFalse();
    })

  });
}

