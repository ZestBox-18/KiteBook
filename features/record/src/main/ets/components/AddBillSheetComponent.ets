/**
 * Copyright (C), 2026-05-18
 * @author ZestBox
 * @date 2026/05/18
 * @version 1.0
 * @description: 新增账单半模态组件
 */

import {
  AppThemeState,
  BillBean,
  BillManager,
  BillTypeEnum,
  SystemOptions
} from 'base';
import { curves } from '@kit.ArkUI';
import { CapsuleSegmentButtonV2, SegmentButtonV2Items } from '@ohos.arkui.advanced.SegmentButtonV2';
import { ColorMetrics, LengthMetrics } from '@ohos.arkui.node';

const KEYBOARD_CORNER_RADIUS: number = 22;
const CATEGORY_CARD_SIZE: number = 74;
const KEYBOARD_KEYS_PER_ROW: number = 4;
const REMARK_PANEL_COLLAPSED_HEIGHT: number = 0;
const REMARK_PANEL_EXPANDED_HEIGHT: number = 88;
const RECORD_MODE_EXPENSE: string = 'expense';
const RECORD_MODE_INCOME: string = 'income';
const RECORD_MODE_TRANSFER: string = 'transfer';

class CategoryOption {
  label: string = '';
  icon: Resource = $r('sys.symbol.creditcard');

  constructor(label: string, icon: Resource) {
    this.label = label;
    this.icon = icon;
  }
}

class KeypadKey {
  label: string = '';
  action: string = '';
  isPrimary: boolean = false;
  isAccent: boolean = false;

  constructor(label: string, action: string, isPrimary: boolean = false, isAccent: boolean = false) {
    this.label = label;
    this.action = action;
    this.isPrimary = isPrimary;
    this.isAccent = isAccent;
  }
}

@ComponentV2
export struct AddBillSheetComponent {
  @Require @Param themeState: AppThemeState;
  @Require @Param optionSystem: SystemOptions;
  @Event onClose: () => void = () => {
  };
  @Event onSaved: () => void = () => {
  };

  @Local amountText: string = '0';
  @Local activeMode: string = RECORD_MODE_EXPENSE;
  @Local selectedType: string = BillTypeEnum.EXPENSE;
  @Local selectedCategory: string = '餐饮';
  @Local selectedAccount: string = '微信';
  @Local remarkText: string = '';
  @Local isSaving: boolean = false;
  @Local selectedDate: number = Date.now();
  @Local isRemarkExpanded: boolean = false;
  @Local remarkPanelHeight: number = REMARK_PANEL_COLLAPSED_HEIGHT;
  @Local remarkPanelOpacity: number = 0;

  private scroller: Scroller = new Scroller();
  private readonly modeSegmentItems: SegmentButtonV2Items = new SegmentButtonV2Items([
    { text: '支出' },
    { text: '收入' },
    { text: '转账' }
  ]);
  private readonly expenseCategories: CategoryOption[] = [
    new CategoryOption('餐饮', $r('sys.symbol.fork_knife')),
    new CategoryOption('交通', $r('sys.symbol.car')),
    new CategoryOption('购物', $r('sys.symbol.cart')),
    new CategoryOption('娱乐', $r('sys.symbol.gamecontroller')),
    new CategoryOption('住房', $r('sys.symbol.house')),
    new CategoryOption('医疗', $r('sys.symbol.cross_case')),
    new CategoryOption('教育', $r('sys.symbol.book')),
    new CategoryOption('其他', $r('sys.symbol.ellipsis_circle'))
  ];
  private readonly incomeCategories: CategoryOption[] = [
    new CategoryOption('工资', $r('sys.symbol.creditcard')),
    new CategoryOption('奖金', $r('sys.symbol.gift')),
    new CategoryOption('理财', $r('sys.symbol.arrow_up_circle')),
    new CategoryOption('其他', $r('sys.symbol.ellipsis_circle'))
  ];
  private readonly accounts: string[] = ['微信', '支付宝', '银行卡'];
  private readonly keypadKeys: KeypadKey[] = [
    new KeypadKey('1', 'digit_1'),
    new KeypadKey('2', 'digit_2'),
    new KeypadKey('3', 'digit_3'),
    new KeypadKey('⌫', 'delete'),
    new KeypadKey('4', 'digit_4'),
    new KeypadKey('5', 'digit_5'),
    new KeypadKey('6', 'digit_6'),
    new KeypadKey('-', 'minus', false, true),
    new KeypadKey('7', 'digit_7'),
    new KeypadKey('8', 'digit_8'),
    new KeypadKey('9', 'digit_9'),
    new KeypadKey('+', 'plus', false, true),
    new KeypadKey('再记', 'save_continue'),
    new KeypadKey('0', 'digit_0'),
    new KeypadKey('.', 'decimal'),
    new KeypadKey('保存', 'save_close', true)
  ];

