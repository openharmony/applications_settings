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

import { afterAll, afterEach, beforeAll, beforeEach, describe, expect, it, MockKit } from '@ohos/hypium';
import { BaseText, LinkText } from '@ohos/settings.aboutdevice/src/main/ets/legalInfo/parser/TextModel';
import Want from '@ohos.app.ability.Want';

export default function textModelTest() {
  describe('textModelTest', (): void => {

    beforeAll((): void => {
    })

    beforeEach((): void => {
    })

    afterAll((): void => {
    })

    afterEach((): void => {
    })

    baseTextConstructor();
    getTextTest();
    setTextTest();
    linkTextTest();
    it('LinkTextTest_setWant', 0, () => {
      let linkText = new LinkText("text");
      let want: Want = {
        deviceId: '',
        bundleName: 'com.example.myapplication',
        abilityName: 'MainAbility',
        uri: 'test',
        type: 'json',
        flags: 1,
        action: '',
        parameters: {
          'ability.params.backToOtherMissionStack': true
        },
        entities: [
          'entity.system.home'
        ],
        moduleName: 'entry'
      };
      linkText.setWant(want);
      expect(linkText.getWant()).assertEqual(want);
    })
  })
}


function linkTextTest() {
  it('linkTextTest', 0, () => {
    let linkText = new LinkText('');
    let mocker: MockKit = new MockKit();
    let want: Want = {
      deviceId: '',
      bundleName: 'com.ohos.ailife',
      abilityName: 'com.ohos.ailife.PhoneLinkAbility',
      parameters: {
        'ability.want.params.uiExtensionType': 'sys/commonUI',
        'phoneLinkVersion': '20',
        'issuer': 'issuer',
        'device': 'device',
        'uuid': 'uuid',
        'homeId': 'homeId',
        'roomId': 'roomId',
        'url': 'url',
      }
    };
    mocker.mockFunc(linkText, linkText.setWant);
    linkText.setWant(want);
    expect(linkText.getWant()).assertEqual(undefined);
    mocker.clear(linkText)
  });
}

function setTextTest() {
  it('setTextTest', 0, () => {
    let bt = new BaseText("123");
    bt.setText("456");
    expect(bt.getText()).assertEqual('456');
  });
}

function getTextTest() {
  it('getTextTest', 0, () => {
    let bt = new BaseText('abc');
    expect(bt.getText()).assertEqual('abc');
  });
}

function baseTextConstructor() {
  it('BaseTextConstructor', 0, () => {
    let bt = new BaseText('test');
    expect(bt.getText()).assertEqual('test');
  });
}
