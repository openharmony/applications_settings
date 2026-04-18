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

import fs, { ListFileOptions } from '@ohos.file.fs';
import abilityDelegatorRegistry from '@ohos.app.ability.abilityDelegatorRegistry';
import { describe, beforeAll, afterAll, it, expect, Level } from '@ohos/hypium';
import { Driver, ON } from '@ohos.UiTest';
import { BusinessError } from '@ohos.base';
import { NavEntryKey } from '@ohos/settings.common/src/main/ets/utils/Consts';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { AbilityContextManager } from '@ohos/settings.common/src/main/ets/ability/AbilityContextManager';
import { Constant } from '../../constant/Constant';
import { APP_FONT_WAIT_DELAY, COMMON_DELAY, SWIPE_DELAY } from '../../types';

const TAG: string = 'AppFontsManagePageTest';
const driver: Driver = Driver.create();
const DELEGATOR: abilityDelegatorRegistry.AbilityDelegator = abilityDelegatorRegistry.getAbilityDelegator();
const userFileDownloadPath = '/storage/Users/currentUser/Download/';
const jsonFileForTest0: string = 'testJson0.json';
let ttfFileForTest0: string = '';
let ttfFileForTest1: string = '';
let ttfFileForTest2: string = '';

/**
 * 拉起设置的系统界面
 */
async function beforeAllTest() {
  try {
    await DELEGATOR.startAbility({
      'bundleName': Constant.SETTINGS_BUNDLE_NAME,
      'abilityName': Constant.SETTINGS_MAIN_ABILITY_NAME,
      'uri': NavEntryKey.FONT_MANAGE,
    });
    LogUtil.info(`${TAG} com.ohos.settings.MainAbility start success.`);
  } catch (exception) {
    LogUtil.error(`${TAG} Failed to startAbility.`);
  }
}

/**
 * 回到桌面
 */
async function afterAllTest() {
  try {
    await driver.delayMs(COMMON_DELAY);
    await driver.pressHome();
    await driver.delayMs(COMMON_DELAY);
  } catch (exception) {
    LogUtil.error(`${TAG} Failed to return to the desktop: Code: ${(exception as BusinessError).code},
    Message: ${(exception as BusinessError).message}`);
  }
}

/**
 * 创建测试数据: 用于构造非法测试字体文件
 */
function createTestData(fileName: string) {
  let testPath = userFileDownloadPath + fileName;
  let stream: fs.Stream | null = null;
  try {
    if (!fs.accessSync(testPath)) {
      let testFileContent = '{"AppFontsManage": "1.0.0.1"}';
      stream = fs.createStreamSync(testPath, 'w');
      stream.writeSync(testFileContent);
    }
  } catch (exception) {
    LogUtil.error(`${TAG} Failed to create data`);
  }
  try {
    stream?.closeSync();
  } catch (exception) {
    LogUtil.error(`${TAG} Failed to close stream`);
  }
}

/**
 * 读取系统字体: 用于构造合法测试字体文件
 * @param testFontIdx 读取系统字体的序号
 */
function copySystemFontForTest(testFontIdx: number) {
  let systemFontDir = '/system/fonts/';
  let listFileOption: ListFileOptions = {
    filter: {
      suffix: ['.ttf', '.ttc', '.otf'],
    }
  };

  try {
    // 访问系统目录
    let files = fs.listFileSync(systemFontDir, listFileOption);
    if (!files) {
      return;
    }
    let fileName = '';
    switch (testFontIdx) {
      case 0: {
        ttfFileForTest0 = files[testFontIdx];
        fileName = ttfFileForTest0;
        break;
      }
      case 1: {
        ttfFileForTest1 = files[testFontIdx];
        fileName = ttfFileForTest1;
        break;
      }
      default: {
        ttfFileForTest2 = files[2];
        fileName = ttfFileForTest2;
      }
    }
    let src = systemFontDir + fileName;
    let dest = userFileDownloadPath + fileName;
    fs.copyFileSync(src, dest);
  } catch (exception) {
    LogUtil.debug(`${TAG} Unable to copy system font.
    Code: ${(exception as BusinessError).code}, Message: ${(exception as BusinessError).message}`);
  }
}

