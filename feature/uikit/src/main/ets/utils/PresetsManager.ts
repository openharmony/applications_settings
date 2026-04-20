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

import configPolicy from '@ohos.configPolicy';
import fs from '@ohos.file.fs';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { StringUtil } from '@ohos/settings.common/src/main/ets/utils/StringUtil';
/* instrument ignore file */
const TAG: string = 'PresetsManager';

/**
 * 预置图标资源新规范目录
 */
const PRESET_PATH_ICON : string = 'icon';

/**
 * 预置图标详细资源新规范目录
 */
const PRESET_PATH_ICON_SUB : string = 'icons';

/**
 * 预置资源属性ID
 */
const MANIFEST_KEY_ID : string = 'id';

/**
 * 预置字体资源文件
 */
const TTF_FILE: string = 'src';

/**
 * 预置图标资源属性preview
 */
const MANIFEST_KEY_PREVIEW : string = 'preview';

/**
 * 预置字体资源新规范目录
 */
const PRESET_PATH_FONT : string = 'font';

/**
 * 预置字体资源预览图前缀
 */
const COVER_IMAGE: string = 'cover';

/**
 * 预置资源根目录
 */
const PRESETS_ROOT_RELATIVE_PATH: string = 'resource/themes';

/**
 * 目录分隔符
 */
const FILE_SEPARATOR: string = '/';

/**
 * 描述文件名
 */
const PRESET_MANIFEST: string = 'manifest.json';

/**
 * 基础子目录名称
 */
const BASE_PREFIX: string = 'base';

export interface IIconPresetsParams {
  /**
   * 标识符，只包含大小写字母、数字和下划线
   */
  readonly id: string;

  /**
   * 图标资源目录路径
   */
  readonly basePath: string;

  /**
   * 图标预览图路径
   */
  readonly previewPath: string;

  /**
   * 是否正在使用
   */
  readonly isCurrent: boolean;
};

/**
 * 预置图标资源内部对象，通过接口对外暴露只读数据
 */
export class IconPresets {
  id: string;
  basePath: string;
  previewPath: string;
  isCurrent: boolean;

  constructor(presets?: IIconPresetsParams) {
    this.id = presets?.id ?? '';
    this.basePath = presets?.basePath ?? '';
    this.previewPath = presets?.previewPath ?? '';
    this.isCurrent = presets?.isCurrent ?? false;
  }
}

/**
 * 字体信息
 */
export class FontInfo {
  /**
   * 字体的Id
   */
  id: string;

  /**
   * 字体ttf文件的路径
   */
  ttfFilePath: string;

  /**
   * 目录路径
   */
  dirPath: string;

  /**
   * 字体预览图的路径
   */
  coverPath: string;

  /**
   * 是否当前在使用的字体
   */
  isCurrent: boolean;
}

/**
 * 预置资源管理接口
 */
export interface IPresetsManager {
  /**
   * 预置图标列表
   */
  readonly iconPresetsList: ReadonlyArray<IconPresets>;

  /**
   * 预置图标映射
   */
  readonly iconPresetsMap: ReadonlyMap<string, IconPresets>;

  /**
   * 预置字体列表
   */
  readonly fontPresetsList: ReadonlyArray<FontInfo>;

  /**
   * 预置字体映射
   */
  readonly fontPresetsMap: ReadonlyMap<string, FontInfo>;

  /**
   * 按需扫描预置目录
   * @param onlyIconNeedRefresh 是否只有图标需要刷新
   * @throws BaseError 预置资源目录结构存在问题，无法正常解析。
   */
  scanPresetsIfNecessary(onlyIconNeedRefresh?: boolean): Promise<void>;

  /**
   * 更新当前应用的图标或者字体
   * @param isIconFlag 是否为图标；true为图标，false为字体。
   * @param oldIndex 上一次应用的图标/字体的索引。
   * @param newIndex 本次应用的图标/字体索引。
   */
  updateCurrentIconOrFont(isIconFlag: boolean, oldIndex: number, newIndex: number): void;

  /**
   * 更新当前正在应用的图标Id
   * @returns 当前正在应用的图标Id在图标列表中的索引
   */
  updateCurrentIconId(): Promise<number>;
}

/**
 * 预置资源管理，通过接口对外暴露只读数据
 */
class PresetsManager implements IPresetsManager {
  private static readonly ACTIVATED_PATH_A: string = '/data/themes/a/';
  private static readonly ACTIVATED_PATH_B: string = '/data/themes/b/';
  private static readonly ACTIVATED_FLAG: string = 'app/flag';

