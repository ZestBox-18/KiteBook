import { hdsMaterial, HdsNavigation, ScrollEffectType, HdsAnimationMode } from '@kit.UIDesignKit';
import { CommonConstants, RouterUrlConstants, SystemOptions, mainTabController } from 'base';
import { Assets, Ordinary } from 'record';
import { AppStorageV2, LengthMetrics } from '@kit.ArkUI';
import { WindowUtil } from 'kite_utils';
import { PersistenceV2 } from '@ohos.arkui.StateManagement';
import { DataOverviewCard } from '../components/DataOverviewCard';
import { TimelineBillCard } from '../components/TimelineBillCard';
import { FloatingActionButton } from '../components/FloatingActionButton';
import { BillItem } from '../entities/BillItem';
import { BudgetItem } from '../entities/BudgetItem';
import { CategoryItem } from '../entities/CategoryItem';
import { 
  queryBillsByMonth, 
  queryBudgetsByMonth, 
  queryAccounts,
  calculateMonthIncome,
  calculateMonthExpense,
  calculateMonthBalance,
  calculateBudgetProgress
} from '../utils/HomeDataHelper';

@ComponentV2
export struct Index {
  @Local pageInfos: NavPathStack = new NavPathStack();
  @Local winUtil: WindowUtil = AppStorageV2.connect(WindowUtil, 'winUtil')!;
  private scrollerForScroll: Scroller = new Scroller();
  @Local optionSystem: SystemOptions =
    PersistenceV2.connect(SystemOptions, 'SystemOptions', () => new SystemOptions())!
  
  // 数据状态
  @Local monthIncome: number = 0;
  @Local monthExpense: number = 0;
  @Local monthBalance: number = 0;
  @Local accountBalance: number = 0;
  @Local budgets: BudgetItem[] = [];
  @Local recentBills: BillItem[] = [];
  @Local isLoading: boolean = true;
  
  // 快捷分类
  private quickCategories: CategoryItem[] = [
    { name: '餐饮', icon: 'sys.symbol.restaurant', color: '#FF6B6B' },
    { name: '交通', icon: 'sys.symbol.car', color: '#4ECDC4' },
    { name: '购物', icon: 'sys.symbol.shopping_cart', color: '#45B7D1' },
    { name: '娱乐', icon: 'sys.symbol.game_controller', color: '#96CEB4' },
    { name: '医疗', icon: 'sys.symbol.pill', color: '#FFEAA7' },
    { name: '教育', icon: 'sys.symbol.book', color: '#DDA0DD' }
  ];
  
  @Builder
  PagesMap(name: string, param?: object) {
    if (name === RouterUrlConstants.ORDINARY) {
      Ordinary()
    }
    if (name === RouterUrlConstants.ASSETS) {
      Assets()
    }
  }
  
  private navigateToSubPage(name: string): void {
    mainTabController.applyHideAnimation(HdsAnimationMode.SCROLL_ANIMATION);
    this.pageInfos.pushPath({ name: name });
  }
  
  /**
   * 加载首页数据
   */
  private async loadHomeData(): Promise<void> {
    this.isLoading = true;
    
    try {
      // 获取本月时间范围
      const now = new Date();
      const month = `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, '0')}`;
      
      // 查询数据
      const bills = await queryBillsByMonth(month);
      const budgetsData = await queryBudgetsByMonth(month);
      const accounts = await queryAccounts();
      
      // 计算统计数据
      this.monthIncome = calculateMonthIncome(bills);
      this.monthExpense = calculateMonthExpense(bills);
      this.monthBalance = calculateMonthBalance(this.monthIncome, this.monthExpense);
      
      // 计算账户余额
      this.accountBalance = accounts.reduce((sum, account) => sum + account.balance, 0);
      
      // 计算预算进度
      this.budgets = budgetsData.map(budget => calculateBudgetProgress(budget, bills));
      
      // 最近账单（最多10条）
      this.recentBills = bills.slice(0, 10);
      
    } catch (error) {
      console.error('加载首页数据失败', error);
    } finally {
      this.isLoading = false;
    }
  }
  
  /**
   * 处理快捷记账点击
   */
  private handleQuickAction(category: CategoryItem): void {
    // 跳转到记账页面，携带分类信息
    this.navigateToSubPage(RouterUrlConstants.ORDINARY);
  }
  
  /**
   * 处理账单点击
   */
  private handleBillClick(bill: BillItem): void {
    // 跳转到编辑页面，携带账单ID
    this.navigateToSubPage(RouterUrlConstants.ORDINARY);
  }
  
