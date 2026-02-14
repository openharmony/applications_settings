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

import { afterAll, afterEach, beforeAll, beforeEach, describe, expect, it } from '@ohos/hypium';
import Want from '@ohos.application.Want';
import { ServiceEntity } from '@ohos/settings.aboutdevice/src/main/ets/legalInfo/model/ServiceEntity';

export default function serviceEntityTest() {
  describe('serviceEntityTest', (): void => {

    beforeAll((): void => {
    })

    beforeEach((): void => {
    })

    afterAll((): void => {
    })

    afterEach((): void => {
    })

    getServiceName();
    setServiceName02();
    getPackageName();
    setPackageName02();
    getModuleName();
    setModuleName02();
    getValidatorList();
    setValidatorList02();
    getCheckboxList();
    setCheckboxList02();
    getSaveDataListList();
    setSaveDataListList02();
    getTitle();
    setTitle02();
    getContent();
    setContent();
    getVersion();
    setVersion02();
    addAbility();
    setServiceType();
    isServiceVisible();
    setServiceVisible();
    isServiceChecked();
    setServiceChecked();
    isServiceExpanded();
  })
}


function isServiceExpanded() {
  it('ServiceEntityTest_isServiceExpanded', 0, () => {
    let isServiceExpanded = false;
    let serviceEntity: ServiceEntity = new ServiceEntity();
    serviceEntity.setServiceExpanded(isServiceExpanded);
    expect(serviceEntity.isServiceExpanded()).assertEqual(isServiceExpanded);
  });
}

function setServiceChecked() {
  it('ServiceEntityTest_setServiceChecked', 0, () => {
    let serviceEntity: ServiceEntity = new ServiceEntity();
    serviceEntity.setServiceChecked(true);
    expect(serviceEntity.isServiceChecked()).assertTrue();
  });
}

function isServiceChecked() {
  it('ServiceEntityTest_isServiceChecked', 0, () => {
    let serviceEntity = new ServiceEntity();
    expect(serviceEntity.isServiceChecked()).assertFalse();
  });
}

function setServiceVisible() {
  it('ServiceEntityTest_setServiceVisible', 0, () => {
    let serviceEntity: ServiceEntity = new ServiceEntity();
    serviceEntity.setServiceVisible(true);
    expect(serviceEntity.isServiceVisible()).assertTrue();
  });
}

function isServiceVisible() {
  it('ServiceEntityTest_isServiceVisible', 0, () => {
    let isVisible: boolean = true;
    let serviceEntity = new ServiceEntity();
    serviceEntity.setServiceVisible(true);
    expect(serviceEntity.isServiceVisible()).assertEqual(isVisible);
  });
}

function setServiceType() {
  it('ServiceEntityTest_setServiceType', 0, () => {
    let serviceEntity = new ServiceEntity();
    serviceEntity.setServiceType("");
    expect(serviceEntity.getServiceType()).assertEqual(2);
  });
}

function addAbility() {
  it('ServiceEntityTest_addAbility', 0, () => {
    let serviceEntity: ServiceEntity = new ServiceEntity();
    let want: Want = {
      deviceId: '123',
      bundleName: 'com.app.test',
      abilityName: 'TestAbility',
      uri: 'test',
      type: '123',
      flags: 1,
      action: 'test',
      parameters: {
        '1': '2'
      },
      entities: ['1']
    };
    serviceEntity.addAbility('1', want);
    expect(serviceEntity.getAbility('1')).assertEqual(want);
  });
}

function setVersion02() {
  it('ServiceEntityTest_setVersion', 0, () => {
    let serviceEntity: ServiceEntity = new ServiceEntity();
    serviceEntity.setVersion(1);
    expect(serviceEntity.getVersion()).assertEqual(1);
  });
}

function getVersion() {
  it('ServiceEntityTest_getVersion', 0, () => {
    let serviceEntity = new ServiceEntity();
    serviceEntity.setVersion(100);
    let version = serviceEntity.getVersion();
    expect(version).assertEqual(100);
  });
}

function setContent() {
  it('ServiceEntityTest_setContent', 0, () => {
    let serviceEntity = new ServiceEntity();
    serviceEntity.setContent("123456");
    expect(serviceEntity.getContent()).assertEqual('123456');
  });
}