  private static sharedInstance: PresetsManager | undefined;

  readonly iconPresetsList: Array<IconPresets>;
  readonly iconPresetsMap: Map<string, IconPresets>;

  readonly fontPresetsList: Array<FontInfo>;
  readonly fontPresetsMap: Map<string, FontInfo>;

  private isLoaded: boolean = false;

  private static getActivatedThemePath(): string {
    if (PresetsManager.isFileExists(PresetsManager.ACTIVATED_PATH_A + PresetsManager.ACTIVATED_FLAG)) {
      return PresetsManager.ACTIVATED_PATH_A;
    } else if (PresetsManager.isFileExists(PresetsManager.ACTIVATED_PATH_B + PresetsManager.ACTIVATED_FLAG)) {
      return PresetsManager.ACTIVATED_PATH_B;
    } else {
      return '';
    }
  }

  private static async getCurrentFontId(): Promise<string> {
    let cfgFile: string = `${PresetsManager.getActivatedThemePath()}app/fonts/manifest.json`;
    if (!PresetsManager.isFileExists(cfgFile)) {
      LogUtil.debug(`${TAG} ${cfgFile} no Exist`);
      return '';
    }
    try {
      let cfgFileContent: string | undefined = await PresetsManager.textOfFile(cfgFile);
      LogUtil.debug(`${TAG} getCurrentFontId:${cfgFileContent}`);
      if (cfgFileContent) {
        let cfg: object = JSON.parse(cfgFileContent);
        let id: string = cfg?.[`id`];
        return id;
      }
    } catch (err) {
      LogUtil.error(`${TAG} getCurrentFontId catch exception. err:${err?.code}, ${err?.message}`);
    }
    return '';
  }

  private static async getCurrentIconId(): Promise<string> {
    let cfgFile: string = `${PresetsManager.getActivatedThemePath()}app/icons/manifest.json`;
    if (!PresetsManager.isFileExists(cfgFile)) {
      LogUtil.info(`${TAG} ${cfgFile} no Exist`);
      return '';
    }
    try {
      let cfgFileContent: string | undefined = await PresetsManager.textOfFile(cfgFile);
      LogUtil.debug(`${TAG} getCurrentIconId:${cfgFileContent}`);
      if (cfgFileContent) {
        let cfg: object = JSON.parse(cfgFileContent);
        let id: string = cfg?.[`id`];
        return id;
      }
    } catch (err) {
      LogUtil.error(`${TAG} getCurrentIconId catch exception. err:${err.code}, ${err.message}`);
    }
    return '';
  }

  public async updateCurrentIconId(): Promise<number> {
    let currentIconId: string = await PresetsManager.getCurrentIconId();
    if (StringUtil.isNotEmpty(currentIconId)) {
      let currentIconIndex: number = -1;
      this.iconPresetsList.map((value, _index) => {
        if (value.id === currentIconId) {
          value.isCurrent = true;
          currentIconIndex = _index;
        } else {
          value.isCurrent = false;
        }
      });
      LogUtil.info(`${TAG} updateCurrentIconId, currentIconIndex = ${currentIconIndex}`);
      return currentIconIndex;
    }
    return -1;
  }

  /**
   * 共享单例
   * @returns 共享单例接口对象
   */
  static sharedManager(): IPresetsManager {
    if (!this.sharedInstance) {
      this.sharedInstance = new PresetsManager();
    }
    return this.sharedInstance;
  }

  private constructor() {
    this.iconPresetsList = new Array();
    this.iconPresetsMap = new Map();
    this.fontPresetsList = new Array();
    this.fontPresetsMap = new Map();
  }

  /**
   * 检查路径是否存在
   * @param path 待检查路径
   * @returns 如果路径不存在则返回 undefined
   */
  private async accessPathOrUndefined(path: string): Promise<string | undefined> {
    if (await fs.access(path)) {
      return path;
    }
    return undefined;
  }

  private static isFileExists(path: string): boolean {
    let exist = false;
    try {
      exist = fs.accessSync(path);
    } catch (e) {
      LogUtil.error(`${TAG} isFileExists error: ${e?.code}, ${e?.message}`);
    }
    return exist;
  }

  private static async isFile(path: string): Promise<boolean> {
    try {
      const attrs: fs.Stat = await fs.stat(path);
      return attrs.isFile();
    } catch (e) {
      LogUtil.error(`${TAG} isFile error: ${e?.code}, ${e?.message}`);
      return false;
    }
  }