/**
 * 检查是否已读取字体字体，如果未读取，则进行读取行为
 * @param testFontIdx 读取系统字体对应序号
 */
function checkAndCopySystemFont(testFontIdx: number) {
  try {
    switch (testFontIdx) {
      case 0: {
        if (!ttfFileForTest0 || !fs.accessSync(userFileDownloadPath + ttfFileForTest0)) {
          copySystemFontForTest(0);
        }
        break;
      }
      case 1: {
        if (!ttfFileForTest1 || !fs.accessSync(userFileDownloadPath + ttfFileForTest1)) {
          copySystemFontForTest(1);
        }
        break;
      }
      default: {
        if (!ttfFileForTest2 || !fs.accessSync(userFileDownloadPath + ttfFileForTest2)) {
          copySystemFontForTest(2);
        }
      }
    }
  } catch (exception) {
    LogUtil.error(`${TAG} Failed to check the font:
    Code: ${(exception as BusinessError).code}, Message: ${(exception as BusinessError).message}`);
  }
}

/**
 * 根据传入的资源 key 值获取相应的 value 值
 * @param key app.string 文件下的资源 name 值
 * @returns app.string 文件下的资源 value 值
 */
function getCorrespondingValue(key: Resource): string {
  try {
    return AbilityContextManager.getContext().resourceManager.getStringSync(key);
  } catch (exception) {
    LogUtil.error(`${TAG} Failed to obtain the resource value corresponding to the key: ${key}:
    Code: ${(exception as BusinessError).code}, Message: ${(exception as BusinessError).message}`);
  }
  return '';
}

/**
 * 点击"从文件选择"按钮
 */
async function clickInstallButton() {
  try {
    let installButton = await driver.waitForComponent(ON.text(
      getCorrespondingValue($r('app.string.select_font'))), APP_FONT_WAIT_DELAY);
    await installButton.click();
    await driver.delayMs(COMMON_DELAY);

    // 关闭安全访问文件管理弹窗
    let gotIt = await driver.waitForComponent(ON.text('知道了'), APP_FONT_WAIT_DELAY);
    if (gotIt) {
      await gotIt.click();
    }

    // 找到'下载按钮'
    let downloadDirComponent = await driver.waitForComponent(ON.text('下载'), APP_FONT_WAIT_DELAY);
    await downloadDirComponent.doubleClick();
    await driver.delayMs(COMMON_DELAY);
  } catch (exception) {
    LogUtil.error(`${TAG} Failed to click the installation button: Code: ${(exception as BusinessError).code},
    Message: ${(exception as BusinessError).message}`);
  }
}

/**
 * 通过字体名称检查指定字体是否已安装
 * @param fontName 字体名称
 * @returns true: 已安装; false: 未安装
 */
async function fontIsInstalled(fontName: string): Promise<boolean> {
  try {
    if (fontName) {
      let installedFont = await driver.waitForComponent(ON.text(fontName.split('.')[0]), APP_FONT_WAIT_DELAY);
      return installedFont ? true : false;
    }
  } catch (exception) {
    LogUtil.error(`${TAG} Failed to find font ${fontName}: Code: ${(exception as BusinessError).code},
    Message: ${(exception as BusinessError).message}`);
  }
  return false;
}

/**
 * 不检查安装状态，直接安装所选字体，可能造成重复安装
 * @param fileName 需要安装的字体文件名
 */
