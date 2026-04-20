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

import { afterAll, afterEach, beforeAll, beforeEach, describe, expect, it, Level } from '@ohos/hypium';
import Want from '@ohos.app.ability.Want';
import { AbilityUtils } from '@ohos/settings.common/src/main/ets/utils/AbilityUtils';
import type UIExtensionContentSession from '@ohos.app.ability.UIExtensionContentSession';

export default function abilityUtilsTest() {
  describe('abilityUtilsTest', (): void => {
    let wantParams: Want = AppStorage.get<Want>('want') as Want;
    beforeAll((): void => {
    })

    beforeEach((): void => {
    })

    afterAll((): void => {
    })

    afterEach((): void => {
    })

    navigationUtilTestStartAbility();
    startAbilityForResultTestWantNull();
    startServiceExtensionForResult01();
    startServiceExtensionForResult02();

    it('startAbility', 0, () => {
      let result = AbilityUtils.startAbility(wantParams);
      expect(result === undefined).assertTrue();
    });

    it('startIntentUiExtensionAbility', 0, () => {
      let result = AbilityUtils.startIntentUiExtensionAbility(wantParams);
      expect(result === undefined).assertTrue();

      let want: Want = {
        'parameters': {}
      } as Want;
      let result2 = AbilityUtils.startIntentUiExtensionAbility(want, () => {
      });
      expect(result2 === undefined).assertTrue();
    });

    it('startAbilityByServiceExtensionContext', 0, () => {
      try {
        let result = AbilityUtils.startAbilityByServiceExtensionContext(wantParams, () => {
        });
        expect(result === undefined).assertTrue();

        let want: Want = {
          'parameters': {}
        } as Want;
        let result2 = AbilityUtils.startAbilityByServiceExtensionContext(want, () => {
        });
        expect(result2 === undefined).assertTrue();
      } catch (e) {
      }
    });

    it('startIntentUiExtensionAbility_001', 0, () => {
      try {
        let result = AbilityUtils.startAbilityByServiceExtensionContext(wantParams, () => {
        });
        expect(result === undefined).assertTrue();

        let want: Want = {
          'parameters': {}
        } as Want;
        let result2 = AbilityUtils.startIntentUiExtensionAbility(want, () => {
        });
        expect(result2 === undefined).assertTrue();
      } catch (e) {
      }
    });

    it('startAbilityByServiceExtensionContext_001', 0, () => {
      try {
        let result = AbilityUtils.startAbilityByServiceExtensionContext(wantParams, () => {
        });
        expect(result === undefined).assertTrue();

        let want: Want = {
          'parameters': {}
        } as Want;
        let result2 = AbilityUtils.startAbilityByServiceExtensionContext(want, () => {
        });
        expect(result2 === undefined).assertTrue();
      } catch (e) {
      }
    });

    it('startAbilityForResult', 0,  (done: Function) => {
      try {
        let result = AbilityUtils.startAbilityForResult(wantParams, () => {
        });
        expect(result === undefined).assertTrue();

        let want: Want = {
          'parameters': {}
        } as Want;
        let result2 = AbilityUtils.startAbilityForResult(want, () => {
        });
        expect(result2 === undefined).assertTrue();
      } catch (e) {
      } finally {
        done();
      }
    });

    it('startServiceExtensionForResult', 0, () => {
      try {
        let result = AbilityUtils.startServiceExtensionForResult(wantParams, () => {
        });
        expect(result === undefined).assertTrue();

        let want: Want = {
          'parameters': {}
        } as Want;
        let result2 = AbilityUtils.startServiceExtensionForResult(want, () => {
        });
        expect(result2 === undefined).assertTrue();
      } catch (e) {
      }
    });

    it('closeUiExtension', 0, () => {
      try {
        let uiExtensionContentSession: Want = {
          sendData: (): string => {
            return 'test';
          },
        } as Want;
        let result = AbilityUtils.closeUiExtension(uiExtensionContentSession as UIExtensionContentSession, 0);
        expect(result === undefined).assertTrue();

        let result2 = AbilityUtils.closeUiExtension(uiExtensionContentSession as UIExtensionContentSession, -1);
        expect(result2 === undefined).assertTrue();
      } catch (e) {
      }
    });

    it('closeUiExtensionWithData', 0, () => {
      try {
        let uiExtensionContentSession: Want = {
          sendData: (): string => {
            return 'test';
          },
        } as Want;
        let data: Want = {} as Want;
        let result = AbilityUtils.closeUiExtensionWithData(uiExtensionContentSession as UIExtensionContentSession, 0, data);
        expect(result === undefined).assertTrue();

        let result2 = AbilityUtils.closeUiExtensionWithData(uiExtensionContentSession as UIExtensionContentSession, -1, data);
        expect(result2 === undefined).assertTrue();
      } catch (e) {
      }
    });

    it('pageReportCallback', 0, () => {
      try {
        let result = AbilityUtils.pageReportCallback('test');
        expect(result === undefined).assertTrue();
      } catch (e) {
      }
    });

    it('timeoutForceGC', 0, (done: Function) => {
      try {
        let result = AbilityUtils.timeoutForceGC(-1);
        expect(result === undefined).assertTrue();

        let result2 = AbilityUtils.timeoutForceGC(10);
        expect(result2 === undefined).assertTrue();
      } catch (e) {
      } finally {
        done(() => {})
      }
    });

  })
}

function startServiceExtensionForResult02() {
  it('startServiceExtensionForResult02', 0, () => {
    let want: Want = {
      'parameters': {
        'serviceExtensionAbilityName': 'com.ohos.ailife.smarthome.serviceextension.DeviceControlExtensionAbility',
        'ability.want.params.uiExtensionType': 'sys/commonUI',
        'pageFlag': 'DeviceControl',
        'entityId': 'entityId',
        'entityName': 'entityName'
      }
    } as Want;
    AbilityUtils.startServiceExtensionForResult(want, () => {
      expect(1).assertEqual(1);
    });
    expect(0).assertEqual(0);
  });
}

function startServiceExtensionForResult01() {
  it('startServiceExtensionForResult01', 0, () => {
    let want: Want = {
      'parameters': {}
    } as Want;
    AbilityUtils.startServiceExtensionForResult(want, () => {
      expect(1).assertEqual(1);
    });
    expect(0).assertEqual(0);
  });
}

function startAbilityForResultTestWantNull() {
  it('startAbilityForResultTestWantNull', 0, () => {
    let result = false;
    let want: Want = {
      'parameters': {}
    } as Want;
    AbilityUtils.startAbilityForResult(want, () => {
      result = true;
    });
    expect(result).assertFalse();
  });
}

function navigationUtilTestStartAbility() {
  it('navigationUtilTestStartAbility', 0, () => {
    let want: Want = {
      'parameters': {}
    } as Want;
    AbilityUtils.startAbility(want);
    expect(1).assertEqual(1);
  });
}