  private static isDir(path: string): boolean {
    try {
      if (!PresetsManager.isFileExists(path)) {
        return false;
      }
      return fs.statSync(path).isDirectory();
    } catch (e) {
      LogUtil.error(`${TAG} isDir error: ${e?.code}, ${e?.message}`);
      return false;
    }
  }

  static async textOfFile(path: string): Promise<string | undefined> {
    try {
      return await fs.readText(path);
    } catch (e) {
      LogUtil.error(`${TAG} textOfFile error: ${e?.code}, ${e?.message}`);
      return undefined;
    }
  }

  private async preparePresetsIcon(iconPresetsPath: string): Promise<void> {
    try {
      let fileNames = fs.listFileSync(iconPresetsPath);
      fileNames.sort();
      let currentId: string = await PresetsManager.getCurrentIconId();
      for (let fileName of fileNames) {
        let subIconPath = iconPresetsPath + FILE_SEPARATOR + fileName;
        let manifest = subIconPath + FILE_SEPARATOR + PRESET_MANIFEST;
        if (!PresetsManager.isDir(subIconPath + FILE_SEPARATOR + PRESET_PATH_ICON_SUB) ||
          !PresetsManager.isDir(subIconPath + FILE_SEPARATOR + MANIFEST_KEY_PREVIEW)) {
          continue;
        }
        LogUtil.info(`${TAG} preparePresetIcon manifest`);
        const content: string = await PresetsManager.textOfFile(manifest);
        if (!content) {
          continue;
        }
        let json: object = JSON.parse(content);
        let iconId = json[MANIFEST_KEY_ID];
        let iconPreview = json[MANIFEST_KEY_PREVIEW];
        if (!iconId || !iconPreview) {
          LogUtil.error(`${TAG} invalid manifest`);
          continue;
        }
        let previewPath = subIconPath + FILE_SEPARATOR + MANIFEST_KEY_PREVIEW + FILE_SEPARATOR +
          BASE_PREFIX + FILE_SEPARATOR + iconPreview;
        if (!PresetsManager.isFile(previewPath)) {
          LogUtil.error(`${TAG} invalid previewPath`);
          continue;
        }
        const preset = new IconPresets({
          id: iconId,
          basePath: subIconPath,
          previewPath: previewPath,
          isCurrent: iconId === currentId
        });
        LogUtil.info(`${TAG} iconId = ${iconId}, currentId = ${currentId}`);
        this.iconPresetsList.push(preset);
        this.iconPresetsMap.set(preset.id, preset);
      }
    } catch (error) {
      LogUtil.error(`${TAG} foreach icon category error:${error.code} ${error.message}`);
    }
  }

  private async parseManifestFile(fullPath: string, defaultFont: FontInfo): Promise<void> {
    if (!PresetsManager.isFileExists(fullPath)) {
      return;
    }

    let manifestContent: string = '';
    try {
      manifestContent = fs.readTextSync(fullPath);
    } catch (error) {
      LogUtil.showError(TAG, 'parse manifest fail');
    }
    try {
      let manifest: Object = JSON.parse(manifestContent);
      defaultFont.id = manifest[MANIFEST_KEY_ID] ?? '';
      defaultFont.ttfFilePath = manifest[TTF_FILE] ?? '';
    } catch (error) {
      LogUtil.error(`${TAG} parse manifestContent error:${error.code} ${error.message}`);
    }
  }

  private parseFontImage(fullPath: string, defaultFont: FontInfo): void {
    let baseFile: string[] = fs.listFileSync(fullPath);
    for (let file of baseFile) {
      if (file.startsWith(COVER_IMAGE)) {
        defaultFont.coverPath = fullPath + FILE_SEPARATOR + file;
      }
    }
  }

  private async preparePresetsFont(fontPresetsPath: string): Promise<void> {
    try {
      let fileNames: string[] = fs.listFileSync(fontPresetsPath);
      fileNames.sort();
      let currentId = await PresetsManager.getCurrentFontId();
      for (let fileName of fileNames) {
        let fullPath: string = fontPresetsPath + FILE_SEPARATOR + fileName;
        this.readPresetsFont(fullPath, currentId);
      }
    } catch (error) {
      LogUtil.showError(TAG, `readDefaultFontResource, error:${error.code} ${error.message}`);
    }
  }