async function installFontWithoutCheckStatus(fileName: string) {
  let dest = userFileDownloadPath + fileName;
  try {
    // 检查安装字体是否存在
    if (fileName && fs.accessSync(dest)) {
      await clickInstallButton();
      let testPathComponent = await driver.waitForComponent(ON.text(fileName), APP_FONT_WAIT_DELAY);
      await testPathComponent.doubleClick();
      await driver.delayMs(COMMON_DELAY);
    }
  } catch (exception) {
    LogUtil.error(`${TAG} Failed to install the font:
    Code: ${(exception as BusinessError).code}, Message: ${(exception as BusinessError).message}`);
  }
}

/**
 * 在安装字体前检查安装状态，如果已安装，则不进行重复安装
 * @param fileName 需要安装的字体文件名
 */
async function installFontWithCheckStatus(fileName: string) {
  const isInstalled = await fontIsInstalled(fileName);
  if (!isInstalled) {
    await installFontWithoutCheckStatus(fileName);
  }
}

/**
 * 点击字体卡片的卸载按钮
 */
async function clickDeleteButton() {
  try {
    let deleteIcon = await driver.waitForComponent(ON.type('Image').isAfter(ON.text(
      getCorrespondingValue($r('app.string.all_font_list_title')))), APP_FONT_WAIT_DELAY);
    await deleteIcon.click();
    await driver.delayMs(COMMON_DELAY);

    let deleteButton = await driver.waitForComponent(ON.text(
      getCorrespondingValue($r('app.string.app_info_uninstall'))), APP_FONT_WAIT_DELAY);
    await deleteButton.click();
    await driver.delayMs(COMMON_DELAY);
  } catch (exception) {
    LogUtil.error(`${TAG} Failed to click the delete button: Code: ${(exception as BusinessError).code},
    Message: ${(exception as BusinessError).message}`);
  }
}

/**
 * 点击"是否卸载此字体"弹窗中的确定卸载按钮
 */
async function clickOKToUninstall() {
  try {
    let delButton = await driver.waitForComponent(ON.text(
      getCorrespondingValue($r('app.string.button_ok'))), APP_FONT_WAIT_DELAY);
    await delButton.click();
    await driver.delayMs(SWIPE_DELAY);
  } catch (exception) {
    LogUtil.error(`${TAG} Failed to click OK to uninstall : Code: ${(exception as BusinessError).code},
    Message: ${(exception as BusinessError).message}`);
  }
}

/**
 * 获取当前页面已安装的字体个数
 * @returns 当前页面所显示的字体个数
 */
async function getCurFontNumber(): Promise<number> {
  try {
    let fontNumComponent = await driver.findComponent(ON.isAfter(ON.text(
      getCorrespondingValue($r('app.string.all_font_list_title')))));
    await driver.delayMs(SWIPE_DELAY);

    if (fontNumComponent) {
      let fontNumText = await fontNumComponent.getText();
      await driver.delayMs(COMMON_DELAY);
      const regex: RegExp = /\d+/;
      let matchArr = fontNumText.match(regex);
      let fontItemsBeforeNum = Number(matchArr![0]);
      return fontItemsBeforeNum;
    } else {
      // 空页面不存在"all font"组件，字体个数为 0
      return 0;
    }
  } catch (exception) {
    LogUtil.error(`${TAG} Failed to obtain the number of fonts on the non-empty page:
    Code: ${(exception as BusinessError).code}, Message: ${(exception as BusinessError).message}`);
  }
  return 0;
}

/**
 * 删除所有字体
 * @param fontNum 要删除的字体个数
 */
async function deleteAllFonts(fontNum: number) {
  try {
    for (let i = fontNum; i > 0; i--) {
      await clickDeleteButton();
      await clickOKToUninstall();
    }
  } catch (exception) {
    LogUtil.error(`${TAG} Failed to delete all fonts: Code: ${(exception as BusinessError).code},
    Message: ${(exception as BusinessError).message}`);
  }
}

/**
 * 删除所有字体，保证当前页面为空页面
 */