  /**
   * 构建半模态主体布局，顶部直接展示模式切换与关闭操作。
   */
  build() {
    Column() {
      this.TopActionSection()

      Stack({ alignContent: Alignment.Top }) {
        List({ scroller: this.scroller }) {
          ListItem() {
            Column() {
              this.CategoryGridSection()
            }
            .width('100%')
            .padding({ left: 16, right: 16, top: 6, bottom: 20 })
          }
        }
        .width('100%')
        .height('100%')
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
        .fadingEdge(true)

        this.TopFadeMask()
        this.BottomFadeMask()
      }
      .width('100%')
      .layoutWeight(1)

      Column({ space: 10 }) {
        this.AmountEditorSection()
        this.CustomKeyboardSection()
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 8, bottom: 18 })
      .backgroundColor(this.themeState.backgroundPrimary)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeState.backgroundPrimary)
  }

  /**
   * 返回当前账单类型对应的分类选项。
   */
  private getCurrentCategoryOptions(): CategoryOption[] {
    if (this.activeMode === RECORD_MODE_TRANSFER) {
      return [new CategoryOption('转账', $r('sys.symbol.arrow_left_arrow_right'))];
    }
    return this.selectedType === BillTypeEnum.EXPENSE ? this.expenseCategories : this.incomeCategories;
  }

  /**
   * 切换账单类型后修正默认分类，避免出现无效选项。
   */
  private updateCategoryForCurrentType(): void {
    const categories: CategoryOption[] = this.getCurrentCategoryOptions();
    let hasMatchedCategory: boolean = false;
    categories.forEach((item: CategoryOption) => {
      if (item.label === this.selectedCategory) {
        hasMatchedCategory = true;
      }
    });
    if (!hasMatchedCategory && categories.length > 0) {
      this.selectedCategory = categories[0].label;
    }
  }

  /**
   * 将账单类型映射为金额显示色。
   */
  private getAmountToneColor(): ResourceColor {
    if (this.activeMode === RECORD_MODE_TRANSFER) {
      return this.themeState.fontPrimary as ResourceColor;
    }
    if (this.selectedType === BillTypeEnum.INCOME) {
      return this.themeState.brand as ResourceColor;
    }
    return '#E55454';
  }

  /**
   * 返回格式化后的日期文案。
   */
  private getSelectedDateText(): string {
    const date: Date = new Date(this.selectedDate);
    return `${date.getMonth() + 1}月${date.getDate()}日`;
  }

  /**
   * 根据索引计算每行应展示的数字键盘按键。
   */
  private getKeyboardRow(rowIndex: number): KeypadKey[] {
    const startIndex: number = rowIndex * KEYBOARD_KEYS_PER_ROW;
    return this.keypadKeys.slice(startIndex, startIndex + KEYBOARD_KEYS_PER_ROW);
  }

  /**
   * 返回顶部模式切换对应的选中索引。
   */
  private getModeSelectedIndex(): number {
    if (this.activeMode === RECORD_MODE_INCOME) {
      return 1;
    }
    if (this.activeMode === RECORD_MODE_TRANSFER) {
      return 2;
    }
    return 0;
  }

  /**
   * 根据分段索引切换当前录入模式。
   */
  private updateModeByIndex(selectedIndex: number): void {
    if (selectedIndex === 1) {
      this.activeMode = RECORD_MODE_INCOME;
      this.selectedType = BillTypeEnum.INCOME;
    } else if (selectedIndex === 2) {
      this.activeMode = RECORD_MODE_TRANSFER;
    } else {
      this.activeMode = RECORD_MODE_EXPENSE;
      this.selectedType = BillTypeEnum.EXPENSE;
    }
    this.updateCategoryForCurrentType();
  }

  /**
   * 返回当前选中的支付账户名称。
   */
  private getSelectedAccountLabel(): string {
    return this.selectedAccount;
  }

  /**
   * 轮换支付账户，减少顶部占位。
   */
  private cycleSelectedAccount(): void {
    let currentIndex: number = 0;
    this.accounts.forEach((account: string, index: number) => {
      if (account === this.selectedAccount) {
        currentIndex = index;
      }
    });
    const nextIndex: number = (currentIndex + 1) % this.accounts.length;
    this.selectedAccount = this.accounts[nextIndex];
  }

  /**
   * 将数字追加到金额字符串，最多保留两位小数。
   */
  private appendDigit(digit: string): void {
    if (this.amountText.includes('.')) {
      const decimalPart: string = this.amountText.split('.')[1];
      if (decimalPart.length >= 2) {
        return;
      }
    }

    if (this.amountText === '0') {
      this.amountText = digit;
      return;
    }
    if (this.amountText === '-0') {
      this.amountText = `-${digit}`;
      return;
    }
    this.amountText = `${this.amountText}${digit}`;
  }

  /**
   * 为金额补充小数点，避免重复输入。
   */
  private appendDecimalPoint(): void {
    if (this.amountText.includes('.')) {
      return;
    }
    this.amountText = `${this.amountText}.`;
  }

  /**
   * 删除金额末尾字符，并保持最小可显示格式。
   */
  private removeLastCharacter(): void {
    if (this.amountText.length <= 1) {
      this.amountText = '0';
      return;
    }
    this.amountText = this.amountText.slice(0, this.amountText.length - 1);
    if (this.amountText === '-' || this.amountText === '-0') {
      this.amountText = '0';
    }
  }

  /**
   * 切换金额正负号，便于快速修正录入方向。
   */
  private toggleAmountSign(): void {
    if (this.amountText === '0' || this.amountText === '0.') {
      return;
    }
    if (this.amountText.startsWith('-')) {
      this.amountText = this.amountText.slice(1);
      return;
    }
    this.amountText = `-${this.amountText}`;
  }

  /**
   * 根据按键动作更新金额或触发保存。
   */
  private handleKeyboardAction(action: string): void {
    if (action.startsWith('digit_')) {
      this.appendDigit(action.substring(6));
      return;
    }
    if (action === 'decimal') {
      this.appendDecimalPoint();
      return;
    }
    if (action === 'delete') {
      this.removeLastCharacter();
      return;
    }
    if (action === 'minus' || action === 'plus') {
      this.toggleAmountSign();
      return;
    }
    if (action === 'save_continue') {
      this.submitBill(false);
      return;
    }
    if (action === 'save_close') {
      this.submitBill(true);
    }
  }

  /**
   * 校验输入内容并返回可提交的金额。
   */
  private validateAmount(): number {
    if (this.activeMode === RECORD_MODE_TRANSFER) {
      this.showToast('转账录入稍后支持');
      return 0;
    }
    const amountValue: number = Number(this.amountText);
    if (!Number.isFinite(amountValue) || amountValue === 0) {
      this.showToast('请输入正确的金额');
      return 0;
    }
    return Math.abs(amountValue);
  }

  /**
   * 构建待保存的账单对象。
   */
  private buildBill(amountValue: number): BillBean {
    const bill: BillBean = new BillBean();
    bill.type = this.selectedType;
    bill.category = this.selectedCategory;
    bill.amount = amountValue;
    bill.account = this.selectedAccount;
    bill.date = this.selectedDate;
    bill.remark = this.remarkText.trim();
    return bill;
  }

  /**
   * 提交新增账单，支持保存后关闭或继续记账两种模式。
   */
  private async submitBill(closeAfterSave: boolean): Promise<void> {
    if (this.isSaving) {
      return;
    }
    const amountValue: number = this.validateAmount();
    if (amountValue <= 0) {
      return;
    }

    this.isSaving = true;
    try {
      await BillManager.addBill(this.buildBill(amountValue));
      this.showToast('已保存账单');
      this.onSaved();
      this.resetForm();
      if (closeAfterSave) {
        this.handleClose();
      }
    } catch (err) {
      this.showToast('保存失败，请稍后重试');
    } finally {
      this.isSaving = false;
    }
  }

  /**
   * 关闭半模态，并保持当前退出动效平滑。
   */
  private handleClose(): void {
    this.getUIContext().animateTo({
      duration: 220,
      curve: curves.springMotion(0.6, 0.9)
    }, () => {
      this.onClose();
    });
  }

  /**
   * 将表单状态恢复为默认值，便于下一笔继续录入。
   */
  private resetForm(): void {
    this.amountText = '0';
    this.activeMode = RECORD_MODE_EXPENSE;
    this.selectedType = BillTypeEnum.EXPENSE;
    this.selectedCategory = '餐饮';
    this.selectedAccount = '微信';
    this.remarkText = '';
    this.selectedDate = Date.now();
    this.updateRemarkPanel(false);
  }

  /**
   * 切换备注编辑区展开状态，让输入区在底部面板内平滑伸缩。
   */
  private updateRemarkPanel(expanded: boolean): void {
    this.getUIContext().animateTo({
      duration: 220,
      curve: curves.springMotion(0.6, 0.9)
    }, () => {
      this.isRemarkExpanded = expanded;
      this.remarkPanelHeight = expanded ? REMARK_PANEL_EXPANDED_HEIGHT : REMARK_PANEL_COLLAPSED_HEIGHT;
      this.remarkPanelOpacity = expanded ? 1 : 0;
    });
  }

  /**
   * 统一弹出操作结果提示。
   */
  private showToast(message: string): void {
    try {
      this.getUIContext().getPromptAction().showToast({
        message: message,
        duration: 1800
      });
    } catch {
    }
  }

  /**
   * 构建顶部操作区，左侧是分段切换，右侧是关闭按钮。
   */
  @Builder
  private TopActionSection() {
    Row() {
      CapsuleSegmentButtonV2({
        items: this.modeSegmentItems,
        selectedIndex: this.getModeSelectedIndex(),
        itemFontSize: LengthMetrics.vp(14),
        itemSelectedFontSize: LengthMetrics.vp(14),
        itemFontWeight: FontWeight.Medium,
        itemSelectedFontWeight: FontWeight.Bold,
        itemFontColor: ColorMetrics.resourceColor(this.themeState.fontPrimary as ResourceColor),
        itemSelectedFontColor: ColorMetrics.resourceColor(this.themeState.fontOnPrimary as ResourceColor),
        itemSelectedBackgroundColor: ColorMetrics.resourceColor(this.themeState.brand as ResourceColor),
        buttonBackgroundColor: ColorMetrics.resourceColor(this.themeState.compBackgroundPrimary as ResourceColor),
        buttonBorderRadius: LengthMetrics.vp(24),
        itemBorderRadius: LengthMetrics.vp(20),
        buttonPadding: LengthMetrics.vp(4),
        buttonMinHeight: LengthMetrics.vp(44),
        itemMinHeight: LengthMetrics.vp(36),
        $selectedIndex: (selectedIndex: number) => {
          this.updateModeByIndex(selectedIndex);
        }
      })
      .layoutWeight(1)

      Button() {
        SymbolGlyph($r('sys.symbol.xmark'))
          .fontSize(18)
          .fontColor([this.themeState.fontPrimary as ResourceColor])
      }
      .width(40)
      .height(40)
      .padding(0)
      .backgroundColor(this.themeState.compBackgroundPrimary)
      .borderRadius(20)
      .border({ width: 1, color: this.themeState.compDivider })
      .onClick(() => {
        this.handleClose();
      })
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 16, bottom: 10 })
    .alignItems(VerticalAlign.Center)
  }

  /**
   * 构建列表顶部渐隐遮罩，视觉上弱化滚动起点。
   */
  @Builder
  private TopFadeMask() {
    Column()
      .width('100%')
      .height(20)
      .linearGradient({
        angle: 180,
        colors: [[this.themeState.backgroundPrimary as ResourceColor, 0], ['#00FFFFFF', 1]]
      })
      .hitTestBehavior(HitTestMode.None)
  }

  /**
   * 构建列表底部渐隐遮罩，让分类区过渡到固定录入面板更自然。
   */
  @Builder
  private BottomFadeMask() {
    Column() {
      Blank()
      Column()
        .width('100%')
        .height(28)
        .linearGradient({
          angle: 0,
          colors: [[this.themeState.backgroundPrimary as ResourceColor, 0], ['#00FFFFFF', 1]]
        })
    }
    .width('100%')
    .height('100%')
    .hitTestBehavior(HitTestMode.None)
  }

  /**
   * 构建参考图风格的分类宫格区域。
   */
  @Builder
  private CategoryGridSection() {
    Column({ space: 14 }) {
      this.SectionHeader('分类');

      Flex({ wrap: FlexWrap.Wrap, direction: FlexDirection.Row }) {
        ForEach(this.getCurrentCategoryOptions(), (item: CategoryOption) => {
          this.CategoryCard(item);
        }, (item: CategoryOption) => item.label);
      }
      .width('100%')
    }
    .width('100%')
    .padding({ top: 4 })
    .alignItems(HorizontalAlign.Start)
  }

  /**
   * 构建备注展开编辑区，默认收起，激活后在底部面板中放大展示。
   */
  @Builder
  private RemarkEditorSection() {
    Column() {
      TextInput({ text: this.remarkText, placeholder: '写点备注，让这笔账更容易回忆' })
        .fontSize(16)
        .fontWeight(this.optionSystem.fontThickness)
        .fontColor(this.themeState.fontPrimary)
        .placeholderColor(this.themeState.fontSecondary)
        .width('100%')
        .height(56)
        .padding({ left: 16, right: 16 })
        .backgroundColor(this.themeState.compBackgroundPrimary)
        .borderRadius(18)
        .onFocus(() => {
          this.updateRemarkPanel(true);
        })
        .onBlur(() => {
          if (this.remarkText.trim().length === 0) {
            this.updateRemarkPanel(false);
          }
        })
        .onChange((value: string) => {
          this.remarkText = value;
        });
    }
    .width('100%')
    .height(this.remarkPanelHeight)
    .opacity(this.remarkPanelOpacity)
    .clip(true)
  }

  /**
   * 构建固定在键盘上方的金额展示面板。
   */
  @Builder
  private AmountEditorSection() {
    Column({ space: 10 }) {
      this.EntryMetaRow()
      this.RemarkEditorSection()

      Row() {
        Text(`¥ ${this.amountText}`)
          .fontSize(30)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.getAmountToneColor())
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis });
        Blank();
        Text(this.selectedCategory)
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeState.fontSecondary);
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .padding(16)
    .backgroundColor(this.themeState.compBackgroundPrimary)
    .borderRadius(22)
    .border({ width: 1, color: this.themeState.compDivider })
    .alignItems(HorizontalAlign.Start)
  }

  /**
   * 构建底部自定义数字键盘。
   */
  @Builder
  private CustomKeyboardSection() {
    Column({ space: 10 }) {
      ForEach([0, 1, 2, 3], (rowIndex: number) => {
        Row({ space: 10 }) {
          ForEach(this.getKeyboardRow(rowIndex), (keyItem: KeypadKey) => {
            this.KeyboardKey(keyItem);
          }, (keyItem: KeypadKey) => keyItem.action);
        }
        .width('100%');
      }, (rowIndex: number) => `${rowIndex}`);
    }
    .width('100%')
    .padding({ top: 4 })
  }

  /**
   * 构建分类宫格里的单个分类卡片。
   */
  @Builder
  private CategoryCard(item: CategoryOption) {
    Column({ space: 8 }) {
      Row() {
        SymbolGlyph(item.icon)
          .fontSize(28)
          .fontWeight(this.optionSystem.iconThickness)
          .fontColor([this.selectedCategory === item.label ? this.themeState.fontOnPrimary as ResourceColor :
            this.themeState.brand as ResourceColor]);
      }
      .width(CATEGORY_CARD_SIZE)
      .height(CATEGORY_CARD_SIZE)
      .justifyContent(FlexAlign.Center)
      .borderRadius(24)
      .backgroundColor(this.selectedCategory === item.label ? this.themeState.brand as ResourceColor :
        this.themeState.compBackgroundPrimary)
      .border({
        width: 1,
        color: this.selectedCategory === item.label ? this.themeState.brand as ResourceColor :
          this.themeState.compDivider
      });

      Text(item.label)
        .fontSize(14)
        .fontWeight(this.selectedCategory === item.label ? FontWeight.Bold : FontWeight.Medium)
        .fontColor(this.themeState.fontPrimary);
    }
    .width('20%')
    .margin({ bottom: 14 })
    .alignItems(HorizontalAlign.Center)
    .onClick(() => {
      this.selectedCategory = item.label;
    })
  }

  /**
   * 构建金额上方的紧凑信息条。
   */
  @Builder
  private EntryMetaRow() {
    Row({ space: 8 }) {
      this.MetaPill(this.getSelectedAccountLabel(), $r('sys.symbol.creditcard'), () => {
        this.cycleSelectedAccount();
      });
      this.MetaPill(this.getSelectedDateText(), $r('sys.symbol.calendar'), () => {
      });
      this.RemarkTriggerPill();
    }
    .width('100%')
    .justifyContent(FlexAlign.Start)
  }

  /**
   * 构建账户、日期这类紧凑型信息按钮。
   */
  @Builder
  private MetaPill(text: string, icon: Resource, onClickAction: () => void) {
    Button() {
      Row({ space: 6 }) {
        SymbolGlyph(icon)
          .fontSize(15)
          .fontWeight(this.optionSystem.iconThickness)
          .fontColor([this.themeState.brand as ResourceColor]);
        Text(text)
          .fontSize(13)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeState.fontPrimary)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis });
      }
    }
    .height(34)
    .padding({ left: 12, right: 12 })
    .backgroundColor(this.themeState.backgroundPrimary)
    .borderRadius(17)
    .border({ width: 1, color: this.themeState.compDivider })
    .onClick(() => {
      onClickAction();
    })
  }

  /**
   * 构建数字键盘单个按钮。
   */
  /**
   * 构建备注入口 pill，点击后在金额上方展开输入区。
   */
  @Builder
  private RemarkTriggerPill() {
    Button() {
      Row({ space: 8 }) {
        SymbolGlyph($r('sys.symbol.square_and_pencil'))
          .fontSize(16)
          .fontWeight(this.optionSystem.iconThickness)
          .fontColor([this.isRemarkExpanded ? this.themeState.fontOnPrimary as ResourceColor :
            this.themeState.brand as ResourceColor]);
        Text(this.remarkText.trim().length > 0 ? this.remarkText : '备注')
          .fontSize(13)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.isRemarkExpanded ? this.themeState.fontOnPrimary : this.themeState.fontPrimary)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis });
      }
    }
    .height(34)
    .padding({ left: 12, right: 12 })
    .backgroundColor(this.isRemarkExpanded ? this.themeState.brand as ResourceColor :
      this.themeState.backgroundPrimary)
    .borderRadius(17)
    .border({
      width: 1,
      color: this.isRemarkExpanded ? this.themeState.brand as ResourceColor : this.themeState.compDivider
    })
    .onClick(() => {
      this.updateRemarkPanel(!this.isRemarkExpanded);
    })
  }

  /**
   * 构建数字键盘单个按钮。
   */
  @Builder
  private KeyboardKey(keyItem: KeypadKey) {
    Button(keyItem.label)
      .width('23%')
      .height(72)
      .fontSize(keyItem.isPrimary ? 18 : 22)
      .fontWeight(keyItem.isPrimary ? FontWeight.Bold : FontWeight.Medium)
      .fontColor(this.getKeyboardKeyTextColor(keyItem))
      .backgroundColor(this.getKeyboardKeyBackgroundColor(keyItem))
      .borderRadius(KEYBOARD_CORNER_RADIUS)
      .enabled(!this.isSaving)
      .onClick(() => {
        this.handleKeyboardAction(keyItem.action);
      })
  }

  /**
   * 返回键盘按钮对应的文字颜色。
   */
  private getKeyboardKeyTextColor(keyItem: KeypadKey): ResourceColor {
    if (keyItem.isPrimary) {
      return this.themeState.fontOnPrimary as ResourceColor;
    }
    if (keyItem.isAccent) {
      return this.themeState.brand as ResourceColor;
    }
    return this.themeState.fontPrimary as ResourceColor;
  }

  /**
   * 返回键盘按钮对应的背景颜色。
   */
  private getKeyboardKeyBackgroundColor(keyItem: KeypadKey): ResourceColor {
    if (keyItem.isPrimary) {
      return this.themeState.brand as ResourceColor;
    }
    return this.themeState.compBackgroundPrimary;
  }

  /**
   * 构建分区标题。
   */
  @Builder
  private SectionHeader(title: string) {
    Text(title)
      .fontSize(14)
      .fontWeight(FontWeight.Medium)
      .fontColor(this.themeState.fontSecondary)
      .width('100%')
  }
}