function getContent() {
  it('ServiceEntityTest_getContent', 0, () => {
    let serviceEntity = new ServiceEntity();
    serviceEntity.setContent('name');
    expect(serviceEntity.getContent()).assertEqual('name');
  });
}

function setTitle02() {
  it('ServiceEntityTest_setTitle', 0, () => {
    let serviceEntity = new ServiceEntity();
    serviceEntity.setTitle("setTitle");
    expect(serviceEntity.getTitle()).assertEqual("setTitle");
  });
}

function getTitle() {
  it('ServiceEntityTest_getTitle', 0, () => {
    let entity: ServiceEntity = new ServiceEntity();
    expect(entity.getTitle()).assertEqual('');
    entity.setTitle('title');
    expect(entity.getTitle()).assertEqual('title');
  });
}

function setSaveDataListList02() {
  it('ServiceEntityTest_setSaveDataListList', 0, () => {
    let saveDataList: Array<string> = [];
    let serviceEntity = new ServiceEntity();
    serviceEntity.setSaveDataListList(saveDataList);
    expect(serviceEntity.getSaveDataListList().length).assertEqual(0);
  });
}

function getSaveDataListList() {
  it('ServiceEntityTest_getSaveDataListList', 0, () => {
    let saveDataListList: Array<string> = [];
    let serviceEntity = new ServiceEntity();
    serviceEntity.setSaveDataListList(saveDataListList);
    let result = serviceEntity.getSaveDataListList();
    expect(result).assertEqual(saveDataListList);
  });
}

function setCheckboxList02() {
  it('ServiceEntityTest_setCheckboxList', 0, () => {
    let checkboxList: Array<string> = [];
    let serviceEntity = new ServiceEntity();
    serviceEntity.setCheckboxList(checkboxList);
    expect(serviceEntity.getCheckboxList()).assertEqual(checkboxList);
  });
}

function getCheckboxList() {
  it('ServiceEntityTest_getCheckboxList', 0, () => {
    let checkboxList: Array<string> = [];
    let serviceEntity = new ServiceEntity();
    serviceEntity.setCheckboxList(checkboxList);
    expect(serviceEntity.getCheckboxList().length).assertEqual(0);
  });
}

function setValidatorList02() {
  it('ServiceEntityTest_setValidatorList', 0, () => {
    let validatorList: Array<string> = ['test'];
    let serviceEntity = new ServiceEntity();
    serviceEntity.setValidatorList(validatorList);
    expect(serviceEntity.getValidatorList()).assertEqual(validatorList);
  });
}

function getValidatorList() {
  it('ServiceEntityTest_getValidatorList', 0, () => {
    let se: ServiceEntity = new ServiceEntity();
    expect(se.getValidatorList().length).assertEqual(0);
  });
}

function setModuleName02() {
  it('ServiceEntityTest_setModuleName', 0, () => {
    let serviceEntity = new ServiceEntity();
    serviceEntity.setModuleName("setModuleName");
    expect(serviceEntity.getModuleName()).assertEqual("setModuleName");
  });
}

function getModuleName() {
  it('ServiceEntityTest_getModuleName', 0, () => {
    let serviceEntity = new ServiceEntity();
    serviceEntity.setModuleName("123456");
    expect(serviceEntity.getModuleName()).assertEqual("123456");
  });
}

function setPackageName02() {
  it('ServiceEntityTest_setPackageName', 0, () => {
    let serviceEntity = new ServiceEntity();
    serviceEntity.setPackageName("123456");
    expect(serviceEntity.getPackageName()).assertEqual("123456");
  });
}

function getPackageName() {
  it('ServiceEntityTest_getPackageName', 0, () => {
    let serviceEntity = new ServiceEntity();
    serviceEntity.packageName = "123";
    const packageName = serviceEntity.getPackageName();
    expect(packageName).assertEqual('123');
  });
}

function setServiceName02() {
  it('ServiceEntityTest_setServiceName', 0, () => {
    let serviceEntity = new ServiceEntity();
    serviceEntity.setServiceName("setServiceName");
    expect(serviceEntity.getServiceName()).assertEqual("setServiceName");
  });
}

function getServiceName() {
  it('ServiceEntityTest_getServiceName', 0, () => {
    let serviceEntity = new ServiceEntity();
    serviceEntity.setServiceName("123456");
    expect(serviceEntity.getServiceName()).assertEqual("123456");
  });
}