async function restoringEmptyPage() {
  const curFontNum = await getCurFontNumber();
  if (curFontNum !== 0) {
    await deleteAllFonts(curFontNum);
  }
}

/**
 * 检查测试路径下是否所有字体都存在
 * @param fileNames 字体名称集合
 * @returns true: 所有字体都存在; false: 部分或全部字体不存在
 */
function allFontsExist(fileNames: string[]): boolean {
  let allExist: boolean = true;
  try {
    for (let idx = 0; idx < fileNames.length; idx++) {
      let dest = userFileDownloadPath + fileNames[idx];
      if (!fileNames || !fs.accessSync(dest)) {
        allExist = false;
        break;
      }
    }
    return allExist;
  } catch (exception) {
    LogUtil.error(`${TAG} Failed to install fonts in batches:
    Code: ${exception?.code}, Message: ${exception?.message}`);
  }
  return false;
}

/**
 * 不检查安装状态，直接批量安装所选的多个字体，可能造成批量重复安装
 * @param fileNames 批量安装字体名称集合
 */
async function installMulFontsWithoutCheckStatus(fileNames: string[]) {
  const allExist = allFontsExist(fileNames);
  if (allExist) {
    await clickInstallButton();
    try {
      // 点击多选
      let mulChoices = await driver.findComponent(ON.id('FileManager_RightBarKey_ToolBarMulChoices'));
      await mulChoices.click();
      await driver.delayMs(COMMON_DELAY);
      // 寻找多个文件
      for (let idx = 0; idx < fileNames.length; idx++) {
        let file = await driver.waitForComponent(ON.text(fileNames[idx]), COMMON_DELAY);
        await file.click();
      }
      let openBtn = await driver.waitForComponent(ON.text('打开'), COMMON_DELAY);
      await openBtn.click();
    } catch (exception) {
      LogUtil.error(`${TAG} Batch installation fails when a file is selected:
    Code: ${(exception as BusinessError).code}, Message: ${(exception as BusinessError).message}`);
    }
  }
}

async function AppFontsManagePageTest_001() {
  await restoringEmptyPage();
  createTestData(jsonFileForTest0);
  await installFontWithoutCheckStatus(jsonFileForTest0);

  try {
    // 出现弹窗
    await driver.assertComponentExist(ON.text(
      getCorrespondingValue($r('app.string.install_fail_warning'))));
  } catch (exception) {
    LogUtil.error(`${TAG} Test 1: The pop-up window does not appear:
    Code: ${(exception as BusinessError).code}, Message: ${(exception as BusinessError).message}`);
  }
}

async function AppFontsManagePageTest_002() {
  await restoringEmptyPage();
  copySystemFontForTest(0);
  await installFontWithoutCheckStatus(ttfFileForTest0);
  const fontNum = await getCurFontNumber();
  // 空页面成功添加字体后，字体数量为 1
  expect(fontNum).assertEqual(1);
}

async function AppFontsManagePageTest_003() {
  const fontItemsBeforeNum = await getCurFontNumber();
  copySystemFontForTest(1);
  await installFontWithoutCheckStatus(ttfFileForTest1);
  const fontItemsAfterNum = await getCurFontNumber();
  expect(fontItemsAfterNum).assertEqual(fontItemsBeforeNum + 1);
}

async function AppFontsManagePageTest_004() {
  let fontItemsBeforeNum = await getCurFontNumber();
  await clickInstallButton();
  try {
    // 关闭文件管理窗口
    let cancelBtn = await driver.waitForComponent(ON.text('取消'), APP_FONT_WAIT_DELAY);
    await cancelBtn.click();
    await driver.delayMs(APP_FONT_WAIT_DELAY);
  } catch (exception) {
    LogUtil.error(`${TAG} Test 4: Failed to deselect the file:
    Code: ${(exception as BusinessError).code}, Message: ${(exception as BusinessError).message}`);
  }

  let fontNum = await getCurFontNumber();
  expect(fontNum).assertEqual(fontItemsBeforeNum);
}