  /**
   * 处理账单删除
   */
  private async handleBillDelete(bill: BillItem): Promise<void> {
    // TODO: 实现删除逻辑
    // 删除后重新加载数据
    await this.loadHomeData();
  }
  
  /**
   * 查看全部账单
   */
  private handleViewAll(): void {
    // 跳转到账单页面
    // this.navigateToSubPage(RouterUrlConstants.BILLING);
  }
  
  aboutToAppear() {
    // 加载首页数据
    this.loadHomeData();
  }
  
  build() {
    HdsNavigation(this.pageInfos) {
      Stack() {
        Scroll(this.scrollerForScroll) {
          Column() {
            // 顶部安全区
            Blank().height(this.winUtil.mainWindowInfo.safeAreaTop + CommonConstants.TITLE_BAR_HEIGHT_FREE)
            
            // 数据概览卡片
            DataOverviewCard({
              monthIncome: this.monthIncome,
              monthExpense: this.monthExpense,
              monthBalance: this.monthBalance,
              accountBalance: this.accountBalance,
              budgets: this.budgets,
              isLoading: this.isLoading
            })
            
            // 时间轴账单卡片
            TimelineBillCard({
              bills: this.recentBills,
              onBillClick: (bill: BillItem) => {
                this.handleBillClick(bill);
              },
              onBillDelete: (bill: BillItem) => {
                this.handleBillDelete(bill);
              },
              onViewAll: () => {
                this.handleViewAll();
              }
            })
            .margin({ top: 16 })
            
            // 底部留白
            Blank().height(20)
          }
          .width('100%')
          .padding({ left: 16, right: 16 })
        }
        .width('100%')
        .height('100%')
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
        
        // 浮动记账按钮
        FloatingActionButton({
          categories: this.quickCategories,
          onCategoryClick: (category: CategoryItem) => {
            this.handleQuickAction(category);
          }
        })
      }
      .width('100%')
      .height('100%')
    }
    .width(CommonConstants.FULL_WIN)
    .height(CommonConstants.FULL_WIN)
    .mode(NavigationMode.Stack)
    .navDestination(this.PagesMap)
    .titleBar({
      style: {
        scrollEffectOpts: {
          enableScrollEffect: true,
          scrollEffectType: ScrollEffectType.IMMERSIVE_GRADIENT_BLUR,
          blurEffectiveStartOffset: LengthMetrics.vp(0),
          blurEffectiveEndOffset: LengthMetrics.vp(20)
        },
        systemMaterialEffect: {
          materialType: hdsMaterial.MaterialType.ADAPTIVE,
          materialLevel: hdsMaterial.MaterialLevel.ADAPTIVE
        },
        originalStyle: {
          backgroundStyle: {
            backgroundColor: $r('app.color.title_bar_bg'),
          },
          contentStyle: {
            titleStyle: {
              mainTitleColor: $r('app.color.text_primary'),
              subTitleColor: $r('app.color.text_secondary')
            },
            menuStyle: {
              backgroundColor: $r('app.color.action_bg'),
              textColor: $r('app.color.text_secondary'),
              iconColor: $r('app.color.text_primary')
            },
            backIconStyle: {
              backgroundColor: $r('app.color.action_bg'),
              iconColor: $r('app.color.text_primary')
            },
          }
        },
        scrollEffectStyle: {
          backgroundStyle: {
            backgroundColor: $r('app.color.title_bar_bg'),
          },
          contentStyle: {
            titleStyle: {
              mainTitleColor: $r('app.color.text_primary'),
              subTitleColor: $r('app.color.text_secondary'),
            },
            menuStyle: {
              backgroundColor: $r('app.color.action_bg'),
              textColor: $r('app.color.text_secondary'),
              iconColor: $r('app.color.text_primary')
            },
            backIconStyle: {
              backgroundColor: $r('app.color.action_bg'),
              iconColor: $r('app.color.text_primary')
            }
          }
        }
      },
      content: {
        title: {
          mainTitle: '纸鸢账本',
          subTitle: '个人账本'
        },
        menu: {
          value: [{
            content: {
              icon: $r('sys.symbol.house'),
              label: 'logo',
              action: () => {
              },
            }
          }]
        },
      },
      avoidLayoutSafeArea: true
    })
    .bindToScrollable([this.scrollerForScroll])
    .ignoreLayoutSafeArea([LayoutSafeAreaType.SYSTEM], [LayoutSafeAreaEdge.TOP, LayoutSafeAreaEdge.BOTTOM])
  }
}