  private readPresetsFont(fullPath: string, currentId: string): void {
    if (PresetsManager.isDir(fullPath)) {
      let defaultFont: FontInfo = new FontInfo();
      defaultFont.dirPath = fullPath;

      this.parseManifestFile(fullPath + FILE_SEPARATOR + PRESET_MANIFEST, defaultFont);
      this.parseFontImage(fullPath + FILE_SEPARATOR + MANIFEST_KEY_PREVIEW + FILE_SEPARATOR + BASE_PREFIX, defaultFont);
      defaultFont.isCurrent = defaultFont?.id === currentId;

      let hasPreviewImage: boolean = defaultFont.coverPath &&
      PresetsManager.isFileExists(defaultFont.coverPath);
      if (PresetsManager.isFileExists(defaultFont.ttfFilePath) && hasPreviewImage) {
        this.fontPresetsList.push(defaultFont);
        this.fontPresetsMap.set(defaultFont.id, defaultFont);
      } else {
        LogUtil.showWarn(TAG, 'No such font file');
      }
    }
  }

  public async getPresetsRootPath(): Promise<string | undefined> {
    try {
      const rootPath: string | undefined = await configPolicy.getOneCfgFile(PRESETS_ROOT_RELATIVE_PATH);
      if (!rootPath || !rootPath.length) {
        LogUtil.error(`${TAG} getPresetsRootPath configPolicy.getOneCfgFile returned empty string, run in simulator?`);
        return undefined;
      }
      return rootPath;
    } catch (e) {
      LogUtil.error(`${TAG} getPresetsRootPath configPolicy.getOneCfgFile failed:${e?.code} ${e?.message}`);
      return undefined;
    }
  }

  private clearPresetIconWithOption(): void {
    this.iconPresetsList.length = 0;
    this.iconPresetsMap.clear();
  }

  private clearPresetFontWithOption(): void {
    this.fontPresetsList.length = 0;
    this.fontPresetsMap.clear();
  }

  public async scanPresetsIfNecessary(onlyIconNeedRefresh?: boolean): Promise<void> {
    LogUtil.info(`${TAG} start scanPresetsIfNecessary, onlyIconNeedRefresh = ${onlyIconNeedRefresh}`);
    if (this.isLoaded && !onlyIconNeedRefresh) {
      // 已经全面扫描过预置资源，不再重复扫描
      LogUtil.info(`${TAG} scanPresetsIfNecessary skipped: already loaded`);
      return;
    }

    // 获取预置目录路径
    const iconPath: string | undefined = await configPolicy.getOneCfgFile('resource/themes/icon');
    if (!iconPath) {
      // 读取配置信息失败
      LogUtil.error(`${TAG} scanPresetsIfNecessary getPresetsRootPath failed!`);
      return;
    }
    LogUtil.info(`${TAG} scanPresetsIfNecessary getPresetsRootPath successfully.`);

    // 清空预置资源列表
    this.clearPresetIconWithOption();
    if (!onlyIconNeedRefresh) {
      this.clearPresetFontWithOption();
    }

    // 扫描预置图标信息
    const iconPresetsPath: string | undefined = await this.accessPathOrUndefined(iconPath);
    if (iconPresetsPath) {
      await this.preparePresetsIcon(iconPresetsPath);
    }

    if (onlyIconNeedRefresh) {
      LogUtil.info(`${TAG} scanPresets icon ${this.iconPresetsList.length}`);
      return;
    }

    const fontPath: string | undefined = await configPolicy.getOneCfgFile('resource/themes/font');
    if (!fontPath) {
      // 读取配置信息失败
      LogUtil.info(`${TAG} scanPresetsIfNecessary no font`);
      return;
    }

    // 扫描预置字体信息
    const fontPresetsPath: string | undefined = await this.accessPathOrUndefined(fontPath);
    if (fontPresetsPath) {
      await this.preparePresetsFont(fontPresetsPath);
    }

    this.isLoaded = true;
    LogUtil.info(`${TAG} scanPresets icon ${this.iconPresetsList.length} font ${this.fontPresetsList.length}`);
  }

  public updateCurrentIconOrFont(isIconFlag: boolean, oldIndex: number, newIndex: number): void {
    let presetsList: Array<IconPresets | FontInfo> = isIconFlag ? this.iconPresetsList : this.fontPresetsList;
    if (presetsList.length > Math.max(oldIndex, newIndex) && presetsList[oldIndex] && presetsList[newIndex]) {
      presetsList[oldIndex].isCurrent = false;
      presetsList[newIndex].isCurrent = true;
    }
  }
}

/**
 * 全局单例
 */
export const PRESETS_MANAGER: IPresetsManager = PresetsManager.sharedManager();