async function AppFontsManagePageTest_005() {
  createTestData(jsonFileForTest0);
  await installFontWithoutCheckStatus(jsonFileForTest0);
  try {
    await driver.assertComponentExist(ON.text(getCorrespondingValue($r('app.string.install_fail_warning'))));
    await driver.delayMs(COMMON_DELAY);
  } catch (exception) {
    LogUtil.error(`${TAG} Test 5: The pop-up window does not exist:
    Code: ${(exception as BusinessError).code}, Message: ${(exception as BusinessError).message}`);
  }
}

async function AppFontsManagePageTest_006() {
  copySystemFontForTest(0);
  await installFontWithCheckStatus(ttfFileForTest0);
  let fontItemsBeforeNum = await getCurFontNumber();

  await installFontWithoutCheckStatus(ttfFileForTest0);
  try {
    // 取消重复安装
    let cancelButton = await driver.waitForComponent(ON.text(
      getCorrespondingValue($r('app.string.cancel'))), APP_FONT_WAIT_DELAY);
    await cancelButton.click();
    await driver.delayMs(COMMON_DELAY);
  } catch (exception) {
    LogUtil.error(`${TAG} Test 6: The cancel button does not appear:
    Code: ${(exception as BusinessError).code}, Message: ${(exception as BusinessError).message}`);
  }
  let fontItemsNum = await getCurFontNumber();
  expect(fontItemsNum).assertEqual(fontItemsBeforeNum);
}

async function AppFontsManagePageTest_007() {
  copySystemFontForTest(0);
  await installFontWithCheckStatus(ttfFileForTest0);
  let fontItemsBeforeNum = await getCurFontNumber();

  await installFontWithoutCheckStatus(ttfFileForTest0);
  try {
    // 点击“替换并安装”
    let replaceButton = await driver.waitForComponent(ON.text(
      getCorrespondingValue($r('app.string.replace_install'))), APP_FONT_WAIT_DELAY);
    await replaceButton.click();
    await driver.delayMs(COMMON_DELAY);
  } catch (exception) {
    LogUtil.error(`${TAG} Test 7: The replace button does not appear:
    Code: ${(exception as BusinessError).code}, Message: ${(exception as BusinessError).message}`);
  }
  let fontItemsNum = await getCurFontNumber();
  expect(fontItemsNum).assertEqual(fontItemsBeforeNum);
}

async function AppFontsManagePageTest_008() {
  // 确保页面不为空
  let fontNum = await getCurFontNumber();
  if (fontNum === 0) {
    copySystemFontForTest(0);
    await installFontWithoutCheckStatus(ttfFileForTest0);
  }
  try {
    // 退出页面
    let backBut = await driver.findComponent(ON.id('__NavdestinationField__BackButton__Back__'));
    await backBut.click();
    await driver.delayMs(COMMON_DELAY);

    // 判断"安装和管理应用中可使用的字体"存在
    await driver.assertComponentExist(ON.text(
      getCorrespondingValue($r('app.string.font_manage_summary'))));

    // 重新进入
    let fontManageBut = await driver.findComponent(ON.text(
      getCorrespondingValue($r('app.string.font_manage'))));
    await fontManageBut.click();
    await driver.delayMs(COMMON_DELAY);

    // 页面检查
    await driver.assertComponentExist(ON.text(
      getCorrespondingValue($r('app.string.drag_install'))));
    await driver.assertComponentExist(ON.text(
      getCorrespondingValue($r('app.string.drag_font_summary'))));
    await driver.assertComponentExist(ON.type('Image').isBefore(ON.text(
      getCorrespondingValue($r('app.string.drag_install')))));
  } catch (exception) {
    LogUtil.error(`${TAG} Test 18: The corresponding component cannot be found:
    Code: ${(exception as BusinessError).code}, Message: ${(exception as BusinessError).message}`);
  }
}

async function AppFontsManagePageTest_009() {
  // 确保页面不为空
  let fontNum = await getCurFontNumber();
  if (fontNum === 0) {
    copySystemFontForTest(0);
    await installFontWithoutCheckStatus(ttfFileForTest0);
  }

  try {
    // 放大页面
    let maxBut = await driver.findComponent(ON.id('EnhanceMaximizeBtn'));
    await driver.delayMs(COMMON_DELAY);
    await maxBut.click();
    await driver.delayMs(COMMON_DELAY);
    // 页面检查
    await driver.assertComponentExist(ON.text(
      getCorrespondingValue($r('app.string.drag_install'))));
    await driver.assertComponentExist(ON.text(
      getCorrespondingValue($r('app.string.drag_font_summary'))));
    await driver.assertComponentExist(ON.type('Image').isBefore(ON.text(
      getCorrespondingValue($r('app.string.drag_install')))));

    // 缩小页面
    let minBut = await driver.findComponent(ON.id('EnhanceMaximizeBtn'));
    await driver.delayMs(COMMON_DELAY);
    await minBut.click();
    await driver.delayMs(COMMON_DELAY);
    // 页面检查
    await driver.assertComponentExist(ON.text(
      getCorrespondingValue($r('app.string.drag_install'))));
    await driver.assertComponentExist(ON.text(
      getCorrespondingValue($r('app.string.drag_font_summary'))));
    await driver.assertComponentExist(ON.type('Image').isBefore(ON.text(
      getCorrespondingValue($r('app.string.drag_install')))));
  } catch (exception) {
    LogUtil.error(`${TAG} Test 19: The corresponding component cannot be found:
    Code: ${(exception as BusinessError).code}, Message: ${(exception as BusinessError).message}`);
  }
}

async function AppFontsManagePageTest_010() {
  // 保证页面为空
  let fontNum = await getCurFontNumber();
  if (fontNum !== 0) {
    await deleteAllFonts(fontNum);
  }
  try {
    // 退出页面
    let backBut = await driver.findComponent(ON.id('__NavdestinationField__BackButton__Back__'));
    await backBut.click();
    await driver.delayMs(COMMON_DELAY);

    // 判断"安装和管理应用中可使用的字体"存在
    await driver.assertComponentExist(ON.text(
      getCorrespondingValue($r('app.string.font_manage_summary'))));

    // 重新进入
    let fontManageBut = await driver.findComponent(ON.text(
      getCorrespondingValue($r('app.string.font_manage'))));
    await fontManageBut.click();
    await driver.delayMs(COMMON_DELAY);

    // 页面仍为空
    await driver.assertComponentExist(ON.text(
      getCorrespondingValue($r('app.string.no_installed_font'))));
    await driver.assertComponentExist(ON.text(
      getCorrespondingValue($r('app.string.drag_font_summary'))));
    await driver.assertComponentExist(ON.text(
      getCorrespondingValue($r('app.string.select_font'))));
    await driver.assertComponentExist(ON.type('Image').isBefore(ON.text(
      getCorrespondingValue($r('app.string.no_installed_font')))));
  } catch (exception) {
    LogUtil.error(`${TAG} Test 20: The corresponding component cannot be found:
    Code: ${(exception as BusinessError).code}, Message: ${(exception as BusinessError).message}`);
  }
}

async function AppFontsManagePageTest_011() {
  // 清理页面，保证测试字体已安装
  checkAndCopySystemFont(0);
  checkAndCopySystemFont(1);

  const fontItemsBeforeNum = await getCurFontNumber();
  const files: string[] = [ttfFileForTest0, ttfFileForTest1];
  await driver.delayMs(COMMON_DELAY);
  await installMulFontsWithoutCheckStatus(files);
  try {
    // 出现 dialog: 是否安装重复字体
    await driver.waitForComponent(ON.text(
      getCorrespondingValue($r('app.string.install_duplicate_fonts'))), APP_FONT_WAIT_DELAY);
    // 点击“替换此字体”后出现第二个弹窗
    let replaceBut = await driver.findComponent(ON.text(getCorrespondingValue($r('app.string.replace_install'))));
    await replaceBut.click();
    await driver.waitForComponent(ON.text(
      getCorrespondingValue($r('app.string.install_duplicate_fonts'))), APP_FONT_WAIT_DELAY);
    // 点击“取消”
    let cancelBut = await driver.findComponent(ON.text(getCorrespondingValue($r('app.string.cancel'))));
    await cancelBut.click();
  } catch (exception) {
    LogUtil.error(`${TAG} Test 27: The dialog window does not appear:
    Code: ${(exception as BusinessError).code}, Message: ${(exception as BusinessError).message}`);
  }
  const fontItemsAfterNum = await getCurFontNumber();
  expect(fontItemsAfterNum).assertEqual(fontItemsBeforeNum);
}

async function AppFontsManagePageTest_012() {
  // 清理页面，保证测试字体已安装
  checkAndCopySystemFont(0);
  checkAndCopySystemFont(1);

  const fontItemsBeforeNum = await getCurFontNumber();
  const files: string[] = [ttfFileForTest0, ttfFileForTest1];
  await installMulFontsWithoutCheckStatus(files);
  try {
    // 出现 dialog: 是否安装重复字体
    await driver.waitForComponent(ON.text(
      getCorrespondingValue($r('app.string.install_duplicate_fonts'))), APP_FONT_WAIT_DELAY);
    // 点击“替换全部字体”后 dialog 不再出现
    let replaceBut =
      await driver.findComponent(ON.text(getCorrespondingValue($r('app.string.replace_all_duplicate_fonts'))));
    await replaceBut.click();
  } catch (exception) {
    LogUtil.error(`${TAG} Test 28: The dialog window does not appear:
    Code: ${(exception as BusinessError).code}, Message: ${(exception as BusinessError).message}`);
  }
  const fontItemsAfterNum = await getCurFontNumber();
  expect(fontItemsAfterNum).assertEqual(fontItemsBeforeNum);
}

export default function AppFontsManagePageTest() {

  /**
   * 从文件选择相关功能测试
   */
  describe('AppFontsManagePageTest_SelectFromFile', () => {
    beforeAll(async (done: Function) => {
      await beforeAllTest();
      done();
    })

    afterAll(async (done: Function) => {
      await afterAllTest();
      done();
    })

    /**
     * @tc.number: AppFontsManagePageTest_001
     * @tc.name: 空页面添加字体验证
     * @tc.type: Level.LEVEL0
     * @tc.desc: 在空页面上添加不支持的字体，弹窗出现“仅支持ttf、ttc、otf格式的字体文件”提醒，仍为空页面
     */
    it('AppFontsManagePageTest_001', Level.LEVEL0, async () => {
      await AppFontsManagePageTest_001();
    })

    /**
     * @tc.number: AppFontsManagePageTest_004
     * @tc.name: 安装字体不选取文件验证
     * @tc.type: Level.LEVEL0
     * @tc.desc: 点击安装字体，弹出文件管理器，不选取文件，点击取消
     */
    it('AppFontsManagePageTest_004', Level.LEVEL0, async () => {
      await AppFontsManagePageTest_004();
    });

    /**
     * @tc.number: AppFontsManagePageTest_005
     * @tc.name: 非空页面安装不支持字体验证
     * @tc.type: Level.LEVEL0
     * @tc.desc: 安装不支持字体，弹窗出现“仅支持ttf、ttc、otf格式的字体文件”提醒，字体数量不变
     */
    it('AppFontsManagePageTest_005', Level.LEVEL0, async () => {
      await AppFontsManagePageTest_005();
    });

    /**
     * @tc.number: AppFontsManagePageTest_006
     * @tc.name: 安装重复字体验证
     * @tc.type: Level.LEVEL0
     * @tc.desc: 安装重复字体，弹窗出现“否安装重复字体”提醒，点击“取消”，字体个数不变
     */
    it('AppFontsManagePageTest_006', Level.LEVEL0, async () => {
      await AppFontsManagePageTest_006();
    });

    /**
     * @tc.number: AppFontsManagePageTest_007
     * @tc.name: 安装重复字体，进行字体更新
     * @tc.type: Level.LEVEL0
     * @tc.desc: 安装重复字体，弹窗出现“否安装重复字体”提醒，点击“替换并安装”，字体数量不变
     */
    it('AppFontsManagePageTest_007', Level.LEVEL0, async () => {
      await AppFontsManagePageTest_007();
    });
  });

  /**
   * 不同情况下的页面检查
   */
  describe('AppFontsManagePageTest_PageCheck', () => {
    beforeAll(async (done: Function) => {
      await beforeAllTest();
      await installFontWithoutCheckStatus(ttfFileForTest0);
      done();
    })

    afterAll(async (done: Function) => {
      await afterAllTest();
      done();
    })

    /**
     * @tc.number: AppFontsManagePageTest_008
     * @tc.name: 非空页面退出进入验证
     * @tc.type: Level.LEVEL0
     * @tc.desc: 非空页面退出再进入后字体数量不变
     */
    it('AppFontsManagePageTest_008', Level.LEVEL0, async () => {
      await AppFontsManagePageTest_008();
    });

    /**
     * @tc.number: AppFontsManagePageTest_009
     * @tc.name: 非空页面放大、缩小窗口验证
     * @tc.type: Level.LEVEL0
     * @tc.desc: 在非空页面上放大、缩小窗口，验证页面内容不受影响
     */
    it('AppFontsManagePageTest_009', Level.LEVEL0, async () => {
      await AppFontsManagePageTest_009();
    })

    /**
     * @tc.number: AppFontsManagePageTest_010
     * @tc.name: 空页面退出、进入验证
     * @tc.type: Level.LEVEL0
     * @tc.desc: 在空页面上退出应用字体管理，再进入应用字体管理，都是空白页面
     */
    it('AppFontsManagePageTest_010', Level.LEVEL0, async () => {
      await AppFontsManagePageTest_010();
    });
  });

  /**
   * 批量安装功能测试
   */
  describe('AppFontsManagePageTest_BatchInstallation', () => {
    beforeAll(async (done: Function) => {
      await beforeAllTest();
      await restoringEmptyPage();
      checkAndCopySystemFont(0);
      checkAndCopySystemFont(1);
      const files: string[] = [ttfFileForTest0, ttfFileForTest1];
      await installMulFontsWithoutCheckStatus(files);
      done();
    })

    afterAll(async (done: Function) => {
      await afterAllTest();
      done();
    })

    /**
     * @tc.number: AppFontsManagePageTest_011
     * @tc.name: 非空页面情况下从文件选择添加多个重复字体
     * @tc.type: Level.LEVEL0
     * @tc.desc: 非空页面情况下从文件选择添加多个重复字体，出现重复字体弹窗，点击“替换”，出现第二个重复字体的弹窗，字体数量不变
     */
    it('AppFontsManagePageTest_011', Level.LEVEL0, async () => {
      await AppFontsManagePageTest_011();
    });

    /**
     * @tc.number: AppFontsManagePageTest_012
     * @tc.name: 非空页面情况下从文件选择添加多个重复字体
     * @tc.type: Level.LEVEL0
     * @tc.desc: 非空页面情况下从文件选择添加多个重复字体，出现重复字体弹窗，点击“替换全部重复字体”，弹窗不再出现，字体数量不变
     */
    it('AppFontsManagePageTest_012', Level.LEVEL0, async () => {
      await AppFontsManagePageTest_012();
    });
  })
}