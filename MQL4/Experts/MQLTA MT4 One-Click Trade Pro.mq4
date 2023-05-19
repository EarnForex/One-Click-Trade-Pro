#property link          "https://www.earnforex.com/metatrader-expert-advisors/one-click-trade-pro/"
#property version       "1.06"
#property strict
#property copyright     "EarnForex.com - 2019-2023"
#property description   "This expert advisor allows you to open trades with just one click."
#property description   "It provides the ability to specify a comment and magic number."
#property description   "You can also view the list of orders with Magic number and change stop-loss and take-profit levels."
#property description   " "
#property description   "Find more on www.EarnForex.com"
#property icon          "\\Files\\EF-Icon-64x64px.ico"

#include <MQLTA ErrorHandling.mqh>
#include <MQLTA Utils.mqh>

enum ENUM_PANEL_SIZE
{
    PANEL_SMALL = 1,  // SMALL
    PANEL_LARGE = 2,  // LARGE
    PANEL_ULTRA = 4,  // ULTRA WIDE
};

enum SCRSHOT_RES
{
    VGA = 0,       // 640x480
    SVGA = 1,      // 800x600
    XGA = 2,       // 1024x768
    SXGA = 3,      // 1280x1024
    WXGA = 4,      // 1600x900
    HD1080 = 5,    // 1920x1080
    CURRENT = 6,   // CHART SIZE
};

enum DEF_MARKPEND
{
    Market = 0,    // MARKET ORDER
    Pending = 1,   // PENDING ORDER
};

enum DEF_SL
{
    ByPts = 0,     // BY POINTS
    ByPrice = 1,   // BY PRICE
};

enum DEF_PERCCALC
{
    Balance = 0,    // BALANCE
    Equity = 1,     // EQUITY
    FreeMargin = 2, // FREE MARGIN
};

enum ENUM_PENDING_TYPE
{
    PENDING_STOP = 0,  // STOP ORDER
    PENDING_LIMIT = 1, // LIMIT ORDER
};

enum ENUM_PENDING_SIDE
{
    PENDING_BUY = 0,   // PENDING BUY
    PENDING_SELL = 1,  // PENDING SELL
    PENDING_BUYSELL = 2, // PENDING BUY AND SELL
};

enum ENUM_PRICE_FOR_PENDING
{
    PRICE_ASK = 0,          // ASK PRICE
    PRICE_BID = 1,          // BID PRICE
};

enum ENUM_PENDING_START_PRICE_MODE
{
    PENDING_START_CURRENT = 0, // CURRENT PRICE
    PENDING_START_MANUAL = 1,  // MANUAL PRICE
};

enum ENUM_LINE_ORDER_SIDE
{
    LINE_ORDER_BUY = 0,  // BUY
    LINE_ORDER_SELL = 1, // SELL
};

enum ENUM_LINE_ORDER_TYPE
{
    LINE_ORDER_MARKET = 0,  // MARKET ORDER
    LINE_ORDER_STOP = 1,    // PENDING STOP ORDER
    LINE_ORDER_LIMIT = 2,   // PENDING LIMIT ORDER
};

enum ENUM_LINE_TYPE
{
    LINE_OPEN_PRICE = 0, // OPEN PRICE
    LINE_SL_PRICE = 1,   // STOP LOSS PRICE
    LINE_TP_PRICE = 2,   // TAKE PROFIT LINE
    LINE_ALL = 3,        // ALL LINES
};


input string Comment_1 = "====================";         // One-Click Trade
input string IndicatorName = "OCTP";                     // Indicator Name (used to draw objects)

input string Comment_2 = "====================";         // Default Settings
input DEF_MARKPEND DefaultMarketPending = Market;        // Default Type of Order
input double DefaultLotSize = 1;                         // Default Lot Size
input double DefaultLotStep = 1;                         // Default Increment/Decrement of size
input double MaxLotSize = 100;                           // Maximum Allowed Position Size
input DEF_SL DefaultSLBy = ByPts;                        // Default Stop Loss Type
input int DefaultSLPts = 0;                              // Default Stop Loss in Points
input int DefaultTPPts = 0;                              // Default Take Profit in Points
input int DefaultMagic = 0;                              // Default Magic Number
input string DefaultComment = "";                        // Default Comment
input double DefaultRiskPerc = 2;                        // Default % of Risk
input DEF_PERCCALC DefaultRiskBase = Balance;            // Default Risk Calculation Base
input bool DefaultTakeScrenshot = false;                 // Default Take Screenshot Option
input SCRSHOT_RES ScreenshotRes = CURRENT;               // Default Screenshot Resolution
input int DefaultOrdersPerPage = 10;                     // Default Orders per page to show
input int Slippage = 10;                                 // Slippage (in Points)
input bool ShowMsg = false;                              // Enable Order Confirmation Message
input bool UseRecommended = false;                       // Always Use Recommended Size When Available

input string Comment_2a = "====================";        // Additional Default For Pending Opposite
input ENUM_PENDING_START_PRICE_MODE DefaultPendingOppStartMode = PENDING_START_CURRENT; // Default Start Price
input ENUM_PENDING_SIDE DefaultPendingOrderSide = PENDING_BUYSELL; // Default Pending Order Side
input ENUM_PENDING_TYPE DefaultPendingOrderType = PENDING_STOP;   // Default Pending Order Type
input ENUM_PRICE_FOR_PENDING DefaultPendingBuyPrice = PRICE_ASK;  // Default Price Used For Buy Pending
input ENUM_PRICE_FOR_PENDING DefaultPendingSellPrice = PRICE_BID; // Default Price Used For Sell Pending
input int DefaultPendingOrderDistance = 500;             // Default Pending Order Distance

input string Comment_2b = "====================";        // Additional Default For Lines Order
input ENUM_LINE_ORDER_SIDE DefaultOrderLineSide = LINE_ORDER_BUY; // Default Order Side
input ENUM_LINE_ORDER_TYPE DefaultOrderLineType = LINE_ORDER_MARKET; // Default Order Type
input color LineOpenPriceColor = clrGray;                // Open Price Line Color
input color LineSLPriceColor = clrRed;                   // Stop Loss Price Line Color
input color LineTPPriceColor = clrGreen;                 // Take Profit Price Line Color
input ENUM_LINE_STYLE LineStyle = STYLE_DASH;            // Line Style

input string Comment_4 = "====================";         // Colors and Position
input color OpenBuyColor = clrGreen;                     // Open Buy Order Color
input color OpenSellColor = clrRed;                      // Open Sell Order Color
extern int Xoff = 20;                                    // Horizontal spacing for the control panel
extern int Yoff = 20;                                    // Vertical spacing for the control panel
input int NOFontSize = 8;                                // Font Size
input ENUM_PANEL_SIZE PanelSize = PANEL_SMALL;           // Panel Size
input bool ShowURL = true;                               // Show Website URL

int CurrMarketPending = Market;
int CurrSLPtsOrPrice = ByPts;
int CurrPendingOppType = PENDING_STOP;
int CurrPendingOppSide = PENDING_BUYSELL;
int CurrPendingOppDistance = DefaultPendingOrderDistance;
int CurrPendingOppBuyPrice = DefaultPendingBuyPrice;
int CurrPendingOppSellPrice = DefaultPendingSellPrice;
int CurrPendingOppStartMode = DefaultPendingOppStartMode;
int CurrLinesSide = DefaultOrderLineSide;
int CurrLinesType = DefaultOrderLineType;
double CurrLotSize = 0;
double CurrSLPrice = 0;
double CurrTPPrice = 0;
double CurrSLPts = 0;
double CurrTPPts = 0;
double CurrOpenPrice = 0;
int CurrMagic = 0;
string CurrComment = "";
bool NewOrderPanelOpen = false;

bool TakeScreenshot = false;
double LotSize = 0;
double LotStep = 0;
double RiskPerc = 0;
int RiskBase = Equity;

bool NewOrderPanelIsOpen = false;
bool NewPendingOppPanelIsOpen = false;
bool NewOrderLinesPanelIsOpen = false;

int TotalOrders = 0;
long Orders[][2];
int DetectedOrders = 0;
int OrdersPerPage = DefaultOrdersPerPage;
int CurrentPage = 0;
bool DetailsOpen = false;
bool EditOpen = false;

int DeinitializationReason = -1;

double DPIScale; // Scaling parameter for the panel based on the screen DPI.
int PanelMovX, PanelMovY, PanelLabX, PanelLabY, PanelRecX;
int NewOrderMonoX, NewOrderDoubleX, NewOrderTripleX, NewOrderLabelY;
int NewPendingOppMonoX, NewPendingOppDoubleX, NewPendingOppTripleX, NewPendingOppLabelY;
int NewOrderLinesMonoX, NewOrderLinesDoubleX, NewOrderLinesTripleX, NewOrderLinesLabelY;
int DetGLabelX, DetGLabelY, DetCmntLabelX, DetButtonX, DetButtonY;
int SetGLabelX, SetGLabelEX, SetGLabelY, SetButtonX;

int OnInit()
{
    CurrentPage = 0;
    DetailsOpen = false;
    EditOpen = false;
    ChartSetInteger(0, CHART_EVENT_MOUSE_MOVE, 1);
    ChartSetInteger(0, CHART_EVENT_OBJECT_DELETE, 1);
    if (DeinitializationReason != REASON_CHARTCHANGE)
    {
        DPIScale = (double)TerminalInfoInteger(TERMINAL_SCREEN_DPI) / 96.0;
    
        PanelMovX = (int)MathRound(26 * DPIScale * PanelSize);
        PanelMovY = (int)MathRound(26 * DPIScale * PanelSize);
        PanelLabX = (int)MathRound(154 * DPIScale * PanelSize);
        PanelLabY = PanelMovY;
        PanelRecX = (PanelMovX + 1) * 5 + PanelLabX + 4;

        NewOrderMonoX = (int)MathRound(208 * DPIScale * PanelSize);
        NewOrderDoubleX = (int)MathRound(103 * DPIScale * PanelSize) + ((PanelSize - 1) * 1);
        NewOrderTripleX = (int)MathRound(68 * DPIScale * PanelSize) + ((PanelSize - 1) * 1);
        NewOrderLabelY = (int)MathRound(20 * DPIScale * PanelSize);

        NewPendingOppMonoX = (int)MathRound(208 * DPIScale * PanelSize);
        NewPendingOppDoubleX = (int)MathRound(103 * DPIScale * PanelSize) + ((PanelSize - 1) * 1);
        NewPendingOppTripleX = (int)MathRound(68 * DPIScale * PanelSize) + ((PanelSize - 1) * 1);
        NewPendingOppLabelY = (int)MathRound(20 * DPIScale * PanelSize);
        
        NewOrderLinesMonoX = (int)MathRound(208 * DPIScale * PanelSize);
        NewOrderLinesDoubleX = (int)MathRound(103 * DPIScale * PanelSize) + ((PanelSize - 1) * 1);
        NewOrderLinesTripleX = (int)MathRound(68 * DPIScale * PanelSize) + ((PanelSize - 1) * 1);
        NewOrderLinesLabelY = (int)MathRound(20 * DPIScale * PanelSize);

        DetGLabelX = (int)MathRound(70 * DPIScale * PanelSize);
        DetGLabelY = (int)MathRound(20 * DPIScale * PanelSize);
        DetCmntLabelX = (int)MathRound(200 * DPIScale * PanelSize);
        DetButtonX = (int)MathRound(50 * DPIScale * PanelSize);
        DetButtonY = (int)MathRound(20 * DPIScale * PanelSize);

        SetGLabelX = (int)MathRound(116 * DPIScale * PanelSize);
        SetGLabelEX = (int)MathRound(90 * DPIScale * PanelSize);
        SetGLabelY = (int)MathRound(20 * DPIScale * PanelSize);
        SetButtonX = (int)MathRound(103 * DPIScale * PanelSize);

        CleanChart();
        InitializeSettings();
        InitializeDefaults();
        CreateMiniPanel();
    }
    return INIT_SUCCEEDED;
}

void OnDeinit(const int reason)
{
    DeinitializationReason = reason; // Remember reason to avoid recreating the panel in the OnInit() if it is not deleted here.
    if (DeinitializationReason != REASON_CHARTCHANGE) CleanChart();
}

void OnTick()
{
    UpdateSpread();
    UpdateRecommendedSize();
    if (UseRecommended) ChangeRecommendedSize();
    if (DetailsOpen)
    {
        CloseDetails();
        ShowDetails(CurrentPage);
    }
    if (EditOpen)
    {
        UpdateEditProfit(EditIndexCurr);
    }
    if (NewOrderLinesPanelIsOpen)
    {
        if ((CurrSLPrice != 0) || (CurrTPPrice != 0))
        {
            UpdateLinesLabels();
        }
    }
}

void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
{
    if (id == CHARTEVENT_OBJECT_CLICK)
    {
        if (sparam == PanelExp)
        {
            InitializeDefaults();
            CloseSettings();
            CloseNewOrder();
            CloseDetails();
            CloseNewOrderLines();
            CloseNewPendingOpp();
            DeleteNewOrderLine(LINE_ALL);
            ExitEdit();
            ShowNewOrder();
        }
        else if (sparam == PanelPend)
        {
            InitializeDefaults();
            CloseSettings();
            CloseNewOrder();
            CloseDetails();
            CloseNewOrderLines();
            DeleteNewOrderLine(LINE_ALL);
            ExitEdit();
            ShowNewPendingOpp();
        }
        else if (sparam == PanelLines)
        {
            InitializeDefaults();
            CloseSettings();
            CloseNewOrder();
            CloseDetails();
            CloseNewPendingOpp();
            DeleteNewOrderLine(LINE_ALL);
            ExitEdit();
            ShowNewOrderLines();
        }
        else if (sparam == PanelList)
        {
            CloseSettings();
            CloseNewOrder();
            CloseDetails();
            CloseNewPendingOpp();
            CloseNewOrderLines();
            DeleteNewOrderLine(LINE_ALL);
            ExitEdit();
            ShowDetails();
        }
        else if (sparam == PanelOptions)
        {
            CloseSettings();
            CloseNewOrder();
            CloseDetails();
            CloseNewOrderLines();
            DeleteNewOrderLine(LINE_ALL);
            CloseNewPendingOpp();
            ExitEdit();
            ShowSettings();
        }
        else if (sparam == NewOrderClose)
        {
            CloseNewOrder();
        }
        else if (sparam == NewPendingOppClose)
        {
            CloseNewPendingOpp();
        }
        else if (sparam == NewOrderLinesClose)
        {
            DeleteNewOrderLine(LINE_ALL);
            CloseNewOrderLines();
        }
        else if (sparam == NewOrderMarketPending)
        {
            ChangeMarketPending();
        }
        else if (sparam == NewOrderSLType)
        {
            ChangeSLPtsPrice();
        }
        else if ((sparam == NewOrderLotMinus) || (sparam == NewPendingOppLotMinus) || (sparam == NewOrderLinesLotMinus))
        {
            DecrementSize();
        }
        else if ((sparam == NewOrderLotPlus) || (sparam == NewPendingOppLotPlus) || (sparam == NewOrderLinesLotPlus))
        {
            IncrementSize();
        }
        else if (sparam == NewOrderBuy)
        {
            ExecuteOrder(OP_BUY);
        }
        else if (sparam == NewOrderBuyLimit)
        {
            ExecuteOrder(OP_BUYLIMIT);
        }
        else if (sparam == NewOrderBuyStop)
        {
            ExecuteOrder(OP_BUYSTOP);
        }
        else if (sparam == NewOrderSell)
        {
            ExecuteOrder(OP_SELL);
        }
        else if (sparam == NewOrderSellLimit)
        {
            ExecuteOrder(OP_SELLLIMIT);
        }
        else if (sparam == NewOrderSellStop)
        {
            ExecuteOrder(OP_SELLSTOP);
        }
        else if ((sparam == NewOrderRecommendedSize) || (sparam == NewPendingOppRecommendedSize) || (sparam == NewOrderLinesRecommendedSize))
        {
            ChangeRecommendedSize();
        }
        else if (sparam == NewPendingOppPendingSide)
        {
            ChangePendingOppSide();
        }
        else if (sparam == NewPendingOppPendingType)
        {
            ChangePendingOppType();
        }
        else if (sparam == NewPendingOppPendingOpenPrice)
        {
            ChangePendingOppStartMode();
        }
        else if (sparam == NewPendingOppSubmit)
        {
            ExecutePendingOpp(CurrPendingOppSide);
        }
        else if (sparam == NewOrderLinesSide)
        {
            ChangeLinesOrderSide();
        }
        else if (sparam == NewOrderLinesOrderType)
        {
            ChangeLinesOrderType();
        }
        else if (sparam == NewOrderLinesSLPrice)
        {
            ClickNewOrderLinesSLPrice();
            if (UseRecommended) ChangeRecommendedSize();
        }
        else if (sparam == NewOrderLinesTPPrice)
        {
            ClickNewOrderLinesTPPrice();
        }
        else if (sparam == NewOrderLinesSubmit)
        {
            ExecuteOrderLines();
        }
        else if (sparam == DetailsClose)
        {
            CloseDetails();
        }
        else if (sparam == DetailsNext)
        {
            if (CurrentPage < TotPages)
            {
                CloseDetails();
                CurrentPage++;
                ShowDetails(CurrentPage);
            }
        }
        else if (sparam == DetailsPrev)
        {
            if (CurrentPage > 1)
            {
                CloseDetails();
                CurrentPage--;
                ShowDetails(CurrentPage);
            }
        }
        else if (sparam == DetailsEdit)
        {
            ExitEdit();
            CloseDetails();
            CloseSettings();
            if (TotalOrders > 0) ShowEdit();
        }
        else if (sparam == EditClose)
        {
            CloseOrder(EditIndexCurr);
        }
        else if (sparam == EditExit)
        {
            ExitEdit();
        }
        else if (sparam == EditNext)
        {
            if (EditIndexNext > -1) ShowEdit(EditIndexNext);
        }
        else if (sparam == EditPrev)
        {
            if (EditIndexPrev > -1) ShowEdit(EditIndexPrev);
        }
        else if (sparam == EditSave)
        {
            UpdateOrder(EditIndexCurr);
        }
        else if (sparam == SettingsClose)
        {
            CloseSettings();
        }
        else if (sparam == SettingsSave)
        {
            SaveSettingsChanges();
        }
        else if (sparam == SettingsTakeScreenshotE)
        {
            ChangeTakeScreenshot();
        }
        else if (sparam == SettingsRiskBaseE)
        {
            ChangeRiskBase();
        }
    }
    else if (id == CHARTEVENT_OBJECT_ENDEDIT)
    {
        if ((sparam == NewOrderLotSize) || (sparam == NewPendingOppLotSize) || (sparam == NewOrderLinesLotSize))
        {
            ChangeSize();
        }
        else if ((sparam == NewOrderSLPriceE) || (sparam == NewOrderLinesSLPriceE))
        {
            ChangeSLPrice();
            if (UseRecommended) ChangeRecommendedSize();
        }
        else if ((sparam == NewOrderTPPriceE) || (sparam == NewOrderLinesTPPriceE))
        {
            ChangeTPPrice();
        }
        else if ((sparam == NewOrderSLPtsE) || (sparam == NewPendingOppSLPtsE))
        {
            ChangeSLPts();
            if (UseRecommended) ChangeRecommendedSize();
        }
        else if ((sparam == NewOrderTPPtsE) || (sparam == NewPendingOppTPPtsE))
        {
            ChangeTPPts();
        }
        else if ((sparam == NewOrderPendingOpenPriceE) || (sparam == NewPendingOppPendingOpenPriceE) || (sparam == NewOrderLinesPendingOpenPriceE))
        {
            ChangePendingOpenPrice();
            if (UseRecommended) ChangeRecommendedSize();
        }
        else if ((sparam == NewOrderMagicE) || (sparam == NewPendingOppMagicE) || (sparam == NewOrderLinesMagicE))
        {
            ChangeMagic();
        }
        else if ((sparam == NewOrderCommentE) || (sparam == NewPendingOppCommentE) || (sparam == NewOrderLinesCommentE))
        {
            ChangeComment();
        }
        else if (sparam == NewPendingOppPendingDistanceE)
        {
            ChangePendingOppDistance();
        }
        else if (sparam == EditOrderSLI)
        {
            CurrSLPrice = (double)ObjectGetString(0, EditOrderSLI, OBJPROP_TEXT);
            UpdateLineByPrice(LineNameSL);
            if (UseRecommended) ChangeRecommendedSize();
        }
        else if (sparam == EditOrderTPI)
        {
            CurrTPPrice = (double)ObjectGetString(0, EditOrderTPI, OBJPROP_TEXT);
            UpdateLineByPrice(LineNameTP);
        }
    }
    else if (id == CHARTEVENT_OBJECT_DRAG)
    {
        if (sparam == LineNameOpen)
        {
            UpdatePriceByLine(LineNameOpen);
            if (UseRecommended) ChangeRecommendedSize();
        }
        else if (sparam == LineNameSL)
        {
            UpdatePriceByLine(LineNameSL);
            if (UseRecommended) ChangeRecommendedSize();
        }
        else if (sparam == LineNameTP)
        {
            UpdatePriceByLine(LineNameTP);
        }
    }
    else if (id == CHARTEVENT_OBJECT_DELETE)
    {
        if ((sparam == LineNameOpen) || (sparam == LineNameSL) || (sparam == LineNameTP))
        {
            UpdateLinesDeleted(sparam);
        }
    }
    else if (id == CHARTEVENT_CHART_CHANGE)
    {
        if (NewOrderLinesPanelIsOpen)
        {
            UpdateLinesLabels();
            ShowNewOrderLines();
        }
    }
}

void InitializeDefaults()
{
    CurrMarketPending = DefaultMarketPending;
    CurrSLPtsOrPrice = DefaultSLBy;
    CurrPendingOppType = PENDING_STOP;
    CurrPendingOppSide = PENDING_BUYSELL;
    CurrPendingOppDistance = DefaultPendingOrderDistance;
    CurrPendingOppBuyPrice = DefaultPendingBuyPrice;
    CurrPendingOppSellPrice = DefaultPendingSellPrice;
    CurrPendingOppStartMode = DefaultPendingOppStartMode;
    CurrLinesSide = DefaultOrderLineSide;
    CurrLinesType = DefaultOrderLineType;
    CurrLotSize = LotSize;
    CurrSLPrice = 0;
    CurrTPPrice = 0;
    CurrSLPts = DefaultSLPts;
    CurrTPPts = DefaultTPPts;
    CurrOpenPrice = MarketInfo(Symbol(), MODE_ASK);
    CurrMagic = DefaultMagic;
    CurrComment = DefaultComment;
}

void InitializeSettings()
{
    TakeScreenshot = DefaultTakeScrenshot;
    LotSize = DefaultLotSize;
    LotStep = DefaultLotStep;
    RiskPerc = DefaultRiskPerc;
    RiskBase = DefaultRiskBase;
    OrdersPerPage = DefaultOrdersPerPage;
    if ((LotSize >= MarketInfo(Symbol(), MODE_MINLOT)) && (LotSize <= MarketInfo(Symbol(), MODE_MAXLOT)))
    {
        LotSize = MathRound(LotSize / MarketInfo(Symbol(), MODE_LOTSTEP)) * MarketInfo(Symbol(), MODE_LOTSTEP);
    }
    else
    {
        Print("Lot Size must be between " + DoubleToString(MarketInfo(Symbol(), MODE_MINLOT), 2) + " and " + DoubleToString(MarketInfo(Symbol(), MODE_MAXLOT), 2));
        LotSize = MarketInfo(Symbol(), MODE_MINLOT);
        LotSize = MathRound(LotSize / MarketInfo(Symbol(), MODE_LOTSTEP)) * MarketInfo(Symbol(), MODE_LOTSTEP);
    }
    if ((LotStep >= MarketInfo(Symbol(), MODE_LOTSTEP)) && (LotStep <= MarketInfo(Symbol(), MODE_MAXLOT)))
    {
        LotStep = MathRound(LotStep / MarketInfo(Symbol(), MODE_LOTSTEP)) * MarketInfo(Symbol(), MODE_LOTSTEP);
    }
    else
    {
        Print("Lot Step must be between " + DoubleToString(MarketInfo(Symbol(), MODE_LOTSTEP), 2) + " and " + DoubleToString(MarketInfo(Symbol(), MODE_MAXLOT), 2));
        LotStep = MarketInfo(Symbol(), MODE_LOTSTEP);
        LotStep = MathRound(LotStep / MarketInfo(Symbol(), MODE_LOTSTEP)) * MarketInfo(Symbol(), MODE_LOTSTEP);
    }
}

void ScanOrders()
{
    TotalOrders = 0;
    for (int i = 0; i < OrdersTotal(); i++)
    {
        if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
        {
            TotalOrders++;
            ArrayResize(Orders, TotalOrders);
            Orders[TotalOrders - 1][0] = OrderOpenTime();
            Orders[TotalOrders - 1][1] = OrderTicket();
        }
    }
    DetectedOrders = ArraySize(Orders) / 2;
}

void ExecuteOrder(int Operation)
{
    int LastError = 0;
    double OpenPrice = 0;
    double TPPrice = 0;
    double SLPrice = 0;
    int SLPts = 0;
    int TPPts = 0;
    int Magic = 0;
    string Comm = "";
    double PositionSize = 0;
    double Points = MarketInfo(Symbol(), MODE_POINT);
    double Spread = MarketInfo(Symbol(), MODE_SPREAD);
    double StopLevel = MarketInfo(Symbol(), MODE_STOPLEVEL) * Points;
    color Color = 0;
    string CurrDate = TimeToStr(TimeCurrent(), TIME_DATE);
    string CurrTime = TimeToStr(TimeCurrent(), TIME_SECONDS);
    string OperationText = "";
    string MessageBoxText = "";
    switch(Operation)
    {
    case OP_BUY:
        OperationText = "BUY";
        break;
    case OP_BUYSTOP:
        OperationText = "BUY STOP";
        break;
    case OP_BUYLIMIT:
        OperationText = "BUY LIMIT";
        break;
    case OP_SELL:
        OperationText = "SELL";
        break;
    case OP_SELLLIMIT:
        OperationText = "SELL LIMIT";
        break;
    case OP_SELLSTOP:
        OperationText = "SELL STOP";
        break;
    }
    if ((Operation == OP_BUY) || (Operation == OP_BUYLIMIT) || (Operation == OP_BUYSTOP)) Color = OpenBuyColor;
    else if ((Operation == OP_SELL) || (Operation == OP_SELLLIMIT) || (Operation == OP_SELLSTOP)) Color = OpenSellColor;
    
    if (CurrMarketPending == Pending)
    {
        OpenPrice = CurrOpenPrice;
    }
    else if (CurrMarketPending == Market)
    {
        if (Operation == OP_BUY) OpenPrice = MarketInfo(Symbol(), MODE_ASK);
        if (Operation == OP_SELL) OpenPrice = MarketInfo(Symbol(), MODE_BID);
    }
    
    if (CurrSLPtsOrPrice == ByPrice)
    {
        SLPrice = CurrSLPrice;
        TPPrice = CurrTPPrice;
    }
    else if (CurrSLPtsOrPrice == ByPts)
    {
        SLPts = (int)CurrSLPts;
        TPPts = (int)CurrTPPts;
        if ((Operation == OP_BUY) || (Operation == OP_BUYLIMIT) || (Operation == OP_BUYSTOP))
        {
            if (SLPts > 0) SLPrice = OpenPrice - SLPts * Points;
            if (TPPts > 0) TPPrice = OpenPrice + TPPts * Points;
        }
        else if ((Operation == OP_SELL) || (Operation == OP_SELLLIMIT) || (Operation == OP_SELLSTOP))
        {
            if (SLPts > 0) SLPrice = OpenPrice + SLPts * Points;
            if (TPPts > 0) TPPrice = OpenPrice - TPPts * Points;
        }
    }
    Magic = CurrMagic;
    Comm = CurrComment;
    PositionSize = CurrLotSize;
    if (CurrMarketPending == Market)
    {
        if (AccountFreeMarginCheck(Symbol(), Operation, PositionSize) <= 0)
        {
            MessageBox("Not enough money to order with this position size.");
            return;
        }
    }
    
    if ((Operation == OP_BUY) || (Operation == OP_BUYLIMIT) || (Operation == OP_BUYSTOP))
    {
        if ((SLPrice > 0) && (SLPrice >= OpenPrice - StopLevel))
        {
            MessageBox("Stop-loss must be below open price minus stop level.");
            return;
        }
        if ((TPPrice > 0) && (TPPrice <= OpenPrice + StopLevel))
        {
            MessageBox("Take-profit must be above open price plus stop level.");
            return;
        }
    }
    else if ((Operation == OP_SELL) || (Operation == OP_SELLLIMIT) || (Operation == OP_SELLSTOP))
    {
        if ((SLPrice > 0) && (SLPrice <= OpenPrice + StopLevel))
        {
            MessageBox("Stop-loss must be above open price plus stop level.");
            return;
        }
        if ((TPPrice > 0) && (TPPrice >= OpenPrice - StopLevel))
        {
            MessageBox("Take-profit must be below open price minus stop level.");
            return;
        }
    }
    
    if (Operation == OP_BUYSTOP)
    {
        if (OpenPrice <= Ask + StopLevel)
        {
            MessageBox("In BUY STOP, the open price must be higher than the ASK + Stop Level.");
            return;
        }
    }
    else if (Operation == OP_SELLLIMIT)
    {
        if (OpenPrice <= Bid + StopLevel)
        {
            MessageBox("In SELL LIMIT, the open price must be higher than the BID + Stop Level.");
            return;
        }
    }
    else if (Operation == OP_SELLSTOP)
    {
        if (OpenPrice >= Bid - StopLevel)
        {
            MessageBox("In SELL STOP, the open price must be lower than the BID - Stop Level.");
            return;
        }
    }
    else if (Operation == OP_BUYLIMIT)
    {
        if (OpenPrice >= Ask - StopLevel)
        {
            MessageBox("In BUY LIMIT, the open price must be lower than the ASK - Stop Level.");
            return;
        }
    }
    MessageBoxText += "Current Server Time : " + CurrDate + " " + CurrTime + "\n\n";
    MessageBoxText += "ORDER SUCCESSFULLY SUBMITTED\n\n";
    MessageBoxText += "Order : " + OperationText + "\n";
    MessageBoxText += "Symbol : " + Symbol() + "\n";
    MessageBoxText += "Position Size (Lots) : " + DoubleToStr(PositionSize, 2) + "\n";
    MessageBoxText += "Open Price : " + DoubleToStr(OpenPrice, Digits) + "\n";
    if (SLPrice > 0) MessageBoxText += "Stop Loss Price : " + DoubleToStr(SLPrice, Digits) + "\n";
    if (SLPrice == 0) MessageBoxText += "Stop Loss : Not set\n";
    if (TPPrice > 0) MessageBoxText += "Take Profit Price : " + DoubleToStr(TPPrice, Digits) + "\n";
    if (TPPrice == 0) MessageBoxText += "Take Profit : Not set\n";
    if (Magic > 0) MessageBoxText += "Magic Number : " + IntegerToString(Magic) + "\n";
    if (Magic == 0) MessageBoxText += "Magic Number : Not set\n";
    if (StringLen(Comm) > 0) MessageBoxText += "Comment : " + Comm + "\n";
    if (StringLen(Comm) == 0) MessageBoxText += "Comment : Not set\n";
    int res = 0;
    res = OrderSend(Symbol(), Operation, PositionSize, OpenPrice, Slippage, SLPrice, TPPrice, Comm, Magic, 0, Color);
    LastError = GetLastError();
    if (res >= 0)
    {
        if (TakeScreenshot)
        {
            string Filename = Screenshot();
            MessageBoxText += "Screenshot file : " + Filename;
        }
        if (ShowMsg)
        {
            MessageBox(MessageBoxText);
        }
        if (NewOrderLinesPanelIsOpen)
        {
            DeleteNewOrderLine(LINE_ALL);
            InitializeDefaults();
            ShowNewOrderLines();
        }
    }
    else
    {
        MessageBox("Order failed - " + IntegerToString(LastError) + " - " + GetLastErrorText(LastError));
    }
}

void ExecutePendingOpp(int Side)
{
    CurrMarketPending = Pending;
    if (CurrPendingOppDistance <= MarketInfo(Symbol(), MODE_STOPLEVEL))
    {
        MessageBox("The distance for pending orders must be greater than the stop-level for the instrument.", "ERROR");
        return;
    }
    if (Side == PENDING_BUY)
    {
        if (CurrPendingOppType == PENDING_LIMIT)
        {
            if (CurrPendingOppStartMode == PENDING_START_CURRENT)
            {
                if (CurrPendingOppBuyPrice == PRICE_ASK)
                {
                    RefreshRates();
                    CurrOpenPrice = Ask - CurrPendingOppDistance * Point;
                    ExecuteOrder(OP_BUYLIMIT);
                }
                else if (CurrPendingOppBuyPrice == PRICE_BID)
                {
                    RefreshRates();
                    CurrOpenPrice = Bid - CurrPendingOppDistance * Point;
                    ExecuteOrder(OP_BUYLIMIT);
                }
            }
            else if (CurrPendingOppStartMode == PENDING_START_MANUAL)
            {
                CurrOpenPrice = CurrOpenPrice - CurrPendingOppDistance * Point;
                ExecuteOrder(OP_BUYLIMIT);
            }
        }
        else if (CurrPendingOppType == PENDING_STOP)
        {
            if (CurrPendingOppStartMode == PENDING_START_CURRENT)
            {
                if (CurrPendingOppBuyPrice == PRICE_ASK)
                {
                    RefreshRates();
                    CurrOpenPrice = Ask + CurrPendingOppDistance * Point;
                    ExecuteOrder(OP_BUYSTOP);
                }
                else if (CurrPendingOppBuyPrice == PRICE_BID)
                {
                    RefreshRates();
                    CurrOpenPrice = Bid + CurrPendingOppDistance * Point;
                    ExecuteOrder(OP_BUYSTOP);
                }
            }
            else if (CurrPendingOppStartMode == PENDING_START_MANUAL)
            {
                CurrOpenPrice = CurrOpenPrice + CurrPendingOppDistance * Point;
                ExecuteOrder(OP_BUYSTOP);
            }
        }
    }
    else if (Side == PENDING_SELL)
    {
        if (CurrPendingOppType == PENDING_LIMIT)
        {
            if (CurrPendingOppStartMode == PENDING_START_CURRENT)
            {
                if (CurrPendingOppSellPrice == PRICE_ASK)
                {
                    RefreshRates();
                    CurrOpenPrice = Ask + CurrPendingOppDistance * Point;
                    ExecuteOrder(OP_SELLLIMIT);
                }
                else if (CurrPendingOppSellPrice == PRICE_BID)
                {
                    RefreshRates();
                    CurrOpenPrice = Bid + CurrPendingOppDistance * Point;
                    ExecuteOrder(OP_SELLLIMIT);
                }
            }
            else if (CurrPendingOppStartMode == PENDING_START_MANUAL)
            {
                CurrOpenPrice = CurrOpenPrice + CurrPendingOppDistance * Point;
                ExecuteOrder(OP_SELLLIMIT);
            }
        }
        else if (CurrPendingOppType == PENDING_STOP)
        {
            if (CurrPendingOppStartMode == PENDING_START_CURRENT)
            {
                if (CurrPendingOppSellPrice == PRICE_ASK)
                {
                    RefreshRates();
                    CurrOpenPrice = Ask - CurrPendingOppDistance * Point;
                    ExecuteOrder(OP_SELLSTOP);
                }
                else if (CurrPendingOppSellPrice == PRICE_BID)
                {
                    RefreshRates();
                    CurrOpenPrice = Bid - CurrPendingOppDistance * Point;
                    ExecuteOrder(OP_SELLSTOP);
                }
            }
            else if (CurrPendingOppStartMode == PENDING_START_MANUAL)
            {
                CurrOpenPrice = CurrOpenPrice - CurrPendingOppDistance * Point;
                ExecuteOrder(OP_SELLSTOP);
            }
        }
    }
    if (Side == PENDING_BUYSELL)
    {
        ExecutePendingOpp(PENDING_BUY);
        ExecutePendingOpp(PENDING_SELL);
    }
}

void ExecuteOrderLines()
{
    int Operation = 0;
    if (CurrLinesSide == LINE_ORDER_BUY)
    {
        if (CurrLinesType == LINE_ORDER_MARKET) Operation = OP_BUY;
        if (CurrLinesType == LINE_ORDER_LIMIT) Operation = OP_BUYLIMIT;
        if (CurrLinesType == LINE_ORDER_STOP) Operation = OP_BUYSTOP;
    }
    else if (CurrLinesSide == LINE_ORDER_SELL)
    {
        if (CurrLinesType == LINE_ORDER_MARKET) Operation = OP_SELL;
        if (CurrLinesType == LINE_ORDER_LIMIT) Operation = OP_SELLLIMIT;
        if (CurrLinesType == LINE_ORDER_STOP) Operation = OP_SELLSTOP;
    }
    ExecuteOrder(Operation);
}

string Screenshot()
{
    int X = 0;
    int Y = 0;
    int FirstBar = -1;
    int Scale = -1;
    int Mode = -1;
    if (ScreenshotRes == VGA)
    {
        X = 640;
        Y = 480;
    }
    else if (ScreenshotRes == SVGA)
    {
        X = 800;
        Y = 600;
    }
    else if (ScreenshotRes == XGA)
    {
        X = 1024;
        Y = 768;
    }
    else if (ScreenshotRes == SXGA)
    {
        X = 1280;
        Y = 1024;
    }
    else if (ScreenshotRes == WXGA)
    {
        X = 1600;
        Y = 900;
    }
    else if (ScreenshotRes == HD1080)
    {
        X = 1920;
        Y = 1080;
    }
    else if (ScreenshotRes == CURRENT)
    {
        X = (int)ChartGetInteger(0, CHART_WIDTH_IN_PIXELS);
        Y = (int)ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS);
    }
    string CurrDate = TimeToStr(TimeCurrent(), TIME_DATE);
    string CurrTime = TimeToStr(TimeCurrent(), TIME_SECONDS);
    StringReplace(CurrDate, ".", "");
    StringReplace(CurrTime, ":", "");
    string Filename = Symbol() + "-" + CurrDate + "-" + CurrTime + ".png";
    WindowScreenShot(Filename, X, Y, FirstBar, Scale, Mode);
    return Filename;
}

void UpdatePanel()
{
    ObjectSet(PanelBase, OBJPROP_XDISTANCE, Xoff);
    ObjectSet(PanelBase, OBJPROP_YDISTANCE, Yoff);
    ObjectSet(PanelExp, OBJPROP_XDISTANCE, Xoff + PanelLabX + 3);
    ObjectSet(PanelExp, OBJPROP_YDISTANCE, Yoff + 2);
    ObjectSet(PanelList, OBJPROP_XDISTANCE, Xoff + PanelLabX + (PanelMovX + 2) * 1 + 2);
    ObjectSet(PanelList, OBJPROP_YDISTANCE, Yoff + 2);
    ObjectSet(PanelOptions, OBJPROP_XDISTANCE, Xoff + (PanelMovX + 2) * 2 + PanelLabX + 1);
    ObjectSet(PanelOptions, OBJPROP_YDISTANCE, Yoff + 2);
    ObjectSet(PanelLabel, OBJPROP_XDISTANCE, Xoff + 2);
    ObjectSet(PanelLabel, OBJPROP_YDISTANCE, Yoff + 2);
}

string PanelBase = IndicatorName + "-BAS";
string PanelMove = IndicatorName + "-MOV";
string PanelList = IndicatorName + "-LST";
string PanelOptions = IndicatorName + "-OPT";
string PanelClose = IndicatorName + "-CLO";
string PanelLabel = IndicatorName + "-LAB";
string PanelExp = IndicatorName + "-EXP";
string PanelPend = IndicatorName + "-PEND";
string PanelLines = IndicatorName + "-LINES";
void CreateMiniPanel()
{
    ObjectCreate(0, PanelBase, OBJ_RECTANGLE_LABEL, 0, 0, 0);
    ObjectSet(PanelBase, OBJPROP_XDISTANCE, Xoff);
    ObjectSet(PanelBase, OBJPROP_YDISTANCE, Yoff);
    ObjectSetInteger(0, PanelBase, OBJPROP_XSIZE, PanelRecX);
    ObjectSetInteger(0, PanelBase, OBJPROP_YSIZE, PanelMovY + 2 * 2);
    ObjectSetInteger(0, PanelBase, OBJPROP_BGCOLOR, clrWhite);
    ObjectSetInteger(0, PanelBase, OBJPROP_BORDER_TYPE, BORDER_FLAT);
    ObjectSetInteger(0, PanelBase, OBJPROP_STATE, false);
    ObjectSetInteger(0, PanelBase, OBJPROP_HIDDEN, true);
    ObjectSetInteger(0, PanelBase, OBJPROP_FONTSIZE, NOFontSize);
    ObjectSet(PanelBase, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, PanelBase, OBJPROP_COLOR, clrBlack);

    ObjectCreate(0, PanelExp, OBJ_EDIT, 0, 0, 0);
    ObjectSet(PanelExp, OBJPROP_XDISTANCE, Xoff + PanelLabX + 3);
    ObjectSet(PanelExp, OBJPROP_YDISTANCE, Yoff + 2);
    ObjectSetInteger(0, PanelExp, OBJPROP_XSIZE, PanelMovX);
    ObjectSetInteger(0, PanelExp, OBJPROP_YSIZE, PanelMovX);
    ObjectSetInteger(0, PanelExp, OBJPROP_BORDER_TYPE, BORDER_FLAT);
    ObjectSetInteger(0, PanelExp, OBJPROP_STATE, false);
    ObjectSetInteger(0, PanelExp, OBJPROP_HIDDEN, true);
    ObjectSetInteger(0, PanelExp, OBJPROP_READONLY, true);
    ObjectSetInteger(0, PanelExp, OBJPROP_FONTSIZE, NOFontSize + 2);
    ObjectSetString(0, PanelExp, OBJPROP_TOOLTIP, "New Simple Order Panel");
    ObjectSetInteger(0, PanelExp, OBJPROP_ALIGN, ALIGN_CENTER);
    ObjectSetString(0, PanelExp, OBJPROP_FONT, "Wingdings");
    ObjectSetString(0, PanelExp, OBJPROP_TEXT, "!");
    ObjectSet(PanelExp, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, PanelExp, OBJPROP_COLOR, clrNavy);
    ObjectSetInteger(0, PanelExp, OBJPROP_BGCOLOR, clrKhaki);
    ObjectSetInteger(0, PanelExp, OBJPROP_BORDER_COLOR, clrBlack);

    ObjectCreate(0, PanelPend, OBJ_EDIT, 0, 0, 0);
    ObjectSet(PanelPend, OBJPROP_XDISTANCE, Xoff + PanelLabX + (PanelMovX + 1) * 1 + 3);
    ObjectSet(PanelPend, OBJPROP_YDISTANCE, Yoff + 2);
    ObjectSetInteger(0, PanelPend, OBJPROP_XSIZE, PanelMovX);
    ObjectSetInteger(0, PanelPend, OBJPROP_YSIZE, PanelMovX);
    ObjectSetInteger(0, PanelPend, OBJPROP_BORDER_TYPE, BORDER_FLAT);
    ObjectSetInteger(0, PanelPend, OBJPROP_STATE, false);
    ObjectSetInteger(0, PanelPend, OBJPROP_HIDDEN, true);
    ObjectSetInteger(0, PanelPend, OBJPROP_READONLY, true);
    ObjectSetInteger(0, PanelPend, OBJPROP_FONTSIZE, NOFontSize + 2);
    ObjectSetString(0, PanelPend, OBJPROP_TOOLTIP, "New Opposite And Pending Order Panel");
    ObjectSetInteger(0, PanelPend, OBJPROP_ALIGN, ALIGN_CENTER);
    ObjectSetString(0, PanelPend, OBJPROP_FONT, "Wingdings");
    ObjectSetString(0, PanelPend, OBJPROP_TEXT, "ô");
    ObjectSet(PanelPend, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, PanelPend, OBJPROP_COLOR, clrNavy);
    ObjectSetInteger(0, PanelPend, OBJPROP_BGCOLOR, clrKhaki);
    ObjectSetInteger(0, PanelPend, OBJPROP_BORDER_COLOR, clrBlack);

    ObjectCreate(0, PanelLines, OBJ_EDIT, 0, 0, 0);
    ObjectSet(PanelLines, OBJPROP_XDISTANCE, Xoff + PanelLabX + (PanelMovX + 1) * 2 + 3);
    ObjectSet(PanelLines, OBJPROP_YDISTANCE, Yoff + 2);
    ObjectSetInteger(0, PanelLines, OBJPROP_XSIZE, PanelMovX);
    ObjectSetInteger(0, PanelLines, OBJPROP_YSIZE, PanelMovX);
    ObjectSetInteger(0, PanelLines, OBJPROP_BORDER_TYPE, BORDER_FLAT);
    ObjectSetInteger(0, PanelLines, OBJPROP_STATE, false);
    ObjectSetInteger(0, PanelLines, OBJPROP_HIDDEN, true);
    ObjectSetInteger(0, PanelLines, OBJPROP_READONLY, true);
    ObjectSetInteger(0, PanelLines, OBJPROP_FONTSIZE, NOFontSize + 2);
    ObjectSetString(0, PanelLines, OBJPROP_TOOLTIP, "New Order Through Lines Panel");
    ObjectSetInteger(0, PanelLines, OBJPROP_ALIGN, ALIGN_CENTER);
    ObjectSetString(0, PanelLines, OBJPROP_FONT, "Consolas");
    ObjectSetString(0, PanelLines, OBJPROP_TEXT, "=");
    ObjectSet(PanelLines, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, PanelLines, OBJPROP_COLOR, clrNavy);
    ObjectSetInteger(0, PanelLines, OBJPROP_BGCOLOR, clrKhaki);
    ObjectSetInteger(0, PanelLines, OBJPROP_BORDER_COLOR, clrBlack);

    ObjectCreate(0, PanelList, OBJ_EDIT, 0, 0, 0);
    ObjectSet(PanelList, OBJPROP_XDISTANCE, Xoff + PanelLabX + (PanelMovX + 1) * 3 + 3);
    ObjectSet(PanelList, OBJPROP_YDISTANCE, Yoff + 2);
    ObjectSetInteger(0, PanelList, OBJPROP_XSIZE, PanelMovX);
    ObjectSetInteger(0, PanelList, OBJPROP_YSIZE, PanelMovX);
    ObjectSetInteger(0, PanelList, OBJPROP_BORDER_TYPE, BORDER_FLAT);
    ObjectSetInteger(0, PanelList, OBJPROP_STATE, false);
    ObjectSetInteger(0, PanelList, OBJPROP_HIDDEN, true);
    ObjectSetInteger(0, PanelList, OBJPROP_READONLY, true);
    ObjectSetInteger(0, PanelList, OBJPROP_FONTSIZE, NOFontSize + 2);
    ObjectSetString(0, PanelList, OBJPROP_TOOLTIP, "Current Orders Panel");
    ObjectSetInteger(0, PanelList, OBJPROP_ALIGN, ALIGN_CENTER);
    ObjectSetString(0, PanelList, OBJPROP_FONT, "Wingdings");
    ObjectSetString(0, PanelList, OBJPROP_TEXT, "4");
    ObjectSet(PanelList, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, PanelList, OBJPROP_COLOR, clrNavy);
    ObjectSetInteger(0, PanelList, OBJPROP_BGCOLOR, clrKhaki);
    ObjectSetInteger(0, PanelList, OBJPROP_BORDER_COLOR, clrBlack);

    ObjectCreate(0, PanelOptions, OBJ_EDIT, 0, 0, 0);
    ObjectSet(PanelOptions, OBJPROP_XDISTANCE, Xoff + PanelLabX + (PanelMovX + 1) * 4 + 3);
    ObjectSet(PanelOptions, OBJPROP_YDISTANCE, Yoff + 2);
    ObjectSetInteger(0, PanelOptions, OBJPROP_XSIZE, PanelMovX);
    ObjectSetInteger(0, PanelOptions, OBJPROP_YSIZE, PanelMovX);
    ObjectSetInteger(0, PanelOptions, OBJPROP_BORDER_TYPE, BORDER_FLAT);
    ObjectSetInteger(0, PanelOptions, OBJPROP_STATE, false);
    ObjectSetInteger(0, PanelOptions, OBJPROP_HIDDEN, true);
    ObjectSetInteger(0, PanelOptions, OBJPROP_READONLY, true);
    ObjectSetInteger(0, PanelOptions, OBJPROP_FONTSIZE, NOFontSize + 2);
    ObjectSetInteger(0, PanelOptions, OBJPROP_ALIGN, ALIGN_CENTER);
    ObjectSetString(0, PanelOptions, OBJPROP_FONT, "Wingdings");
    ObjectSetString(0, PanelOptions, OBJPROP_TOOLTIP, "Options Panel");
    ObjectSetString(0, PanelOptions, OBJPROP_TEXT, ":");
    ObjectSet(PanelOptions, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, PanelOptions, OBJPROP_COLOR, clrNavy);
    ObjectSetInteger(0, PanelOptions, OBJPROP_BGCOLOR, clrKhaki);
    ObjectSetInteger(0, PanelOptions, OBJPROP_BORDER_COLOR, clrBlack);

    ObjectCreate(0, PanelLabel, OBJ_EDIT, 0, 0, 0);
    ObjectSet(PanelLabel, OBJPROP_XDISTANCE, Xoff + 2);
    ObjectSet(PanelLabel, OBJPROP_YDISTANCE, Yoff + 2);
    ObjectSetInteger(0, PanelLabel, OBJPROP_XSIZE, PanelLabX);
    ObjectSetInteger(0, PanelLabel, OBJPROP_YSIZE, PanelLabY);
    ObjectSetInteger(0, PanelLabel, OBJPROP_BORDER_TYPE, BORDER_FLAT);
    ObjectSetInteger(0, PanelLabel, OBJPROP_STATE, false);
    ObjectSetInteger(0, PanelLabel, OBJPROP_HIDDEN, true);
    ObjectSetInteger(0, PanelLabel, OBJPROP_READONLY, true);
    ObjectSetInteger(0, PanelLabel, OBJPROP_ALIGN, ALIGN_CENTER);
    ObjectSetString(0, PanelLabel, OBJPROP_TOOLTIP, "One-Click Trade Pro EA");
    ObjectSetString(0, PanelLabel, OBJPROP_TEXT, "ONE-CLICK TRADE PRO");
    ObjectSetString(0, PanelLabel, OBJPROP_FONT, "Consolas");
    ObjectSetInteger(0, PanelLabel, OBJPROP_FONTSIZE, NOFontSize + 2);
    ObjectSet(PanelLabel, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, PanelLabel, OBJPROP_COLOR, clrNavy);
    ObjectSetInteger(0, PanelLabel, OBJPROP_BGCOLOR, clrKhaki);
    ObjectSetInteger(0, PanelLabel, OBJPROP_BORDER_COLOR, clrBlack);
}

string NewOrderBase = IndicatorName + "-NO-Base";
string NewOrderClose = IndicatorName + "-NO-Close";
string NewOrderMarketPending = IndicatorName + "-NO-MarketPending";
string NewOrderPositionSize = IndicatorName + "-NO-PosSize";
string NewOrderRecommendedSize = IndicatorName + "-NO-RecSize";
string NewOrderSpread = IndicatorName + "-NO-Spread";
string NewOrderBuy = IndicatorName + "-NO-Buy";
string NewOrderSell = IndicatorName + "-NO-Sell";
string NewOrderPendingOpenPrice = IndicatorName + "-NO-PendingOP";
string NewOrderPendingOpenPriceE = IndicatorName + "-NO-PendingOPE";
string NewOrderBuyLimit = IndicatorName + "-NO-BuyLimit";
string NewOrderSellLimit = IndicatorName + "-NO-SellLimit";
string NewOrderBuyStop = IndicatorName + "-NO-BuyStop";
string NewOrderSellStop = IndicatorName + "-NO-SellStop";
string NewOrderLotMinus = IndicatorName + "-NO-LotMinus";
string NewOrderLotSize = IndicatorName + "-NO-LotSize";
string NewOrderLotPlus = IndicatorName + "-NO-LotPlus";
string NewOrderSLType = IndicatorName + "-NO-SLType";
string NewOrderSLPts = IndicatorName + "-NO-SLPts";
string NewOrderSLPrice = IndicatorName + "-NO-SLPrice";
string NewOrderTPPts = IndicatorName + "-NO-TPPrs";
string NewOrderTPPrice = IndicatorName + "-NO-TPPrice";
string NewOrderSLPtsE = IndicatorName + "-NO-SLPtsE";
string NewOrderSLPriceE = IndicatorName + "-NO-SLPriceE";
string NewOrderTPPtsE = IndicatorName + "-NO-TPPtsE";
string NewOrderTPPriceE = IndicatorName + "-NO-TPPriceE";
string NewOrderMagic = IndicatorName + "-NO-Magic";
string NewOrderMagicE = IndicatorName + "-NO-MagicE";
string NewOrderComment = IndicatorName + "-NO-Comment";
string NewOrderCommentE = IndicatorName + "-NO-CommentE";
string NewOrderURL = IndicatorName + "-NO-URL";

string NOFont = "Consolas";
void ShowNewOrder()
{
    NewOrderPanelIsOpen = true;

    int NewOrderXoff = Xoff;
    int NewOrderYoff = Yoff + PanelMovY + 2 * 4;
    int NewOrderX = NewOrderMonoX + 2 + 2;
    int NewOrderY = (NewOrderLabelY + 2) * 11 + 2;

    string TextMarketPending = "";
    string TextBuyButton = "";
    string TextSellButton = "";
    string TextSpread = "";
    string TextLotSize = "";
    string TextSLType = "";
    string TextSLPts = "";
    string TextTPPts = "";
    string TextSLPrice = "";
    string TextTPPrice = "";
    string TextMagic = "";
    string TextComment = "";
    string TextSLPtsE = "";
    string TextTPPtsE = "";
    string TextSLPriceE = "";
    string TextTPPriceE = "";
    string TextPendingOpenPrice = "";
    string TextPendingOpenPriceE = "";
    string TextPositionSize = "";
    string TextRecSize = "";
    int j = 1;

    TextSpread = "CURRENT SPREAD IS " + IntegerToString((int)MarketInfo(Symbol(), MODE_SPREAD)) + " POINTS";
    TextSLPts = "SL in Points";
    TextTPPts = "TP in Points";
    TextSLPrice = "SL Price";
    TextTPPrice = "TP Price";
    TextPendingOpenPrice = "OPEN PRICE";
    TextLotSize = DoubleToString(CurrLotSize, 2);
    TextMagic = IntegerToString(CurrMagic);
    TextComment = CurrComment;
    TextSLPriceE = DoubleToString(CurrSLPrice, _Digits);
    TextTPPriceE = DoubleToString(CurrTPPrice, _Digits);
    TextSLPtsE = DoubleToString(CurrSLPts, 0);
    TextTPPtsE = DoubleToString(CurrTPPts, 0);
    TextPendingOpenPriceE = DoubleToString(CurrOpenPrice, _Digits);
    if (CurrMarketPending == Market) TextMarketPending = "MARKET ORDER";
    if (CurrMarketPending == Pending) TextMarketPending = "PENDING ORDER";
    TextPositionSize = "POSITION SIZE (LOTS)";
    if (RecommendedSize() > 0) TextRecSize = "RECOMMENDED SIZE (LOTS) : " + DoubleToStr(RecommendedSize(), 2);
    else TextRecSize = "RECOMMENDED SIZE (LOTS) : N/A";
    if (CurrSLPtsOrPrice == ByPts) TextSLType = "STOP LOSS BY POINTS";
    if (CurrSLPtsOrPrice == ByPrice) TextSLType = "STOP LOSS BY PRICE";
    ObjectCreate(0, NewOrderBase, OBJ_RECTANGLE_LABEL, 0, 0, 0);
    ObjectSet(NewOrderBase, OBJPROP_XDISTANCE, NewOrderXoff);
    ObjectSet(NewOrderBase, OBJPROP_YDISTANCE, NewOrderYoff);
    ObjectSetInteger(0, NewOrderBase, OBJPROP_XSIZE, NewOrderX);
    ObjectSetInteger(0, NewOrderBase, OBJPROP_YSIZE, NewOrderY);
    ObjectSetInteger(0, NewOrderBase, OBJPROP_BGCOLOR, clrWhite);
    ObjectSetInteger(0, NewOrderBase, OBJPROP_BORDER_TYPE, BORDER_FLAT);
    ObjectSetInteger(0, NewOrderBase, OBJPROP_STATE, false);
    ObjectSetInteger(0, NewOrderBase, OBJPROP_HIDDEN, true);
    ObjectSetInteger(0, NewOrderBase, OBJPROP_FONTSIZE, NOFontSize);
    ObjectSet(NewOrderBase, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, NewOrderBase, OBJPROP_COLOR, clrBlack);

    ObjectCreate(0, NewOrderClose, OBJ_EDIT, 0, 0, 0);
    ObjectSet(NewOrderClose, OBJPROP_XDISTANCE, NewOrderXoff + 2);
    ObjectSet(NewOrderClose, OBJPROP_YDISTANCE, NewOrderYoff + 2);
    ObjectSetInteger(0, NewOrderClose, OBJPROP_XSIZE, NewOrderMonoX);
    ObjectSetInteger(0, NewOrderClose, OBJPROP_YSIZE, NewOrderLabelY);
    ObjectSetInteger(0, NewOrderClose, OBJPROP_BORDER_TYPE, BORDER_FLAT);
    ObjectSetInteger(0, NewOrderClose, OBJPROP_STATE, false);
    ObjectSetInteger(0, NewOrderClose, OBJPROP_HIDDEN, true);
    ObjectSetInteger(0, NewOrderClose, OBJPROP_READONLY, true);
    ObjectSetInteger(0, NewOrderClose, OBJPROP_FONTSIZE, NOFontSize);
    ObjectSetString(0, NewOrderClose, OBJPROP_TOOLTIP, "Close Panel");
    ObjectSetInteger(0, NewOrderClose, OBJPROP_ALIGN, ALIGN_CENTER);
    ObjectSetString(0, NewOrderClose, OBJPROP_FONT, NOFont);
    ObjectSetString(0, NewOrderClose, OBJPROP_TEXT, "X");
    ObjectSet(NewOrderClose, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, NewOrderClose, OBJPROP_COLOR, clrBlack);
    ObjectSetInteger(0, NewOrderClose, OBJPROP_BGCOLOR, clrCrimson);
    ObjectSetInteger(0, NewOrderClose, OBJPROP_BORDER_COLOR, clrBlack);

    ObjectCreate(0, NewOrderSpread, OBJ_EDIT, 0, 0, 0);
    ObjectSet(NewOrderSpread, OBJPROP_XDISTANCE, NewOrderXoff + 2);
    ObjectSet(NewOrderSpread, OBJPROP_YDISTANCE, NewOrderYoff + 2 + (NewOrderLabelY + 1) * j);
    ObjectSetInteger(0, NewOrderSpread, OBJPROP_XSIZE, NewOrderMonoX);
    ObjectSetInteger(0, NewOrderSpread, OBJPROP_YSIZE, NewOrderLabelY);
    ObjectSetInteger(0, NewOrderSpread, OBJPROP_BORDER_TYPE, BORDER_FLAT);
    ObjectSetInteger(0, NewOrderSpread, OBJPROP_STATE, false);
    ObjectSetInteger(0, NewOrderSpread, OBJPROP_HIDDEN, true);
    ObjectSetInteger(0, NewOrderSpread, OBJPROP_READONLY, true);
    ObjectSetInteger(0, NewOrderSpread, OBJPROP_FONTSIZE, NOFontSize);
    ObjectSetString(0, NewOrderSpread, OBJPROP_TOOLTIP, "Current Spread");
    ObjectSetInteger(0, NewOrderSpread, OBJPROP_ALIGN, ALIGN_CENTER);
    ObjectSetString(0, NewOrderSpread, OBJPROP_FONT, NOFont);
    ObjectSetString(0, NewOrderSpread, OBJPROP_TEXT, TextSpread);
    ObjectSet(NewOrderSpread, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, NewOrderSpread, OBJPROP_COLOR, clrBlack);
    j++;

    ObjectCreate(0, NewOrderMarketPending, OBJ_EDIT, 0, 0, 0);
    ObjectSet(NewOrderMarketPending, OBJPROP_XDISTANCE, NewOrderXoff + 2);
    ObjectSet(NewOrderMarketPending, OBJPROP_YDISTANCE, NewOrderYoff + 2 + (NewOrderLabelY + 1) * j);
    ObjectSetInteger(0, NewOrderMarketPending, OBJPROP_XSIZE, NewOrderMonoX);
    ObjectSetInteger(0, NewOrderMarketPending, OBJPROP_YSIZE, NewOrderLabelY);
    ObjectSetInteger(0, NewOrderMarketPending, OBJPROP_BORDER_TYPE, BORDER_FLAT);
    ObjectSetInteger(0, NewOrderMarketPending, OBJPROP_STATE, false);
    ObjectSetInteger(0, NewOrderMarketPending, OBJPROP_HIDDEN, true);
    ObjectSetInteger(0, NewOrderMarketPending, OBJPROP_READONLY, true);
    ObjectSetInteger(0, NewOrderMarketPending, OBJPROP_FONTSIZE, NOFontSize);
    ObjectSetString(0, NewOrderMarketPending, OBJPROP_TOOLTIP, "Market or Pending Order? Click to change");
    ObjectSetInteger(0, NewOrderMarketPending, OBJPROP_ALIGN, ALIGN_CENTER);
    ObjectSetString(0, NewOrderMarketPending, OBJPROP_FONT, NOFont);
    ObjectSetString(0, NewOrderMarketPending, OBJPROP_TEXT, TextMarketPending);
    ObjectSet(NewOrderMarketPending, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, NewOrderMarketPending, OBJPROP_COLOR, clrBlack);
    ObjectSetInteger(0, NewOrderMarketPending, OBJPROP_BGCOLOR, clrPaleGreen);
    ObjectSetInteger(0, NewOrderMarketPending, OBJPROP_BORDER_COLOR, clrBlack);
    j++;

    if (CurrMarketPending == 0)
    {
        ObjectCreate(0, NewOrderBuy, OBJ_EDIT, 0, 0, 0);
        ObjectSet(NewOrderBuy, OBJPROP_XDISTANCE, NewOrderXoff + 2);
        ObjectSet(NewOrderBuy, OBJPROP_YDISTANCE, NewOrderYoff + 2 + (NewOrderLabelY + 1) * j);
        ObjectSetInteger(0, NewOrderBuy, OBJPROP_XSIZE, NewOrderDoubleX);
        ObjectSetInteger(0, NewOrderBuy, OBJPROP_YSIZE, NewOrderLabelY);
        ObjectSetInteger(0, NewOrderBuy, OBJPROP_BORDER_TYPE, BORDER_FLAT);
        ObjectSetInteger(0, NewOrderBuy, OBJPROP_STATE, false);
        ObjectSetInteger(0, NewOrderBuy, OBJPROP_HIDDEN, true);
        ObjectSetInteger(0, NewOrderBuy, OBJPROP_READONLY, true);
        ObjectSetInteger(0, NewOrderBuy, OBJPROP_FONTSIZE, NOFontSize);
        ObjectSetString(0, NewOrderBuy, OBJPROP_TOOLTIP, "BUY");
        ObjectSetInteger(0, NewOrderBuy, OBJPROP_ALIGN, ALIGN_CENTER);
        ObjectSetString(0, NewOrderBuy, OBJPROP_FONT, NOFont);
        ObjectSetString(0, NewOrderBuy, OBJPROP_TEXT, "BUY");
        ObjectSet(NewOrderBuy, OBJPROP_SELECTABLE, false);
        ObjectSetInteger(0, NewOrderBuy, OBJPROP_COLOR, clrWhite);
        ObjectSetInteger(0, NewOrderBuy, OBJPROP_BGCOLOR, clrBlue);
        ObjectSetInteger(0, NewOrderBuy, OBJPROP_BORDER_COLOR, clrBlack);

        ObjectCreate(0, NewOrderSell, OBJ_EDIT, 0, 0, 0);
        ObjectSet(NewOrderSell, OBJPROP_XDISTANCE, NewOrderXoff + (NewOrderDoubleX + 2) + 2);
        ObjectSet(NewOrderSell, OBJPROP_YDISTANCE, NewOrderYoff + 2 + (NewOrderLabelY + 1) * j);
        ObjectSetInteger(0, NewOrderSell, OBJPROP_XSIZE, NewOrderDoubleX);
        ObjectSetInteger(0, NewOrderSell, OBJPROP_YSIZE, NewOrderLabelY);
        ObjectSetInteger(0, NewOrderSell, OBJPROP_BORDER_TYPE, BORDER_FLAT);
        ObjectSetInteger(0, NewOrderSell, OBJPROP_STATE, false);
        ObjectSetInteger(0, NewOrderSell, OBJPROP_HIDDEN, true);
        ObjectSetInteger(0, NewOrderSell, OBJPROP_READONLY, true);
        ObjectSetInteger(0, NewOrderSell, OBJPROP_FONTSIZE, NOFontSize);
        ObjectSetString(0, NewOrderSell, OBJPROP_TOOLTIP, "SELL");
        ObjectSetInteger(0, NewOrderSell, OBJPROP_ALIGN, ALIGN_CENTER);
        ObjectSetString(0, NewOrderSell, OBJPROP_FONT, NOFont);
        ObjectSetString(0, NewOrderSell, OBJPROP_TEXT, "SELL");
        ObjectSet(NewOrderSell, OBJPROP_SELECTABLE, false);
        ObjectSetInteger(0, NewOrderSell, OBJPROP_COLOR, clrWhite);
        ObjectSetInteger(0, NewOrderSell, OBJPROP_BGCOLOR, clrRed);
        ObjectSetInteger(0, NewOrderSell, OBJPROP_BORDER_COLOR, clrBlack);
        j++;
    }
    else if (CurrMarketPending == 1)
    {
        ObjectCreate(0, NewOrderBuyStop, OBJ_EDIT, 0, 0, 0);
        ObjectSet(NewOrderBuyStop, OBJPROP_XDISTANCE, NewOrderXoff + 2);
        ObjectSet(NewOrderBuyStop, OBJPROP_YDISTANCE, NewOrderYoff + 2 + (NewOrderLabelY + 1) * j);
        ObjectSetInteger(0, NewOrderBuyStop, OBJPROP_XSIZE, NewOrderDoubleX);
        ObjectSetInteger(0, NewOrderBuyStop, OBJPROP_YSIZE, NewOrderLabelY);
        ObjectSetInteger(0, NewOrderBuyStop, OBJPROP_BORDER_TYPE, BORDER_FLAT);
        ObjectSetInteger(0, NewOrderBuyStop, OBJPROP_STATE, false);
        ObjectSetInteger(0, NewOrderBuyStop, OBJPROP_HIDDEN, true);
        ObjectSetInteger(0, NewOrderBuyStop, OBJPROP_READONLY, true);
        ObjectSetInteger(0, NewOrderBuyStop, OBJPROP_FONTSIZE, NOFontSize);
        ObjectSetString(0, NewOrderBuyStop, OBJPROP_TOOLTIP, "BUY STOP");
        ObjectSetInteger(0, NewOrderBuyStop, OBJPROP_ALIGN, ALIGN_CENTER);
        ObjectSetString(0, NewOrderBuyStop, OBJPROP_FONT, NOFont);
        ObjectSetString(0, NewOrderBuyStop, OBJPROP_TEXT, "BUY STOP");
        ObjectSet(NewOrderBuyStop, OBJPROP_SELECTABLE, false);
        ObjectSetInteger(0, NewOrderBuyStop, OBJPROP_COLOR, clrWhite);
        ObjectSetInteger(0, NewOrderBuyStop, OBJPROP_BGCOLOR, clrBlue);
        ObjectSetInteger(0, NewOrderBuyStop, OBJPROP_BORDER_COLOR, clrBlack);

        ObjectCreate(0, NewOrderSellStop, OBJ_EDIT, 0, 0, 0);
        ObjectSet(NewOrderSellStop, OBJPROP_XDISTANCE, NewOrderXoff + (NewOrderDoubleX + 2) + 2);
        ObjectSet(NewOrderSellStop, OBJPROP_YDISTANCE, NewOrderYoff + 2 + (NewOrderLabelY + 1) * j);
        ObjectSetInteger(0, NewOrderSellStop, OBJPROP_XSIZE, NewOrderDoubleX);
        ObjectSetInteger(0, NewOrderSellStop, OBJPROP_YSIZE, NewOrderLabelY);
        ObjectSetInteger(0, NewOrderSellStop, OBJPROP_BORDER_TYPE, BORDER_FLAT);
        ObjectSetInteger(0, NewOrderSellStop, OBJPROP_STATE, false);
        ObjectSetInteger(0, NewOrderSellStop, OBJPROP_HIDDEN, true);
        ObjectSetInteger(0, NewOrderSellStop, OBJPROP_READONLY, true);
        ObjectSetInteger(0, NewOrderSellStop, OBJPROP_FONTSIZE, NOFontSize);
        ObjectSetString(0, NewOrderSellStop, OBJPROP_TOOLTIP, "SELL STOP");
        ObjectSetInteger(0, NewOrderSellStop, OBJPROP_ALIGN, ALIGN_CENTER);
        ObjectSetString(0, NewOrderSellStop, OBJPROP_FONT, NOFont);
        ObjectSetString(0, NewOrderSellStop, OBJPROP_TEXT, "SELL STOP");
        ObjectSet(NewOrderSellStop, OBJPROP_SELECTABLE, false);
        ObjectSetInteger(0, NewOrderSellStop, OBJPROP_COLOR, clrWhite);
        ObjectSetInteger(0, NewOrderSellStop, OBJPROP_BGCOLOR, clrRed);
        ObjectSetInteger(0, NewOrderSellStop, OBJPROP_BORDER_COLOR, clrBlack);
        j++;

        ObjectCreate(0, NewOrderBuyLimit, OBJ_EDIT, 0, 0, 0);
        ObjectSet(NewOrderBuyLimit, OBJPROP_XDISTANCE, NewOrderXoff + 2);
        ObjectSet(NewOrderBuyLimit, OBJPROP_YDISTANCE, NewOrderYoff + 2 + (NewOrderLabelY + 1) * j);
        ObjectSetInteger(0, NewOrderBuyLimit, OBJPROP_XSIZE, NewOrderDoubleX);
        ObjectSetInteger(0, NewOrderBuyLimit, OBJPROP_YSIZE, NewOrderLabelY);
        ObjectSetInteger(0, NewOrderBuyLimit, OBJPROP_BORDER_TYPE, BORDER_FLAT);
        ObjectSetInteger(0, NewOrderBuyLimit, OBJPROP_STATE, false);
        ObjectSetInteger(0, NewOrderBuyLimit, OBJPROP_HIDDEN, true);
        ObjectSetInteger(0, NewOrderBuyLimit, OBJPROP_READONLY, true);
        ObjectSetInteger(0, NewOrderBuyLimit, OBJPROP_FONTSIZE, NOFontSize);
        ObjectSetString(0, NewOrderBuyLimit, OBJPROP_TOOLTIP, "BUY LIMIT");
        ObjectSetInteger(0, NewOrderBuyLimit, OBJPROP_ALIGN, ALIGN_CENTER);
        ObjectSetString(0, NewOrderBuyLimit, OBJPROP_FONT, NOFont);
        ObjectSetString(0, NewOrderBuyLimit, OBJPROP_TEXT, "BUY LIMIT");
        ObjectSet(NewOrderBuyLimit, OBJPROP_SELECTABLE, false);
        ObjectSetInteger(0, NewOrderBuyLimit, OBJPROP_COLOR, clrWhite);
        ObjectSetInteger(0, NewOrderBuyLimit, OBJPROP_BGCOLOR, clrBlue);
        ObjectSetInteger(0, NewOrderBuyLimit, OBJPROP_BORDER_COLOR, clrBlack);

        ObjectCreate(0, NewOrderSellLimit, OBJ_EDIT, 0, 0, 0);
        ObjectSet(NewOrderSellLimit, OBJPROP_XDISTANCE, NewOrderXoff + (NewOrderDoubleX + 2) + 2);
        ObjectSet(NewOrderSellLimit, OBJPROP_YDISTANCE, NewOrderYoff + 2 + (NewOrderLabelY + 1) * j);
        ObjectSetInteger(0, NewOrderSellLimit, OBJPROP_XSIZE, NewOrderDoubleX);
        ObjectSetInteger(0, NewOrderSellLimit, OBJPROP_YSIZE, NewOrderLabelY);
        ObjectSetInteger(0, NewOrderSellLimit, OBJPROP_BORDER_TYPE, BORDER_FLAT);
        ObjectSetInteger(0, NewOrderSellLimit, OBJPROP_STATE, false);
        ObjectSetInteger(0, NewOrderSellLimit, OBJPROP_HIDDEN, true);
        ObjectSetInteger(0, NewOrderSellLimit, OBJPROP_READONLY, true);
        ObjectSetInteger(0, NewOrderSellLimit, OBJPROP_FONTSIZE, NOFontSize);
        ObjectSetString(0, NewOrderSellLimit, OBJPROP_TOOLTIP, "SELL LIMIT");
        ObjectSetInteger(0, NewOrderSellLimit, OBJPROP_ALIGN, ALIGN_CENTER);
        ObjectSetString(0, NewOrderSellLimit, OBJPROP_FONT, NOFont);
        ObjectSetString(0, NewOrderSellLimit, OBJPROP_TEXT, "SELL LIMIT");
        ObjectSet(NewOrderSellLimit, OBJPROP_SELECTABLE, false);
        ObjectSetInteger(0, NewOrderSellLimit, OBJPROP_COLOR, clrWhite);
        ObjectSetInteger(0, NewOrderSellLimit, OBJPROP_BGCOLOR, clrRed);
        ObjectSetInteger(0, NewOrderSellLimit, OBJPROP_BORDER_COLOR, clrBlack);
        j++;

        ObjectCreate(0, NewOrderPendingOpenPrice, OBJ_EDIT, 0, 0, 0);
        ObjectSet(NewOrderPendingOpenPrice, OBJPROP_XDISTANCE, NewOrderXoff + 2);
        ObjectSet(NewOrderPendingOpenPrice, OBJPROP_YDISTANCE, NewOrderYoff + 2 + (NewOrderLabelY + 1) * j);
        ObjectSetInteger(0, NewOrderPendingOpenPrice, OBJPROP_XSIZE, NewOrderDoubleX);
        ObjectSetInteger(0, NewOrderPendingOpenPrice, OBJPROP_YSIZE, NewOrderLabelY);
        ObjectSetInteger(0, NewOrderPendingOpenPrice, OBJPROP_BORDER_TYPE, BORDER_FLAT);
        ObjectSetInteger(0, NewOrderPendingOpenPrice, OBJPROP_STATE, false);
        ObjectSetInteger(0, NewOrderPendingOpenPrice, OBJPROP_HIDDEN, true);
        ObjectSetInteger(0, NewOrderPendingOpenPrice, OBJPROP_READONLY, true);
        ObjectSetInteger(0, NewOrderPendingOpenPrice, OBJPROP_FONTSIZE, NOFontSize);
        ObjectSetString(0, NewOrderPendingOpenPrice, OBJPROP_TOOLTIP, "Open Price");
        ObjectSetInteger(0, NewOrderPendingOpenPrice, OBJPROP_ALIGN, ALIGN_CENTER);
        ObjectSetString(0, NewOrderPendingOpenPrice, OBJPROP_FONT, NOFont);
        ObjectSetString(0, NewOrderPendingOpenPrice, OBJPROP_TEXT, TextPendingOpenPrice);
        ObjectSet(NewOrderPendingOpenPrice, OBJPROP_SELECTABLE, false);
        ObjectSetInteger(0, NewOrderPendingOpenPrice, OBJPROP_COLOR, clrBlack);

        ObjectCreate(0, NewOrderPendingOpenPriceE, OBJ_EDIT, 0, 0, 0);
        ObjectSet(NewOrderPendingOpenPriceE, OBJPROP_XDISTANCE, NewOrderXoff + (NewOrderDoubleX + 2) + 2);
        ObjectSet(NewOrderPendingOpenPriceE, OBJPROP_YDISTANCE, NewOrderYoff + 2 + (NewOrderLabelY + 1) * j);
        ObjectSetInteger(0, NewOrderPendingOpenPriceE, OBJPROP_XSIZE, NewOrderDoubleX);
        ObjectSetInteger(0, NewOrderPendingOpenPriceE, OBJPROP_YSIZE, NewOrderLabelY);
        ObjectSetInteger(0, NewOrderPendingOpenPriceE, OBJPROP_BORDER_TYPE, BORDER_FLAT);
        ObjectSetInteger(0, NewOrderPendingOpenPriceE, OBJPROP_STATE, false);
        ObjectSetInteger(0, NewOrderPendingOpenPriceE, OBJPROP_HIDDEN, true);
        ObjectSetInteger(0, NewOrderPendingOpenPriceE, OBJPROP_READONLY, false);
        ObjectSetInteger(0, NewOrderPendingOpenPriceE, OBJPROP_FONTSIZE, NOFontSize);
        ObjectSetString(0, NewOrderPendingOpenPriceE, OBJPROP_TOOLTIP, "Open Price - Click to change");
        ObjectSetInteger(0, NewOrderPendingOpenPriceE, OBJPROP_ALIGN, ALIGN_CENTER);
        ObjectSetString(0, NewOrderPendingOpenPriceE, OBJPROP_FONT, NOFont);
        ObjectSetString(0, NewOrderPendingOpenPriceE, OBJPROP_TEXT, TextPendingOpenPriceE);
        ObjectSet(NewOrderPendingOpenPriceE, OBJPROP_SELECTABLE, false);
        ObjectSetInteger(0, NewOrderPendingOpenPriceE, OBJPROP_COLOR, clrBlack);
        j++;
    }

    ObjectCreate(0, NewOrderPositionSize, OBJ_EDIT, 0, 0, 0);
    ObjectSet(NewOrderPositionSize, OBJPROP_XDISTANCE, NewOrderXoff + 2);
    ObjectSet(NewOrderPositionSize, OBJPROP_YDISTANCE, NewOrderYoff + 2 + (NewOrderLabelY + 1) * j);
    ObjectSetInteger(0, NewOrderPositionSize, OBJPROP_XSIZE, NewOrderMonoX);
    ObjectSetInteger(0, NewOrderPositionSize, OBJPROP_YSIZE, NewOrderLabelY);
    ObjectSetInteger(0, NewOrderPositionSize, OBJPROP_BORDER_TYPE, BORDER_FLAT);
    ObjectSetInteger(0, NewOrderPositionSize, OBJPROP_STATE, false);
    ObjectSetInteger(0, NewOrderPositionSize, OBJPROP_HIDDEN, true);
    ObjectSetInteger(0, NewOrderPositionSize, OBJPROP_READONLY, true);
    ObjectSetInteger(0, NewOrderPositionSize, OBJPROP_FONTSIZE, NOFontSize);
    ObjectSetString(0, NewOrderPositionSize, OBJPROP_TOOLTIP, "Position Size Title");
    ObjectSetInteger(0, NewOrderPositionSize, OBJPROP_ALIGN, ALIGN_CENTER);
    ObjectSetString(0, NewOrderPositionSize, OBJPROP_FONT, NOFont);
    ObjectSetString(0, NewOrderPositionSize, OBJPROP_TEXT, TextPositionSize);
    ObjectSet(NewOrderPositionSize, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, NewOrderPositionSize, OBJPROP_COLOR, clrBlack);
    j++;

    ObjectCreate(0, NewOrderLotMinus, OBJ_EDIT, 0, 0, 0);
    ObjectSet(NewOrderLotMinus, OBJPROP_XDISTANCE, NewOrderXoff + 2);
    ObjectSet(NewOrderLotMinus, OBJPROP_YDISTANCE, NewOrderYoff + 2 + (NewOrderLabelY + 1) * j);
    ObjectSetInteger(0, NewOrderLotMinus, OBJPROP_XSIZE, NewOrderTripleX);
    ObjectSetInteger(0, NewOrderLotMinus, OBJPROP_YSIZE, NewOrderLabelY);
    ObjectSetInteger(0, NewOrderLotMinus, OBJPROP_BORDER_TYPE, BORDER_FLAT);
    ObjectSetInteger(0, NewOrderLotMinus, OBJPROP_STATE, false);
    ObjectSetInteger(0, NewOrderLotMinus, OBJPROP_HIDDEN, true);
    ObjectSetInteger(0, NewOrderLotMinus, OBJPROP_READONLY, true);
    ObjectSetInteger(0, NewOrderLotMinus, OBJPROP_FONTSIZE, NOFontSize);
    ObjectSetString(0, NewOrderLotMinus, OBJPROP_TOOLTIP, "Decrease Lot Size");
    ObjectSetInteger(0, NewOrderLotMinus, OBJPROP_ALIGN, ALIGN_CENTER);
    ObjectSetString(0, NewOrderLotMinus, OBJPROP_FONT, NOFont);
    ObjectSetString(0, NewOrderLotMinus, OBJPROP_TEXT, "-");
    ObjectSet(NewOrderLotMinus, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, NewOrderLotMinus, OBJPROP_COLOR, clrBlack);

    ObjectCreate(0, NewOrderLotSize, OBJ_EDIT, 0, 0, 0);
    ObjectSet(NewOrderLotSize, OBJPROP_XDISTANCE, NewOrderXoff + 2 + NewOrderTripleX + 2);
    ObjectSet(NewOrderLotSize, OBJPROP_YDISTANCE, NewOrderYoff + 2 + (NewOrderLabelY + 1) * j);
    ObjectSetInteger(0, NewOrderLotSize, OBJPROP_XSIZE, NewOrderTripleX);
    ObjectSetInteger(0, NewOrderLotSize, OBJPROP_YSIZE, NewOrderLabelY);
    ObjectSetInteger(0, NewOrderLotSize, OBJPROP_BORDER_TYPE, BORDER_FLAT);
    ObjectSetInteger(0, NewOrderLotSize, OBJPROP_STATE, false);
    ObjectSetInteger(0, NewOrderLotSize, OBJPROP_HIDDEN, true);
    ObjectSetInteger(0, NewOrderLotSize, OBJPROP_READONLY, false);
    ObjectSetInteger(0, NewOrderLotSize, OBJPROP_FONTSIZE, NOFontSize);
    ObjectSetString(0, NewOrderLotSize, OBJPROP_TOOLTIP, "Lot Size");
    ObjectSetInteger(0, NewOrderLotSize, OBJPROP_ALIGN, ALIGN_CENTER);
    ObjectSetString(0, NewOrderLotSize, OBJPROP_FONT, NOFont);
    ObjectSetString(0, NewOrderLotSize, OBJPROP_TEXT, TextLotSize);
    ObjectSet(NewOrderLotSize, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, NewOrderLotSize, OBJPROP_COLOR, clrBlack);

    ObjectCreate(0, NewOrderLotPlus, OBJ_EDIT, 0, 0, 0);
    ObjectSet(NewOrderLotPlus, OBJPROP_XDISTANCE, NewOrderXoff + 2 + (NewOrderTripleX + 2) * 2);
    ObjectSet(NewOrderLotPlus, OBJPROP_YDISTANCE, NewOrderYoff + 2 + (NewOrderLabelY + 1) * j);
    ObjectSetInteger(0, NewOrderLotPlus, OBJPROP_XSIZE, NewOrderTripleX);
    ObjectSetInteger(0, NewOrderLotPlus, OBJPROP_YSIZE, NewOrderLabelY);
    ObjectSetInteger(0, NewOrderLotPlus, OBJPROP_BORDER_TYPE, BORDER_FLAT);
    ObjectSetInteger(0, NewOrderLotPlus, OBJPROP_STATE, false);
    ObjectSetInteger(0, NewOrderLotPlus, OBJPROP_HIDDEN, true);
    ObjectSetInteger(0, NewOrderLotPlus, OBJPROP_READONLY, true);
    ObjectSetInteger(0, NewOrderLotPlus, OBJPROP_FONTSIZE, NOFontSize);
    ObjectSetString(0, NewOrderLotPlus, OBJPROP_TOOLTIP, "Increase Lot Size");
    ObjectSetInteger(0, NewOrderLotPlus, OBJPROP_ALIGN, ALIGN_CENTER);
    ObjectSetString(0, NewOrderLotPlus, OBJPROP_FONT, NOFont);
    ObjectSetString(0, NewOrderLotPlus, OBJPROP_TEXT, "+");
    ObjectSet(NewOrderLotPlus, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, NewOrderLotPlus, OBJPROP_COLOR, clrBlack);
    j++;

    ObjectCreate(0, NewOrderRecommendedSize, OBJ_EDIT, 0, 0, 0);
    ObjectSet(NewOrderRecommendedSize, OBJPROP_XDISTANCE, NewOrderXoff + 2);
    ObjectSet(NewOrderRecommendedSize, OBJPROP_YDISTANCE, NewOrderYoff + 2 + (NewOrderLabelY + 1) * j);
    ObjectSetInteger(0, NewOrderRecommendedSize, OBJPROP_XSIZE, NewOrderMonoX);
    ObjectSetInteger(0, NewOrderRecommendedSize, OBJPROP_YSIZE, NewOrderLabelY);
    ObjectSetInteger(0, NewOrderRecommendedSize, OBJPROP_BORDER_TYPE, BORDER_FLAT);
    ObjectSetInteger(0, NewOrderRecommendedSize, OBJPROP_STATE, false);
    ObjectSetInteger(0, NewOrderRecommendedSize, OBJPROP_HIDDEN, true);
    ObjectSetInteger(0, NewOrderRecommendedSize, OBJPROP_READONLY, true);
    ObjectSetInteger(0, NewOrderRecommendedSize, OBJPROP_FONTSIZE, NOFontSize);
    ObjectSetString(0, NewOrderRecommendedSize, OBJPROP_TOOLTIP, "Recommended Position Size - Click to copy to Position Size");
    ObjectSetInteger(0, NewOrderRecommendedSize, OBJPROP_ALIGN, ALIGN_CENTER);
    ObjectSetString(0, NewOrderRecommendedSize, OBJPROP_FONT, NOFont);
    ObjectSetString(0, NewOrderRecommendedSize, OBJPROP_TEXT, TextRecSize);
    ObjectSet(NewOrderRecommendedSize, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, NewOrderRecommendedSize, OBJPROP_COLOR, clrBlack);
    j++;

    ObjectCreate(0, NewOrderSLType, OBJ_EDIT, 0, 0, 0);
    ObjectSet(NewOrderSLType, OBJPROP_XDISTANCE, NewOrderXoff + 2);
    ObjectSet(NewOrderSLType, OBJPROP_YDISTANCE, NewOrderYoff + 2 + (NewOrderLabelY + 1) * j);
    ObjectSetInteger(0, NewOrderSLType, OBJPROP_XSIZE, NewOrderMonoX);
    ObjectSetInteger(0, NewOrderSLType, OBJPROP_YSIZE, NewOrderLabelY);
    ObjectSetInteger(0, NewOrderSLType, OBJPROP_BORDER_TYPE, BORDER_FLAT);
    ObjectSetInteger(0, NewOrderSLType, OBJPROP_STATE, false);
    ObjectSetInteger(0, NewOrderSLType, OBJPROP_HIDDEN, true);
    ObjectSetInteger(0, NewOrderSLType, OBJPROP_READONLY, true);
    ObjectSetInteger(0, NewOrderSLType, OBJPROP_FONTSIZE, NOFontSize);
    ObjectSetString(0, NewOrderSLType, OBJPROP_TOOLTIP, "Stop Loss by Price or Points? Click to change");
    ObjectSetInteger(0, NewOrderSLType, OBJPROP_ALIGN, ALIGN_CENTER);
    ObjectSetString(0, NewOrderSLType, OBJPROP_FONT, NOFont);
    ObjectSetString(0, NewOrderSLType, OBJPROP_TEXT, TextSLType);
    ObjectSet(NewOrderSLType, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, NewOrderSLType, OBJPROP_COLOR, clrBlack);
    ObjectSetInteger(0, NewOrderSLType, OBJPROP_BGCOLOR, clrPaleGreen);
    ObjectSetInteger(0, NewOrderSLType, OBJPROP_BORDER_COLOR, clrBlack);
    j++;

    if (CurrSLPtsOrPrice == 0)
    {
        ObjectCreate(0, NewOrderSLPts, OBJ_EDIT, 0, 0, 0);
        ObjectSet(NewOrderSLPts, OBJPROP_XDISTANCE, NewOrderXoff + 2);
        ObjectSet(NewOrderSLPts, OBJPROP_YDISTANCE, NewOrderYoff + 2 + (NewOrderLabelY + 1) * j);
        ObjectSetInteger(0, NewOrderSLPts, OBJPROP_XSIZE, NewOrderDoubleX);
        ObjectSetInteger(0, NewOrderSLPts, OBJPROP_YSIZE, NewOrderLabelY);
        ObjectSetInteger(0, NewOrderSLPts, OBJPROP_BORDER_TYPE, BORDER_FLAT);
        ObjectSetInteger(0, NewOrderSLPts, OBJPROP_STATE, false);
        ObjectSetInteger(0, NewOrderSLPts, OBJPROP_HIDDEN, true);
        ObjectSetInteger(0, NewOrderSLPts, OBJPROP_READONLY, true);
        ObjectSetInteger(0, NewOrderSLPts, OBJPROP_FONTSIZE, NOFontSize);
        ObjectSetString(0, NewOrderSLPts, OBJPROP_TOOLTIP, "Stop Loss in Points");
        ObjectSetInteger(0, NewOrderSLPts, OBJPROP_ALIGN, ALIGN_CENTER);
        ObjectSetString(0, NewOrderSLPts, OBJPROP_FONT, NOFont);
        ObjectSetString(0, NewOrderSLPts, OBJPROP_TEXT, TextSLPts);
        ObjectSet(NewOrderSLPts, OBJPROP_SELECTABLE, false);
        ObjectSetInteger(0, NewOrderSLPts, OBJPROP_COLOR, clrBlack);

        ObjectCreate(0, NewOrderSLPtsE, OBJ_EDIT, 0, 0, 0);
        ObjectSet(NewOrderSLPtsE, OBJPROP_XDISTANCE, NewOrderXoff + (NewOrderDoubleX + 2) + 2);
        ObjectSet(NewOrderSLPtsE, OBJPROP_YDISTANCE, NewOrderYoff + 2 + (NewOrderLabelY + 1) * j);
        ObjectSetInteger(0, NewOrderSLPtsE, OBJPROP_XSIZE, NewOrderDoubleX);
        ObjectSetInteger(0, NewOrderSLPtsE, OBJPROP_YSIZE, NewOrderLabelY);
        ObjectSetInteger(0, NewOrderSLPtsE, OBJPROP_BORDER_TYPE, BORDER_FLAT);
        ObjectSetInteger(0, NewOrderSLPtsE, OBJPROP_STATE, false);
        ObjectSetInteger(0, NewOrderSLPtsE, OBJPROP_HIDDEN, true);
        ObjectSetInteger(0, NewOrderSLPtsE, OBJPROP_READONLY, false);
        ObjectSetInteger(0, NewOrderSLPtsE, OBJPROP_FONTSIZE, NOFontSize);
        ObjectSetString(0, NewOrderSLPtsE, OBJPROP_TOOLTIP, "Stop Loss in Points");
        ObjectSetInteger(0, NewOrderSLPtsE, OBJPROP_ALIGN, ALIGN_CENTER);
        ObjectSetString(0, NewOrderSLPtsE, OBJPROP_FONT, NOFont);
        ObjectSetString(0, NewOrderSLPtsE, OBJPROP_TEXT, TextSLPtsE);
        ObjectSet(NewOrderSLPtsE, OBJPROP_SELECTABLE, false);
        ObjectSetInteger(0, NewOrderSLPtsE, OBJPROP_COLOR, clrBlack);
        j++;

        ObjectCreate(0, NewOrderTPPts, OBJ_EDIT, 0, 0, 0);
        ObjectSet(NewOrderTPPts, OBJPROP_XDISTANCE, NewOrderXoff + 2);
        ObjectSet(NewOrderTPPts, OBJPROP_YDISTANCE, NewOrderYoff + 2 + (NewOrderLabelY + 1) * j);
        ObjectSetInteger(0, NewOrderTPPts, OBJPROP_XSIZE, NewOrderDoubleX);
        ObjectSetInteger(0, NewOrderTPPts, OBJPROP_YSIZE, NewOrderLabelY);
        ObjectSetInteger(0, NewOrderTPPts, OBJPROP_BORDER_TYPE, BORDER_FLAT);
        ObjectSetInteger(0, NewOrderTPPts, OBJPROP_STATE, false);
        ObjectSetInteger(0, NewOrderTPPts, OBJPROP_HIDDEN, true);
        ObjectSetInteger(0, NewOrderTPPts, OBJPROP_READONLY, true);
        ObjectSetInteger(0, NewOrderTPPts, OBJPROP_FONTSIZE, NOFontSize);
        ObjectSetString(0, NewOrderTPPts, OBJPROP_TOOLTIP, "Take Profit in Points");
        ObjectSetInteger(0, NewOrderTPPts, OBJPROP_ALIGN, ALIGN_CENTER);
        ObjectSetString(0, NewOrderTPPts, OBJPROP_FONT, NOFont);
        ObjectSetString(0, NewOrderTPPts, OBJPROP_TEXT, TextTPPts);
        ObjectSet(NewOrderTPPts, OBJPROP_SELECTABLE, false);
        ObjectSetInteger(0, NewOrderTPPts, OBJPROP_COLOR, clrBlack);

        ObjectCreate(0, NewOrderTPPtsE, OBJ_EDIT, 0, 0, 0);
        ObjectSet(NewOrderTPPtsE, OBJPROP_XDISTANCE, NewOrderXoff + (NewOrderDoubleX + 2) + 2);
        ObjectSet(NewOrderTPPtsE, OBJPROP_YDISTANCE, NewOrderYoff + 2 + (NewOrderLabelY + 1) * j);
        ObjectSetInteger(0, NewOrderTPPtsE, OBJPROP_XSIZE, NewOrderDoubleX);
        ObjectSetInteger(0, NewOrderTPPtsE, OBJPROP_YSIZE, NewOrderLabelY);
        ObjectSetInteger(0, NewOrderTPPtsE, OBJPROP_BORDER_TYPE, BORDER_FLAT);
        ObjectSetInteger(0, NewOrderTPPtsE, OBJPROP_STATE, false);
        ObjectSetInteger(0, NewOrderTPPtsE, OBJPROP_HIDDEN, true);
        ObjectSetInteger(0, NewOrderTPPtsE, OBJPROP_READONLY, false);
        ObjectSetInteger(0, NewOrderTPPtsE, OBJPROP_FONTSIZE, NOFontSize);
        ObjectSetString(0, NewOrderTPPtsE, OBJPROP_TOOLTIP, "Take Profit in Points");
        ObjectSetInteger(0, NewOrderTPPtsE, OBJPROP_ALIGN, ALIGN_CENTER);
        ObjectSetString(0, NewOrderTPPtsE, OBJPROP_FONT, NOFont);
        ObjectSetString(0, NewOrderTPPtsE, OBJPROP_TEXT, TextTPPtsE);
        ObjectSet(NewOrderTPPtsE, OBJPROP_SELECTABLE, false);
        ObjectSetInteger(0, NewOrderTPPtsE, OBJPROP_COLOR, clrBlack);
        j++;
    }
    else if (CurrSLPtsOrPrice == 1)
    {
        ObjectCreate(0, NewOrderSLPrice, OBJ_EDIT, 0, 0, 0);
        ObjectSet(NewOrderSLPrice, OBJPROP_XDISTANCE, NewOrderXoff + 2);
        ObjectSet(NewOrderSLPrice, OBJPROP_YDISTANCE, NewOrderYoff + 2 + (NewOrderLabelY + 1) * j);
        ObjectSetInteger(0, NewOrderSLPrice, OBJPROP_XSIZE, NewOrderDoubleX);
        ObjectSetInteger(0, NewOrderSLPrice, OBJPROP_YSIZE, NewOrderLabelY);
        ObjectSetInteger(0, NewOrderSLPrice, OBJPROP_BORDER_TYPE, BORDER_FLAT);
        ObjectSetInteger(0, NewOrderSLPrice, OBJPROP_STATE, false);
        ObjectSetInteger(0, NewOrderSLPrice, OBJPROP_HIDDEN, true);
        ObjectSetInteger(0, NewOrderSLPrice, OBJPROP_READONLY, true);
        ObjectSetInteger(0, NewOrderSLPrice, OBJPROP_FONTSIZE, NOFontSize);
        ObjectSetString(0, NewOrderSLPrice, OBJPROP_TOOLTIP, "Stop Loss Price");
        ObjectSetInteger(0, NewOrderSLPrice, OBJPROP_ALIGN, ALIGN_CENTER);
        ObjectSetString(0, NewOrderSLPrice, OBJPROP_FONT, NOFont);
        ObjectSetString(0, NewOrderSLPrice, OBJPROP_TEXT, TextSLPrice);
        ObjectSet(NewOrderSLPrice, OBJPROP_SELECTABLE, false);
        ObjectSetInteger(0, NewOrderSLPrice, OBJPROP_COLOR, clrBlack);

        ObjectCreate(0, NewOrderSLPriceE, OBJ_EDIT, 0, 0, 0);
        ObjectSet(NewOrderSLPriceE, OBJPROP_XDISTANCE, NewOrderXoff + (NewOrderDoubleX + 2) + 2);
        ObjectSet(NewOrderSLPriceE, OBJPROP_YDISTANCE, NewOrderYoff + 2 + (NewOrderLabelY + 1) * j);
        ObjectSetInteger(0, NewOrderSLPriceE, OBJPROP_XSIZE, NewOrderDoubleX);
        ObjectSetInteger(0, NewOrderSLPriceE, OBJPROP_YSIZE, NewOrderLabelY);
        ObjectSetInteger(0, NewOrderSLPriceE, OBJPROP_BORDER_TYPE, BORDER_FLAT);
        ObjectSetInteger(0, NewOrderSLPriceE, OBJPROP_STATE, false);
        ObjectSetInteger(0, NewOrderSLPriceE, OBJPROP_HIDDEN, true);
        ObjectSetInteger(0, NewOrderSLPriceE, OBJPROP_READONLY, false);
        ObjectSetInteger(0, NewOrderSLPriceE, OBJPROP_FONTSIZE, NOFontSize);
        ObjectSetString(0, NewOrderSLPriceE, OBJPROP_TOOLTIP, "Stop Loss Price");
        ObjectSetInteger(0, NewOrderSLPriceE, OBJPROP_ALIGN, ALIGN_CENTER);
        ObjectSetString(0, NewOrderSLPriceE, OBJPROP_FONT, NOFont);
        ObjectSetString(0, NewOrderSLPriceE, OBJPROP_TEXT, TextSLPriceE);
        ObjectSet(NewOrderSLPriceE, OBJPROP_SELECTABLE, false);
        ObjectSetInteger(0, NewOrderSLPriceE, OBJPROP_COLOR, clrBlack);
        j++;

        ObjectCreate(0, NewOrderTPPrice, OBJ_EDIT, 0, 0, 0);
        ObjectSet(NewOrderTPPrice, OBJPROP_XDISTANCE, NewOrderXoff + 2);
        ObjectSet(NewOrderTPPrice, OBJPROP_YDISTANCE, NewOrderYoff + 2 + (NewOrderLabelY + 1) * j);
        ObjectSetInteger(0, NewOrderTPPrice, OBJPROP_XSIZE, NewOrderDoubleX);
        ObjectSetInteger(0, NewOrderTPPrice, OBJPROP_YSIZE, NewOrderLabelY);
        ObjectSetInteger(0, NewOrderTPPrice, OBJPROP_BORDER_TYPE, BORDER_FLAT);
        ObjectSetInteger(0, NewOrderTPPrice, OBJPROP_STATE, false);
        ObjectSetInteger(0, NewOrderTPPrice, OBJPROP_HIDDEN, true);
        ObjectSetInteger(0, NewOrderTPPrice, OBJPROP_READONLY, true);
        ObjectSetInteger(0, NewOrderTPPrice, OBJPROP_FONTSIZE, NOFontSize);
        ObjectSetString(0, NewOrderTPPrice, OBJPROP_TOOLTIP, "Take Profit Price");
        ObjectSetInteger(0, NewOrderTPPrice, OBJPROP_ALIGN, ALIGN_CENTER);
        ObjectSetString(0, NewOrderTPPrice, OBJPROP_FONT, NOFont);
        ObjectSetString(0, NewOrderTPPrice, OBJPROP_TEXT, TextTPPrice);
        ObjectSet(NewOrderTPPrice, OBJPROP_SELECTABLE, false);
        ObjectSetInteger(0, NewOrderTPPrice, OBJPROP_COLOR, clrBlack);

        ObjectCreate(0, NewOrderTPPriceE, OBJ_EDIT, 0, 0, 0);
        ObjectSet(NewOrderTPPriceE, OBJPROP_XDISTANCE, NewOrderXoff + (NewOrderDoubleX + 2) + 2);
        ObjectSet(NewOrderTPPriceE, OBJPROP_YDISTANCE, NewOrderYoff + 2 + (NewOrderLabelY + 1) * j);
        ObjectSetInteger(0, NewOrderTPPriceE, OBJPROP_XSIZE, NewOrderDoubleX);
        ObjectSetInteger(0, NewOrderTPPriceE, OBJPROP_YSIZE, NewOrderLabelY);
        ObjectSetInteger(0, NewOrderTPPriceE, OBJPROP_BORDER_TYPE, BORDER_FLAT);
        ObjectSetInteger(0, NewOrderTPPriceE, OBJPROP_STATE, false);
        ObjectSetInteger(0, NewOrderTPPriceE, OBJPROP_HIDDEN, true);
        ObjectSetInteger(0, NewOrderTPPriceE, OBJPROP_READONLY, false);
        ObjectSetInteger(0, NewOrderTPPriceE, OBJPROP_FONTSIZE, NOFontSize);
        ObjectSetString(0, NewOrderTPPriceE, OBJPROP_TOOLTIP, "Take Profit Price");
        ObjectSetInteger(0, NewOrderTPPriceE, OBJPROP_ALIGN, ALIGN_CENTER);
        ObjectSetString(0, NewOrderTPPriceE, OBJPROP_FONT, NOFont);
        ObjectSetString(0, NewOrderTPPriceE, OBJPROP_TEXT, TextTPPriceE);
        ObjectSet(NewOrderTPPriceE, OBJPROP_SELECTABLE, false);
        ObjectSetInteger(0, NewOrderTPPriceE, OBJPROP_COLOR, clrBlack);
        j++;
    }
    ObjectCreate(0, NewOrderMagic, OBJ_EDIT, 0, 0, 0);
    ObjectSet(NewOrderMagic, OBJPROP_XDISTANCE, NewOrderXoff + 2);
    ObjectSet(NewOrderMagic, OBJPROP_YDISTANCE, NewOrderYoff + 2 + (NewOrderLabelY + 1) * j);
    ObjectSetInteger(0, NewOrderMagic, OBJPROP_XSIZE, NewOrderDoubleX);
    ObjectSetInteger(0, NewOrderMagic, OBJPROP_YSIZE, NewOrderLabelY);
    ObjectSetInteger(0, NewOrderMagic, OBJPROP_BORDER_TYPE, BORDER_FLAT);
    ObjectSetInteger(0, NewOrderMagic, OBJPROP_STATE, false);
    ObjectSetInteger(0, NewOrderMagic, OBJPROP_HIDDEN, true);
    ObjectSetInteger(0, NewOrderMagic, OBJPROP_READONLY, true);
    ObjectSetInteger(0, NewOrderMagic, OBJPROP_FONTSIZE, NOFontSize);
    ObjectSetString(0, NewOrderMagic, OBJPROP_TOOLTIP, "Magic Number");
    ObjectSetInteger(0, NewOrderMagic, OBJPROP_ALIGN, ALIGN_CENTER);
    ObjectSetString(0, NewOrderMagic, OBJPROP_FONT, NOFont);
    ObjectSetString(0, NewOrderMagic, OBJPROP_TEXT, "MAGIC #");
    ObjectSet(NewOrderMagic, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, NewOrderMagic, OBJPROP_COLOR, clrBlack);

    ObjectCreate(0, NewOrderMagicE, OBJ_EDIT, 0, 0, 0);
    ObjectSet(NewOrderMagicE, OBJPROP_XDISTANCE, NewOrderXoff + (NewOrderDoubleX + 2) + 2);
    ObjectSet(NewOrderMagicE, OBJPROP_YDISTANCE, NewOrderYoff + 2 + (NewOrderLabelY + 1) * j);
    ObjectSetInteger(0, NewOrderMagicE, OBJPROP_XSIZE, NewOrderDoubleX);
    ObjectSetInteger(0, NewOrderMagicE, OBJPROP_YSIZE, NewOrderLabelY);
    ObjectSetInteger(0, NewOrderMagicE, OBJPROP_BORDER_TYPE, BORDER_FLAT);
    ObjectSetInteger(0, NewOrderMagicE, OBJPROP_STATE, false);
    ObjectSetInteger(0, NewOrderMagicE, OBJPROP_HIDDEN, true);
    ObjectSetInteger(0, NewOrderMagicE, OBJPROP_READONLY, false);
    ObjectSetInteger(0, NewOrderMagicE, OBJPROP_FONTSIZE, NOFontSize);
    ObjectSetString(0, NewOrderMagicE, OBJPROP_TOOLTIP, "Magic Number for the order - Click to change");
    ObjectSetInteger(0, NewOrderMagicE, OBJPROP_ALIGN, ALIGN_CENTER);
    ObjectSetString(0, NewOrderMagicE, OBJPROP_FONT, NOFont);
    ObjectSetString(0, NewOrderMagicE, OBJPROP_TEXT, TextMagic);
    ObjectSet(NewOrderMagicE, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, NewOrderMagicE, OBJPROP_COLOR, clrBlack);
    j++;

    ObjectCreate(0, NewOrderComment, OBJ_EDIT, 0, 0, 0);
    ObjectSet(NewOrderComment, OBJPROP_XDISTANCE, NewOrderXoff + 2);
    ObjectSet(NewOrderComment, OBJPROP_YDISTANCE, NewOrderYoff + 2 + (NewOrderLabelY + 1) * j);
    ObjectSetInteger(0, NewOrderComment, OBJPROP_XSIZE, NewOrderMonoX);
    ObjectSetInteger(0, NewOrderComment, OBJPROP_YSIZE, NewOrderLabelY);
    ObjectSetInteger(0, NewOrderComment, OBJPROP_BORDER_TYPE, BORDER_FLAT);
    ObjectSetInteger(0, NewOrderComment, OBJPROP_STATE, false);
    ObjectSetInteger(0, NewOrderComment, OBJPROP_HIDDEN, true);
    ObjectSetInteger(0, NewOrderComment, OBJPROP_READONLY, true);
    ObjectSetInteger(0, NewOrderComment, OBJPROP_FONTSIZE, NOFontSize);
    ObjectSetString(0, NewOrderComment, OBJPROP_TOOLTIP, "Comment for the order");
    ObjectSetInteger(0, NewOrderComment, OBJPROP_ALIGN, ALIGN_CENTER);
    ObjectSetString(0, NewOrderComment, OBJPROP_FONT, NOFont);
    ObjectSetString(0, NewOrderComment, OBJPROP_TEXT, "COMMENT");
    ObjectSet(NewOrderComment, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, NewOrderComment, OBJPROP_COLOR, clrBlack);
    j++;

    ObjectCreate(0, NewOrderCommentE, OBJ_EDIT, 0, 0, 0);
    ObjectSet(NewOrderCommentE, OBJPROP_XDISTANCE, NewOrderXoff + 2);
    ObjectSet(NewOrderCommentE, OBJPROP_YDISTANCE, NewOrderYoff + 2 + (NewOrderLabelY + 1) * j);
    ObjectSetInteger(0, NewOrderCommentE, OBJPROP_XSIZE, NewOrderMonoX);
    ObjectSetInteger(0, NewOrderCommentE, OBJPROP_YSIZE, NewOrderLabelY);
    ObjectSetInteger(0, NewOrderCommentE, OBJPROP_BORDER_TYPE, BORDER_FLAT);
    ObjectSetInteger(0, NewOrderCommentE, OBJPROP_STATE, false);
    ObjectSetInteger(0, NewOrderCommentE, OBJPROP_HIDDEN, true);
    ObjectSetInteger(0, NewOrderCommentE, OBJPROP_READONLY, false);
    ObjectSetInteger(0, NewOrderCommentE, OBJPROP_FONTSIZE, NOFontSize);
    ObjectSetString(0, NewOrderCommentE, OBJPROP_TOOLTIP, "Comment for the order - Click to change");
    ObjectSetInteger(0, NewOrderCommentE, OBJPROP_ALIGN, ALIGN_CENTER);
    ObjectSetString(0, NewOrderCommentE, OBJPROP_FONT, NOFont);
    ObjectSetString(0, NewOrderCommentE, OBJPROP_TEXT, TextComment);
    ObjectSet(NewOrderCommentE, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, NewOrderCommentE, OBJPROP_COLOR, clrBlack);
    j++;

    if (ShowURL)
    {
        ObjectCreate(0, NewOrderURL, OBJ_EDIT, 0, 0, 0);
        ObjectSet(NewOrderURL, OBJPROP_XDISTANCE, NewOrderXoff + 2);
        ObjectSet(NewOrderURL, OBJPROP_YDISTANCE, NewOrderYoff + 2 + (NewOrderLabelY + 1) * j);
        ObjectSetInteger(0, NewOrderURL, OBJPROP_XSIZE, NewOrderMonoX);
        ObjectSetInteger(0, NewOrderURL, OBJPROP_YSIZE, NewOrderLabelY);
        ObjectSetInteger(0, NewOrderURL, OBJPROP_BORDER_TYPE, BORDER_FLAT);
        ObjectSetInteger(0, NewOrderURL, OBJPROP_STATE, false);
        ObjectSetInteger(0, NewOrderURL, OBJPROP_HIDDEN, true);
        ObjectSetInteger(0, NewOrderURL, OBJPROP_READONLY, true);
        ObjectSetInteger(0, NewOrderURL, OBJPROP_FONTSIZE, NOFontSize);
        ObjectSetString(0, NewOrderURL, OBJPROP_TOOLTIP, "Visit Us");
        ObjectSetInteger(0, NewOrderURL, OBJPROP_ALIGN, ALIGN_CENTER);
        ObjectSetString(0, NewOrderURL, OBJPROP_FONT, NOFont);
        ObjectSetString(0, NewOrderURL, OBJPROP_TEXT, "EarnForex.com");
        ObjectSet(NewOrderURL, OBJPROP_SELECTABLE, false);
        ObjectSetInteger(0, NewOrderURL, OBJPROP_COLOR, clrNavy);
        ObjectSetInteger(0, NewOrderURL, OBJPROP_BGCOLOR, clrKhaki);
        ObjectSetInteger(0, NewOrderURL, OBJPROP_BORDER_COLOR, clrBlack);
        j++;
    }

    NewOrderY = (NewOrderLabelY + 1) * j + 3;
    ObjectSetInteger(0, NewOrderBase, OBJPROP_YSIZE, NewOrderY);
}

void ChangeMarketPending()
{
    if (CurrMarketPending == Market)
    {
        CurrMarketPending = Pending;
        CloseNewOrder();
        ShowNewOrder();
        return;
    }
    else if (CurrMarketPending == Pending)
    {
        CurrMarketPending = Market;
        CloseNewOrder();
        ShowNewOrder();
        return;
    }
}

void ChangeSLPtsPrice()
{
    if (CurrSLPtsOrPrice == ByPrice)
    {
        CurrSLPtsOrPrice = ByPts;
        CurrSLPrice = 0;
        CurrTPPrice = 0;
        CurrSLPts = 0;
        CurrTPPts = 0;
        CloseNewOrder();
        ShowNewOrder();
        return;
    }
    else if (CurrSLPtsOrPrice == ByPts)
    {
        CurrSLPtsOrPrice = ByPrice;
        CurrSLPts = 0;
        CurrTPPts = 0;
        CurrSLPrice = 0;
        CurrTPPrice = 0;
        CloseNewOrder();
        ShowNewOrder();
        return;
    }
}

void ChangeRecommendedSize()
{
    double recommended_size = RecommendedSize();
    if (recommended_size > 0)
    {
        string TextLotSize = DoubleToString(NormalizeDouble(recommended_size, 2), 2);
        if (NewOrderPanelIsOpen) ObjectSetString(0, NewOrderLotSize, OBJPROP_TEXT, TextLotSize);
        if (NewPendingOppPanelIsOpen) ObjectSetString(0, NewPendingOppLotSize, OBJPROP_TEXT, TextLotSize);
        if (NewOrderLinesPanelIsOpen) ObjectSetString(0, NewOrderLinesLotSize, OBJPROP_TEXT, TextLotSize);
    }
    ChangeSize();
}

void IncrementSize()
{
    CurrLotSize += LotStep;
    if (CurrLotSize > MaxLotSize)
    {
        Print("The maximum allowed position size is " + DoubleToString(MaxLotSize, 2));
        CurrLotSize = MaxLotSize;
    }
    CurrLotSize = MathRound(CurrLotSize / MarketInfo(Symbol(), MODE_LOTSTEP)) * MarketInfo(Symbol(), MODE_LOTSTEP);
    if (CurrLotSize > MarketInfo(Symbol(), MODE_MAXLOT))
    {
        Print("The maximum position size is " + DoubleToString(MarketInfo(Symbol(), MODE_MAXLOT), 2));
        CurrLotSize = MarketInfo(Symbol(), MODE_MAXLOT);
    }
    if (CurrLotSize < MarketInfo(Symbol(), MODE_MINLOT))
    {
        Print("The minimum position size is " + DoubleToString(MarketInfo(Symbol(), MODE_MINLOT), 2));
        CurrLotSize = MarketInfo(Symbol(), MODE_MINLOT);
    }
    if (NewOrderPanelIsOpen) ShowNewOrder();
    if (NewPendingOppPanelIsOpen) ShowNewPendingOpp();
    if (NewOrderLinesPanelIsOpen) ShowNewOrderLines();
}

void DecrementSize()
{
    CurrLotSize -= LotStep;
    CurrLotSize = MathRound(CurrLotSize / MarketInfo(Symbol(), MODE_LOTSTEP)) * MarketInfo(Symbol(), MODE_LOTSTEP);
    if (CurrLotSize > MarketInfo(Symbol(), MODE_MAXLOT))
    {
        Print("The maximum position size is " + DoubleToString(MarketInfo(Symbol(), MODE_MAXLOT), 2));
        CurrLotSize = MarketInfo(Symbol(), MODE_MAXLOT);
    }
    if (CurrLotSize < MarketInfo(Symbol(), MODE_MINLOT))
    {
        Print("The minimum position size is " + DoubleToString(MarketInfo(Symbol(), MODE_MINLOT), 2));
        CurrLotSize = MarketInfo(Symbol(), MODE_MINLOT);
    }
    if (NewOrderPanelIsOpen) ShowNewOrder();
    if (NewPendingOppPanelIsOpen) ShowNewPendingOpp();
    if (NewOrderLinesPanelIsOpen) ShowNewOrderLines();
}

void ChangeSize()
{
    if (NewOrderPanelIsOpen) CurrLotSize = StringToDouble(ObjectGetString(0, NewOrderLotSize, OBJPROP_TEXT));
    if (NewPendingOppPanelIsOpen) CurrLotSize = StringToDouble(ObjectGetString(0, NewPendingOppLotSize, OBJPROP_TEXT));
    if (NewOrderLinesPanelIsOpen) CurrLotSize = StringToDouble(ObjectGetString(0, NewOrderLinesLotSize, OBJPROP_TEXT));
    if (CurrLotSize > MaxLotSize)
    {
        Print("The maximum allowed position size is " + DoubleToString(MaxLotSize, 2));
        CurrLotSize = MaxLotSize;
    }
    CurrLotSize = MathRound(CurrLotSize / MarketInfo(Symbol(), MODE_LOTSTEP)) * MarketInfo(Symbol(), MODE_LOTSTEP);
    if (CurrLotSize > MarketInfo(Symbol(), MODE_MAXLOT))
    {
        Print("The maximum position size is " + DoubleToString(MarketInfo(Symbol(), MODE_MAXLOT), 2));
        CurrLotSize = MarketInfo(Symbol(), MODE_MAXLOT);
    }
    if (CurrLotSize < MarketInfo(Symbol(), MODE_MINLOT))
    {
        Print("The minimum position size is " + DoubleToString(MarketInfo(Symbol(), MODE_MINLOT), 2));
        CurrLotSize = MarketInfo(Symbol(), MODE_MINLOT);
    }
    if (NewOrderPanelIsOpen) ShowNewOrder();
    if (NewPendingOppPanelIsOpen) ShowNewPendingOpp();
    if (NewOrderLinesPanelIsOpen) ShowNewOrderLines();
}

void ChangePendingOpenPrice()
{
    if (NewOrderPanelIsOpen)
    {
        CurrOpenPrice = StringToDouble(ObjectGetString(0, NewOrderPendingOpenPriceE, OBJPROP_TEXT));
        ShowNewOrder();
    }
    if (NewPendingOppPanelIsOpen)
    {
        CurrOpenPrice = StringToDouble(ObjectGetString(0, NewPendingOppPendingOpenPriceE, OBJPROP_TEXT));
        ShowNewPendingOpp();
    }
    if (NewOrderLinesPanelIsOpen)
    {
        CurrOpenPrice = StringToDouble(ObjectGetString(0, NewOrderLinesPendingOpenPriceE, OBJPROP_TEXT));
        ShowNewOrderLines();
        UpdateLineByPrice(LineNameOpen);
    }
}

void ChangeSLPrice()
{
    if (NewOrderPanelIsOpen)
    {
        CurrSLPrice = StringToDouble(ObjectGetString(0, NewOrderSLPriceE, OBJPROP_TEXT));
        ShowNewOrder();
    }
    if (NewOrderLinesPanelIsOpen)
    {
        CurrSLPrice = StringToDouble(ObjectGetString(0, NewOrderLinesSLPriceE, OBJPROP_TEXT));
        ShowNewOrderLines();
        UpdateLineByPrice(LineNameSL);
    }
}

void ChangeTPPrice()
{
    if (NewOrderPanelIsOpen)
    {
        CurrTPPrice = StringToDouble(ObjectGetString(0, NewOrderTPPriceE, OBJPROP_TEXT));
        ShowNewOrder();
    }
    if (NewOrderLinesPanelIsOpen)
    {
        CurrTPPrice = StringToDouble(ObjectGetString(0, NewOrderLinesTPPriceE, OBJPROP_TEXT));
        ShowNewOrderLines();
        UpdateLineByPrice(LineNameTP);
    }
}

void ChangeTPPts()
{
    if (NewOrderPanelIsOpen)
    {
        CurrTPPts = StringToDouble(ObjectGetString(0, NewOrderTPPtsE, OBJPROP_TEXT));
        ShowNewOrder();
    }
    if (NewPendingOppPanelIsOpen)
    {
        CurrTPPts = StringToDouble(ObjectGetString(0, NewPendingOppTPPtsE, OBJPROP_TEXT));
        ShowNewPendingOpp();
    }
}

void ChangeSLPts()
{
    if (NewOrderPanelIsOpen)
    {
        CurrSLPts = StringToDouble(ObjectGetString(0, NewOrderSLPtsE, OBJPROP_TEXT));
        ShowNewOrder();
    }
    if (NewPendingOppPanelIsOpen)
    {
        CurrSLPts = StringToDouble(ObjectGetString(0, NewPendingOppSLPtsE, OBJPROP_TEXT));
        ShowNewPendingOpp();
    }
}

void ChangeMagic()
{
    if (NewOrderPanelIsOpen)
    {
        CurrMagic = (int)StringToInteger(ObjectGetString(0, NewOrderMagicE, OBJPROP_TEXT));
        ShowNewOrder();
    }
    if (NewPendingOppPanelIsOpen)
    {
        CurrMagic = (int)StringToInteger(ObjectGetString(0, NewPendingOppMagicE, OBJPROP_TEXT));
        ShowNewPendingOpp();
    }
    if (NewOrderLinesPanelIsOpen)
    {
        CurrMagic = (int)StringToInteger(ObjectGetString(0, NewOrderLinesMagicE, OBJPROP_TEXT));
        ShowNewOrderLines();
    }
}

void ChangeComment()
{
    if (NewOrderPanelIsOpen)
    {
        CurrComment = ObjectGetString(0, NewOrderCommentE, OBJPROP_TEXT);
        ShowNewOrder();
    }
    if (NewPendingOppPanelIsOpen)
    {
        CurrComment = ObjectGetString(0, NewPendingOppCommentE, OBJPROP_TEXT);
        ShowNewPendingOpp();
    }
    if (NewOrderLinesPanelIsOpen)
    {
        CurrComment = ObjectGetString(0, NewOrderLinesCommentE, OBJPROP_TEXT);
        ShowNewOrderLines();
    }
}

void CloseNewOrder()
{
    ObjectsDeleteAll(0, IndicatorName + "-NO-");
    NewOrderPanelIsOpen = false;
}

string NewPendingOppBase = IndicatorName + "-NPO-Base";
string NewPendingOppClose = IndicatorName + "-NPO-Close";
string NewPendingOppPendingOrder = IndicatorName + "-NPO-PendingOrder";
string NewPendingOppPositionSize = IndicatorName + "-NPO-PosSize";
string NewPendingOppRecommendedSize = IndicatorName + "-NPO-RecSize";
string NewPendingOppPendingOpenPrice = IndicatorName + "-NPO-PendingOP";
string NewPendingOppPendingOpenPriceE = IndicatorName + "-NPO-PendingOPE";
string NewPendingOppPendingDistance = IndicatorName + "-NPO-PedingDistanceOP";
string NewPendingOppPendingDistanceE = IndicatorName + "-NPO-PedingDistanceOPE";
string NewPendingOppPendingSide = IndicatorName + "-NPO-PendingSide";
string NewPendingOppPendingType = IndicatorName + "-NPO-PendingType";
string NewPendingOppLotMinus = IndicatorName + "-NPO-LotMinus";
string NewPendingOppLotSize = IndicatorName + "-NPO-LotSize";
string NewPendingOppLotPlus = IndicatorName + "-NPO-LotPlus";
string NewPendingOppSLPts = IndicatorName + "-NPO-SLPts";
string NewPendingOppTPPts = IndicatorName + "-NPO-TPPrs";
string NewPendingOppSLPtsE = IndicatorName + "-NPO-SLPtsE";
string NewPendingOppTPPtsE = IndicatorName + "-NPO-TPPtsE";
string NewPendingOppMagic = IndicatorName + "-NPO-Magic";
string NewPendingOppMagicE = IndicatorName + "-NPO-MagicE";
string NewPendingOppComment = IndicatorName + "-NPO-Comment";
string NewPendingOppCommentE = IndicatorName + "-NPO-CommentE";
string NewPendingOppSubmit = IndicatorName + "-NPO-Submit";
string NewPendingOppURL = IndicatorName + "-NPO-URL";
void ShowNewPendingOpp()
{
    NewPendingOppPanelIsOpen = true;

    int NewPendingOppXoff = Xoff;
    int NewPendingOppYoff = Yoff + PanelMovY + 2 * 4;
    int NewPendingOppX = NewPendingOppMonoX + 2 + 2;
    int NewPendingOppY = (NewPendingOppLabelY + 2) * 11 + 2;

    string TextPendingOrder = "";
    string TextSide = "";
    string TextType = "";
    string TextBuyButton = "";
    string TextSellButton = "";
    string TextLotSize = "";
    string TextSLType = "";
    string TextSLPts = "";
    string TextTPPts = "";
    string TextMagic = "";
    string TextComment = "";
    string TextSLPtsE = "";
    string TextTPPtsE = "";
    string TextPendingOpenPrice = "";
    string TextPendingOpenPriceE = "";
    string TextPendingDistance = "";
    string TextPendingDistanceE = "";
    string TextPositionSize = "";
    string TextRecSize = "";
    int j = 1;


    TextSLPts = "SL in Points";
    TextTPPts = "TP in Points";
    TextPendingOpenPrice = "START PRICE";
    TextLotSize = DoubleToString(CurrLotSize, 2);
    TextMagic = DoubleToString(CurrMagic, 2);
    TextComment = CurrComment;
    TextSLPtsE = DoubleToString(CurrSLPts, 0);
    TextTPPtsE = DoubleToString(CurrTPPts, 0);
    TextPendingOpenPriceE = DoubleToString(CurrOpenPrice, _Digits);
    TextPendingOrder = "PENDING ORDER BY DISTANCE";
    TextPendingDistance = "DISTANCE";
    TextPendingDistanceE = IntegerToString(CurrPendingOppDistance);
    if (CurrPendingOppSide == PENDING_BUY) TextSide = "BUY";
    if (CurrPendingOppSide == PENDING_BUYSELL) TextSide = "BUY/SELL";
    if (CurrPendingOppSide == PENDING_SELL) TextSide = "SELL";
    if (CurrPendingOppType == PENDING_LIMIT) TextType = "LIMIT";
    if (CurrPendingOppType == PENDING_STOP) TextType = "STOP";
    TextPositionSize = "POSITION SIZE (LOTS)";
    if (RecommendedSize() > 0) TextRecSize = "RECOMMENDED SIZE (LOTS) : " + DoubleToStr(RecommendedSize(), 2);
    else TextRecSize = "RECOMMENDED SIZE (LOTS) : N/A";
    ObjectCreate(0, NewPendingOppBase, OBJ_RECTANGLE_LABEL, 0, 0, 0);
    ObjectSet(NewPendingOppBase, OBJPROP_XDISTANCE, NewPendingOppXoff);
    ObjectSet(NewPendingOppBase, OBJPROP_YDISTANCE, NewPendingOppYoff);
    ObjectSetInteger(0, NewPendingOppBase, OBJPROP_XSIZE, NewPendingOppX);
    ObjectSetInteger(0, NewPendingOppBase, OBJPROP_YSIZE, NewPendingOppY);
    ObjectSetInteger(0, NewPendingOppBase, OBJPROP_BGCOLOR, clrWhite);
    ObjectSetInteger(0, NewPendingOppBase, OBJPROP_BORDER_TYPE, BORDER_FLAT);
    ObjectSetInteger(0, NewPendingOppBase, OBJPROP_STATE, false);
    ObjectSetInteger(0, NewPendingOppBase, OBJPROP_HIDDEN, true);
    ObjectSetInteger(0, NewPendingOppBase, OBJPROP_FONTSIZE, NOFontSize);
    ObjectSet(NewPendingOppBase, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, NewPendingOppBase, OBJPROP_COLOR, clrBlack);

    ObjectCreate(0, NewPendingOppClose, OBJ_EDIT, 0, 0, 0);
    ObjectSet(NewPendingOppClose, OBJPROP_XDISTANCE, NewPendingOppXoff + 2);
    ObjectSet(NewPendingOppClose, OBJPROP_YDISTANCE, NewPendingOppYoff + 2);
    ObjectSetInteger(0, NewPendingOppClose, OBJPROP_XSIZE, NewPendingOppMonoX);
    ObjectSetInteger(0, NewPendingOppClose, OBJPROP_YSIZE, NewPendingOppLabelY);
    ObjectSetInteger(0, NewPendingOppClose, OBJPROP_BORDER_TYPE, BORDER_FLAT);
    ObjectSetInteger(0, NewPendingOppClose, OBJPROP_STATE, false);
    ObjectSetInteger(0, NewPendingOppClose, OBJPROP_HIDDEN, true);
    ObjectSetInteger(0, NewPendingOppClose, OBJPROP_READONLY, true);
    ObjectSetInteger(0, NewPendingOppClose, OBJPROP_FONTSIZE, NOFontSize);
    ObjectSetString(0, NewPendingOppClose, OBJPROP_TOOLTIP, "Close Panel");
    ObjectSetInteger(0, NewPendingOppClose, OBJPROP_ALIGN, ALIGN_CENTER);
    ObjectSetString(0, NewPendingOppClose, OBJPROP_FONT, NOFont);
    ObjectSetString(0, NewPendingOppClose, OBJPROP_TEXT, "X");
    ObjectSet(NewPendingOppClose, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, NewPendingOppClose, OBJPROP_COLOR, clrBlack);
    ObjectSetInteger(0, NewPendingOppClose, OBJPROP_BGCOLOR, clrCrimson);
    ObjectSetInteger(0, NewPendingOppClose, OBJPROP_BORDER_COLOR, clrBlack);

    ObjectCreate(0, NewPendingOppPendingOrder, OBJ_EDIT, 0, 0, 0);
    ObjectSet(NewPendingOppPendingOrder, OBJPROP_XDISTANCE, NewPendingOppXoff + 2);
    ObjectSet(NewPendingOppPendingOrder, OBJPROP_YDISTANCE, NewPendingOppYoff + 2 + (NewPendingOppLabelY + 1) * j);
    ObjectSetInteger(0, NewPendingOppPendingOrder, OBJPROP_XSIZE, NewPendingOppMonoX);
    ObjectSetInteger(0, NewPendingOppPendingOrder, OBJPROP_YSIZE, NewPendingOppLabelY);
    ObjectSetInteger(0, NewPendingOppPendingOrder, OBJPROP_BORDER_TYPE, BORDER_FLAT);
    ObjectSetInteger(0, NewPendingOppPendingOrder, OBJPROP_STATE, false);
    ObjectSetInteger(0, NewPendingOppPendingOrder, OBJPROP_HIDDEN, true);
    ObjectSetInteger(0, NewPendingOppPendingOrder, OBJPROP_READONLY, true);
    ObjectSetInteger(0, NewPendingOppPendingOrder, OBJPROP_FONTSIZE, NOFontSize);
    ObjectSetString(0, NewPendingOppPendingOrder, OBJPROP_TOOLTIP, "Pending Orders And Opposite Orders By Distance From A Start Price");
    ObjectSetInteger(0, NewPendingOppPendingOrder, OBJPROP_ALIGN, ALIGN_CENTER);
    ObjectSetString(0, NewPendingOppPendingOrder, OBJPROP_FONT, NOFont);
    ObjectSetString(0, NewPendingOppPendingOrder, OBJPROP_TEXT, TextPendingOrder);
    ObjectSet(NewPendingOppPendingOrder, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, NewPendingOppPendingOrder, OBJPROP_COLOR, clrBlack);
    ObjectSetInteger(0, NewPendingOppPendingOrder, OBJPROP_BGCOLOR, clrPaleGreen);
    ObjectSetInteger(0, NewPendingOppPendingOrder, OBJPROP_BORDER_COLOR, clrBlack);
    j++;

    ObjectCreate(0, NewPendingOppPendingSide, OBJ_EDIT, 0, 0, 0);
    ObjectSet(NewPendingOppPendingSide, OBJPROP_XDISTANCE, NewPendingOppXoff + 2);
    ObjectSet(NewPendingOppPendingSide, OBJPROP_YDISTANCE, NewPendingOppYoff + 2 + (NewPendingOppLabelY + 1) * j);
    ObjectSetInteger(0, NewPendingOppPendingSide, OBJPROP_XSIZE, NewPendingOppDoubleX);
    ObjectSetInteger(0, NewPendingOppPendingSide, OBJPROP_YSIZE, NewPendingOppLabelY);
    ObjectSetInteger(0, NewPendingOppPendingSide, OBJPROP_BORDER_TYPE, BORDER_FLAT);
    ObjectSetInteger(0, NewPendingOppPendingSide, OBJPROP_STATE, false);
    ObjectSetInteger(0, NewPendingOppPendingSide, OBJPROP_HIDDEN, true);
    ObjectSetInteger(0, NewPendingOppPendingSide, OBJPROP_READONLY, true);
    ObjectSetInteger(0, NewPendingOppPendingSide, OBJPROP_FONTSIZE, NOFontSize);
    ObjectSetString(0, NewPendingOppPendingSide, OBJPROP_TOOLTIP, "Click To Change");
    ObjectSetInteger(0, NewPendingOppPendingSide, OBJPROP_ALIGN, ALIGN_CENTER);
    ObjectSetString(0, NewPendingOppPendingSide, OBJPROP_FONT, NOFont);
    ObjectSetString(0, NewPendingOppPendingSide, OBJPROP_TEXT, TextSide);
    ObjectSet(NewPendingOppPendingSide, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, NewPendingOppPendingSide, OBJPROP_COLOR, clrWhite);
    ObjectSetInteger(0, NewPendingOppPendingSide, OBJPROP_BGCOLOR, clrBlue);
    ObjectSetInteger(0, NewPendingOppPendingSide, OBJPROP_BORDER_COLOR, clrBlack);

    ObjectCreate(0, NewPendingOppPendingType, OBJ_EDIT, 0, 0, 0);
    ObjectSet(NewPendingOppPendingType, OBJPROP_XDISTANCE, NewPendingOppXoff + (NewPendingOppDoubleX + 2) + 2);
    ObjectSet(NewPendingOppPendingType, OBJPROP_YDISTANCE, NewPendingOppYoff + 2 + (NewPendingOppLabelY + 1) * j);
    ObjectSetInteger(0, NewPendingOppPendingType, OBJPROP_XSIZE, NewPendingOppDoubleX);
    ObjectSetInteger(0, NewPendingOppPendingType, OBJPROP_YSIZE, NewPendingOppLabelY);
    ObjectSetInteger(0, NewPendingOppPendingType, OBJPROP_BORDER_TYPE, BORDER_FLAT);
    ObjectSetInteger(0, NewPendingOppPendingType, OBJPROP_STATE, false);
    ObjectSetInteger(0, NewPendingOppPendingType, OBJPROP_HIDDEN, true);
    ObjectSetInteger(0, NewPendingOppPendingType, OBJPROP_READONLY, true);
    ObjectSetInteger(0, NewPendingOppPendingType, OBJPROP_FONTSIZE, NOFontSize);
    ObjectSetString(0, NewPendingOppPendingType, OBJPROP_TOOLTIP, "Click To Change");
    ObjectSetInteger(0, NewPendingOppPendingType, OBJPROP_ALIGN, ALIGN_CENTER);
    ObjectSetString(0, NewPendingOppPendingType, OBJPROP_FONT, NOFont);
    ObjectSetString(0, NewPendingOppPendingType, OBJPROP_TEXT, TextType);
    ObjectSet(NewPendingOppPendingType, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, NewPendingOppPendingType, OBJPROP_COLOR, clrWhite);
    ObjectSetInteger(0, NewPendingOppPendingType, OBJPROP_BGCOLOR, clrRed);
    ObjectSetInteger(0, NewPendingOppPendingType, OBJPROP_BORDER_COLOR, clrBlack);
    j++;

    if (CurrPendingOppStartMode == PENDING_START_CURRENT)
    {
        ObjectCreate(0, NewPendingOppPendingOpenPrice, OBJ_EDIT, 0, 0, 0);
        ObjectSet(NewPendingOppPendingOpenPrice, OBJPROP_XDISTANCE, NewPendingOppXoff + 2);
        ObjectSet(NewPendingOppPendingOpenPrice, OBJPROP_YDISTANCE, NewPendingOppYoff + 2 + (NewPendingOppLabelY + 1) * j);
        ObjectSetInteger(0, NewPendingOppPendingOpenPrice, OBJPROP_XSIZE, NewPendingOppDoubleX);
        ObjectSetInteger(0, NewPendingOppPendingOpenPrice, OBJPROP_YSIZE, NewPendingOppLabelY);
        ObjectSetInteger(0, NewPendingOppPendingOpenPrice, OBJPROP_BORDER_TYPE, BORDER_FLAT);
        ObjectSetInteger(0, NewPendingOppPendingOpenPrice, OBJPROP_STATE, false);
        ObjectSetInteger(0, NewPendingOppPendingOpenPrice, OBJPROP_HIDDEN, true);
        ObjectSetInteger(0, NewPendingOppPendingOpenPrice, OBJPROP_READONLY, true);
        ObjectSetInteger(0, NewPendingOppPendingOpenPrice, OBJPROP_FONTSIZE, NOFontSize);
        ObjectSetString(0, NewPendingOppPendingOpenPrice, OBJPROP_TOOLTIP, "Start Price - Click To Change");
        ObjectSetInteger(0, NewPendingOppPendingOpenPrice, OBJPROP_ALIGN, ALIGN_CENTER);
        ObjectSetString(0, NewPendingOppPendingOpenPrice, OBJPROP_FONT, NOFont);
        ObjectSetString(0, NewPendingOppPendingOpenPrice, OBJPROP_TEXT, TextPendingOpenPrice);
        ObjectSet(NewPendingOppPendingOpenPrice, OBJPROP_SELECTABLE, false);
        ObjectSetInteger(0, NewPendingOppPendingOpenPrice, OBJPROP_COLOR, clrBlack);

        ObjectCreate(0, NewPendingOppPendingOpenPriceE, OBJ_EDIT, 0, 0, 0);
        ObjectSet(NewPendingOppPendingOpenPriceE, OBJPROP_XDISTANCE, NewPendingOppXoff + (NewPendingOppDoubleX + 2) + 2);
        ObjectSet(NewPendingOppPendingOpenPriceE, OBJPROP_YDISTANCE, NewPendingOppYoff + 2 + (NewPendingOppLabelY + 1) * j);
        ObjectSetInteger(0, NewPendingOppPendingOpenPriceE, OBJPROP_XSIZE, NewPendingOppDoubleX);
        ObjectSetInteger(0, NewPendingOppPendingOpenPriceE, OBJPROP_YSIZE, NewPendingOppLabelY);
        ObjectSetInteger(0, NewPendingOppPendingOpenPriceE, OBJPROP_BORDER_TYPE, BORDER_FLAT);
        ObjectSetInteger(0, NewPendingOppPendingOpenPriceE, OBJPROP_STATE, false);
        ObjectSetInteger(0, NewPendingOppPendingOpenPriceE, OBJPROP_HIDDEN, true);
        ObjectSetInteger(0, NewPendingOppPendingOpenPriceE, OBJPROP_READONLY, true);
        ObjectSetInteger(0, NewPendingOppPendingOpenPriceE, OBJPROP_FONTSIZE, NOFontSize);
        ObjectSetString(0, NewPendingOppPendingOpenPriceE, OBJPROP_TOOLTIP, "Start Price Is Current Price");
        ObjectSetInteger(0, NewPendingOppPendingOpenPriceE, OBJPROP_ALIGN, ALIGN_CENTER);
        ObjectSetString(0, NewPendingOppPendingOpenPriceE, OBJPROP_FONT, NOFont);
        ObjectSetString(0, NewPendingOppPendingOpenPriceE, OBJPROP_TEXT, "CURRENT");
        ObjectSet(NewPendingOppPendingOpenPriceE, OBJPROP_SELECTABLE, false);
        ObjectSetInteger(0, NewPendingOppPendingOpenPriceE, OBJPROP_COLOR, clrBlack);
        j++;

    }
    else if (CurrPendingOppStartMode == PENDING_START_MANUAL)
    {
        ObjectCreate(0, NewPendingOppPendingOpenPrice, OBJ_EDIT, 0, 0, 0);
        ObjectSet(NewPendingOppPendingOpenPrice, OBJPROP_XDISTANCE, NewPendingOppXoff + 2);
        ObjectSet(NewPendingOppPendingOpenPrice, OBJPROP_YDISTANCE, NewPendingOppYoff + 2 + (NewPendingOppLabelY + 1) * j);
        ObjectSetInteger(0, NewPendingOppPendingOpenPrice, OBJPROP_XSIZE, NewPendingOppDoubleX);
        ObjectSetInteger(0, NewPendingOppPendingOpenPrice, OBJPROP_YSIZE, NewPendingOppLabelY);
        ObjectSetInteger(0, NewPendingOppPendingOpenPrice, OBJPROP_BORDER_TYPE, BORDER_FLAT);
        ObjectSetInteger(0, NewPendingOppPendingOpenPrice, OBJPROP_STATE, false);
        ObjectSetInteger(0, NewPendingOppPendingOpenPrice, OBJPROP_HIDDEN, true);
        ObjectSetInteger(0, NewPendingOppPendingOpenPrice, OBJPROP_READONLY, true);
        ObjectSetInteger(0, NewPendingOppPendingOpenPrice, OBJPROP_FONTSIZE, NOFontSize);
        ObjectSetString(0, NewPendingOppPendingOpenPrice, OBJPROP_TOOLTIP, "Start Price - Click To Change");
        ObjectSetInteger(0, NewPendingOppPendingOpenPrice, OBJPROP_ALIGN, ALIGN_CENTER);
        ObjectSetString(0, NewPendingOppPendingOpenPrice, OBJPROP_FONT, NOFont);
        ObjectSetString(0, NewPendingOppPendingOpenPrice, OBJPROP_TEXT, TextPendingOpenPrice);
        ObjectSet(NewPendingOppPendingOpenPrice, OBJPROP_SELECTABLE, false);
        ObjectSetInteger(0, NewPendingOppPendingOpenPrice, OBJPROP_COLOR, clrBlack);

        ObjectCreate(0, NewPendingOppPendingOpenPriceE, OBJ_EDIT, 0, 0, 0);
        ObjectSet(NewPendingOppPendingOpenPriceE, OBJPROP_XDISTANCE, NewPendingOppXoff + (NewPendingOppDoubleX + 2) + 2);
        ObjectSet(NewPendingOppPendingOpenPriceE, OBJPROP_YDISTANCE, NewPendingOppYoff + 2 + (NewPendingOppLabelY + 1) * j);
        ObjectSetInteger(0, NewPendingOppPendingOpenPriceE, OBJPROP_XSIZE, NewPendingOppDoubleX);
        ObjectSetInteger(0, NewPendingOppPendingOpenPriceE, OBJPROP_YSIZE, NewPendingOppLabelY);
        ObjectSetInteger(0, NewPendingOppPendingOpenPriceE, OBJPROP_BORDER_TYPE, BORDER_FLAT);
        ObjectSetInteger(0, NewPendingOppPendingOpenPriceE, OBJPROP_STATE, false);
        ObjectSetInteger(0, NewPendingOppPendingOpenPriceE, OBJPROP_HIDDEN, true);
        ObjectSetInteger(0, NewPendingOppPendingOpenPriceE, OBJPROP_READONLY, false);
        ObjectSetInteger(0, NewPendingOppPendingOpenPriceE, OBJPROP_FONTSIZE, NOFontSize);
        ObjectSetString(0, NewPendingOppPendingOpenPriceE, OBJPROP_TOOLTIP, "Start Price");
        ObjectSetInteger(0, NewPendingOppPendingOpenPriceE, OBJPROP_ALIGN, ALIGN_CENTER);
        ObjectSetString(0, NewPendingOppPendingOpenPriceE, OBJPROP_FONT, NOFont);
        ObjectSetString(0, NewPendingOppPendingOpenPriceE, OBJPROP_TEXT, TextPendingOpenPriceE);
        ObjectSet(NewPendingOppPendingOpenPriceE, OBJPROP_SELECTABLE, false);
        ObjectSetInteger(0, NewPendingOppPendingOpenPriceE, OBJPROP_COLOR, clrBlack);
        j++;
    }

    ObjectCreate(0, NewPendingOppPendingDistance, OBJ_EDIT, 0, 0, 0);
    ObjectSet(NewPendingOppPendingDistance, OBJPROP_XDISTANCE, NewPendingOppXoff + 2);
    ObjectSet(NewPendingOppPendingDistance, OBJPROP_YDISTANCE, NewPendingOppYoff + 2 + (NewPendingOppLabelY + 1) * j);
    ObjectSetInteger(0, NewPendingOppPendingDistance, OBJPROP_XSIZE, NewPendingOppDoubleX);
    ObjectSetInteger(0, NewPendingOppPendingDistance, OBJPROP_YSIZE, NewPendingOppLabelY);
    ObjectSetInteger(0, NewPendingOppPendingDistance, OBJPROP_BORDER_TYPE, BORDER_FLAT);
    ObjectSetInteger(0, NewPendingOppPendingDistance, OBJPROP_STATE, false);
    ObjectSetInteger(0, NewPendingOppPendingDistance, OBJPROP_HIDDEN, true);
    ObjectSetInteger(0, NewPendingOppPendingDistance, OBJPROP_READONLY, true);
    ObjectSetInteger(0, NewPendingOppPendingDistance, OBJPROP_FONTSIZE, NOFontSize);
    ObjectSetString(0, NewPendingOppPendingDistance, OBJPROP_TOOLTIP, "Distance From Start Price In Points");
    ObjectSetInteger(0, NewPendingOppPendingDistance, OBJPROP_ALIGN, ALIGN_CENTER);
    ObjectSetString(0, NewPendingOppPendingDistance, OBJPROP_FONT, NOFont);
    ObjectSetString(0, NewPendingOppPendingDistance, OBJPROP_TEXT, TextPendingDistance);
    ObjectSet(NewPendingOppPendingDistance, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, NewPendingOppPendingDistance, OBJPROP_COLOR, clrBlack);

    ObjectCreate(0, NewPendingOppPendingDistanceE, OBJ_EDIT, 0, 0, 0);
    ObjectSet(NewPendingOppPendingDistanceE, OBJPROP_XDISTANCE, NewPendingOppXoff + (NewPendingOppDoubleX + 2) + 2);
    ObjectSet(NewPendingOppPendingDistanceE, OBJPROP_YDISTANCE, NewPendingOppYoff + 2 + (NewPendingOppLabelY + 1) * j);
    ObjectSetInteger(0, NewPendingOppPendingDistanceE, OBJPROP_XSIZE, NewPendingOppDoubleX);
    ObjectSetInteger(0, NewPendingOppPendingDistanceE, OBJPROP_YSIZE, NewPendingOppLabelY);
    ObjectSetInteger(0, NewPendingOppPendingDistanceE, OBJPROP_BORDER_TYPE, BORDER_FLAT);
    ObjectSetInteger(0, NewPendingOppPendingDistanceE, OBJPROP_STATE, false);
    ObjectSetInteger(0, NewPendingOppPendingDistanceE, OBJPROP_HIDDEN, true);
    ObjectSetInteger(0, NewPendingOppPendingDistanceE, OBJPROP_READONLY, false);
    ObjectSetInteger(0, NewPendingOppPendingDistanceE, OBJPROP_FONTSIZE, NOFontSize);
    ObjectSetString(0, NewPendingOppPendingDistanceE, OBJPROP_TOOLTIP, "Distance From Start Price");
    ObjectSetInteger(0, NewPendingOppPendingDistanceE, OBJPROP_ALIGN, ALIGN_CENTER);
    ObjectSetString(0, NewPendingOppPendingDistanceE, OBJPROP_FONT, NOFont);
    ObjectSetString(0, NewPendingOppPendingDistanceE, OBJPROP_TEXT, TextPendingDistanceE);
    ObjectSet(NewPendingOppPendingDistanceE, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, NewPendingOppPendingDistanceE, OBJPROP_COLOR, clrBlack);
    j++;

    ObjectCreate(0, NewPendingOppPositionSize, OBJ_EDIT, 0, 0, 0);
    ObjectSet(NewPendingOppPositionSize, OBJPROP_XDISTANCE, NewPendingOppXoff + 2);
    ObjectSet(NewPendingOppPositionSize, OBJPROP_YDISTANCE, NewPendingOppYoff + 2 + (NewPendingOppLabelY + 1) * j);
    ObjectSetInteger(0, NewPendingOppPositionSize, OBJPROP_XSIZE, NewPendingOppMonoX);
    ObjectSetInteger(0, NewPendingOppPositionSize, OBJPROP_YSIZE, NewPendingOppLabelY);
    ObjectSetInteger(0, NewPendingOppPositionSize, OBJPROP_BORDER_TYPE, BORDER_FLAT);
    ObjectSetInteger(0, NewPendingOppPositionSize, OBJPROP_STATE, false);
    ObjectSetInteger(0, NewPendingOppPositionSize, OBJPROP_HIDDEN, true);
    ObjectSetInteger(0, NewPendingOppPositionSize, OBJPROP_READONLY, true);
    ObjectSetInteger(0, NewPendingOppPositionSize, OBJPROP_FONTSIZE, NOFontSize);
    ObjectSetString(0, NewPendingOppPositionSize, OBJPROP_TOOLTIP, "Position Size Title");
    ObjectSetInteger(0, NewPendingOppPositionSize, OBJPROP_ALIGN, ALIGN_CENTER);
    ObjectSetString(0, NewPendingOppPositionSize, OBJPROP_FONT, NOFont);
    ObjectSetString(0, NewPendingOppPositionSize, OBJPROP_TEXT, TextPositionSize);
    ObjectSet(NewPendingOppPositionSize, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, NewPendingOppPositionSize, OBJPROP_COLOR, clrBlack);
    j++;

    ObjectCreate(0, NewPendingOppLotMinus, OBJ_EDIT, 0, 0, 0);
    ObjectSet(NewPendingOppLotMinus, OBJPROP_XDISTANCE, NewPendingOppXoff + 2);
    ObjectSet(NewPendingOppLotMinus, OBJPROP_YDISTANCE, NewPendingOppYoff + 2 + (NewPendingOppLabelY + 1) * j);
    ObjectSetInteger(0, NewPendingOppLotMinus, OBJPROP_XSIZE, NewPendingOppTripleX);
    ObjectSetInteger(0, NewPendingOppLotMinus, OBJPROP_YSIZE, NewPendingOppLabelY);
    ObjectSetInteger(0, NewPendingOppLotMinus, OBJPROP_BORDER_TYPE, BORDER_FLAT);
    ObjectSetInteger(0, NewPendingOppLotMinus, OBJPROP_STATE, false);
    ObjectSetInteger(0, NewPendingOppLotMinus, OBJPROP_HIDDEN, true);
    ObjectSetInteger(0, NewPendingOppLotMinus, OBJPROP_READONLY, true);
    ObjectSetInteger(0, NewPendingOppLotMinus, OBJPROP_FONTSIZE, NOFontSize);
    ObjectSetString(0, NewPendingOppLotMinus, OBJPROP_TOOLTIP, "Decrease Lot Size");
    ObjectSetInteger(0, NewPendingOppLotMinus, OBJPROP_ALIGN, ALIGN_CENTER);
    ObjectSetString(0, NewPendingOppLotMinus, OBJPROP_FONT, NOFont);
    ObjectSetString(0, NewPendingOppLotMinus, OBJPROP_TEXT, "-");
    ObjectSet(NewPendingOppLotMinus, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, NewPendingOppLotMinus, OBJPROP_COLOR, clrBlack);

    ObjectCreate(0, NewPendingOppLotSize, OBJ_EDIT, 0, 0, 0);
    ObjectSet(NewPendingOppLotSize, OBJPROP_XDISTANCE, NewPendingOppXoff + 2 + NewPendingOppTripleX + 2);
    ObjectSet(NewPendingOppLotSize, OBJPROP_YDISTANCE, NewPendingOppYoff + 2 + (NewPendingOppLabelY + 1) * j);
    ObjectSetInteger(0, NewPendingOppLotSize, OBJPROP_XSIZE, NewPendingOppTripleX);
    ObjectSetInteger(0, NewPendingOppLotSize, OBJPROP_YSIZE, NewPendingOppLabelY);
    ObjectSetInteger(0, NewPendingOppLotSize, OBJPROP_BORDER_TYPE, BORDER_FLAT);
    ObjectSetInteger(0, NewPendingOppLotSize, OBJPROP_STATE, false);
    ObjectSetInteger(0, NewPendingOppLotSize, OBJPROP_HIDDEN, true);
    ObjectSetInteger(0, NewPendingOppLotSize, OBJPROP_READONLY, false);
    ObjectSetInteger(0, NewPendingOppLotSize, OBJPROP_FONTSIZE, NOFontSize);
    ObjectSetString(0, NewPendingOppLotSize, OBJPROP_TOOLTIP, "Lot Size");
    ObjectSetInteger(0, NewPendingOppLotSize, OBJPROP_ALIGN, ALIGN_CENTER);
    ObjectSetString(0, NewPendingOppLotSize, OBJPROP_FONT, NOFont);
    ObjectSetString(0, NewPendingOppLotSize, OBJPROP_TEXT, TextLotSize);
    ObjectSet(NewPendingOppLotSize, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, NewPendingOppLotSize, OBJPROP_COLOR, clrBlack);

    ObjectCreate(0, NewPendingOppLotPlus, OBJ_EDIT, 0, 0, 0);
    ObjectSet(NewPendingOppLotPlus, OBJPROP_XDISTANCE, NewPendingOppXoff + 2 + (NewPendingOppTripleX + 2) * 2);
    ObjectSet(NewPendingOppLotPlus, OBJPROP_YDISTANCE, NewPendingOppYoff + 2 + (NewPendingOppLabelY + 1) * j);
    ObjectSetInteger(0, NewPendingOppLotPlus, OBJPROP_XSIZE, NewPendingOppTripleX);
    ObjectSetInteger(0, NewPendingOppLotPlus, OBJPROP_YSIZE, NewPendingOppLabelY);
    ObjectSetInteger(0, NewPendingOppLotPlus, OBJPROP_BORDER_TYPE, BORDER_FLAT);
    ObjectSetInteger(0, NewPendingOppLotPlus, OBJPROP_STATE, false);
    ObjectSetInteger(0, NewPendingOppLotPlus, OBJPROP_HIDDEN, true);
    ObjectSetInteger(0, NewPendingOppLotPlus, OBJPROP_READONLY, true);
    ObjectSetInteger(0, NewPendingOppLotPlus, OBJPROP_FONTSIZE, NOFontSize);
    ObjectSetString(0, NewPendingOppLotPlus, OBJPROP_TOOLTIP, "Increase Lot Size");
    ObjectSetInteger(0, NewPendingOppLotPlus, OBJPROP_ALIGN, ALIGN_CENTER);
    ObjectSetString(0, NewPendingOppLotPlus, OBJPROP_FONT, NOFont);
    ObjectSetString(0, NewPendingOppLotPlus, OBJPROP_TEXT, "+");
    ObjectSet(NewPendingOppLotPlus, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, NewPendingOppLotPlus, OBJPROP_COLOR, clrBlack);
    j++;

    ObjectCreate(0, NewPendingOppRecommendedSize, OBJ_EDIT, 0, 0, 0);
    ObjectSet(NewPendingOppRecommendedSize, OBJPROP_XDISTANCE, NewPendingOppXoff + 2);
    ObjectSet(NewPendingOppRecommendedSize, OBJPROP_YDISTANCE, NewPendingOppYoff + 2 + (NewPendingOppLabelY + 1) * j);
    ObjectSetInteger(0, NewPendingOppRecommendedSize, OBJPROP_XSIZE, NewPendingOppMonoX);
    ObjectSetInteger(0, NewPendingOppRecommendedSize, OBJPROP_YSIZE, NewPendingOppLabelY);
    ObjectSetInteger(0, NewPendingOppRecommendedSize, OBJPROP_BORDER_TYPE, BORDER_FLAT);
    ObjectSetInteger(0, NewPendingOppRecommendedSize, OBJPROP_STATE, false);
    ObjectSetInteger(0, NewPendingOppRecommendedSize, OBJPROP_HIDDEN, true);
    ObjectSetInteger(0, NewPendingOppRecommendedSize, OBJPROP_READONLY, true);
    ObjectSetInteger(0, NewPendingOppRecommendedSize, OBJPROP_FONTSIZE, NOFontSize);
    ObjectSetString(0, NewPendingOppRecommendedSize, OBJPROP_TOOLTIP, "Recommended Position Size - Click to copy to Position Size");
    ObjectSetInteger(0, NewPendingOppRecommendedSize, OBJPROP_ALIGN, ALIGN_CENTER);
    ObjectSetString(0, NewPendingOppRecommendedSize, OBJPROP_FONT, NOFont);
    ObjectSetString(0, NewPendingOppRecommendedSize, OBJPROP_TEXT, TextRecSize);
    ObjectSet(NewPendingOppRecommendedSize, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, NewPendingOppRecommendedSize, OBJPROP_COLOR, clrBlack);
    j++;

    ObjectCreate(0, NewPendingOppSLPts, OBJ_EDIT, 0, 0, 0);
    ObjectSet(NewPendingOppSLPts, OBJPROP_XDISTANCE, NewPendingOppXoff + 2);
    ObjectSet(NewPendingOppSLPts, OBJPROP_YDISTANCE, NewPendingOppYoff + 2 + (NewPendingOppLabelY + 1) * j);
    ObjectSetInteger(0, NewPendingOppSLPts, OBJPROP_XSIZE, NewPendingOppDoubleX);
    ObjectSetInteger(0, NewPendingOppSLPts, OBJPROP_YSIZE, NewPendingOppLabelY);
    ObjectSetInteger(0, NewPendingOppSLPts, OBJPROP_BORDER_TYPE, BORDER_FLAT);
    ObjectSetInteger(0, NewPendingOppSLPts, OBJPROP_STATE, false);
    ObjectSetInteger(0, NewPendingOppSLPts, OBJPROP_HIDDEN, true);
    ObjectSetInteger(0, NewPendingOppSLPts, OBJPROP_READONLY, true);
    ObjectSetInteger(0, NewPendingOppSLPts, OBJPROP_FONTSIZE, NOFontSize);
    ObjectSetString(0, NewPendingOppSLPts, OBJPROP_TOOLTIP, "Stop Loss in Points");
    ObjectSetInteger(0, NewPendingOppSLPts, OBJPROP_ALIGN, ALIGN_CENTER);
    ObjectSetString(0, NewPendingOppSLPts, OBJPROP_FONT, NOFont);
    ObjectSetString(0, NewPendingOppSLPts, OBJPROP_TEXT, TextSLPts);
    ObjectSet(NewPendingOppSLPts, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, NewPendingOppSLPts, OBJPROP_COLOR, clrBlack);

    ObjectCreate(0, NewPendingOppSLPtsE, OBJ_EDIT, 0, 0, 0);
    ObjectSet(NewPendingOppSLPtsE, OBJPROP_XDISTANCE, NewPendingOppXoff + (NewPendingOppDoubleX + 2) + 2);
    ObjectSet(NewPendingOppSLPtsE, OBJPROP_YDISTANCE, NewPendingOppYoff + 2 + (NewPendingOppLabelY + 1) * j);
    ObjectSetInteger(0, NewPendingOppSLPtsE, OBJPROP_XSIZE, NewPendingOppDoubleX);
    ObjectSetInteger(0, NewPendingOppSLPtsE, OBJPROP_YSIZE, NewPendingOppLabelY);
    ObjectSetInteger(0, NewPendingOppSLPtsE, OBJPROP_BORDER_TYPE, BORDER_FLAT);
    ObjectSetInteger(0, NewPendingOppSLPtsE, OBJPROP_STATE, false);
    ObjectSetInteger(0, NewPendingOppSLPtsE, OBJPROP_HIDDEN, true);
    ObjectSetInteger(0, NewPendingOppSLPtsE, OBJPROP_READONLY, false);
    ObjectSetInteger(0, NewPendingOppSLPtsE, OBJPROP_FONTSIZE, NOFontSize);
    ObjectSetString(0, NewPendingOppSLPtsE, OBJPROP_TOOLTIP, "Stop Loss in Points");
    ObjectSetInteger(0, NewPendingOppSLPtsE, OBJPROP_ALIGN, ALIGN_CENTER);
    ObjectSetString(0, NewPendingOppSLPtsE, OBJPROP_FONT, NOFont);
    ObjectSetString(0, NewPendingOppSLPtsE, OBJPROP_TEXT, TextSLPtsE);
    ObjectSet(NewPendingOppSLPtsE, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, NewPendingOppSLPtsE, OBJPROP_COLOR, clrBlack);
    j++;

    ObjectCreate(0, NewPendingOppTPPts, OBJ_EDIT, 0, 0, 0);
    ObjectSet(NewPendingOppTPPts, OBJPROP_XDISTANCE, NewPendingOppXoff + 2);
    ObjectSet(NewPendingOppTPPts, OBJPROP_YDISTANCE, NewPendingOppYoff + 2 + (NewPendingOppLabelY + 1) * j);
    ObjectSetInteger(0, NewPendingOppTPPts, OBJPROP_XSIZE, NewPendingOppDoubleX);
    ObjectSetInteger(0, NewPendingOppTPPts, OBJPROP_YSIZE, NewPendingOppLabelY);
    ObjectSetInteger(0, NewPendingOppTPPts, OBJPROP_BORDER_TYPE, BORDER_FLAT);
    ObjectSetInteger(0, NewPendingOppTPPts, OBJPROP_STATE, false);
    ObjectSetInteger(0, NewPendingOppTPPts, OBJPROP_HIDDEN, true);
    ObjectSetInteger(0, NewPendingOppTPPts, OBJPROP_READONLY, true);
    ObjectSetInteger(0, NewPendingOppTPPts, OBJPROP_FONTSIZE, NOFontSize);
    ObjectSetString(0, NewPendingOppTPPts, OBJPROP_TOOLTIP, "Take Profit in Points");
    ObjectSetInteger(0, NewPendingOppTPPts, OBJPROP_ALIGN, ALIGN_CENTER);
    ObjectSetString(0, NewPendingOppTPPts, OBJPROP_FONT, NOFont);
    ObjectSetString(0, NewPendingOppTPPts, OBJPROP_TEXT, TextTPPts);
    ObjectSet(NewPendingOppTPPts, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, NewPendingOppTPPts, OBJPROP_COLOR, clrBlack);

    ObjectCreate(0, NewPendingOppTPPtsE, OBJ_EDIT, 0, 0, 0);
    ObjectSet(NewPendingOppTPPtsE, OBJPROP_XDISTANCE, NewPendingOppXoff + (NewPendingOppDoubleX + 2) + 2);
    ObjectSet(NewPendingOppTPPtsE, OBJPROP_YDISTANCE, NewPendingOppYoff + 2 + (NewPendingOppLabelY + 1) * j);
    ObjectSetInteger(0, NewPendingOppTPPtsE, OBJPROP_XSIZE, NewPendingOppDoubleX);
    ObjectSetInteger(0, NewPendingOppTPPtsE, OBJPROP_YSIZE, NewPendingOppLabelY);
    ObjectSetInteger(0, NewPendingOppTPPtsE, OBJPROP_BORDER_TYPE, BORDER_FLAT);
    ObjectSetInteger(0, NewPendingOppTPPtsE, OBJPROP_STATE, false);
    ObjectSetInteger(0, NewPendingOppTPPtsE, OBJPROP_HIDDEN, true);
    ObjectSetInteger(0, NewPendingOppTPPtsE, OBJPROP_READONLY, false);
    ObjectSetInteger(0, NewPendingOppTPPtsE, OBJPROP_FONTSIZE, NOFontSize);
    ObjectSetString(0, NewPendingOppTPPtsE, OBJPROP_TOOLTIP, "Take Profit in Points");
    ObjectSetInteger(0, NewPendingOppTPPtsE, OBJPROP_ALIGN, ALIGN_CENTER);
    ObjectSetString(0, NewPendingOppTPPtsE, OBJPROP_FONT, NOFont);
    ObjectSetString(0, NewPendingOppTPPtsE, OBJPROP_TEXT, TextTPPtsE);
    ObjectSet(NewPendingOppTPPtsE, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, NewPendingOppTPPtsE, OBJPROP_COLOR, clrBlack);
    j++;

    ObjectCreate(0, NewPendingOppMagic, OBJ_EDIT, 0, 0, 0);
    ObjectSet(NewPendingOppMagic, OBJPROP_XDISTANCE, NewPendingOppXoff + 2);
    ObjectSet(NewPendingOppMagic, OBJPROP_YDISTANCE, NewPendingOppYoff + 2 + (NewPendingOppLabelY + 1) * j);
    ObjectSetInteger(0, NewPendingOppMagic, OBJPROP_XSIZE, NewPendingOppDoubleX);
    ObjectSetInteger(0, NewPendingOppMagic, OBJPROP_YSIZE, NewPendingOppLabelY);
    ObjectSetInteger(0, NewPendingOppMagic, OBJPROP_BORDER_TYPE, BORDER_FLAT);
    ObjectSetInteger(0, NewPendingOppMagic, OBJPROP_STATE, false);
    ObjectSetInteger(0, NewPendingOppMagic, OBJPROP_HIDDEN, true);
    ObjectSetInteger(0, NewPendingOppMagic, OBJPROP_READONLY, true);
    ObjectSetInteger(0, NewPendingOppMagic, OBJPROP_FONTSIZE, NOFontSize);
    ObjectSetString(0, NewPendingOppMagic, OBJPROP_TOOLTIP, "Magic Number");
    ObjectSetInteger(0, NewPendingOppMagic, OBJPROP_ALIGN, ALIGN_CENTER);
    ObjectSetString(0, NewPendingOppMagic, OBJPROP_FONT, NOFont);
    ObjectSetString(0, NewPendingOppMagic, OBJPROP_TEXT, "MAGIC #");
    ObjectSet(NewPendingOppMagic, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, NewPendingOppMagic, OBJPROP_COLOR, clrBlack);

    ObjectCreate(0, NewPendingOppMagicE, OBJ_EDIT, 0, 0, 0);
    ObjectSet(NewPendingOppMagicE, OBJPROP_XDISTANCE, NewPendingOppXoff + (NewPendingOppDoubleX + 2) + 2);
    ObjectSet(NewPendingOppMagicE, OBJPROP_YDISTANCE, NewPendingOppYoff + 2 + (NewPendingOppLabelY + 1) * j);
    ObjectSetInteger(0, NewPendingOppMagicE, OBJPROP_XSIZE, NewPendingOppDoubleX);
    ObjectSetInteger(0, NewPendingOppMagicE, OBJPROP_YSIZE, NewPendingOppLabelY);
    ObjectSetInteger(0, NewPendingOppMagicE, OBJPROP_BORDER_TYPE, BORDER_FLAT);
    ObjectSetInteger(0, NewPendingOppMagicE, OBJPROP_STATE, false);
    ObjectSetInteger(0, NewPendingOppMagicE, OBJPROP_HIDDEN, true);
    ObjectSetInteger(0, NewPendingOppMagicE, OBJPROP_READONLY, false);
    ObjectSetInteger(0, NewPendingOppMagicE, OBJPROP_FONTSIZE, NOFontSize);
    ObjectSetString(0, NewPendingOppMagicE, OBJPROP_TOOLTIP, "Magic Number for the order - Click to change");
    ObjectSetInteger(0, NewPendingOppMagicE, OBJPROP_ALIGN, ALIGN_CENTER);
    ObjectSetString(0, NewPendingOppMagicE, OBJPROP_FONT, NOFont);
    ObjectSetString(0, NewPendingOppMagicE, OBJPROP_TEXT, TextMagic);
    ObjectSet(NewPendingOppMagicE, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, NewPendingOppMagicE, OBJPROP_COLOR, clrBlack);
    j++;

    ObjectCreate(0, NewPendingOppComment, OBJ_EDIT, 0, 0, 0);
    ObjectSet(NewPendingOppComment, OBJPROP_XDISTANCE, NewPendingOppXoff + 2);
    ObjectSet(NewPendingOppComment, OBJPROP_YDISTANCE, NewPendingOppYoff + 2 + (NewPendingOppLabelY + 1) * j);
    ObjectSetInteger(0, NewPendingOppComment, OBJPROP_XSIZE, NewPendingOppMonoX);
    ObjectSetInteger(0, NewPendingOppComment, OBJPROP_YSIZE, NewPendingOppLabelY);
    ObjectSetInteger(0, NewPendingOppComment, OBJPROP_BORDER_TYPE, BORDER_FLAT);
    ObjectSetInteger(0, NewPendingOppComment, OBJPROP_STATE, false);
    ObjectSetInteger(0, NewPendingOppComment, OBJPROP_HIDDEN, true);
    ObjectSetInteger(0, NewPendingOppComment, OBJPROP_READONLY, true);
    ObjectSetInteger(0, NewPendingOppComment, OBJPROP_FONTSIZE, NOFontSize);
    ObjectSetString(0, NewPendingOppComment, OBJPROP_TOOLTIP, "Comment for the order");
    ObjectSetInteger(0, NewPendingOppComment, OBJPROP_ALIGN, ALIGN_CENTER);
    ObjectSetString(0, NewPendingOppComment, OBJPROP_FONT, NOFont);
    ObjectSetString(0, NewPendingOppComment, OBJPROP_TEXT, "COMMENT");
    ObjectSet(NewPendingOppComment, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, NewPendingOppComment, OBJPROP_COLOR, clrBlack);
    j++;

    ObjectCreate(0, NewPendingOppCommentE, OBJ_EDIT, 0, 0, 0);
    ObjectSet(NewPendingOppCommentE, OBJPROP_XDISTANCE, NewPendingOppXoff + 2);
    ObjectSet(NewPendingOppCommentE, OBJPROP_YDISTANCE, NewPendingOppYoff + 2 + (NewPendingOppLabelY + 1) * j);
    ObjectSetInteger(0, NewPendingOppCommentE, OBJPROP_XSIZE, NewPendingOppMonoX);
    ObjectSetInteger(0, NewPendingOppCommentE, OBJPROP_YSIZE, NewPendingOppLabelY);
    ObjectSetInteger(0, NewPendingOppCommentE, OBJPROP_BORDER_TYPE, BORDER_FLAT);
    ObjectSetInteger(0, NewPendingOppCommentE, OBJPROP_STATE, false);
    ObjectSetInteger(0, NewPendingOppCommentE, OBJPROP_HIDDEN, true);
    ObjectSetInteger(0, NewPendingOppCommentE, OBJPROP_READONLY, false);
    ObjectSetInteger(0, NewPendingOppCommentE, OBJPROP_FONTSIZE, NOFontSize);
    ObjectSetString(0, NewPendingOppCommentE, OBJPROP_TOOLTIP, "Comment for the order - Click to change");
    ObjectSetInteger(0, NewPendingOppCommentE, OBJPROP_ALIGN, ALIGN_CENTER);
    ObjectSetString(0, NewPendingOppCommentE, OBJPROP_FONT, NOFont);
    ObjectSetString(0, NewPendingOppCommentE, OBJPROP_TEXT, TextComment);
    ObjectSet(NewPendingOppCommentE, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, NewPendingOppCommentE, OBJPROP_COLOR, clrBlack);
    j++;

    ObjectCreate(0, NewPendingOppSubmit, OBJ_EDIT, 0, 0, 0);
    ObjectSet(NewPendingOppSubmit, OBJPROP_XDISTANCE, NewPendingOppXoff + 2);
    ObjectSet(NewPendingOppSubmit, OBJPROP_YDISTANCE, NewPendingOppYoff + 2 + (NewPendingOppLabelY + 1) * j);
    ObjectSetInteger(0, NewPendingOppSubmit, OBJPROP_XSIZE, NewPendingOppMonoX);
    ObjectSetInteger(0, NewPendingOppSubmit, OBJPROP_YSIZE, NewPendingOppLabelY);
    ObjectSetInteger(0, NewPendingOppSubmit, OBJPROP_BORDER_TYPE, BORDER_FLAT);
    ObjectSetInteger(0, NewPendingOppSubmit, OBJPROP_STATE, false);
    ObjectSetInteger(0, NewPendingOppSubmit, OBJPROP_HIDDEN, true);
    ObjectSetInteger(0, NewPendingOppSubmit, OBJPROP_READONLY, true);
    ObjectSetInteger(0, NewPendingOppSubmit, OBJPROP_FONTSIZE, NOFontSize);
    ObjectSetString(0, NewPendingOppSubmit, OBJPROP_TOOLTIP, "Submit Order Or Orders");
    ObjectSetInteger(0, NewPendingOppSubmit, OBJPROP_ALIGN, ALIGN_CENTER);
    ObjectSetString(0, NewPendingOppSubmit, OBJPROP_FONT, NOFont);
    ObjectSetString(0, NewPendingOppSubmit, OBJPROP_TEXT, "SUBMIT");
    ObjectSet(NewPendingOppSubmit, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, NewPendingOppSubmit, OBJPROP_COLOR, clrBlack);
    ObjectSetInteger(0, NewPendingOppSubmit, OBJPROP_BGCOLOR, clrPaleGreen);
    ObjectSetInteger(0, NewPendingOppSubmit, OBJPROP_BORDER_COLOR, clrBlack);
    j++;

    if (ShowURL)
    {
        ObjectCreate(0, NewPendingOppURL, OBJ_EDIT, 0, 0, 0);
        ObjectSet(NewPendingOppURL, OBJPROP_XDISTANCE, NewPendingOppXoff + 2);
        ObjectSet(NewPendingOppURL, OBJPROP_YDISTANCE, NewPendingOppYoff + 2 + (NewPendingOppLabelY + 1) * j);
        ObjectSetInteger(0, NewPendingOppURL, OBJPROP_XSIZE, NewPendingOppMonoX);
        ObjectSetInteger(0, NewPendingOppURL, OBJPROP_YSIZE, NewPendingOppLabelY);
        ObjectSetInteger(0, NewPendingOppURL, OBJPROP_BORDER_TYPE, BORDER_FLAT);
        ObjectSetInteger(0, NewPendingOppURL, OBJPROP_STATE, false);
        ObjectSetInteger(0, NewPendingOppURL, OBJPROP_HIDDEN, true);
        ObjectSetInteger(0, NewPendingOppURL, OBJPROP_READONLY, true);
        ObjectSetInteger(0, NewPendingOppURL, OBJPROP_FONTSIZE, NOFontSize);
        ObjectSetString(0, NewPendingOppURL, OBJPROP_TOOLTIP, "Visit Us");
        ObjectSetInteger(0, NewPendingOppURL, OBJPROP_ALIGN, ALIGN_CENTER);
        ObjectSetString(0, NewPendingOppURL, OBJPROP_FONT, NOFont);
        ObjectSetString(0, NewPendingOppURL, OBJPROP_TEXT, "EarnForex.com");
        ObjectSet(NewPendingOppURL, OBJPROP_SELECTABLE, false);
        ObjectSetInteger(0, NewPendingOppURL, OBJPROP_COLOR, clrNavy);
        ObjectSetInteger(0, NewPendingOppURL, OBJPROP_BGCOLOR, clrKhaki);
        ObjectSetInteger(0, NewPendingOppURL, OBJPROP_BORDER_COLOR, clrBlack);
        j++;
    }

    NewPendingOppY = (NewPendingOppLabelY + 1) * j + 3;
    ObjectSetInteger(0, NewPendingOppBase, OBJPROP_YSIZE, NewPendingOppY);
}

void CloseNewPendingOpp()
{
    ObjectsDeleteAll(0, IndicatorName + "-NPO-");
    NewPendingOppPanelIsOpen = false;
}

void ChangePendingOppSide()
{
    if (CurrPendingOppSide == PENDING_BUY)
    {
        CurrPendingOppSide = PENDING_SELL;
        CloseNewPendingOpp();
        ShowNewPendingOpp();
        return;
    }
    else if (CurrPendingOppSide == PENDING_SELL)
    {
        CurrPendingOppSide = PENDING_BUYSELL;
        CloseNewPendingOpp();
        ShowNewPendingOpp();
        return;
    }
    else if (CurrPendingOppSide == PENDING_BUYSELL)
    {
        CurrPendingOppSide = PENDING_BUY;
        CloseNewPendingOpp();
        ShowNewPendingOpp();
        return;
    }
}

void ChangePendingOppType()
{
    if (CurrPendingOppType == PENDING_LIMIT)
    {
        CurrPendingOppType = PENDING_STOP;
        CloseNewPendingOpp();
        ShowNewPendingOpp();
        return;
    }
    else if (CurrPendingOppType == PENDING_STOP)
    {
        CurrPendingOppType = PENDING_LIMIT;
        CloseNewPendingOpp();
        ShowNewPendingOpp();
        return;
    }
}

void ChangePendingOppStartMode()
{
    if (CurrPendingOppStartMode == PENDING_START_CURRENT)
    {
        CurrPendingOppStartMode = PENDING_START_MANUAL;
        CloseNewPendingOpp();
        ShowNewPendingOpp();
        return;
    }
    else if (CurrPendingOppStartMode == PENDING_START_MANUAL)
    {
        CurrPendingOppStartMode = PENDING_START_CURRENT;
        CloseNewPendingOpp();
        ShowNewPendingOpp();
        return;
    }
}

void ChangePendingOppDistance()
{
    CurrPendingOppDistance = (int)StringToInteger(ObjectGetString(0, NewPendingOppPendingDistanceE, OBJPROP_TEXT));
    ShowNewPendingOpp();
}

string NewOrderLinesBase = IndicatorName + "-NOL-Base";
string NewOrderLinesClose = IndicatorName + "-NOL-Close";
string NewOrderLinesOrder = IndicatorName + "-NOL-LinesOrder";
string NewOrderLinesPositionSize = IndicatorName + "-NOL-PosSize";
string NewOrderLinesRecommendedSize = IndicatorName + "-NOL-RecSize";
string NewOrderLinesPendingOpenPrice = IndicatorName + "-NOL-PendingOP";
string NewOrderLinesPendingOpenPriceE = IndicatorName + "-NOL-PendingOPE";
string NewOrderLinesSide = IndicatorName + "-NOL-Side";
string NewOrderLinesOrderType = IndicatorName + "-NOL-OrderType";
string NewOrderLinesLotMinus = IndicatorName + "-NOL-LotMinus";
string NewOrderLinesLotSize = IndicatorName + "-NOL-LotSize";
string NewOrderLinesLotPlus = IndicatorName + "-NOL-LotPlus";
string NewOrderLinesSLPrice = IndicatorName + "-NOL-SLPrice";
string NewOrderLinesTPPrice = IndicatorName + "-NOL-TPPrice";
string NewOrderLinesSLPriceE = IndicatorName + "-NOL-SLPriceE";
string NewOrderLinesTPPriceE = IndicatorName + "-NOL-TPPriceE";
string NewOrderLinesMagic = IndicatorName + "-NOL-Magic";
string NewOrderLinesMagicE = IndicatorName + "-NOL-MagicE";
string NewOrderLinesComment = IndicatorName + "-NOL-Comment";
string NewOrderLinesCommentE = IndicatorName + "-NOL-CommentE";
string NewOrderLinesSubmit = IndicatorName + "-NOL-Submit";
string NewOrderLinesURL = IndicatorName + "-NOL-URL";
void ShowNewOrderLines()
{
    NewOrderLinesPanelIsOpen = true;

    UpdateLinesLabels();

    int NewOrderLinesXoff = Xoff;
    int NewOrderLinesYoff = Yoff + PanelMovY + 2 * 4;
    int NewOrderLinesX = NewOrderLinesMonoX + 2 + 2;
    int NewOrderLinesY = (NewOrderLinesLabelY + 2) * 11 + 2;

    string TextOrderLines = "";
    string TextSide = "";
    string TextType = "";
    string TextBuyButton = "";
    string TextSellButton = "";
    string TextLotSize = "";
    string TextPositionSizeTip = "";
    string TextSLPrice = "";
    string TextTPPrice = "";
    string TextMagic = "";
    string TextComment = "";
    string TextSLPriceE = "";
    string TextTPPriceE = "";
    string TextPendingOpenPrice = "";
    string TextPendingOpenPriceE = "";
    string TextPositionSize = "";
    string TextRecSize = "";
    int j = 1;

    TextPendingOpenPrice = "OPEN PRICE";
    TextMagic = IntegerToString(CurrMagic);
    TextComment = CurrComment;
    TextSLPrice = "SL Price";
    TextTPPrice = "TP Price";
    TextSLPriceE = DoubleToString(CurrSLPrice, _Digits);
    TextTPPriceE = DoubleToString(CurrTPPrice, _Digits);
    TextPendingOpenPriceE = DoubleToString(CurrOpenPrice, _Digits);
    TextOrderLines = "ORDER WITH LINES";
    if (CurrLinesSide == LINE_ORDER_BUY) TextSide = "BUY";
    if (CurrLinesSide == LINE_ORDER_SELL) TextSide = "SELL";
    if (CurrLinesType == LINE_ORDER_LIMIT) TextType = "LIMIT";
    if (CurrLinesType == LINE_ORDER_STOP) TextType = "STOP";
    if (CurrLinesType == LINE_ORDER_MARKET) TextType = "MARKET";
    if (CurrLinesType == LINE_ORDER_MARKET)
    {
        CurrMarketPending = Market;
    }
    else
    {
        CurrMarketPending = Pending;
    }
    CurrSLPtsOrPrice = ByPrice;
    double CurrRecommendedSize = RecommendedSize();
    if (CurrRecommendedSize > 0) TextRecSize = "RECOMMENDED SIZE (LOTS): " + DoubleToStr(CurrRecommendedSize, 2);
    else TextRecSize = "RECOMMENDED SIZE (LOTS): N/A";
    TextPositionSize = "POSITION SIZE (LOTS)";
    TextPositionSizeTip = "Position Size In Lots";
    TextLotSize = DoubleToString(CurrLotSize, 2);
    ObjectCreate(0, NewOrderLinesBase, OBJ_RECTANGLE_LABEL, 0, 0, 0);
    ObjectSet(NewOrderLinesBase, OBJPROP_XDISTANCE, NewOrderLinesXoff);
    ObjectSet(NewOrderLinesBase, OBJPROP_YDISTANCE, NewOrderLinesYoff);
    ObjectSetInteger(0, NewOrderLinesBase, OBJPROP_XSIZE, NewOrderLinesX);
    ObjectSetInteger(0, NewOrderLinesBase, OBJPROP_YSIZE, NewOrderLinesY);
    ObjectSetInteger(0, NewOrderLinesBase, OBJPROP_BGCOLOR, clrWhite);
    ObjectSetInteger(0, NewOrderLinesBase, OBJPROP_BORDER_TYPE, BORDER_FLAT);
    ObjectSetInteger(0, NewOrderLinesBase, OBJPROP_STATE, false);
    ObjectSetInteger(0, NewOrderLinesBase, OBJPROP_HIDDEN, true);
    ObjectSetInteger(0, NewOrderLinesBase, OBJPROP_FONTSIZE, NOFontSize);
    ObjectSet(NewOrderLinesBase, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, NewOrderLinesBase, OBJPROP_COLOR, clrBlack);

    ObjectCreate(0, NewOrderLinesClose, OBJ_EDIT, 0, 0, 0);
    ObjectSet(NewOrderLinesClose, OBJPROP_XDISTANCE, NewOrderLinesXoff + 2);
    ObjectSet(NewOrderLinesClose, OBJPROP_YDISTANCE, NewOrderLinesYoff + 2);
    ObjectSetInteger(0, NewOrderLinesClose, OBJPROP_XSIZE, NewOrderLinesMonoX);
    ObjectSetInteger(0, NewOrderLinesClose, OBJPROP_YSIZE, NewOrderLinesLabelY);
    ObjectSetInteger(0, NewOrderLinesClose, OBJPROP_BORDER_TYPE, BORDER_FLAT);
    ObjectSetInteger(0, NewOrderLinesClose, OBJPROP_STATE, false);
    ObjectSetInteger(0, NewOrderLinesClose, OBJPROP_HIDDEN, true);
    ObjectSetInteger(0, NewOrderLinesClose, OBJPROP_READONLY, true);
    ObjectSetInteger(0, NewOrderLinesClose, OBJPROP_FONTSIZE, NOFontSize);
    ObjectSetString(0, NewOrderLinesClose, OBJPROP_TOOLTIP, "Close Panel");
    ObjectSetInteger(0, NewOrderLinesClose, OBJPROP_ALIGN, ALIGN_CENTER);
    ObjectSetString(0, NewOrderLinesClose, OBJPROP_FONT, NOFont);
    ObjectSetString(0, NewOrderLinesClose, OBJPROP_TEXT, "X");
    ObjectSet(NewOrderLinesClose, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, NewOrderLinesClose, OBJPROP_COLOR, clrBlack);
    ObjectSetInteger(0, NewOrderLinesClose, OBJPROP_BGCOLOR, clrCrimson);
    ObjectSetInteger(0, NewOrderLinesClose, OBJPROP_BORDER_COLOR, clrBlack);

    ObjectCreate(0, NewOrderLinesOrder, OBJ_EDIT, 0, 0, 0);
    ObjectSet(NewOrderLinesOrder, OBJPROP_XDISTANCE, NewOrderLinesXoff + 2);
    ObjectSet(NewOrderLinesOrder, OBJPROP_YDISTANCE, NewOrderLinesYoff + 2 + (NewOrderLinesLabelY + 1) * j);
    ObjectSetInteger(0, NewOrderLinesOrder, OBJPROP_XSIZE, NewOrderLinesMonoX);
    ObjectSetInteger(0, NewOrderLinesOrder, OBJPROP_YSIZE, NewOrderLinesLabelY);
    ObjectSetInteger(0, NewOrderLinesOrder, OBJPROP_BORDER_TYPE, BORDER_FLAT);
    ObjectSetInteger(0, NewOrderLinesOrder, OBJPROP_STATE, false);
    ObjectSetInteger(0, NewOrderLinesOrder, OBJPROP_HIDDEN, true);
    ObjectSetInteger(0, NewOrderLinesOrder, OBJPROP_READONLY, true);
    ObjectSetInteger(0, NewOrderLinesOrder, OBJPROP_FONTSIZE, NOFontSize);
    ObjectSetString(0, NewOrderLinesOrder, OBJPROP_TOOLTIP, "New Orders Assisted By Lines");
    ObjectSetInteger(0, NewOrderLinesOrder, OBJPROP_ALIGN, ALIGN_CENTER);
    ObjectSetString(0, NewOrderLinesOrder, OBJPROP_FONT, NOFont);
    ObjectSetString(0, NewOrderLinesOrder, OBJPROP_TEXT, TextOrderLines);
    ObjectSet(NewOrderLinesOrder, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, NewOrderLinesOrder, OBJPROP_COLOR, clrBlack);
    ObjectSetInteger(0, NewOrderLinesOrder, OBJPROP_BGCOLOR, clrPaleGreen);
    ObjectSetInteger(0, NewOrderLinesOrder, OBJPROP_BORDER_COLOR, clrBlack);
    j++;

    ObjectCreate(0, NewOrderLinesSide, OBJ_EDIT, 0, 0, 0);
    ObjectSet(NewOrderLinesSide, OBJPROP_XDISTANCE, NewOrderLinesXoff + 2);
    ObjectSet(NewOrderLinesSide, OBJPROP_YDISTANCE, NewOrderLinesYoff + 2 + (NewOrderLinesLabelY + 1) * j);
    ObjectSetInteger(0, NewOrderLinesSide, OBJPROP_XSIZE, NewOrderLinesDoubleX);
    ObjectSetInteger(0, NewOrderLinesSide, OBJPROP_YSIZE, NewOrderLinesLabelY);
    ObjectSetInteger(0, NewOrderLinesSide, OBJPROP_BORDER_TYPE, BORDER_FLAT);
    ObjectSetInteger(0, NewOrderLinesSide, OBJPROP_STATE, false);
    ObjectSetInteger(0, NewOrderLinesSide, OBJPROP_HIDDEN, true);
    ObjectSetInteger(0, NewOrderLinesSide, OBJPROP_READONLY, true);
    ObjectSetInteger(0, NewOrderLinesSide, OBJPROP_FONTSIZE, NOFontSize);
    ObjectSetString(0, NewOrderLinesSide, OBJPROP_TOOLTIP, "Click To Change");
    ObjectSetInteger(0, NewOrderLinesSide, OBJPROP_ALIGN, ALIGN_CENTER);
    ObjectSetString(0, NewOrderLinesSide, OBJPROP_FONT, NOFont);
    ObjectSetString(0, NewOrderLinesSide, OBJPROP_TEXT, TextSide);
    ObjectSet(NewOrderLinesSide, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, NewOrderLinesSide, OBJPROP_COLOR, clrWhite);
    ObjectSetInteger(0, NewOrderLinesSide, OBJPROP_BGCOLOR, clrBlue);
    ObjectSetInteger(0, NewOrderLinesSide, OBJPROP_BORDER_COLOR, clrBlack);

    ObjectCreate(0, NewOrderLinesOrderType, OBJ_EDIT, 0, 0, 0);
    ObjectSet(NewOrderLinesOrderType, OBJPROP_XDISTANCE, NewOrderLinesXoff + (NewOrderLinesDoubleX + 2) + 2);
    ObjectSet(NewOrderLinesOrderType, OBJPROP_YDISTANCE, NewOrderLinesYoff + 2 + (NewOrderLinesLabelY + 1) * j);
    ObjectSetInteger(0, NewOrderLinesOrderType, OBJPROP_XSIZE, NewOrderLinesDoubleX);
    ObjectSetInteger(0, NewOrderLinesOrderType, OBJPROP_YSIZE, NewOrderLinesLabelY);
    ObjectSetInteger(0, NewOrderLinesOrderType, OBJPROP_BORDER_TYPE, BORDER_FLAT);
    ObjectSetInteger(0, NewOrderLinesOrderType, OBJPROP_STATE, false);
    ObjectSetInteger(0, NewOrderLinesOrderType, OBJPROP_HIDDEN, true);
    ObjectSetInteger(0, NewOrderLinesOrderType, OBJPROP_READONLY, true);
    ObjectSetInteger(0, NewOrderLinesOrderType, OBJPROP_FONTSIZE, NOFontSize);
    ObjectSetString(0, NewOrderLinesOrderType, OBJPROP_TOOLTIP, "Click To Change");
    ObjectSetInteger(0, NewOrderLinesOrderType, OBJPROP_ALIGN, ALIGN_CENTER);
    ObjectSetString(0, NewOrderLinesOrderType, OBJPROP_FONT, NOFont);
    ObjectSetString(0, NewOrderLinesOrderType, OBJPROP_TEXT, TextType);
    ObjectSet(NewOrderLinesOrderType, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, NewOrderLinesOrderType, OBJPROP_COLOR, clrWhite);
    ObjectSetInteger(0, NewOrderLinesOrderType, OBJPROP_BGCOLOR, clrRed);
    ObjectSetInteger(0, NewOrderLinesOrderType, OBJPROP_BORDER_COLOR, clrBlack);
    j++;

    if (CurrLinesType != LINE_ORDER_MARKET)
    {
        ObjectCreate(0, NewOrderLinesPendingOpenPrice, OBJ_EDIT, 0, 0, 0);
        ObjectSet(NewOrderLinesPendingOpenPrice, OBJPROP_XDISTANCE, NewOrderLinesXoff + 2);
        ObjectSet(NewOrderLinesPendingOpenPrice, OBJPROP_YDISTANCE, NewOrderLinesYoff + 2 + (NewOrderLinesLabelY + 1) * j);
        ObjectSetInteger(0, NewOrderLinesPendingOpenPrice, OBJPROP_XSIZE, NewOrderLinesDoubleX);
        ObjectSetInteger(0, NewOrderLinesPendingOpenPrice, OBJPROP_YSIZE, NewOrderLinesLabelY);
        ObjectSetInteger(0, NewOrderLinesPendingOpenPrice, OBJPROP_BORDER_TYPE, BORDER_FLAT);
        ObjectSetInteger(0, NewOrderLinesPendingOpenPrice, OBJPROP_STATE, false);
        ObjectSetInteger(0, NewOrderLinesPendingOpenPrice, OBJPROP_HIDDEN, true);
        ObjectSetInteger(0, NewOrderLinesPendingOpenPrice, OBJPROP_READONLY, true);
        ObjectSetInteger(0, NewOrderLinesPendingOpenPrice, OBJPROP_FONTSIZE, NOFontSize);
        ObjectSetString(0, NewOrderLinesPendingOpenPrice, OBJPROP_TOOLTIP, "Start Price - Click To Change");
        ObjectSetInteger(0, NewOrderLinesPendingOpenPrice, OBJPROP_ALIGN, ALIGN_CENTER);
        ObjectSetString(0, NewOrderLinesPendingOpenPrice, OBJPROP_FONT, NOFont);
        ObjectSetString(0, NewOrderLinesPendingOpenPrice, OBJPROP_TEXT, TextPendingOpenPrice);
        ObjectSet(NewOrderLinesPendingOpenPrice, OBJPROP_SELECTABLE, false);
        ObjectSetInteger(0, NewOrderLinesPendingOpenPrice, OBJPROP_COLOR, clrBlack);

        ObjectCreate(0, NewOrderLinesPendingOpenPriceE, OBJ_EDIT, 0, 0, 0);
        ObjectSet(NewOrderLinesPendingOpenPriceE, OBJPROP_XDISTANCE, NewOrderLinesXoff + (NewOrderLinesDoubleX + 2) + 2);
        ObjectSet(NewOrderLinesPendingOpenPriceE, OBJPROP_YDISTANCE, NewOrderLinesYoff + 2 + (NewOrderLinesLabelY + 1) * j);
        ObjectSetInteger(0, NewOrderLinesPendingOpenPriceE, OBJPROP_XSIZE, NewOrderLinesDoubleX);
        ObjectSetInteger(0, NewOrderLinesPendingOpenPriceE, OBJPROP_YSIZE, NewOrderLinesLabelY);
        ObjectSetInteger(0, NewOrderLinesPendingOpenPriceE, OBJPROP_BORDER_TYPE, BORDER_FLAT);
        ObjectSetInteger(0, NewOrderLinesPendingOpenPriceE, OBJPROP_STATE, false);
        ObjectSetInteger(0, NewOrderLinesPendingOpenPriceE, OBJPROP_HIDDEN, true);
        ObjectSetInteger(0, NewOrderLinesPendingOpenPriceE, OBJPROP_READONLY, false);
        ObjectSetInteger(0, NewOrderLinesPendingOpenPriceE, OBJPROP_FONTSIZE, NOFontSize);
        ObjectSetString(0, NewOrderLinesPendingOpenPriceE, OBJPROP_TOOLTIP, "Start Price");
        ObjectSetInteger(0, NewOrderLinesPendingOpenPriceE, OBJPROP_ALIGN, ALIGN_CENTER);
        ObjectSetString(0, NewOrderLinesPendingOpenPriceE, OBJPROP_FONT, NOFont);
        ObjectSetString(0, NewOrderLinesPendingOpenPriceE, OBJPROP_TEXT, TextPendingOpenPriceE);
        ObjectSet(NewOrderLinesPendingOpenPriceE, OBJPROP_SELECTABLE, false);
        ObjectSetInteger(0, NewOrderLinesPendingOpenPriceE, OBJPROP_COLOR, clrBlack);
        j++;
    }

    ObjectCreate(0, NewOrderLinesPositionSize, OBJ_EDIT, 0, 0, 0);
    ObjectSet(NewOrderLinesPositionSize, OBJPROP_XDISTANCE, NewOrderLinesXoff + 2);
    ObjectSet(NewOrderLinesPositionSize, OBJPROP_YDISTANCE, NewOrderLinesYoff + 2 + (NewOrderLinesLabelY + 1) * j);
    ObjectSetInteger(0, NewOrderLinesPositionSize, OBJPROP_XSIZE, NewOrderLinesMonoX);
    ObjectSetInteger(0, NewOrderLinesPositionSize, OBJPROP_YSIZE, NewOrderLinesLabelY);
    ObjectSetInteger(0, NewOrderLinesPositionSize, OBJPROP_BORDER_TYPE, BORDER_FLAT);
    ObjectSetInteger(0, NewOrderLinesPositionSize, OBJPROP_STATE, false);
    ObjectSetInteger(0, NewOrderLinesPositionSize, OBJPROP_HIDDEN, true);
    ObjectSetInteger(0, NewOrderLinesPositionSize, OBJPROP_READONLY, true);
    ObjectSetInteger(0, NewOrderLinesPositionSize, OBJPROP_FONTSIZE, NOFontSize);
    ObjectSetString(0, NewOrderLinesPositionSize, OBJPROP_TOOLTIP, TextPositionSizeTip);
    ObjectSetInteger(0, NewOrderLinesPositionSize, OBJPROP_ALIGN, ALIGN_CENTER);
    ObjectSetString(0, NewOrderLinesPositionSize, OBJPROP_FONT, NOFont);
    ObjectSetString(0, NewOrderLinesPositionSize, OBJPROP_TEXT, TextPositionSize);
    ObjectSet(NewOrderLinesPositionSize, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, NewOrderLinesPositionSize, OBJPROP_COLOR, clrBlack);
    j++;

    ObjectCreate(0, NewOrderLinesLotMinus, OBJ_EDIT, 0, 0, 0);
    ObjectSet(NewOrderLinesLotMinus, OBJPROP_XDISTANCE, NewOrderLinesXoff + 2);
    ObjectSet(NewOrderLinesLotMinus, OBJPROP_YDISTANCE, NewOrderLinesYoff + 2 + (NewOrderLinesLabelY + 1) * j);
    ObjectSetInteger(0, NewOrderLinesLotMinus, OBJPROP_XSIZE, NewOrderLinesTripleX);
    ObjectSetInteger(0, NewOrderLinesLotMinus, OBJPROP_YSIZE, NewOrderLinesLabelY);
    ObjectSetInteger(0, NewOrderLinesLotMinus, OBJPROP_BORDER_TYPE, BORDER_FLAT);
    ObjectSetInteger(0, NewOrderLinesLotMinus, OBJPROP_STATE, false);
    ObjectSetInteger(0, NewOrderLinesLotMinus, OBJPROP_HIDDEN, true);
    ObjectSetInteger(0, NewOrderLinesLotMinus, OBJPROP_READONLY, true);
    ObjectSetInteger(0, NewOrderLinesLotMinus, OBJPROP_FONTSIZE, NOFontSize);
    ObjectSetString(0, NewOrderLinesLotMinus, OBJPROP_TOOLTIP, "Decrease Lot Size");
    ObjectSetInteger(0, NewOrderLinesLotMinus, OBJPROP_ALIGN, ALIGN_CENTER);
    ObjectSetString(0, NewOrderLinesLotMinus, OBJPROP_FONT, NOFont);
    ObjectSetString(0, NewOrderLinesLotMinus, OBJPROP_TEXT, "-");
    ObjectSet(NewOrderLinesLotMinus, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, NewOrderLinesLotMinus, OBJPROP_COLOR, clrBlack);

    ObjectCreate(0, NewOrderLinesLotSize, OBJ_EDIT, 0, 0, 0);
    ObjectSet(NewOrderLinesLotSize, OBJPROP_XDISTANCE, NewOrderLinesXoff + 2 + NewOrderLinesTripleX + 2);
    ObjectSet(NewOrderLinesLotSize, OBJPROP_YDISTANCE, NewOrderLinesYoff + 2 + (NewOrderLinesLabelY + 1) * j);
    ObjectSetInteger(0, NewOrderLinesLotSize, OBJPROP_XSIZE, NewOrderLinesTripleX);
    ObjectSetInteger(0, NewOrderLinesLotSize, OBJPROP_YSIZE, NewOrderLinesLabelY);
    ObjectSetInteger(0, NewOrderLinesLotSize, OBJPROP_BORDER_TYPE, BORDER_FLAT);
    ObjectSetInteger(0, NewOrderLinesLotSize, OBJPROP_STATE, false);
    ObjectSetInteger(0, NewOrderLinesLotSize, OBJPROP_HIDDEN, true);
    ObjectSetInteger(0, NewOrderLinesLotSize, OBJPROP_READONLY, false);
    ObjectSetInteger(0, NewOrderLinesLotSize, OBJPROP_FONTSIZE, NOFontSize);
    ObjectSetString(0, NewOrderLinesLotSize, OBJPROP_TOOLTIP, "Lot Size");
    ObjectSetInteger(0, NewOrderLinesLotSize, OBJPROP_ALIGN, ALIGN_CENTER);
    ObjectSetString(0, NewOrderLinesLotSize, OBJPROP_FONT, NOFont);
    ObjectSetString(0, NewOrderLinesLotSize, OBJPROP_TEXT, TextLotSize);
    ObjectSet(NewOrderLinesLotSize, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, NewOrderLinesLotSize, OBJPROP_COLOR, clrBlack);

    ObjectCreate(0, NewOrderLinesLotPlus, OBJ_EDIT, 0, 0, 0);
    ObjectSet(NewOrderLinesLotPlus, OBJPROP_XDISTANCE, NewOrderLinesXoff + 2 + (NewOrderLinesTripleX + 2) * 2);
    ObjectSet(NewOrderLinesLotPlus, OBJPROP_YDISTANCE, NewOrderLinesYoff + 2 + (NewOrderLinesLabelY + 1) * j);
    ObjectSetInteger(0, NewOrderLinesLotPlus, OBJPROP_XSIZE, NewOrderLinesTripleX);
    ObjectSetInteger(0, NewOrderLinesLotPlus, OBJPROP_YSIZE, NewOrderLinesLabelY);
    ObjectSetInteger(0, NewOrderLinesLotPlus, OBJPROP_BORDER_TYPE, BORDER_FLAT);
    ObjectSetInteger(0, NewOrderLinesLotPlus, OBJPROP_STATE, false);
    ObjectSetInteger(0, NewOrderLinesLotPlus, OBJPROP_HIDDEN, true);
    ObjectSetInteger(0, NewOrderLinesLotPlus, OBJPROP_READONLY, true);
    ObjectSetInteger(0, NewOrderLinesLotPlus, OBJPROP_FONTSIZE, NOFontSize);
    ObjectSetString(0, NewOrderLinesLotPlus, OBJPROP_TOOLTIP, "Increase Lot Size");
    ObjectSetInteger(0, NewOrderLinesLotPlus, OBJPROP_ALIGN, ALIGN_CENTER);
    ObjectSetString(0, NewOrderLinesLotPlus, OBJPROP_FONT, NOFont);
    ObjectSetString(0, NewOrderLinesLotPlus, OBJPROP_TEXT, "+");
    ObjectSet(NewOrderLinesLotPlus, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, NewOrderLinesLotPlus, OBJPROP_COLOR, clrBlack);
    j++;

    ObjectCreate(0, NewOrderLinesRecommendedSize, OBJ_EDIT, 0, 0, 0);
    ObjectSet(NewOrderLinesRecommendedSize, OBJPROP_XDISTANCE, NewOrderLinesXoff + 2);
    ObjectSet(NewOrderLinesRecommendedSize, OBJPROP_YDISTANCE, NewOrderLinesYoff + 2 + (NewOrderLinesLabelY + 1) * j);
    ObjectSetInteger(0, NewOrderLinesRecommendedSize, OBJPROP_XSIZE, NewOrderLinesMonoX);
    ObjectSetInteger(0, NewOrderLinesRecommendedSize, OBJPROP_YSIZE, NewOrderLinesLabelY);
    ObjectSetInteger(0, NewOrderLinesRecommendedSize, OBJPROP_BORDER_TYPE, BORDER_FLAT);
    ObjectSetInteger(0, NewOrderLinesRecommendedSize, OBJPROP_STATE, false);
    ObjectSetInteger(0, NewOrderLinesRecommendedSize, OBJPROP_HIDDEN, true);
    ObjectSetInteger(0, NewOrderLinesRecommendedSize, OBJPROP_READONLY, true);
    ObjectSetInteger(0, NewOrderLinesRecommendedSize, OBJPROP_FONTSIZE, NOFontSize);
    ObjectSetString(0, NewOrderLinesRecommendedSize, OBJPROP_TOOLTIP, "Recommended Position Size - Click to copy to Position Size");
    ObjectSetInteger(0, NewOrderLinesRecommendedSize, OBJPROP_ALIGN, ALIGN_CENTER);
    ObjectSetString(0, NewOrderLinesRecommendedSize, OBJPROP_FONT, NOFont);
    ObjectSetString(0, NewOrderLinesRecommendedSize, OBJPROP_TEXT, TextRecSize);
    ObjectSet(NewOrderLinesRecommendedSize, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, NewOrderLinesRecommendedSize, OBJPROP_COLOR, clrBlack);
    j++;

    ObjectCreate(0, NewOrderLinesSLPrice, OBJ_EDIT, 0, 0, 0);
    ObjectSet(NewOrderLinesSLPrice, OBJPROP_XDISTANCE, NewOrderLinesXoff + 2);
    ObjectSet(NewOrderLinesSLPrice, OBJPROP_YDISTANCE, NewOrderLinesYoff + 2 + (NewOrderLinesLabelY + 1) * j);
    ObjectSetInteger(0, NewOrderLinesSLPrice, OBJPROP_XSIZE, NewOrderLinesDoubleX);
    ObjectSetInteger(0, NewOrderLinesSLPrice, OBJPROP_YSIZE, NewOrderLinesLabelY);
    ObjectSetInteger(0, NewOrderLinesSLPrice, OBJPROP_BORDER_TYPE, BORDER_FLAT);
    ObjectSetInteger(0, NewOrderLinesSLPrice, OBJPROP_STATE, false);
    ObjectSetInteger(0, NewOrderLinesSLPrice, OBJPROP_HIDDEN, true);
    ObjectSetInteger(0, NewOrderLinesSLPrice, OBJPROP_READONLY, true);
    ObjectSetInteger(0, NewOrderLinesSLPrice, OBJPROP_FONTSIZE, NOFontSize);
    ObjectSetString(0, NewOrderLinesSLPrice, OBJPROP_TOOLTIP, "Stop Loss Price - Click To Create Line");
    ObjectSetInteger(0, NewOrderLinesSLPrice, OBJPROP_ALIGN, ALIGN_CENTER);
    ObjectSetString(0, NewOrderLinesSLPrice, OBJPROP_FONT, NOFont);
    ObjectSetString(0, NewOrderLinesSLPrice, OBJPROP_TEXT, TextSLPrice);
    ObjectSet(NewOrderLinesSLPrice, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, NewOrderLinesSLPrice, OBJPROP_COLOR, clrBlack);

    ObjectCreate(0, NewOrderLinesSLPriceE, OBJ_EDIT, 0, 0, 0);
    ObjectSet(NewOrderLinesSLPriceE, OBJPROP_XDISTANCE, NewOrderLinesXoff + (NewOrderLinesDoubleX + 2) + 2);
    ObjectSet(NewOrderLinesSLPriceE, OBJPROP_YDISTANCE, NewOrderLinesYoff + 2 + (NewOrderLinesLabelY + 1) * j);
    ObjectSetInteger(0, NewOrderLinesSLPriceE, OBJPROP_XSIZE, NewOrderLinesDoubleX);
    ObjectSetInteger(0, NewOrderLinesSLPriceE, OBJPROP_YSIZE, NewOrderLinesLabelY);
    ObjectSetInteger(0, NewOrderLinesSLPriceE, OBJPROP_BORDER_TYPE, BORDER_FLAT);
    ObjectSetInteger(0, NewOrderLinesSLPriceE, OBJPROP_STATE, false);
    ObjectSetInteger(0, NewOrderLinesSLPriceE, OBJPROP_HIDDEN, true);
    ObjectSetInteger(0, NewOrderLinesSLPriceE, OBJPROP_READONLY, false);
    ObjectSetInteger(0, NewOrderLinesSLPriceE, OBJPROP_FONTSIZE, NOFontSize);
    ObjectSetString(0, NewOrderLinesSLPriceE, OBJPROP_TOOLTIP, "Stop Loss Price");
    ObjectSetInteger(0, NewOrderLinesSLPriceE, OBJPROP_ALIGN, ALIGN_CENTER);
    ObjectSetString(0, NewOrderLinesSLPriceE, OBJPROP_FONT, NOFont);
    ObjectSetString(0, NewOrderLinesSLPriceE, OBJPROP_TEXT, TextSLPriceE);
    ObjectSet(NewOrderLinesSLPriceE, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, NewOrderLinesSLPriceE, OBJPROP_COLOR, clrBlack);
    j++;

    ObjectCreate(0, NewOrderLinesTPPrice, OBJ_EDIT, 0, 0, 0);
    ObjectSet(NewOrderLinesTPPrice, OBJPROP_XDISTANCE, NewOrderLinesXoff + 2);
    ObjectSet(NewOrderLinesTPPrice, OBJPROP_YDISTANCE, NewOrderLinesYoff + 2 + (NewOrderLinesLabelY + 1) * j);
    ObjectSetInteger(0, NewOrderLinesTPPrice, OBJPROP_XSIZE, NewOrderLinesDoubleX);
    ObjectSetInteger(0, NewOrderLinesTPPrice, OBJPROP_YSIZE, NewOrderLinesLabelY);
    ObjectSetInteger(0, NewOrderLinesTPPrice, OBJPROP_BORDER_TYPE, BORDER_FLAT);
    ObjectSetInteger(0, NewOrderLinesTPPrice, OBJPROP_STATE, false);
    ObjectSetInteger(0, NewOrderLinesTPPrice, OBJPROP_HIDDEN, true);
    ObjectSetInteger(0, NewOrderLinesTPPrice, OBJPROP_READONLY, true);
    ObjectSetInteger(0, NewOrderLinesTPPrice, OBJPROP_FONTSIZE, NOFontSize);
    ObjectSetString(0, NewOrderLinesTPPrice, OBJPROP_TOOLTIP, "Take Profit Price - Click To Create Line");
    ObjectSetInteger(0, NewOrderLinesTPPrice, OBJPROP_ALIGN, ALIGN_CENTER);
    ObjectSetString(0, NewOrderLinesTPPrice, OBJPROP_FONT, NOFont);
    ObjectSetString(0, NewOrderLinesTPPrice, OBJPROP_TEXT, TextTPPrice);
    ObjectSet(NewOrderLinesTPPrice, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, NewOrderLinesTPPrice, OBJPROP_COLOR, clrBlack);

    ObjectCreate(0, NewOrderLinesTPPriceE, OBJ_EDIT, 0, 0, 0);
    ObjectSet(NewOrderLinesTPPriceE, OBJPROP_XDISTANCE, NewOrderLinesXoff + (NewOrderLinesDoubleX + 2) + 2);
    ObjectSet(NewOrderLinesTPPriceE, OBJPROP_YDISTANCE, NewOrderLinesYoff + 2 + (NewOrderLinesLabelY + 1) * j);
    ObjectSetInteger(0, NewOrderLinesTPPriceE, OBJPROP_XSIZE, NewOrderLinesDoubleX);
    ObjectSetInteger(0, NewOrderLinesTPPriceE, OBJPROP_YSIZE, NewOrderLinesLabelY);
    ObjectSetInteger(0, NewOrderLinesTPPriceE, OBJPROP_BORDER_TYPE, BORDER_FLAT);
    ObjectSetInteger(0, NewOrderLinesTPPriceE, OBJPROP_STATE, false);
    ObjectSetInteger(0, NewOrderLinesTPPriceE, OBJPROP_HIDDEN, true);
    ObjectSetInteger(0, NewOrderLinesTPPriceE, OBJPROP_READONLY, false);
    ObjectSetInteger(0, NewOrderLinesTPPriceE, OBJPROP_FONTSIZE, NOFontSize);
    ObjectSetString(0, NewOrderLinesTPPriceE, OBJPROP_TOOLTIP, "Take Profit Price");
    ObjectSetInteger(0, NewOrderLinesTPPriceE, OBJPROP_ALIGN, ALIGN_CENTER);
    ObjectSetString(0, NewOrderLinesTPPriceE, OBJPROP_FONT, NOFont);
    ObjectSetString(0, NewOrderLinesTPPriceE, OBJPROP_TEXT, TextTPPriceE);
    ObjectSet(NewOrderLinesTPPriceE, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, NewOrderLinesTPPriceE, OBJPROP_COLOR, clrBlack);
    j++;

    ObjectCreate(0, NewOrderLinesMagic, OBJ_EDIT, 0, 0, 0);
    ObjectSet(NewOrderLinesMagic, OBJPROP_XDISTANCE, NewOrderLinesXoff + 2);
    ObjectSet(NewOrderLinesMagic, OBJPROP_YDISTANCE, NewOrderLinesYoff + 2 + (NewOrderLinesLabelY + 1) * j);
    ObjectSetInteger(0, NewOrderLinesMagic, OBJPROP_XSIZE, NewOrderLinesDoubleX);
    ObjectSetInteger(0, NewOrderLinesMagic, OBJPROP_YSIZE, NewOrderLinesLabelY);
    ObjectSetInteger(0, NewOrderLinesMagic, OBJPROP_BORDER_TYPE, BORDER_FLAT);
    ObjectSetInteger(0, NewOrderLinesMagic, OBJPROP_STATE, false);
    ObjectSetInteger(0, NewOrderLinesMagic, OBJPROP_HIDDEN, true);
    ObjectSetInteger(0, NewOrderLinesMagic, OBJPROP_READONLY, true);
    ObjectSetInteger(0, NewOrderLinesMagic, OBJPROP_FONTSIZE, NOFontSize);
    ObjectSetString(0, NewOrderLinesMagic, OBJPROP_TOOLTIP, "Magic Number");
    ObjectSetInteger(0, NewOrderLinesMagic, OBJPROP_ALIGN, ALIGN_CENTER);
    ObjectSetString(0, NewOrderLinesMagic, OBJPROP_FONT, NOFont);
    ObjectSetString(0, NewOrderLinesMagic, OBJPROP_TEXT, "MAGIC #");
    ObjectSet(NewOrderLinesMagic, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, NewOrderLinesMagic, OBJPROP_COLOR, clrBlack);

    ObjectCreate(0, NewOrderLinesMagicE, OBJ_EDIT, 0, 0, 0);
    ObjectSet(NewOrderLinesMagicE, OBJPROP_XDISTANCE, NewOrderLinesXoff + (NewOrderLinesDoubleX + 2) + 2);
    ObjectSet(NewOrderLinesMagicE, OBJPROP_YDISTANCE, NewOrderLinesYoff + 2 + (NewOrderLinesLabelY + 1) * j);
    ObjectSetInteger(0, NewOrderLinesMagicE, OBJPROP_XSIZE, NewOrderLinesDoubleX);
    ObjectSetInteger(0, NewOrderLinesMagicE, OBJPROP_YSIZE, NewOrderLinesLabelY);
    ObjectSetInteger(0, NewOrderLinesMagicE, OBJPROP_BORDER_TYPE, BORDER_FLAT);
    ObjectSetInteger(0, NewOrderLinesMagicE, OBJPROP_STATE, false);
    ObjectSetInteger(0, NewOrderLinesMagicE, OBJPROP_HIDDEN, true);
    ObjectSetInteger(0, NewOrderLinesMagicE, OBJPROP_READONLY, false);
    ObjectSetInteger(0, NewOrderLinesMagicE, OBJPROP_FONTSIZE, NOFontSize);
    ObjectSetString(0, NewOrderLinesMagicE, OBJPROP_TOOLTIP, "Magic Number for the order - Click to change");
    ObjectSetInteger(0, NewOrderLinesMagicE, OBJPROP_ALIGN, ALIGN_CENTER);
    ObjectSetString(0, NewOrderLinesMagicE, OBJPROP_FONT, NOFont);
    ObjectSetString(0, NewOrderLinesMagicE, OBJPROP_TEXT, TextMagic);
    ObjectSet(NewOrderLinesMagicE, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, NewOrderLinesMagicE, OBJPROP_COLOR, clrBlack);
    j++;

    ObjectCreate(0, NewOrderLinesComment, OBJ_EDIT, 0, 0, 0);
    ObjectSet(NewOrderLinesComment, OBJPROP_XDISTANCE, NewOrderLinesXoff + 2);
    ObjectSet(NewOrderLinesComment, OBJPROP_YDISTANCE, NewOrderLinesYoff + 2 + (NewOrderLinesLabelY + 1) * j);
    ObjectSetInteger(0, NewOrderLinesComment, OBJPROP_XSIZE, NewOrderLinesMonoX);
    ObjectSetInteger(0, NewOrderLinesComment, OBJPROP_YSIZE, NewOrderLinesLabelY);
    ObjectSetInteger(0, NewOrderLinesComment, OBJPROP_BORDER_TYPE, BORDER_FLAT);
    ObjectSetInteger(0, NewOrderLinesComment, OBJPROP_STATE, false);
    ObjectSetInteger(0, NewOrderLinesComment, OBJPROP_HIDDEN, true);
    ObjectSetInteger(0, NewOrderLinesComment, OBJPROP_READONLY, true);
    ObjectSetInteger(0, NewOrderLinesComment, OBJPROP_FONTSIZE, NOFontSize);
    ObjectSetString(0, NewOrderLinesComment, OBJPROP_TOOLTIP, "Comment for the order");
    ObjectSetInteger(0, NewOrderLinesComment, OBJPROP_ALIGN, ALIGN_CENTER);
    ObjectSetString(0, NewOrderLinesComment, OBJPROP_FONT, NOFont);
    ObjectSetString(0, NewOrderLinesComment, OBJPROP_TEXT, "COMMENT");
    ObjectSet(NewOrderLinesComment, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, NewOrderLinesComment, OBJPROP_COLOR, clrBlack);
    j++;

    ObjectCreate(0, NewOrderLinesCommentE, OBJ_EDIT, 0, 0, 0);
    ObjectSet(NewOrderLinesCommentE, OBJPROP_XDISTANCE, NewOrderLinesXoff + 2);
    ObjectSet(NewOrderLinesCommentE, OBJPROP_YDISTANCE, NewOrderLinesYoff + 2 + (NewOrderLinesLabelY + 1) * j);
    ObjectSetInteger(0, NewOrderLinesCommentE, OBJPROP_XSIZE, NewOrderLinesMonoX);
    ObjectSetInteger(0, NewOrderLinesCommentE, OBJPROP_YSIZE, NewOrderLinesLabelY);
    ObjectSetInteger(0, NewOrderLinesCommentE, OBJPROP_BORDER_TYPE, BORDER_FLAT);
    ObjectSetInteger(0, NewOrderLinesCommentE, OBJPROP_STATE, false);
    ObjectSetInteger(0, NewOrderLinesCommentE, OBJPROP_HIDDEN, true);
    ObjectSetInteger(0, NewOrderLinesCommentE, OBJPROP_READONLY, false);
    ObjectSetInteger(0, NewOrderLinesCommentE, OBJPROP_FONTSIZE, NOFontSize);
    ObjectSetString(0, NewOrderLinesCommentE, OBJPROP_TOOLTIP, "Comment for the order - Click to change");
    ObjectSetInteger(0, NewOrderLinesCommentE, OBJPROP_ALIGN, ALIGN_CENTER);
    ObjectSetString(0, NewOrderLinesCommentE, OBJPROP_FONT, NOFont);
    ObjectSetString(0, NewOrderLinesCommentE, OBJPROP_TEXT, TextComment);
    ObjectSet(NewOrderLinesCommentE, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, NewOrderLinesCommentE, OBJPROP_COLOR, clrBlack);
    j++;

    ObjectCreate(0, NewOrderLinesSubmit, OBJ_EDIT, 0, 0, 0);
    ObjectSet(NewOrderLinesSubmit, OBJPROP_XDISTANCE, NewOrderLinesXoff + 2);
    ObjectSet(NewOrderLinesSubmit, OBJPROP_YDISTANCE, NewOrderLinesYoff + 2 + (NewOrderLinesLabelY + 1) * j);
    ObjectSetInteger(0, NewOrderLinesSubmit, OBJPROP_XSIZE, NewOrderLinesMonoX);
    ObjectSetInteger(0, NewOrderLinesSubmit, OBJPROP_YSIZE, NewOrderLinesLabelY);
    ObjectSetInteger(0, NewOrderLinesSubmit, OBJPROP_BORDER_TYPE, BORDER_FLAT);
    ObjectSetInteger(0, NewOrderLinesSubmit, OBJPROP_STATE, false);
    ObjectSetInteger(0, NewOrderLinesSubmit, OBJPROP_HIDDEN, true);
    ObjectSetInteger(0, NewOrderLinesSubmit, OBJPROP_READONLY, true);
    ObjectSetInteger(0, NewOrderLinesSubmit, OBJPROP_FONTSIZE, NOFontSize);
    ObjectSetString(0, NewOrderLinesSubmit, OBJPROP_TOOLTIP, "Submit Order Or Orders");
    ObjectSetInteger(0, NewOrderLinesSubmit, OBJPROP_ALIGN, ALIGN_CENTER);
    ObjectSetString(0, NewOrderLinesSubmit, OBJPROP_FONT, NOFont);
    ObjectSetString(0, NewOrderLinesSubmit, OBJPROP_TEXT, "SUBMIT");
    ObjectSet(NewOrderLinesSubmit, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, NewOrderLinesSubmit, OBJPROP_COLOR, clrBlack);
    ObjectSetInteger(0, NewOrderLinesSubmit, OBJPROP_BGCOLOR, clrPaleGreen);
    ObjectSetInteger(0, NewOrderLinesSubmit, OBJPROP_BORDER_COLOR, clrBlack);
    j++;

    if (ShowURL)
    {
        ObjectCreate(0, NewOrderLinesURL, OBJ_EDIT, 0, 0, 0);
        ObjectSet(NewOrderLinesURL, OBJPROP_XDISTANCE, NewOrderLinesXoff + 2);
        ObjectSet(NewOrderLinesURL, OBJPROP_YDISTANCE, NewOrderLinesYoff + 2 + (NewOrderLinesLabelY + 1) * j);
        ObjectSetInteger(0, NewOrderLinesURL, OBJPROP_XSIZE, NewOrderLinesMonoX);
        ObjectSetInteger(0, NewOrderLinesURL, OBJPROP_YSIZE, NewOrderLinesLabelY);
        ObjectSetInteger(0, NewOrderLinesURL, OBJPROP_BORDER_TYPE, BORDER_FLAT);
        ObjectSetInteger(0, NewOrderLinesURL, OBJPROP_STATE, false);
        ObjectSetInteger(0, NewOrderLinesURL, OBJPROP_HIDDEN, true);
        ObjectSetInteger(0, NewOrderLinesURL, OBJPROP_READONLY, true);
        ObjectSetInteger(0, NewOrderLinesURL, OBJPROP_FONTSIZE, NOFontSize);
        ObjectSetString(0, NewOrderLinesURL, OBJPROP_TOOLTIP, "Visit Us");
        ObjectSetInteger(0, NewOrderLinesURL, OBJPROP_ALIGN, ALIGN_CENTER);
        ObjectSetString(0, NewOrderLinesURL, OBJPROP_FONT, NOFont);
        ObjectSetString(0, NewOrderLinesURL, OBJPROP_TEXT, "EarnForex.com");
        ObjectSet(NewOrderLinesURL, OBJPROP_SELECTABLE, false);
        ObjectSetInteger(0, NewOrderLinesURL, OBJPROP_COLOR, clrNavy);
        ObjectSetInteger(0, NewOrderLinesURL, OBJPROP_BGCOLOR, clrKhaki);
        ObjectSetInteger(0, NewOrderLinesURL, OBJPROP_BORDER_COLOR, clrBlack);
        j++;
    }

    NewOrderLinesY = (NewOrderLinesLabelY + 1) * j + 3;
    ObjectSetInteger(0, NewOrderLinesBase, OBJPROP_YSIZE, NewOrderLinesY);
}

void CloseNewOrderLines()
{
    ObjectsDeleteAll(0, IndicatorName + "-NOL-");
    NewOrderLinesPanelIsOpen = false;
}

void ChangeLinesOrderSide()
{
    if (CurrLinesSide == LINE_ORDER_BUY)
    {
        CurrLinesSide = LINE_ORDER_SELL;
        CloseNewOrderLines();
        ShowNewOrderLines();
        return;
    }
    else if (CurrLinesSide == LINE_ORDER_SELL)
    {
        CurrLinesSide = LINE_ORDER_BUY;
        CloseNewOrderLines();
        ShowNewOrderLines();
        return;
    }
}

void ChangeLinesOrderType()
{
    if (CurrLinesType == LINE_ORDER_MARKET)
    {
        CurrLinesType = LINE_ORDER_STOP;
        CreateNewOrderLine(LINE_OPEN_PRICE);
        CloseNewOrderLines();
        ShowNewOrderLines();
        return;
    }
    else if (CurrLinesType == LINE_ORDER_STOP)
    {
        CurrLinesType = LINE_ORDER_LIMIT;
        CreateNewOrderLine(LINE_OPEN_PRICE);
        CloseNewOrderLines();
        ShowNewOrderLines();
        return;
    }
    else if (CurrLinesType == LINE_ORDER_LIMIT)
    {
        CurrLinesType = LINE_ORDER_MARKET;
        DeleteNewOrderLine(LINE_OPEN_PRICE);
        CloseNewOrderLines();
        ShowNewOrderLines();
        return;
    }
}

void DeleteNewOrderLine(ENUM_LINE_TYPE Type)
{
    string TextType = "";
    if (Type == LINE_ALL)
    {
        DeleteNewOrderLine(LINE_OPEN_PRICE);
        DeleteNewOrderLine(LINE_TP_PRICE);
        DeleteNewOrderLine(LINE_SL_PRICE);
    }
    else if (Type == LINE_OPEN_PRICE) TextType = "OPEN";
    else if (Type == LINE_TP_PRICE) TextType = "TP";
    else if (Type == LINE_SL_PRICE) TextType = "SL";

    ObjectsDeleteAll(0, IndicatorName + "-NOL-H-" + TextType);

    DeleteLineLabels();
}

void UpdateLinesDeleted(string LineName)
{
    if (NewOrderLinesPanelIsOpen)
    {
        if (LineName == LineNameOpen)
        {
            CurrLinesType = LINE_ORDER_MARKET;
            ShowNewOrderLines();
        }
        else if (LineName == LineNameSL)
        {
            CurrSLPrice = 0;
            ShowNewOrderLines();
        }
        else if (LineName == LineNameTP)
        {
            CurrTPPrice = 0;
            ShowNewOrderLines();
        }
        UpdateLinesLabels();
    }
}

string LineNameOpen = IndicatorName + "-NOL-H-OPEN";
string LineNameSL = IndicatorName + "-NOL-H-SL";
string LineNameTP = IndicatorName + "-NOL-H-TP";
void CreateNewOrderLine(ENUM_LINE_TYPE Type)
{
    string TextType = "";
    color LineColor = clrNONE;
    double LinePrice = 0;
    string LineName = "";
    if (Type == LINE_OPEN_PRICE)
    {
        LineName = LineNameOpen;
        LineColor = LineOpenPriceColor;
        LinePrice = Close[0];
        TextType = "OPEN-PRICE";
    }
    else if (Type == LINE_TP_PRICE)
    {
        LineName = LineNameTP;
        LineColor = LineTPPriceColor;
        LinePrice = CurrTPPrice;
        TextType = "TP-PRICE";
    }
    else if (Type == LINE_SL_PRICE)
    {
        LineName = LineNameSL;
        LineColor = LineSLPriceColor;
        LinePrice = CurrSLPrice;
        TextType = "SL-PRICE";
    }
    int Window = 0;
    ObjectsDeleteAll(ChartID(), LineName, Window, OBJ_HLINE);
    ObjectCreate(0, LineName, OBJ_HLINE, 0, 0, LinePrice);
    ObjectSetString(0, LineName, OBJPROP_TEXT, "LINE-" + TextType);
    ObjectSet(LineName, OBJPROP_COLOR, LineColor);
    ObjectSet(LineName, OBJPROP_STYLE, LineStyle);
    ObjectSet(LineName, OBJPROP_BACK, false);
    ObjectSet(LineName, OBJPROP_SELECTABLE, true);
    ObjectSet(LineName, OBJPROP_HIDDEN, false);
    UpdateLinesLabels();
}

void ClickNewOrderLinesSLPrice()
{
    bool LineExist = false;
    string LineName = LineNameSL;
    int Window = 0;
    for (int i = ObjectsTotal(ChartID(), Window, -1) - 1; i >= 0; i--)
    {
        if ((StringFind(ObjectName(i), LineName, 0) >= 0))
        {
            LineExist = true;
        }
    }
    if (LineExist)
    {
        CurrSLPrice = 0;
        ObjectDelete(0, LineName);
        ShowNewOrderLines();
    }
    else
    {
        if (CurrLinesSide == LINE_ORDER_BUY)
        {
            CurrSLPrice = Low[0];
        }
        if (CurrLinesSide == LINE_ORDER_SELL)
        {
            CurrSLPrice = High[0];
        }
        CreateNewOrderLine(LINE_SL_PRICE);
        ShowNewOrderLines();
    }
}

void ClickNewOrderLinesTPPrice()
{
    bool LineExist = false;
    string LineName = LineNameTP;
    int Window = 0;
    for (int i = ObjectsTotal(ChartID(), Window, -1) - 1; i >= 0; i--)
    {
        if ((StringFind(ObjectName(i), LineName, 0) >= 0))
        {
            LineExist = true;
        }
    }
    if (LineExist)
    {
        CurrTPPrice = 0;
        ObjectDelete(0, LineName);
        ShowNewOrderLines();
    }
    else
    {
        if (CurrLinesSide == LINE_ORDER_BUY)
        {
            CurrTPPrice = High[0];
        }
        else if (CurrLinesSide == LINE_ORDER_SELL)
        {
            CurrTPPrice = Low[0];
        }
        CreateNewOrderLine(LINE_TP_PRICE);
        ShowNewOrderLines();
    }
}

void UpdatePriceByLine(string LineName)
{
    if (NewOrderLinesPanelIsOpen)
    {
        if (LineName == LineNameOpen)
        {
            CurrOpenPrice = NormalizeDouble(ObjectGetDouble(0, LineName, OBJPROP_PRICE, 0), Digits);
            ShowNewOrderLines();
        }
        else if (LineName == LineNameSL)
        {
            CurrSLPrice = NormalizeDouble(ObjectGetDouble(0, LineName, OBJPROP_PRICE, 0), Digits);
            ShowNewOrderLines();
        }
        else if (LineName == LineNameTP)
        {
            CurrTPPrice = NormalizeDouble(ObjectGetDouble(0, LineName, OBJPROP_PRICE, 0), Digits);
            ShowNewOrderLines();
        }
    }
}

void UpdateLineByPrice(string LineName)
{
    if (LineName == LineNameOpen)
    {
        bool LineExist = false;
        int Window = 0;
        for (int i = ObjectsTotal(ChartID(), Window, -1) - 1; i >= 0; i--)
        {
            if ((StringFind(ObjectName(i), LineName, 0) >= 0))
            {
                LineExist = true;
                break;
            }
        }
        if (LineExist) ObjectSetDouble(0, LineName, OBJPROP_PRICE, CurrOpenPrice);
        else CreateNewOrderLine(LINE_OPEN_PRICE);
    }
    else if (LineName == LineNameSL)
    {
        bool LineExist = false;
        int Window = 0;
        for (int i = ObjectsTotal(ChartID(), Window, -1) - 1; i >= 0; i--)
        {
            if ((StringFind(ObjectName(i), LineName, 0) >= 0))
            {
                LineExist = true;
                break;
            }
        }
        if (LineExist) ObjectSetDouble(0, LineName, OBJPROP_PRICE, CurrSLPrice);
        else CreateNewOrderLine(LINE_SL_PRICE);
    }
    else if (LineName == LineNameTP)
    {
        bool LineExist = false;
        int Window = 0;
        for (int i = ObjectsTotal(ChartID(), Window, -1) - 1; i >= 0; i--)
        {
            if ((StringFind(ObjectName(i), LineName, 0) >= 0))
            {
                LineExist = true;
                break;
            }
        }
        if (LineExist) ObjectSetDouble(0, LineName, OBJPROP_PRICE, CurrTPPrice);
        else CreateNewOrderLine(LINE_TP_PRICE);
    }
    UpdateLinesLabels();
}


string LineLabelNameOpen = IndicatorName + "-NOL-HLAB-OPEN";
string LineLabelNameSL = IndicatorName + "-NOL-HLAB-SL";
string LineLabelNameTP = IndicatorName + "-NOL-HLAB-TP";
void UpdateLinesLabels()
{
    DeleteLineLabels();
    int XLab = (int)MathRound(200 * DPIScale);
    int YLab = (int)MathRound(20 * DPIScale);
    double Loss = 0;
    double Profit = 0;
    double Ratio = 0;
    double LossPts = 0;
    double ProfitPts = 0;
    double LossCurrency = 0;
    double ProfitCurrency = 0;
    double OpenPrice = 0;
    string OpenText = "";
    string SLText = "";
    string TPText = "";
    string OpenTextTip = "";
    string SLTextTip = "";
    string TPTextTip = "";
    RefreshRates();
    if ((CurrLinesSide == LINE_ORDER_BUY) && (CurrLinesType == LINE_ORDER_MARKET))
    {
        OpenPrice = Ask;
    }
    else if ((CurrLinesSide == LINE_ORDER_SELL) && (CurrLinesType == LINE_ORDER_MARKET))
    {
        OpenPrice = Bid;
    }
    if (CurrLinesType != LINE_ORDER_MARKET)
    {
        OpenPrice = CurrOpenPrice;
    }
    if (CurrLinesSide == LINE_ORDER_BUY)
    {
        if (CurrSLPrice != 0) LossPts = (OpenPrice - CurrSLPrice) / Point;
        if (CurrTPPrice != 0) ProfitPts = (CurrTPPrice - OpenPrice) / Point;
    }
    else if (CurrLinesSide == LINE_ORDER_SELL)
    {
        if (CurrSLPrice != 0) LossPts = (CurrSLPrice - OpenPrice) / Point;
        if (CurrTPPrice != 0) ProfitPts = (OpenPrice - CurrTPPrice) / Point;
    }
    if ((LossPts > 0) || ((LossPts == 0) && (CurrSLPrice != 0)))
    {
        LossCurrency = NormalizeDouble(LossPts * CurrLotSize * MarketInfo(Symbol(), MODE_TICKVALUE), 2);
        SLText = "LOSS - " + DoubleToString(LossPts, 0) + " Pts - " + DoubleToString(LossCurrency, 2) + " " + AccountCurrency();
        SLTextTip = "Possible Loss Of - " + DoubleToString(LossPts, 0) + " Points - " + DoubleToString(LossCurrency, 2) + " " + AccountCurrency();
    }
    if ((ProfitPts > 0) || ((ProfitPts == 0) && (CurrTPPrice != 0)))
    {
        ProfitCurrency = NormalizeDouble(ProfitPts * CurrLotSize * MarketInfo(Symbol(), MODE_TICKVALUE), 2);
        TPText = "PROFIT - " + DoubleToString(ProfitPts, 0) + " Pts - " + DoubleToString(ProfitCurrency, 2) + " " + AccountCurrency();
        TPTextTip = "Possible Profit Of - " + DoubleToString(ProfitPts, 0) + " Points - " + DoubleToString(ProfitCurrency, 2) + " " + AccountCurrency();
    }
    if ((LossPts > 0) && (ProfitPts > 0))
    {
        Ratio = NormalizeDouble(ProfitPts / LossPts, 2);
        OpenText = "R/R RATIO : 1 / " + DoubleToString(Ratio, 2);
        OpenTextTip = "This trade has a risk-reward ratio of 1 to " + DoubleToString(Ratio, 2);
    }
    if (LossPts < 0)
    {
        SLText = "SL NOT VALID";
        SLTextTip = "The stop-loss value is in a wrong position, please check.";
    }
    if (ProfitPts < 0)
    {
        TPText = "TP NOT VALID";
        TPTextTip = "The take-profit value is in a wrong position, please check.";
    }
    if (Ratio != 0)
    {
        int XStart = (int)MathRound(220 * DPIScale);
        int YStart = 0;
        ChartTimePriceToXY(0, 0, Time[0], OpenPrice, XStart, YStart);
        XStart = 220;
        DrawEdit(LineLabelNameOpen,
                 XStart,
                 YStart,
                 XLab,
                 YLab,
                 true,
                 8,
                 OpenTextTip,
                 ALIGN_CENTER,
                 "Consolas",
                 OpenText,
                 false,
                 LineOpenPriceColor);
        ObjectSetInteger(0, LineLabelNameOpen, OBJPROP_CORNER, CORNER_RIGHT_UPPER);
    }
    if ((LossPts != 0) || ((LossPts == 0) && (CurrSLPrice != 0)))
    {
        int XStart = (int)MathRound(220 * DPIScale);
        int YStart = 0;
        ChartTimePriceToXY(0, 0, Time[0], CurrSLPrice, XStart, YStart);
        XStart = 220;
        DrawEdit(LineLabelNameSL,
                 XStart,
                 YStart,
                 XLab,
                 YLab,
                 true,
                 8,
                 SLTextTip,
                 ALIGN_CENTER,
                 "Consolas",
                 SLText,
                 false,
                 LineSLPriceColor);
        ObjectSetInteger(0, LineLabelNameSL, OBJPROP_CORNER, CORNER_RIGHT_UPPER);
    }
    if ((ProfitPts != 0) || ((ProfitPts == 0) && (CurrTPPrice != 0)))
    {
        int XStart = (int)MathRound(220 * DPIScale);
        int YStart = 0;
        ChartTimePriceToXY(0, 0, Time[0], CurrTPPrice, XStart, YStart);
        XStart = 220;
        DrawEdit(LineLabelNameTP,
                 XStart,
                 YStart,
                 XLab,
                 YLab,
                 true,
                 8,
                 TPTextTip,
                 ALIGN_CENTER,
                 "Consolas",
                 TPText,
                 false,
                 LineTPPriceColor);
        ObjectSetInteger(0, LineLabelNameTP, OBJPROP_CORNER, CORNER_RIGHT_UPPER);
    }
}

void DeleteLineLabels()
{
    ObjectsDeleteAll(0, IndicatorName + "-NOL-HLAB-");
}

string DetailsBase = IndicatorName + "-D-Base";
string DetailsEdit = IndicatorName + "-D-Edit";
string DetailsClose = IndicatorName + "-D-Close";
string DetailsPage = IndicatorName + "-D-Page";
string DetailsPrev = IndicatorName + "-D-Prev";
string DetailsNext = IndicatorName + "-D-Next";
string DetailsOrderNumber = IndicatorName + "-D-OrderNumber";
string DetailsOrderDate = IndicatorName + "-D-OrderDate";
string DetailsOrderTime = IndicatorName + "-D-OrderTime";
string DetailsOrderMagic = IndicatorName + "-D-OrderMagic";
string DetailsOrderSymbol = IndicatorName + "-D-OrderSymbol";
string DetailsOrderType = IndicatorName + "-D-OrderType";
string DetailsOrderSize = IndicatorName + "-D-OrderSize";
string DetailsOrderPrice = IndicatorName + "-D-OrderPrice";
string DetailsOrderSL = IndicatorName + "-D-OrderSL";
string DetailsOrderTP = IndicatorName + "-D-OrderTP";
string DetailsOrderProfit = IndicatorName + "-D-OrderProfit";
string DetailsOrderComment = IndicatorName + "-D-OrderCmnt";
string DetFont = "Consolas";
int TotPages = 0;
int MaxOrdersPerPage = OrdersPerPage;
// Shows a panel with a list of current orders.
void ShowDetails(int CurrPage = 1)
{
    ExitEdit();
    CloseSettings();
    CloseNewOrder();
    ScanOrders();
    int DetXoff = Xoff;
    int DetYoff = Yoff + PanelMovY + 2 * 4;
    MaxOrdersPerPage = OrdersPerPage;
    int DetX = 0;
    int DetY = 0;
    int OrdersThisPage = 0;
    CurrentPage = CurrPage;
    TotPages = (int)MathCeil((double)TotalOrders / (double)MaxOrdersPerPage);
    if ((TotalOrders > 0) && ((MathMod(TotalOrders, MaxOrdersPerPage) == 0) || (CurrPage < TotPages)))
    {
        OrdersThisPage = MaxOrdersPerPage;
    }
    if ((TotalOrders > 0) && (MathMod(TotalOrders, MaxOrdersPerPage) > 0) && (CurrPage == TotPages))
    {
        OrdersThisPage = (int)MathMod(TotalOrders, MaxOrdersPerPage);
    }
    int IndexFirstOrder = (CurrPage - 1) * MaxOrdersPerPage;
    if (TotalOrders == 0)
    {
        DetX = (DetButtonX + 2) * 2 + 2;
        DetY = DetButtonY + 2 * 2;
    }
    else
    {
        DetX = (DetGLabelX + 2) * 11 + DetCmntLabelX + 4;
        DetY = DetButtonY + (DetGLabelY + 5) * (OrdersThisPage + 1) + 10 + 7;
    }
    ObjectCreate(0, DetailsBase, OBJ_RECTANGLE_LABEL, 0, 0, 0);
    ObjectSet(DetailsBase, OBJPROP_XDISTANCE, DetXoff);
    ObjectSet(DetailsBase, OBJPROP_YDISTANCE, DetYoff);
    ObjectSetInteger(0, DetailsBase, OBJPROP_XSIZE, DetX);
    ObjectSetInteger(0, DetailsBase, OBJPROP_YSIZE, DetY);
    ObjectSetInteger(0, DetailsBase, OBJPROP_BGCOLOR, clrWhite);
    ObjectSetInteger(0, DetailsBase, OBJPROP_BORDER_TYPE, BORDER_FLAT);
    ObjectSetInteger(0, DetailsBase, OBJPROP_STATE, false);
    ObjectSetInteger(0, DetailsBase, OBJPROP_HIDDEN, true);
    ObjectSetInteger(0, DetailsBase, OBJPROP_FONTSIZE, NOFontSize);
    ObjectSet(DetailsBase, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, DetailsBase, OBJPROP_COLOR, clrBlack);

    ObjectCreate(0, DetailsEdit, OBJ_EDIT, 0, 0, 0);
    ObjectSet(DetailsEdit, OBJPROP_XDISTANCE, DetXoff + 2);
    ObjectSet(DetailsEdit, OBJPROP_YDISTANCE, DetYoff + 2);
    ObjectSetInteger(0, DetailsEdit, OBJPROP_XSIZE, DetButtonX);
    ObjectSetInteger(0, DetailsEdit, OBJPROP_YSIZE, DetButtonY);
    ObjectSetInteger(0, DetailsEdit, OBJPROP_BORDER_TYPE, BORDER_FLAT);
    ObjectSetInteger(0, DetailsEdit, OBJPROP_STATE, false);
    ObjectSetInteger(0, DetailsEdit, OBJPROP_HIDDEN, true);
    ObjectSetInteger(0, DetailsEdit, OBJPROP_READONLY, true);
    ObjectSetInteger(0, DetailsEdit, OBJPROP_FONTSIZE, NOFontSize);
    ObjectSetString(0, DetailsEdit, OBJPROP_TOOLTIP, "Edit Orders");
    ObjectSetInteger(0, DetailsEdit, OBJPROP_ALIGN, ALIGN_CENTER);
    ObjectSetString(0, DetailsEdit, OBJPROP_FONT, DetFont);
    ObjectSetString(0, DetailsEdit, OBJPROP_TEXT, "Edit");
    ObjectSet(DetailsEdit, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, DetailsEdit, OBJPROP_COLOR, clrBlack);
    ObjectSetInteger(0, DetailsEdit, OBJPROP_BGCOLOR, clrPaleGreen);
    ObjectSetInteger(0, DetailsEdit, OBJPROP_BORDER_COLOR, clrBlack);

    ObjectCreate(0, DetailsClose, OBJ_EDIT, 0, 0, 0);
    ObjectSet(DetailsClose, OBJPROP_XDISTANCE, DetXoff + (DetButtonX + 2) + 2);
    ObjectSet(DetailsClose, OBJPROP_YDISTANCE, DetYoff + 2);
    ObjectSetInteger(0, DetailsClose, OBJPROP_XSIZE, DetButtonX);
    ObjectSetInteger(0, DetailsClose, OBJPROP_YSIZE, DetButtonY);
    ObjectSetInteger(0, DetailsClose, OBJPROP_BORDER_TYPE, BORDER_FLAT);
    ObjectSetInteger(0, DetailsClose, OBJPROP_STATE, false);
    ObjectSetInteger(0, DetailsClose, OBJPROP_HIDDEN, true);
    ObjectSetInteger(0, DetailsClose, OBJPROP_READONLY, true);
    ObjectSetInteger(0, DetailsClose, OBJPROP_FONTSIZE, NOFontSize);
    ObjectSetString(0, DetailsClose, OBJPROP_TOOLTIP, "Close Details Panel");
    ObjectSetInteger(0, DetailsClose, OBJPROP_ALIGN, ALIGN_CENTER);
    ObjectSetString(0, DetailsClose, OBJPROP_FONT, DetFont);
    ObjectSetString(0, DetailsClose, OBJPROP_TEXT, "X");
    ObjectSet(DetailsClose, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, DetailsClose, OBJPROP_COLOR, clrBlack);
    ObjectSetInteger(0, DetailsClose, OBJPROP_BGCOLOR, clrCrimson);
    ObjectSetInteger(0, DetailsClose, OBJPROP_BORDER_COLOR, clrBlack);

    if (TotPages > 1)
    {
        string TextPage = IntegerToString(CurrPage) + " / " + IntegerToString(TotPages);
        ObjectCreate(0, DetailsPage, OBJ_EDIT, 0, 0, 0);
        ObjectSet(DetailsPage, OBJPROP_XDISTANCE, DetXoff + (DetButtonX + 2) * 5 + 2);
        ObjectSet(DetailsPage, OBJPROP_YDISTANCE, DetYoff + 2);
        ObjectSetInteger(0, DetailsPage, OBJPROP_XSIZE, DetButtonX);
        ObjectSetInteger(0, DetailsPage, OBJPROP_YSIZE, DetButtonY);
        ObjectSetInteger(0, DetailsPage, OBJPROP_BORDER_TYPE, BORDER_FLAT);
        ObjectSetInteger(0, DetailsPage, OBJPROP_STATE, false);
        ObjectSetInteger(0, DetailsPage, OBJPROP_HIDDEN, true);
        ObjectSetInteger(0, DetailsPage, OBJPROP_READONLY, true);
        ObjectSetInteger(0, DetailsPage, OBJPROP_FONTSIZE, NOFontSize);
        ObjectSetString(0, DetailsPage, OBJPROP_TOOLTIP, "Page");
        ObjectSetInteger(0, DetailsPage, OBJPROP_ALIGN, ALIGN_CENTER);
        ObjectSetString(0, DetailsPage, OBJPROP_FONT, DetFont);
        ObjectSetString(0, DetailsPage, OBJPROP_TEXT, TextPage);
        ObjectSet(DetailsPage, OBJPROP_SELECTABLE, false);
        ObjectSetInteger(0, DetailsPage, OBJPROP_COLOR, clrBlack);
        ObjectSetInteger(0, DetailsPage, OBJPROP_BGCOLOR, clrPaleGreen);
        ObjectSetInteger(0, DetailsPage, OBJPROP_BORDER_COLOR, clrBlack);

        ObjectCreate(0, DetailsPrev, OBJ_EDIT, 0, 0, 0);
        ObjectSet(DetailsPrev, OBJPROP_XDISTANCE, DetXoff + (DetButtonX + 2) * 4 + 2);
        ObjectSet(DetailsPrev, OBJPROP_YDISTANCE, DetYoff + 2);
        ObjectSetInteger(0, DetailsPrev, OBJPROP_XSIZE, DetButtonX);
        ObjectSetInteger(0, DetailsPrev, OBJPROP_YSIZE, DetButtonY);
        ObjectSetInteger(0, DetailsPrev, OBJPROP_BORDER_TYPE, BORDER_FLAT);
        ObjectSetInteger(0, DetailsPrev, OBJPROP_STATE, false);
        ObjectSetInteger(0, DetailsPrev, OBJPROP_HIDDEN, true);
        ObjectSetInteger(0, DetailsPrev, OBJPROP_READONLY, true);
        ObjectSetInteger(0, DetailsPrev, OBJPROP_FONTSIZE, NOFontSize);
        ObjectSetString(0, DetailsPrev, OBJPROP_TOOLTIP, "Go to previous page");
        ObjectSetInteger(0, DetailsPrev, OBJPROP_ALIGN, ALIGN_CENTER);
        ObjectSetString(0, DetailsPrev, OBJPROP_FONT, DetFont);
        ObjectSetString(0, DetailsPrev, OBJPROP_TEXT, "Prev");
        ObjectSet(DetailsPrev, OBJPROP_SELECTABLE, false);
        ObjectSetInteger(0, DetailsPrev, OBJPROP_COLOR, clrBlack);
        ObjectSetInteger(0, DetailsPrev, OBJPROP_BGCOLOR, clrPaleGreen);
        ObjectSetInteger(0, DetailsPrev, OBJPROP_BORDER_COLOR, clrBlack);

        ObjectCreate(0, DetailsNext, OBJ_EDIT, 0, 0, 0);
        ObjectSet(DetailsNext, OBJPROP_XDISTANCE, DetXoff + (DetButtonX + 2) * 6 + 2);
        ObjectSet(DetailsNext, OBJPROP_YDISTANCE, DetYoff + 2);
        ObjectSetInteger(0, DetailsNext, OBJPROP_XSIZE, DetButtonX);
        ObjectSetInteger(0, DetailsNext, OBJPROP_YSIZE, DetButtonY);
        ObjectSetInteger(0, DetailsNext, OBJPROP_BORDER_TYPE, BORDER_FLAT);
        ObjectSetInteger(0, DetailsNext, OBJPROP_STATE, false);
        ObjectSetInteger(0, DetailsNext, OBJPROP_HIDDEN, true);
        ObjectSetInteger(0, DetailsNext, OBJPROP_READONLY, true);
        ObjectSetInteger(0, DetailsNext, OBJPROP_FONTSIZE, NOFontSize);
        ObjectSetString(0, DetailsNext, OBJPROP_TOOLTIP, "Go to next page");
        ObjectSetInteger(0, DetailsNext, OBJPROP_ALIGN, ALIGN_CENTER);
        ObjectSetString(0, DetailsNext, OBJPROP_FONT, DetFont);
        ObjectSetString(0, DetailsNext, OBJPROP_TEXT, "Next");
        ObjectSet(DetailsNext, OBJPROP_SELECTABLE, false);
        ObjectSetInteger(0, DetailsNext, OBJPROP_COLOR, clrBlack);
        ObjectSetInteger(0, DetailsNext, OBJPROP_BGCOLOR, clrPaleGreen);
        ObjectSetInteger(0, DetailsNext, OBJPROP_BORDER_COLOR, clrBlack);
    }

    if (TotalOrders == 0) return;
    ObjectCreate(0, DetailsOrderNumber, OBJ_EDIT, 0, 0, 0);
    ObjectSet(DetailsOrderNumber, OBJPROP_XDISTANCE, DetXoff + 2);
    ObjectSet(DetailsOrderNumber, OBJPROP_YDISTANCE, (DetYoff + 2) + (DetButtonY + 2) + 10);
    ObjectSetInteger(0, DetailsOrderNumber, OBJPROP_XSIZE, DetGLabelX);
    ObjectSetInteger(0, DetailsOrderNumber, OBJPROP_YSIZE, DetGLabelY);
    ObjectSetInteger(0, DetailsOrderNumber, OBJPROP_BORDER_TYPE, BORDER_FLAT);
    ObjectSetInteger(0, DetailsOrderNumber, OBJPROP_STATE, false);
    ObjectSetInteger(0, DetailsOrderNumber, OBJPROP_HIDDEN, true);
    ObjectSetInteger(0, DetailsOrderNumber, OBJPROP_READONLY, true);
    ObjectSetInteger(0, DetailsOrderNumber, OBJPROP_FONTSIZE, NOFontSize);
    ObjectSetString(0, DetailsOrderNumber, OBJPROP_TOOLTIP, "Order Number");
    ObjectSetInteger(0, DetailsOrderNumber, OBJPROP_ALIGN, ALIGN_CENTER);
    ObjectSetString(0, DetailsOrderNumber, OBJPROP_FONT, DetFont);
    ObjectSetString(0, DetailsOrderNumber, OBJPROP_TEXT, "Order #");
    ObjectSet(DetailsOrderNumber, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, DetailsOrderNumber, OBJPROP_COLOR, clrBlack);
    ObjectSetInteger(0, DetailsOrderNumber, OBJPROP_BGCOLOR, clrLightCyan);
    ObjectSetInteger(0, DetailsOrderNumber, OBJPROP_BORDER_COLOR, clrBlack);

    ObjectCreate(0, DetailsOrderDate, OBJ_EDIT, 0, 0, 0);
    ObjectSet(DetailsOrderDate, OBJPROP_XDISTANCE, DetXoff + (DetGLabelX + 4));
    ObjectSet(DetailsOrderDate, OBJPROP_YDISTANCE, (DetYoff + 2) + (DetButtonY + 2) + 10);
    ObjectSetInteger(0, DetailsOrderDate, OBJPROP_XSIZE, DetGLabelX);
    ObjectSetInteger(0, DetailsOrderDate, OBJPROP_YSIZE, DetGLabelY);
    ObjectSetInteger(0, DetailsOrderDate, OBJPROP_BORDER_TYPE, BORDER_FLAT);
    ObjectSetInteger(0, DetailsOrderDate, OBJPROP_STATE, false);
    ObjectSetInteger(0, DetailsOrderDate, OBJPROP_HIDDEN, true);
    ObjectSetInteger(0, DetailsOrderDate, OBJPROP_READONLY, true);
    ObjectSetInteger(0, DetailsOrderDate, OBJPROP_FONTSIZE, NOFontSize);
    ObjectSetString(0, DetailsOrderDate, OBJPROP_TOOLTIP, "Open Order Date (YYYY/MM/DD) (Server Date)");
    ObjectSetInteger(0, DetailsOrderDate, OBJPROP_ALIGN, ALIGN_CENTER);
    ObjectSetString(0, DetailsOrderDate, OBJPROP_FONT, DetFont);
    ObjectSetString(0, DetailsOrderDate, OBJPROP_TEXT, "Date");
    ObjectSet(DetailsOrderDate, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, DetailsOrderDate, OBJPROP_COLOR, clrBlack);
    ObjectSetInteger(0, DetailsOrderDate, OBJPROP_BGCOLOR, clrLightCyan);
    ObjectSetInteger(0, DetailsOrderDate, OBJPROP_BORDER_COLOR, clrBlack);

    ObjectCreate(0, DetailsOrderTime, OBJ_EDIT, 0, 0, 0);
    ObjectSet(DetailsOrderTime, OBJPROP_XDISTANCE, DetXoff + (DetGLabelX + 2) * 2 + 2);
    ObjectSet(DetailsOrderTime, OBJPROP_YDISTANCE, (DetYoff + 2) + (DetButtonY + 2) + 10);
    ObjectSetInteger(0, DetailsOrderTime, OBJPROP_XSIZE, DetGLabelX);
    ObjectSetInteger(0, DetailsOrderTime, OBJPROP_YSIZE, DetGLabelY);
    ObjectSetInteger(0, DetailsOrderTime, OBJPROP_BORDER_TYPE, BORDER_FLAT);
    ObjectSetInteger(0, DetailsOrderTime, OBJPROP_STATE, false);
    ObjectSetInteger(0, DetailsOrderTime, OBJPROP_HIDDEN, true);
    ObjectSetInteger(0, DetailsOrderTime, OBJPROP_READONLY, true);
    ObjectSetInteger(0, DetailsOrderTime, OBJPROP_FONTSIZE, NOFontSize);
    ObjectSetString(0, DetailsOrderTime, OBJPROP_TOOLTIP, "Open Order Time (HH:MM) (Server Time)");
    ObjectSetInteger(0, DetailsOrderTime, OBJPROP_ALIGN, ALIGN_CENTER);
    ObjectSetString(0, DetailsOrderTime, OBJPROP_FONT, DetFont);
    ObjectSetString(0, DetailsOrderTime, OBJPROP_TEXT, "Time");
    ObjectSet(DetailsOrderTime, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, DetailsOrderTime, OBJPROP_COLOR, clrBlack);
    ObjectSetInteger(0, DetailsOrderTime, OBJPROP_BGCOLOR, clrLightCyan);
    ObjectSetInteger(0, DetailsOrderTime, OBJPROP_BORDER_COLOR, clrBlack);

    ObjectCreate(0, DetailsOrderType, OBJ_EDIT, 0, 0, 0);
    ObjectSet(DetailsOrderType, OBJPROP_XDISTANCE, DetXoff + (DetGLabelX + 2) * 3 + 2);
    ObjectSet(DetailsOrderType, OBJPROP_YDISTANCE, (DetYoff + 2) + (DetButtonY + 2) + 10);
    ObjectSetInteger(0, DetailsOrderType, OBJPROP_XSIZE, DetGLabelX);
    ObjectSetInteger(0, DetailsOrderType, OBJPROP_YSIZE, DetGLabelY);
    ObjectSetInteger(0, DetailsOrderType, OBJPROP_BORDER_TYPE, BORDER_FLAT);
    ObjectSetInteger(0, DetailsOrderType, OBJPROP_STATE, false);
    ObjectSetInteger(0, DetailsOrderType, OBJPROP_HIDDEN, true);
    ObjectSetInteger(0, DetailsOrderType, OBJPROP_READONLY, true);
    ObjectSetInteger(0, DetailsOrderType, OBJPROP_FONTSIZE, NOFontSize);
    ObjectSetString(0, DetailsOrderType, OBJPROP_TOOLTIP, "Order Type");
    ObjectSetInteger(0, DetailsOrderType, OBJPROP_ALIGN, ALIGN_CENTER);
    ObjectSetString(0, DetailsOrderType, OBJPROP_FONT, DetFont);
    ObjectSetString(0, DetailsOrderType, OBJPROP_TEXT, "Type");
    ObjectSet(DetailsOrderType, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, DetailsOrderType, OBJPROP_COLOR, clrBlack);
    ObjectSetInteger(0, DetailsOrderType, OBJPROP_BGCOLOR, clrLightCyan);
    ObjectSetInteger(0, DetailsOrderType, OBJPROP_BORDER_COLOR, clrBlack);

    ObjectCreate(0, DetailsOrderSize, OBJ_EDIT, 0, 0, 0);
    ObjectSet(DetailsOrderSize, OBJPROP_XDISTANCE, DetXoff + (DetGLabelX + 2) * 4 + 2);
    ObjectSet(DetailsOrderSize, OBJPROP_YDISTANCE, (DetYoff + 2) + (DetButtonY + 2) + 10);
    ObjectSetInteger(0, DetailsOrderSize, OBJPROP_XSIZE, DetGLabelX);
    ObjectSetInteger(0, DetailsOrderSize, OBJPROP_YSIZE, DetGLabelY);
    ObjectSetInteger(0, DetailsOrderSize, OBJPROP_BORDER_TYPE, BORDER_FLAT);
    ObjectSetInteger(0, DetailsOrderSize, OBJPROP_STATE, false);
    ObjectSetInteger(0, DetailsOrderSize, OBJPROP_HIDDEN, true);
    ObjectSetInteger(0, DetailsOrderSize, OBJPROP_READONLY, true);
    ObjectSetInteger(0, DetailsOrderSize, OBJPROP_FONTSIZE, NOFontSize);
    ObjectSetString(0, DetailsOrderSize, OBJPROP_TOOLTIP, "Order Size");
    ObjectSetInteger(0, DetailsOrderSize, OBJPROP_ALIGN, ALIGN_CENTER);
    ObjectSetString(0, DetailsOrderSize, OBJPROP_FONT, DetFont);
    ObjectSetString(0, DetailsOrderSize, OBJPROP_TEXT, "Size");
    ObjectSet(DetailsOrderSize, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, DetailsOrderSize, OBJPROP_COLOR, clrBlack);
    ObjectSetInteger(0, DetailsOrderSize, OBJPROP_BGCOLOR, clrLightCyan);
    ObjectSetInteger(0, DetailsOrderSize, OBJPROP_BORDER_COLOR, clrBlack);

    ObjectCreate(0, DetailsOrderSymbol, OBJ_EDIT, 0, 0, 0);
    ObjectSet(DetailsOrderSymbol, OBJPROP_XDISTANCE, DetXoff + (DetGLabelX + 2) * 5 + 2);
    ObjectSet(DetailsOrderSymbol, OBJPROP_YDISTANCE, (DetYoff + 2) + (DetButtonY + 2) + 10);
    ObjectSetInteger(0, DetailsOrderSymbol, OBJPROP_XSIZE, DetGLabelX);
    ObjectSetInteger(0, DetailsOrderSymbol, OBJPROP_YSIZE, DetGLabelY);
    ObjectSetInteger(0, DetailsOrderSymbol, OBJPROP_BORDER_TYPE, BORDER_FLAT);
    ObjectSetInteger(0, DetailsOrderSymbol, OBJPROP_STATE, false);
    ObjectSetInteger(0, DetailsOrderSymbol, OBJPROP_HIDDEN, true);
    ObjectSetInteger(0, DetailsOrderSymbol, OBJPROP_READONLY, true);
    ObjectSetInteger(0, DetailsOrderSymbol, OBJPROP_FONTSIZE, NOFontSize);
    ObjectSetString(0, DetailsOrderSymbol, OBJPROP_TOOLTIP, "Order Symbol");
    ObjectSetInteger(0, DetailsOrderSymbol, OBJPROP_ALIGN, ALIGN_CENTER);
    ObjectSetString(0, DetailsOrderSymbol, OBJPROP_FONT, DetFont);
    ObjectSetString(0, DetailsOrderSymbol, OBJPROP_TEXT, "Symbol");
    ObjectSet(DetailsOrderSymbol, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, DetailsOrderSymbol, OBJPROP_COLOR, clrBlack);
    ObjectSetInteger(0, DetailsOrderSymbol, OBJPROP_BGCOLOR, clrLightCyan);
    ObjectSetInteger(0, DetailsOrderSymbol, OBJPROP_BORDER_COLOR, clrBlack);

    ObjectCreate(0, DetailsOrderPrice, OBJ_EDIT, 0, 0, 0);
    ObjectSet(DetailsOrderPrice, OBJPROP_XDISTANCE, DetXoff + (DetGLabelX + 2) * 6 + 2);
    ObjectSet(DetailsOrderPrice, OBJPROP_YDISTANCE, (DetYoff + 2) + (DetButtonY + 2) + 10);
    ObjectSetInteger(0, DetailsOrderPrice, OBJPROP_XSIZE, DetGLabelX);
    ObjectSetInteger(0, DetailsOrderPrice, OBJPROP_YSIZE, DetGLabelY);
    ObjectSetInteger(0, DetailsOrderPrice, OBJPROP_BORDER_TYPE, BORDER_FLAT);
    ObjectSetInteger(0, DetailsOrderPrice, OBJPROP_STATE, false);
    ObjectSetInteger(0, DetailsOrderPrice, OBJPROP_HIDDEN, true);
    ObjectSetInteger(0, DetailsOrderPrice, OBJPROP_READONLY, true);
    ObjectSetInteger(0, DetailsOrderPrice, OBJPROP_FONTSIZE, NOFontSize);
    ObjectSetString(0, DetailsOrderPrice, OBJPROP_TOOLTIP, "Order Open Price");
    ObjectSetInteger(0, DetailsOrderPrice, OBJPROP_ALIGN, ALIGN_CENTER);
    ObjectSetString(0, DetailsOrderPrice, OBJPROP_FONT, DetFont);
    ObjectSetString(0, DetailsOrderPrice, OBJPROP_TEXT, "OP");
    ObjectSet(DetailsOrderPrice, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, DetailsOrderPrice, OBJPROP_COLOR, clrBlack);
    ObjectSetInteger(0, DetailsOrderPrice, OBJPROP_BGCOLOR, clrLightCyan);
    ObjectSetInteger(0, DetailsOrderPrice, OBJPROP_BORDER_COLOR, clrBlack);

    ObjectCreate(0, DetailsOrderSL, OBJ_EDIT, 0, 0, 0);
    ObjectSet(DetailsOrderSL, OBJPROP_XDISTANCE, DetXoff + (DetGLabelX + 2) * 7 + 2);
    ObjectSet(DetailsOrderSL, OBJPROP_YDISTANCE, (DetYoff + 2) + (DetButtonY + 2) + 10);
    ObjectSetInteger(0, DetailsOrderSL, OBJPROP_XSIZE, DetGLabelX);
    ObjectSetInteger(0, DetailsOrderSL, OBJPROP_YSIZE, DetGLabelY);
    ObjectSetInteger(0, DetailsOrderSL, OBJPROP_BORDER_TYPE, BORDER_FLAT);
    ObjectSetInteger(0, DetailsOrderSL, OBJPROP_STATE, false);
    ObjectSetInteger(0, DetailsOrderSL, OBJPROP_HIDDEN, true);
    ObjectSetInteger(0, DetailsOrderSL, OBJPROP_READONLY, true);
    ObjectSetInteger(0, DetailsOrderSL, OBJPROP_FONTSIZE, NOFontSize);
    ObjectSetString(0, DetailsOrderSL, OBJPROP_TOOLTIP, "Order Stop Loss Price");
    ObjectSetInteger(0, DetailsOrderSL, OBJPROP_ALIGN, ALIGN_CENTER);
    ObjectSetString(0, DetailsOrderSL, OBJPROP_FONT, DetFont);
    ObjectSetString(0, DetailsOrderSL, OBJPROP_TEXT, "SL");
    ObjectSet(DetailsOrderSL, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, DetailsOrderSL, OBJPROP_COLOR, clrBlack);
    ObjectSetInteger(0, DetailsOrderSL, OBJPROP_BGCOLOR, clrLightCyan);
    ObjectSetInteger(0, DetailsOrderSL, OBJPROP_BORDER_COLOR, clrBlack);

    ObjectCreate(0, DetailsOrderTP, OBJ_EDIT, 0, 0, 0);
    ObjectSet(DetailsOrderTP, OBJPROP_XDISTANCE, DetXoff + (DetGLabelX + 2) * 8 + 2);
    ObjectSet(DetailsOrderTP, OBJPROP_YDISTANCE, (DetYoff + 2) + (DetButtonY + 2) + 10);
    ObjectSetInteger(0, DetailsOrderTP, OBJPROP_XSIZE, DetGLabelX);
    ObjectSetInteger(0, DetailsOrderTP, OBJPROP_YSIZE, DetGLabelY);
    ObjectSetInteger(0, DetailsOrderTP, OBJPROP_BORDER_TYPE, BORDER_FLAT);
    ObjectSetInteger(0, DetailsOrderTP, OBJPROP_STATE, false);
    ObjectSetInteger(0, DetailsOrderTP, OBJPROP_HIDDEN, true);
    ObjectSetInteger(0, DetailsOrderTP, OBJPROP_READONLY, true);
    ObjectSetInteger(0, DetailsOrderTP, OBJPROP_FONTSIZE, NOFontSize);
    ObjectSetString(0, DetailsOrderTP, OBJPROP_TOOLTIP, "Order Take Profit Price");
    ObjectSetInteger(0, DetailsOrderTP, OBJPROP_ALIGN, ALIGN_CENTER);
    ObjectSetString(0, DetailsOrderTP, OBJPROP_FONT, DetFont);
    ObjectSetString(0, DetailsOrderTP, OBJPROP_TEXT, "TP");
    ObjectSet(DetailsOrderTP, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, DetailsOrderTP, OBJPROP_COLOR, clrBlack);
    ObjectSetInteger(0, DetailsOrderTP, OBJPROP_BGCOLOR, clrLightCyan);
    ObjectSetInteger(0, DetailsOrderTP, OBJPROP_BORDER_COLOR, clrBlack);

    ObjectCreate(0, DetailsOrderProfit, OBJ_EDIT, 0, 0, 0);
    ObjectSet(DetailsOrderProfit, OBJPROP_XDISTANCE, DetXoff + (DetGLabelX + 2) * 9 + 2);
    ObjectSet(DetailsOrderProfit, OBJPROP_YDISTANCE, (DetYoff + 2) + (DetButtonY + 2) + 10);
    ObjectSetInteger(0, DetailsOrderProfit, OBJPROP_XSIZE, DetGLabelX);
    ObjectSetInteger(0, DetailsOrderProfit, OBJPROP_YSIZE, DetGLabelY);
    ObjectSetInteger(0, DetailsOrderProfit, OBJPROP_BORDER_TYPE, BORDER_FLAT);
    ObjectSetInteger(0, DetailsOrderProfit, OBJPROP_STATE, false);
    ObjectSetInteger(0, DetailsOrderProfit, OBJPROP_HIDDEN, true);
    ObjectSetInteger(0, DetailsOrderProfit, OBJPROP_READONLY, true);
    ObjectSetInteger(0, DetailsOrderProfit, OBJPROP_FONTSIZE, NOFontSize);
    ObjectSetString(0, DetailsOrderProfit, OBJPROP_TOOLTIP, "Order Current Profit/Loss");
    ObjectSetInteger(0, DetailsOrderProfit, OBJPROP_ALIGN, ALIGN_CENTER);
    ObjectSetString(0, DetailsOrderProfit, OBJPROP_FONT, DetFont);
    ObjectSetString(0, DetailsOrderProfit, OBJPROP_TEXT, "Profit");
    ObjectSet(DetailsOrderProfit, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, DetailsOrderProfit, OBJPROP_COLOR, clrBlack);
    ObjectSetInteger(0, DetailsOrderProfit, OBJPROP_BGCOLOR, clrLightCyan);
    ObjectSetInteger(0, DetailsOrderProfit, OBJPROP_BORDER_COLOR, clrBlack);

    ObjectCreate(0, DetailsOrderMagic, OBJ_EDIT, 0, 0, 0);
    ObjectSet(DetailsOrderMagic, OBJPROP_XDISTANCE, DetXoff + (DetGLabelX + 2) * 10 + 2);
    ObjectSet(DetailsOrderMagic, OBJPROP_YDISTANCE, (DetYoff + 2) + (DetButtonY + 2) + 10);
    ObjectSetInteger(0, DetailsOrderMagic, OBJPROP_XSIZE, DetGLabelX);
    ObjectSetInteger(0, DetailsOrderMagic, OBJPROP_YSIZE, DetGLabelY);
    ObjectSetInteger(0, DetailsOrderMagic, OBJPROP_BORDER_TYPE, BORDER_FLAT);
    ObjectSetInteger(0, DetailsOrderMagic, OBJPROP_STATE, false);
    ObjectSetInteger(0, DetailsOrderMagic, OBJPROP_HIDDEN, true);
    ObjectSetInteger(0, DetailsOrderMagic, OBJPROP_READONLY, true);
    ObjectSetInteger(0, DetailsOrderMagic, OBJPROP_FONTSIZE, NOFontSize);
    ObjectSetString(0, DetailsOrderMagic, OBJPROP_TOOLTIP, "Order Magic Number");
    ObjectSetInteger(0, DetailsOrderMagic, OBJPROP_ALIGN, ALIGN_CENTER);
    ObjectSetString(0, DetailsOrderMagic, OBJPROP_FONT, DetFont);
    ObjectSetString(0, DetailsOrderMagic, OBJPROP_TEXT, "Magic");
    ObjectSet(DetailsOrderMagic, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, DetailsOrderMagic, OBJPROP_COLOR, clrBlack);
    ObjectSetInteger(0, DetailsOrderMagic, OBJPROP_BGCOLOR, clrLightCyan);
    ObjectSetInteger(0, DetailsOrderMagic, OBJPROP_BORDER_COLOR, clrBlack);

    ObjectCreate(0, DetailsOrderComment, OBJ_EDIT, 0, 0, 0);
    ObjectSet(DetailsOrderComment, OBJPROP_XDISTANCE, DetXoff + (DetGLabelX + 2) * 11 + 2);
    ObjectSet(DetailsOrderComment, OBJPROP_YDISTANCE, (DetYoff + 2) + (DetButtonY + 2) + 10);
    ObjectSetInteger(0, DetailsOrderComment, OBJPROP_XSIZE, DetCmntLabelX);
    ObjectSetInteger(0, DetailsOrderComment, OBJPROP_YSIZE, DetGLabelY);
    ObjectSetInteger(0, DetailsOrderComment, OBJPROP_BORDER_TYPE, BORDER_FLAT);
    ObjectSetInteger(0, DetailsOrderComment, OBJPROP_STATE, false);
    ObjectSetInteger(0, DetailsOrderComment, OBJPROP_HIDDEN, true);
    ObjectSetInteger(0, DetailsOrderComment, OBJPROP_READONLY, true);
    ObjectSetInteger(0, DetailsOrderComment, OBJPROP_FONTSIZE, NOFontSize);
    ObjectSetString(0, DetailsOrderComment, OBJPROP_TOOLTIP, "Order Comment");
    ObjectSetInteger(0, DetailsOrderComment, OBJPROP_ALIGN, ALIGN_CENTER);
    ObjectSetString(0, DetailsOrderComment, OBJPROP_FONT, DetFont);
    ObjectSetString(0, DetailsOrderComment, OBJPROP_TEXT, "Comment");
    ObjectSet(DetailsOrderComment, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, DetailsOrderComment, OBJPROP_COLOR, clrBlack);
    ObjectSetInteger(0, DetailsOrderComment, OBJPROP_BGCOLOR, clrLightCyan);
    ObjectSetInteger(0, DetailsOrderComment, OBJPROP_BORDER_COLOR, clrBlack);

    int j = 1;
    for (int i = IndexFirstOrder; i < IndexFirstOrder + OrdersThisPage; i++)
    {
        string DetailsOrderNumberI = IndicatorName + "-D-OrderNumberI" + IntegerToString(i);
        string DetailsOrderDateI = IndicatorName + "-D-OrderDateI" + IntegerToString(i);
        string DetailsOrderTimeI = IndicatorName + "-D-OrderTimeI" + IntegerToString(i);
        string DetailsOrderMagicI = IndicatorName + "-D-OrderMagicI" + IntegerToString(i);
        string DetailsOrderSymbolI = IndicatorName + "-D-OrderSymbolI" + IntegerToString(i);
        string DetailsOrderTypeI = IndicatorName + "-D-OrderType" + IntegerToString(i);
        string DetailsOrderSizeI = IndicatorName + "-D-OrderSizeI" + IntegerToString(i);
        string DetailsOrderPriceI = IndicatorName + "-D-OrderPriceI" + IntegerToString(i);
        string DetailsOrderSLI = IndicatorName + "-D-OrderSLI" + IntegerToString(i);
        string DetailsOrderTPI = IndicatorName + "-D-OrderTPI" + IntegerToString(i);
        string DetailsOrderProfitI = IndicatorName + "-D-OrderProfitI" + IntegerToString(i);
        string DetailsOrderCommentI = IndicatorName + "-D-OrderCmntI" + IntegerToString(i);
        int OrderNumber = (int)Orders[i][1];
        if (!OrderSelect(OrderNumber, SELECT_BY_TICKET)) continue;
        string TextTicket = IntegerToString(OrderTicket());
        string TextMagic = IntegerToString(OrderMagicNumber());
        string TextDate = TimeToStr(OrderOpenTime(), TIME_DATE);
        string TextTime = TimeToStr(OrderOpenTime(), TIME_MINUTES);
        string TextSymbol = OrderSymbol();
        string TextType = "";
        if (OrderType() == 0) TextType = "BUY";
        if (OrderType() == 1) TextType = "SELL";
        if (OrderType() == 2) TextType = "BUY LIMIT";
        if (OrderType() == 3) TextType = "SELL LIMIT";
        if (OrderType() == 4) TextType = "BUY STOP";
        if (OrderType() == 5) TextType = "SELL STOP";
        int eDigits = (int)MarketInfo(TextSymbol, MODE_DIGITS);
        string TextSize = DoubleToStr(OrderLots(), 2);
        string TextTP = DoubleToStr(OrderTakeProfit(), eDigits);
        string TextSL = DoubleToStr(OrderStopLoss(), eDigits);
        string TextPrice = DoubleToStr(OrderOpenPrice(), eDigits);
        string TextProfit = DoubleToStr(OrderProfit(), 2);
        string TextCmnt = OrderComment();

        ObjectCreate(0, DetailsOrderNumberI, OBJ_EDIT, 0, 0, 0);
        ObjectSet(DetailsOrderNumberI, OBJPROP_XDISTANCE, DetXoff + 2);
        ObjectSet(DetailsOrderNumberI, OBJPROP_YDISTANCE, DetYoff + DetButtonY + (DetGLabelY + 5) * j + 20);
        ObjectSetInteger(0, DetailsOrderNumberI, OBJPROP_XSIZE, DetGLabelX);
        ObjectSetInteger(0, DetailsOrderNumberI, OBJPROP_YSIZE, DetGLabelY);
        ObjectSetInteger(0, DetailsOrderNumberI, OBJPROP_BORDER_TYPE, BORDER_FLAT);
        ObjectSetInteger(0, DetailsOrderNumberI, OBJPROP_STATE, false);
        ObjectSetInteger(0, DetailsOrderNumberI, OBJPROP_HIDDEN, true);
        ObjectSetInteger(0, DetailsOrderNumberI, OBJPROP_READONLY, true);
        ObjectSetInteger(0, DetailsOrderNumberI, OBJPROP_FONTSIZE, NOFontSize);
        ObjectSetString(0, DetailsOrderNumberI, OBJPROP_TOOLTIP, "Order Number");
        ObjectSetInteger(0, DetailsOrderNumberI, OBJPROP_ALIGN, ALIGN_CENTER);
        ObjectSetString(0, DetailsOrderNumberI, OBJPROP_FONT, DetFont);
        ObjectSetString(0, DetailsOrderNumberI, OBJPROP_TEXT, TextTicket);
        ObjectSet(DetailsOrderNumberI, OBJPROP_SELECTABLE, false);
        ObjectSetInteger(0, DetailsOrderNumberI, OBJPROP_COLOR, clrBlack);

        ObjectCreate(0, DetailsOrderDateI, OBJ_EDIT, 0, 0, 0);
        ObjectSet(DetailsOrderDateI, OBJPROP_XDISTANCE, DetXoff + (DetGLabelX + 4));
        ObjectSet(DetailsOrderDateI, OBJPROP_YDISTANCE, DetYoff + DetButtonY + (DetGLabelY + 5) * j + 20);
        ObjectSetInteger(0, DetailsOrderDateI, OBJPROP_XSIZE, DetGLabelX);
        ObjectSetInteger(0, DetailsOrderDateI, OBJPROP_YSIZE, DetGLabelY);
        ObjectSetInteger(0, DetailsOrderDateI, OBJPROP_BORDER_TYPE, BORDER_FLAT);
        ObjectSetInteger(0, DetailsOrderDateI, OBJPROP_STATE, false);
        ObjectSetInteger(0, DetailsOrderDateI, OBJPROP_HIDDEN, true);
        ObjectSetInteger(0, DetailsOrderDateI, OBJPROP_READONLY, true);
        ObjectSetInteger(0, DetailsOrderDateI, OBJPROP_FONTSIZE, NOFontSize);
        ObjectSetString(0, DetailsOrderDateI, OBJPROP_TOOLTIP, "Order Date (YYYY/MM/DD)");
        ObjectSetInteger(0, DetailsOrderDateI, OBJPROP_ALIGN, ALIGN_CENTER);
        ObjectSetString(0, DetailsOrderDateI, OBJPROP_FONT, DetFont);
        ObjectSetString(0, DetailsOrderDateI, OBJPROP_TEXT, TextDate);
        ObjectSet(DetailsOrderDateI, OBJPROP_SELECTABLE, false);
        ObjectSetInteger(0, DetailsOrderDateI, OBJPROP_COLOR, clrBlack);

        ObjectCreate(0, DetailsOrderTimeI, OBJ_EDIT, 0, 0, 0);
        ObjectSet(DetailsOrderTimeI, OBJPROP_XDISTANCE, DetXoff + (DetGLabelX + 2) * 2 + 2);
        ObjectSet(DetailsOrderTimeI, OBJPROP_YDISTANCE, DetYoff + DetButtonY + (DetGLabelY + 5) * j + 20);
        ObjectSetInteger(0, DetailsOrderTimeI, OBJPROP_XSIZE, DetGLabelX);
        ObjectSetInteger(0, DetailsOrderTimeI, OBJPROP_YSIZE, DetGLabelY);
        ObjectSetInteger(0, DetailsOrderTimeI, OBJPROP_BORDER_TYPE, BORDER_FLAT);
        ObjectSetInteger(0, DetailsOrderTimeI, OBJPROP_STATE, false);
        ObjectSetInteger(0, DetailsOrderTimeI, OBJPROP_HIDDEN, true);
        ObjectSetInteger(0, DetailsOrderTimeI, OBJPROP_READONLY, true);
        ObjectSetInteger(0, DetailsOrderTimeI, OBJPROP_FONTSIZE, NOFontSize);
        ObjectSetString(0, DetailsOrderTimeI, OBJPROP_TOOLTIP, "Order Time (HH:MM)");
        ObjectSetInteger(0, DetailsOrderTimeI, OBJPROP_ALIGN, ALIGN_CENTER);
        ObjectSetString(0, DetailsOrderTimeI, OBJPROP_FONT, DetFont);
        ObjectSetString(0, DetailsOrderTimeI, OBJPROP_TEXT, TextTime);
        ObjectSet(DetailsOrderTimeI, OBJPROP_SELECTABLE, false);
        ObjectSetInteger(0, DetailsOrderTimeI, OBJPROP_COLOR, clrBlack);

        ObjectCreate(0, DetailsOrderTypeI, OBJ_EDIT, 0, 0, 0);
        ObjectSet(DetailsOrderTypeI, OBJPROP_XDISTANCE, DetXoff + (DetGLabelX + 2) * 3 + 2);
        ObjectSet(DetailsOrderTypeI, OBJPROP_YDISTANCE, DetYoff + DetButtonY + (DetGLabelY + 5) * j + 20);
        ObjectSetInteger(0, DetailsOrderTypeI, OBJPROP_XSIZE, DetGLabelX);
        ObjectSetInteger(0, DetailsOrderTypeI, OBJPROP_YSIZE, DetGLabelY);
        ObjectSetInteger(0, DetailsOrderTypeI, OBJPROP_BORDER_TYPE, BORDER_FLAT);
        ObjectSetInteger(0, DetailsOrderTypeI, OBJPROP_STATE, false);
        ObjectSetInteger(0, DetailsOrderTypeI, OBJPROP_HIDDEN, true);
        ObjectSetInteger(0, DetailsOrderTypeI, OBJPROP_READONLY, true);
        ObjectSetInteger(0, DetailsOrderTypeI, OBJPROP_FONTSIZE, NOFontSize);
        ObjectSetString(0, DetailsOrderTypeI, OBJPROP_TOOLTIP, "Order Type");
        ObjectSetInteger(0, DetailsOrderTypeI, OBJPROP_ALIGN, ALIGN_CENTER);
        ObjectSetString(0, DetailsOrderTypeI, OBJPROP_FONT, DetFont);
        ObjectSetString(0, DetailsOrderTypeI, OBJPROP_TEXT, TextType);
        ObjectSet(DetailsOrderTypeI, OBJPROP_SELECTABLE, false);
        ObjectSetInteger(0, DetailsOrderTypeI, OBJPROP_COLOR, clrBlack);

        ObjectCreate(0, DetailsOrderSizeI, OBJ_EDIT, 0, 0, 0);
        ObjectSet(DetailsOrderSizeI, OBJPROP_XDISTANCE, DetXoff + (DetGLabelX + 2) * 4 + 2);
        ObjectSet(DetailsOrderSizeI, OBJPROP_YDISTANCE, DetYoff + DetButtonY + (DetGLabelY + 5) * j + 20);
        ObjectSetInteger(0, DetailsOrderSizeI, OBJPROP_XSIZE, DetGLabelX);
        ObjectSetInteger(0, DetailsOrderSizeI, OBJPROP_YSIZE, DetGLabelY);
        ObjectSetInteger(0, DetailsOrderSizeI, OBJPROP_BORDER_TYPE, BORDER_FLAT);
        ObjectSetInteger(0, DetailsOrderSizeI, OBJPROP_STATE, false);
        ObjectSetInteger(0, DetailsOrderSizeI, OBJPROP_HIDDEN, true);
        ObjectSetInteger(0, DetailsOrderSizeI, OBJPROP_READONLY, true);
        ObjectSetInteger(0, DetailsOrderSizeI, OBJPROP_FONTSIZE, NOFontSize);
        ObjectSetString(0, DetailsOrderSizeI, OBJPROP_TOOLTIP, "Order Size");
        ObjectSetInteger(0, DetailsOrderSizeI, OBJPROP_ALIGN, ALIGN_CENTER);
        ObjectSetString(0, DetailsOrderSizeI, OBJPROP_FONT, DetFont);
        ObjectSetString(0, DetailsOrderSizeI, OBJPROP_TEXT, TextSize);
        ObjectSet(DetailsOrderSizeI, OBJPROP_SELECTABLE, false);
        ObjectSetInteger(0, DetailsOrderSizeI, OBJPROP_COLOR, clrBlack);

        ObjectCreate(0, DetailsOrderSymbolI, OBJ_EDIT, 0, 0, 0);
        ObjectSet(DetailsOrderSymbolI, OBJPROP_XDISTANCE, DetXoff + (DetGLabelX + 2) * 5 + 2);
        ObjectSet(DetailsOrderSymbolI, OBJPROP_YDISTANCE, DetYoff + DetButtonY + (DetGLabelY + 5) * j + 20);
        ObjectSetInteger(0, DetailsOrderSymbolI, OBJPROP_XSIZE, DetGLabelX);
        ObjectSetInteger(0, DetailsOrderSymbolI, OBJPROP_YSIZE, DetGLabelY);
        ObjectSetInteger(0, DetailsOrderSymbolI, OBJPROP_BORDER_TYPE, BORDER_FLAT);
        ObjectSetInteger(0, DetailsOrderSymbolI, OBJPROP_STATE, false);
        ObjectSetInteger(0, DetailsOrderSymbolI, OBJPROP_HIDDEN, true);
        ObjectSetInteger(0, DetailsOrderSymbolI, OBJPROP_READONLY, true);
        ObjectSetInteger(0, DetailsOrderSymbolI, OBJPROP_FONTSIZE, NOFontSize);
        ObjectSetString(0, DetailsOrderSymbolI, OBJPROP_TOOLTIP, "Order Symbol");
        ObjectSetInteger(0, DetailsOrderSymbolI, OBJPROP_ALIGN, ALIGN_CENTER);
        ObjectSetString(0, DetailsOrderSymbolI, OBJPROP_FONT, DetFont);
        ObjectSetString(0, DetailsOrderSymbolI, OBJPROP_TEXT, TextSymbol);
        ObjectSet(DetailsOrderSymbolI, OBJPROP_SELECTABLE, false);
        ObjectSetInteger(0, DetailsOrderSymbolI, OBJPROP_COLOR, clrBlack);

        ObjectCreate(0, DetailsOrderPriceI, OBJ_EDIT, 0, 0, 0);
        ObjectSet(DetailsOrderPriceI, OBJPROP_XDISTANCE, DetXoff + (DetGLabelX + 2) * 6 + 2);
        ObjectSet(DetailsOrderPriceI, OBJPROP_YDISTANCE, DetYoff + DetButtonY + (DetGLabelY + 5) * j + 20);
        ObjectSetInteger(0, DetailsOrderPriceI, OBJPROP_XSIZE, DetGLabelX);
        ObjectSetInteger(0, DetailsOrderPriceI, OBJPROP_YSIZE, DetGLabelY);
        ObjectSetInteger(0, DetailsOrderPriceI, OBJPROP_BORDER_TYPE, BORDER_FLAT);
        ObjectSetInteger(0, DetailsOrderPriceI, OBJPROP_STATE, false);
        ObjectSetInteger(0, DetailsOrderPriceI, OBJPROP_HIDDEN, true);
        ObjectSetInteger(0, DetailsOrderPriceI, OBJPROP_READONLY, true);
        ObjectSetInteger(0, DetailsOrderPriceI, OBJPROP_FONTSIZE, NOFontSize);
        ObjectSetString(0, DetailsOrderPriceI, OBJPROP_TOOLTIP, "Order Open Price");
        ObjectSetInteger(0, DetailsOrderPriceI, OBJPROP_ALIGN, ALIGN_CENTER);
        ObjectSetString(0, DetailsOrderPriceI, OBJPROP_FONT, DetFont);
        ObjectSetString(0, DetailsOrderPriceI, OBJPROP_TEXT, TextPrice);
        ObjectSet(DetailsOrderPriceI, OBJPROP_SELECTABLE, false);
        ObjectSetInteger(0, DetailsOrderPriceI, OBJPROP_COLOR, clrBlack);

        ObjectCreate(0, DetailsOrderSLI, OBJ_EDIT, 0, 0, 0);
        ObjectSet(DetailsOrderSLI, OBJPROP_XDISTANCE, DetXoff + (DetGLabelX + 2) * 7 + 2);
        ObjectSet(DetailsOrderSLI, OBJPROP_YDISTANCE, DetYoff + DetButtonY + (DetGLabelY + 5) * j + 20);
        ObjectSetInteger(0, DetailsOrderSLI, OBJPROP_XSIZE, DetGLabelX);
        ObjectSetInteger(0, DetailsOrderSLI, OBJPROP_YSIZE, DetGLabelY);
        ObjectSetInteger(0, DetailsOrderSLI, OBJPROP_BORDER_TYPE, BORDER_FLAT);
        ObjectSetInteger(0, DetailsOrderSLI, OBJPROP_STATE, false);
        ObjectSetInteger(0, DetailsOrderSLI, OBJPROP_HIDDEN, true);
        ObjectSetInteger(0, DetailsOrderSLI, OBJPROP_READONLY, true);
        ObjectSetInteger(0, DetailsOrderSLI, OBJPROP_FONTSIZE, NOFontSize);
        ObjectSetString(0, DetailsOrderSLI, OBJPROP_TOOLTIP, "Order Stop Loss Price");
        ObjectSetInteger(0, DetailsOrderSLI, OBJPROP_ALIGN, ALIGN_CENTER);
        ObjectSetString(0, DetailsOrderSLI, OBJPROP_FONT, DetFont);
        ObjectSetString(0, DetailsOrderSLI, OBJPROP_TEXT, TextSL);
        ObjectSet(DetailsOrderSLI, OBJPROP_SELECTABLE, false);
        ObjectSetInteger(0, DetailsOrderSLI, OBJPROP_COLOR, clrBlack);

        ObjectCreate(0, DetailsOrderTPI, OBJ_EDIT, 0, 0, 0);
        ObjectSet(DetailsOrderTPI, OBJPROP_XDISTANCE, DetXoff + (DetGLabelX + 2) * 8 + 2);
        ObjectSet(DetailsOrderTPI, OBJPROP_YDISTANCE, DetYoff + DetButtonY + (DetGLabelY + 5) * j + 20);
        ObjectSetInteger(0, DetailsOrderTPI, OBJPROP_XSIZE, DetGLabelX);
        ObjectSetInteger(0, DetailsOrderTPI, OBJPROP_YSIZE, DetGLabelY);
        ObjectSetInteger(0, DetailsOrderTPI, OBJPROP_BORDER_TYPE, BORDER_FLAT);
        ObjectSetInteger(0, DetailsOrderTPI, OBJPROP_STATE, false);
        ObjectSetInteger(0, DetailsOrderTPI, OBJPROP_HIDDEN, true);
        ObjectSetInteger(0, DetailsOrderTPI, OBJPROP_READONLY, true);
        ObjectSetInteger(0, DetailsOrderTPI, OBJPROP_FONTSIZE, NOFontSize);
        ObjectSetString(0, DetailsOrderTPI, OBJPROP_TOOLTIP, "Order Take Profit Price");
        ObjectSetInteger(0, DetailsOrderTPI, OBJPROP_ALIGN, ALIGN_CENTER);
        ObjectSetString(0, DetailsOrderTPI, OBJPROP_FONT, DetFont);
        ObjectSetString(0, DetailsOrderTPI, OBJPROP_TEXT, TextTP);
        ObjectSet(DetailsOrderTPI, OBJPROP_SELECTABLE, false);
        ObjectSetInteger(0, DetailsOrderTPI, OBJPROP_COLOR, clrBlack);

        ObjectCreate(0, DetailsOrderProfitI, OBJ_EDIT, 0, 0, 0);
        ObjectSet(DetailsOrderProfitI, OBJPROP_XDISTANCE, DetXoff + (DetGLabelX + 2) * 9 + 2);
        ObjectSet(DetailsOrderProfitI, OBJPROP_YDISTANCE, DetYoff + DetButtonY + (DetGLabelY + 5) * j + 20);
        ObjectSetInteger(0, DetailsOrderProfitI, OBJPROP_XSIZE, DetGLabelX);
        ObjectSetInteger(0, DetailsOrderProfitI, OBJPROP_YSIZE, DetGLabelY);
        ObjectSetInteger(0, DetailsOrderProfitI, OBJPROP_BORDER_TYPE, BORDER_FLAT);
        ObjectSetInteger(0, DetailsOrderProfitI, OBJPROP_STATE, false);
        ObjectSetInteger(0, DetailsOrderProfitI, OBJPROP_HIDDEN, true);
        ObjectSetInteger(0, DetailsOrderProfitI, OBJPROP_READONLY, true);
        ObjectSetInteger(0, DetailsOrderProfitI, OBJPROP_FONTSIZE, NOFontSize);
        ObjectSetString(0, DetailsOrderProfitI, OBJPROP_TOOLTIP, "Order Current Profit/Loss");
        ObjectSetInteger(0, DetailsOrderProfitI, OBJPROP_ALIGN, ALIGN_CENTER);
        ObjectSetString(0, DetailsOrderProfitI, OBJPROP_FONT, DetFont);
        ObjectSetString(0, DetailsOrderProfitI, OBJPROP_TEXT, TextProfit);
        ObjectSet(DetailsOrderProfitI, OBJPROP_SELECTABLE, false);
        ObjectSetInteger(0, DetailsOrderProfitI, OBJPROP_COLOR, clrBlack);

        ObjectCreate(0, DetailsOrderMagicI, OBJ_EDIT, 0, 0, 0);
        ObjectSet(DetailsOrderMagicI, OBJPROP_XDISTANCE, DetXoff + (DetGLabelX + 2) * 10 + 2);
        ObjectSet(DetailsOrderMagicI, OBJPROP_YDISTANCE, DetYoff + DetButtonY + (DetGLabelY + 5) * j + 20);
        ObjectSetInteger(0, DetailsOrderMagicI, OBJPROP_XSIZE, DetGLabelX);
        ObjectSetInteger(0, DetailsOrderMagicI, OBJPROP_YSIZE, DetGLabelY);
        ObjectSetInteger(0, DetailsOrderMagicI, OBJPROP_BORDER_TYPE, BORDER_FLAT);
        ObjectSetInteger(0, DetailsOrderMagicI, OBJPROP_STATE, false);
        ObjectSetInteger(0, DetailsOrderMagicI, OBJPROP_HIDDEN, true);
        ObjectSetInteger(0, DetailsOrderMagicI, OBJPROP_READONLY, true);
        ObjectSetInteger(0, DetailsOrderMagicI, OBJPROP_FONTSIZE, NOFontSize);
        ObjectSetString(0, DetailsOrderMagicI, OBJPROP_TOOLTIP, "Order Magic Number");
        ObjectSetInteger(0, DetailsOrderMagicI, OBJPROP_ALIGN, ALIGN_CENTER);
        ObjectSetString(0, DetailsOrderMagicI, OBJPROP_FONT, DetFont);
        ObjectSetString(0, DetailsOrderMagicI, OBJPROP_TEXT, TextMagic);
        ObjectSet(DetailsOrderMagicI, OBJPROP_SELECTABLE, false);
        ObjectSetInteger(0, DetailsOrderMagicI, OBJPROP_COLOR, clrBlack);

        ObjectCreate(0, DetailsOrderCommentI, OBJ_EDIT, 0, 0, 0);
        ObjectSet(DetailsOrderCommentI, OBJPROP_XDISTANCE, DetXoff + (DetGLabelX + 2) * 11 + 2);
        ObjectSet(DetailsOrderCommentI, OBJPROP_YDISTANCE, DetYoff + DetButtonY + (DetGLabelY + 5) * j + 20);
        ObjectSetInteger(0, DetailsOrderCommentI, OBJPROP_XSIZE, DetCmntLabelX);
        ObjectSetInteger(0, DetailsOrderCommentI, OBJPROP_YSIZE, DetGLabelY);
        ObjectSetInteger(0, DetailsOrderCommentI, OBJPROP_BORDER_TYPE, BORDER_FLAT);
        ObjectSetInteger(0, DetailsOrderCommentI, OBJPROP_STATE, false);
        ObjectSetInteger(0, DetailsOrderCommentI, OBJPROP_HIDDEN, true);
        ObjectSetInteger(0, DetailsOrderCommentI, OBJPROP_READONLY, true);
        ObjectSetInteger(0, DetailsOrderCommentI, OBJPROP_FONTSIZE, NOFontSize);
        ObjectSetString(0, DetailsOrderCommentI, OBJPROP_TOOLTIP, "Order Comment");
        ObjectSetInteger(0, DetailsOrderCommentI, OBJPROP_ALIGN, ALIGN_CENTER);
        ObjectSetString(0, DetailsOrderCommentI, OBJPROP_FONT, DetFont);
        ObjectSetString(0, DetailsOrderCommentI, OBJPROP_TEXT, TextCmnt);
        ObjectSet(DetailsOrderCommentI, OBJPROP_SELECTABLE, false);
        ObjectSetInteger(0, DetailsOrderCommentI, OBJPROP_COLOR, clrBlack);

        j++;
    }
    DetailsOpen = true;
}

void CloseDetails()
{
    ObjectsDeleteAll(0, IndicatorName + "-D-");
    DetailsOpen = false;
}

string EditBase = IndicatorName + "-E-Base";
string EditSave = IndicatorName + "-E-Save";
string EditClose = IndicatorName + "-E-Close";
string EditExit = IndicatorName + "-E-Exit";
string EditPage = IndicatorName + "-E-Page";
string EditPrev = IndicatorName + "-E-Prev";
string EditNext = IndicatorName + "-E-Next";
string EditOrderNumber = IndicatorName + "-E-OrderNumber";
string EditOrderDate = IndicatorName + "-E-OrderDate";
string EditOrderTime = IndicatorName + "-E-OrderTime";
string EditOrderMagic = IndicatorName + "-E-OrderMagic";
string EditOrderSymbol = IndicatorName + "-E-OrderSymbol";
string EditOrderType = IndicatorName + "-E-OrderType";
string EditOrderSize = IndicatorName + "-E-OrderSize";
string EditOrderPrice = IndicatorName + "-E-OrderPrice";
string EditOrderSL = IndicatorName + "-E-OrderSL";
string EditOrderTP = IndicatorName + "-E-OrderTP";
string EditOrderProfit = IndicatorName + "-E-Profit";
string EditOrderComment = IndicatorName + "-E-OrderCmnt";
string EditOrderNumberI = IndicatorName + "-E-OrderNumberI";
string EditOrderDateI = IndicatorName + "-E-OrderDateI";
string EditOrderTimeI = IndicatorName + "-E-OrderTimeI";
string EditOrderMagicI = IndicatorName + "-E-OrderMagicI";
string EditOrderSymbolI = IndicatorName + "-E-OrderSymbolI";
string EditOrderTypeI = IndicatorName + "-E-OrderTypeI";
string EditOrderSizeI = IndicatorName + "-E-OrderSizeI";
string EditOrderPriceI = IndicatorName + "-E-OrderPriceI";
string EditOrderSLI = IndicatorName + "-E-OrderSLI";
string EditOrderTPI = IndicatorName + "-E-OrderTPI";
string EditOrderProfitI = IndicatorName + "-E-ProfitI";
string EditOrderCommentI = IndicatorName + "-E-OrderCmntI";
int EditIndexPrev = -1;
int EditIndexNext = -1;
int EditIndexCurr = 0;
void ShowEdit(int Order = -1)
{
    CloseDetails();
    CloseSettings();
    CloseNewOrder();
    EditOpen = true;
    ScanOrders();
    if (TotalOrders == 0) return;
    if (Order == -1) Order = (int)Orders[0][1];
    EditIndexPrev = -1;
    EditIndexNext = -1;
    EditIndexCurr = 0;
    int CurrIndex = -1;
    int EditXoff = Xoff;
    int EditYoff = Yoff + PanelMovY + 2 * 4;
    int EditX = 0;
    int EditY = 0;
    int OrdersThisPage = 1;
    if (TotalOrders == 0)
    {
        EditX = (DetButtonX + 1) * 3;
        EditY = DetButtonY + 2 * 2;
    }
    else
    {
        EditX = (DetGLabelX + 2) * 11 + DetCmntLabelX + 4;
        EditY = DetButtonY + (DetGLabelY + 5) * (OrdersThisPage + 1) + 10 + 7;
    }
    for (int i = 0; i < TotalOrders; i++)
    {
        if (Orders[i][1] == Order)
        {
            CurrIndex = i + 1;
            EditIndexCurr = (int)Orders[i][1];
            if (i > 0) EditIndexPrev = (int)Orders[i - 1][1];
            if (i < TotalOrders - 1) EditIndexNext = (int)Orders[i + 1][1];
        }
    }
    if (CurrIndex == -1) return;

    ObjectCreate(0, EditBase, OBJ_RECTANGLE_LABEL, 0, 0, 0);
    ObjectSet(EditBase, OBJPROP_XDISTANCE, EditXoff);
    ObjectSet(EditBase, OBJPROP_YDISTANCE, EditYoff);
    ObjectSetInteger(0, EditBase, OBJPROP_XSIZE, EditX);
    ObjectSetInteger(0, EditBase, OBJPROP_YSIZE, EditY);
    ObjectSetInteger(0, EditBase, OBJPROP_BGCOLOR, clrWhite);
    ObjectSetInteger(0, EditBase, OBJPROP_BORDER_TYPE, BORDER_FLAT);
    ObjectSetInteger(0, EditBase, OBJPROP_STATE, false);
    ObjectSetInteger(0, EditBase, OBJPROP_HIDDEN, true);
    ObjectSetInteger(0, EditBase, OBJPROP_FONTSIZE, NOFontSize);
    ObjectSet(EditBase, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, EditBase, OBJPROP_COLOR, clrBlack);

    ObjectCreate(0, EditSave, OBJ_EDIT, 0, 0, 0);
    ObjectSet(EditSave, OBJPROP_XDISTANCE, EditXoff + 2);
    ObjectSet(EditSave, OBJPROP_YDISTANCE, EditYoff + 2);
    ObjectSetInteger(0, EditSave, OBJPROP_XSIZE, DetButtonX);
    ObjectSetInteger(0, EditSave, OBJPROP_YSIZE, DetButtonY);
    ObjectSetInteger(0, EditSave, OBJPROP_BORDER_TYPE, BORDER_FLAT);
    ObjectSetInteger(0, EditSave, OBJPROP_STATE, false);
    ObjectSetInteger(0, EditSave, OBJPROP_HIDDEN, true);
    ObjectSetInteger(0, EditSave, OBJPROP_READONLY, true);
    ObjectSetInteger(0, EditSave, OBJPROP_FONTSIZE, NOFontSize);
    ObjectSetString(0, EditSave, OBJPROP_TOOLTIP, "Update Order");
    ObjectSetInteger(0, EditSave, OBJPROP_ALIGN, ALIGN_CENTER);
    ObjectSetString(0, EditSave, OBJPROP_FONT, DetFont);
    ObjectSetString(0, EditSave, OBJPROP_TEXT, "Update");
    ObjectSet(EditSave, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, EditSave, OBJPROP_COLOR, clrBlack);
    ObjectSetInteger(0, EditSave, OBJPROP_BGCOLOR, clrPaleGreen);
    ObjectSetInteger(0, EditSave, OBJPROP_BORDER_COLOR, clrBlack);

    ObjectCreate(0, EditClose, OBJ_EDIT, 0, 0, 0);
    ObjectSet(EditClose, OBJPROP_XDISTANCE, EditXoff + (DetButtonX + 2) * 1 + 2);
    ObjectSet(EditClose, OBJPROP_YDISTANCE, EditYoff + 2);
    ObjectSetInteger(0, EditClose, OBJPROP_XSIZE, DetButtonX);
    ObjectSetInteger(0, EditClose, OBJPROP_YSIZE, DetButtonY);
    ObjectSetInteger(0, EditClose, OBJPROP_BORDER_TYPE, BORDER_FLAT);
    ObjectSetInteger(0, EditClose, OBJPROP_STATE, false);
    ObjectSetInteger(0, EditClose, OBJPROP_HIDDEN, true);
    ObjectSetInteger(0, EditClose, OBJPROP_READONLY, true);
    ObjectSetInteger(0, EditClose, OBJPROP_FONTSIZE, NOFontSize);
    ObjectSetString(0, EditClose, OBJPROP_TOOLTIP, "Close/Delete Order");
    ObjectSetInteger(0, EditClose, OBJPROP_ALIGN, ALIGN_CENTER);
    ObjectSetString(0, EditClose, OBJPROP_FONT, DetFont);
    ObjectSetString(0, EditClose, OBJPROP_TEXT, "Close");
    ObjectSet(EditClose, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, EditClose, OBJPROP_COLOR, clrBlack);
    ObjectSetInteger(0, EditClose, OBJPROP_BGCOLOR, clrPaleGreen);
    ObjectSetInteger(0, EditClose, OBJPROP_BORDER_COLOR, clrBlack);

    ObjectCreate(0, EditExit, OBJ_EDIT, 0, 0, 0);
    ObjectSet(EditExit, OBJPROP_XDISTANCE, EditXoff + (DetButtonX + 2) * 2 + 2);
    ObjectSet(EditExit, OBJPROP_YDISTANCE, EditYoff + 2);
    ObjectSetInteger(0, EditExit, OBJPROP_XSIZE, DetButtonX);
    ObjectSetInteger(0, EditExit, OBJPROP_YSIZE, DetButtonY);
    ObjectSetInteger(0, EditExit, OBJPROP_BORDER_TYPE, BORDER_FLAT);
    ObjectSetInteger(0, EditExit, OBJPROP_STATE, false);
    ObjectSetInteger(0, EditExit, OBJPROP_HIDDEN, true);
    ObjectSetInteger(0, EditExit, OBJPROP_READONLY, true);
    ObjectSetInteger(0, EditExit, OBJPROP_FONTSIZE, NOFontSize);
    ObjectSetString(0, EditExit, OBJPROP_TOOLTIP, "Exit Edit Panel");
    ObjectSetInteger(0, EditExit, OBJPROP_ALIGN, ALIGN_CENTER);
    ObjectSetString(0, EditExit, OBJPROP_FONT, DetFont);
    ObjectSetString(0, EditExit, OBJPROP_TEXT, "X");
    ObjectSet(EditExit, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, EditExit, OBJPROP_COLOR, clrBlack);
    ObjectSetInteger(0, EditExit, OBJPROP_BGCOLOR, clrCrimson);
    ObjectSetInteger(0, EditExit, OBJPROP_BORDER_COLOR, clrBlack);

    if (TotalOrders > 1)
    {
        string TextPage = IntegerToString(CurrIndex) + " / " + IntegerToString(TotalOrders);
        ObjectCreate(0, EditPage, OBJ_EDIT, 0, 0, 0);
        ObjectSet(EditPage, OBJPROP_XDISTANCE, EditXoff + (DetButtonX + 2) * 5 + 2);
        ObjectSet(EditPage, OBJPROP_YDISTANCE, EditYoff + 2);
        ObjectSetInteger(0, EditPage, OBJPROP_XSIZE, DetButtonX);
        ObjectSetInteger(0, EditPage, OBJPROP_YSIZE, DetButtonY);
        ObjectSetInteger(0, EditPage, OBJPROP_BORDER_TYPE, BORDER_FLAT);
        ObjectSetInteger(0, EditPage, OBJPROP_STATE, false);
        ObjectSetInteger(0, EditPage, OBJPROP_HIDDEN, true);
        ObjectSetInteger(0, EditPage, OBJPROP_READONLY, true);
        ObjectSetInteger(0, EditPage, OBJPROP_FONTSIZE, NOFontSize);
        ObjectSetString(0, EditPage, OBJPROP_TOOLTIP, "Page");
        ObjectSetInteger(0, EditPage, OBJPROP_ALIGN, ALIGN_CENTER);
        ObjectSetString(0, EditPage, OBJPROP_FONT, DetFont);
        ObjectSetString(0, EditPage, OBJPROP_TEXT, TextPage);
        ObjectSet(EditPage, OBJPROP_SELECTABLE, false);
        ObjectSetInteger(0, EditPage, OBJPROP_COLOR, clrBlack);
        ObjectSetInteger(0, EditPage, OBJPROP_BGCOLOR, clrPaleGreen);
        ObjectSetInteger(0, EditPage, OBJPROP_BORDER_COLOR, clrBlack);

        ObjectCreate(0, EditPrev, OBJ_EDIT, 0, 0, 0);
        ObjectSet(EditPrev, OBJPROP_XDISTANCE, EditXoff + (DetButtonX + 2) * 4 + 2);
        ObjectSet(EditPrev, OBJPROP_YDISTANCE, EditYoff + 2);
        ObjectSetInteger(0, EditPrev, OBJPROP_XSIZE, DetButtonX);
        ObjectSetInteger(0, EditPrev, OBJPROP_YSIZE, DetButtonY);
        ObjectSetInteger(0, EditPrev, OBJPROP_BORDER_TYPE, BORDER_FLAT);
        ObjectSetInteger(0, EditPrev, OBJPROP_STATE, false);
        ObjectSetInteger(0, EditPrev, OBJPROP_HIDDEN, true);
        ObjectSetInteger(0, EditPrev, OBJPROP_READONLY, true);
        ObjectSetInteger(0, EditPrev, OBJPROP_FONTSIZE, NOFontSize);
        ObjectSetString(0, EditPrev, OBJPROP_TOOLTIP, "Go to previous page");
        ObjectSetInteger(0, EditPrev, OBJPROP_ALIGN, ALIGN_CENTER);
        ObjectSetString(0, EditPrev, OBJPROP_FONT, DetFont);
        ObjectSetString(0, EditPrev, OBJPROP_TEXT, "Prev");
        ObjectSet(EditPrev, OBJPROP_SELECTABLE, false);
        ObjectSetInteger(0, EditPrev, OBJPROP_COLOR, clrBlack);
        ObjectSetInteger(0, EditPrev, OBJPROP_BGCOLOR, clrPaleGreen);
        ObjectSetInteger(0, EditPrev, OBJPROP_BORDER_COLOR, clrBlack);

        ObjectCreate(0, EditNext, OBJ_EDIT, 0, 0, 0);
        ObjectSet(EditNext, OBJPROP_XDISTANCE, EditXoff + (DetButtonX + 2) * 6 + 2);
        ObjectSet(EditNext, OBJPROP_YDISTANCE, EditYoff + 2);
        ObjectSetInteger(0, EditNext, OBJPROP_XSIZE, DetButtonX);
        ObjectSetInteger(0, EditNext, OBJPROP_YSIZE, DetButtonY);
        ObjectSetInteger(0, EditNext, OBJPROP_BORDER_TYPE, BORDER_FLAT);
        ObjectSetInteger(0, EditNext, OBJPROP_STATE, false);
        ObjectSetInteger(0, EditNext, OBJPROP_HIDDEN, true);
        ObjectSetInteger(0, EditNext, OBJPROP_READONLY, true);
        ObjectSetInteger(0, EditNext, OBJPROP_FONTSIZE, NOFontSize);
        ObjectSetString(0, EditNext, OBJPROP_TOOLTIP, "Go to next page");
        ObjectSetInteger(0, EditNext, OBJPROP_ALIGN, ALIGN_CENTER);
        ObjectSetString(0, EditNext, OBJPROP_FONT, DetFont);
        ObjectSetString(0, EditNext, OBJPROP_TEXT, "Next");
        ObjectSet(EditNext, OBJPROP_SELECTABLE, false);
        ObjectSetInteger(0, EditNext, OBJPROP_COLOR, clrBlack);
        ObjectSetInteger(0, EditNext, OBJPROP_BGCOLOR, clrPaleGreen);
        ObjectSetInteger(0, EditNext, OBJPROP_BORDER_COLOR, clrBlack);
    }

    ObjectCreate(0, EditOrderNumber, OBJ_EDIT, 0, 0, 0);
    ObjectSet(EditOrderNumber, OBJPROP_XDISTANCE, EditXoff + 2);
    ObjectSet(EditOrderNumber, OBJPROP_YDISTANCE, (EditYoff + 2) + (DetButtonY + 2) + 10);
    ObjectSetInteger(0, EditOrderNumber, OBJPROP_XSIZE, DetGLabelX);
    ObjectSetInteger(0, EditOrderNumber, OBJPROP_YSIZE, DetGLabelY);
    ObjectSetInteger(0, EditOrderNumber, OBJPROP_BORDER_TYPE, BORDER_FLAT);
    ObjectSetInteger(0, EditOrderNumber, OBJPROP_STATE, false);
    ObjectSetInteger(0, EditOrderNumber, OBJPROP_HIDDEN, true);
    ObjectSetInteger(0, EditOrderNumber, OBJPROP_READONLY, true);
    ObjectSetInteger(0, EditOrderNumber, OBJPROP_FONTSIZE, NOFontSize);
    ObjectSetString(0, EditOrderNumber, OBJPROP_TOOLTIP, "Order Number");
    ObjectSetInteger(0, EditOrderNumber, OBJPROP_ALIGN, ALIGN_CENTER);
    ObjectSetString(0, EditOrderNumber, OBJPROP_FONT, DetFont);
    ObjectSetString(0, EditOrderNumber, OBJPROP_TEXT, "Order #");
    ObjectSet(EditOrderNumber, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, EditOrderNumber, OBJPROP_COLOR, clrBlack);
    ObjectSetInteger(0, EditOrderNumber, OBJPROP_BGCOLOR, clrLightCyan);
    ObjectSetInteger(0, EditOrderNumber, OBJPROP_BORDER_COLOR, clrBlack);

    ObjectCreate(0, EditOrderDate, OBJ_EDIT, 0, 0, 0);
    ObjectSet(EditOrderDate, OBJPROP_XDISTANCE, EditXoff + (DetGLabelX + 4));
    ObjectSet(EditOrderDate, OBJPROP_YDISTANCE, (EditYoff + 2) + (DetButtonY + 2) + 10);
    ObjectSetInteger(0, EditOrderDate, OBJPROP_XSIZE, DetGLabelX);
    ObjectSetInteger(0, EditOrderDate, OBJPROP_YSIZE, DetGLabelY);
    ObjectSetInteger(0, EditOrderDate, OBJPROP_BORDER_TYPE, BORDER_FLAT);
    ObjectSetInteger(0, EditOrderDate, OBJPROP_STATE, false);
    ObjectSetInteger(0, EditOrderDate, OBJPROP_HIDDEN, true);
    ObjectSetInteger(0, EditOrderDate, OBJPROP_READONLY, true);
    ObjectSetInteger(0, EditOrderDate, OBJPROP_FONTSIZE, NOFontSize);
    ObjectSetString(0, EditOrderDate, OBJPROP_TOOLTIP, "Open Order Date (YYYY/MM/DD) (Server Date)");
    ObjectSetInteger(0, EditOrderDate, OBJPROP_ALIGN, ALIGN_CENTER);
    ObjectSetString(0, EditOrderDate, OBJPROP_FONT, DetFont);
    ObjectSetString(0, EditOrderDate, OBJPROP_TEXT, "Date");
    ObjectSet(EditOrderDate, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, EditOrderDate, OBJPROP_COLOR, clrBlack);
    ObjectSetInteger(0, EditOrderDate, OBJPROP_BGCOLOR, clrLightCyan);
    ObjectSetInteger(0, EditOrderDate, OBJPROP_BORDER_COLOR, clrBlack);

    ObjectCreate(0, EditOrderTime, OBJ_EDIT, 0, 0, 0);
    ObjectSet(EditOrderTime, OBJPROP_XDISTANCE, EditXoff + (DetGLabelX + 2) * 2 + 2);
    ObjectSet(EditOrderTime, OBJPROP_YDISTANCE, (EditYoff + 2) + (DetButtonY + 2) + 10);
    ObjectSetInteger(0, EditOrderTime, OBJPROP_XSIZE, DetGLabelX);
    ObjectSetInteger(0, EditOrderTime, OBJPROP_YSIZE, DetGLabelY);
    ObjectSetInteger(0, EditOrderTime, OBJPROP_BORDER_TYPE, BORDER_FLAT);
    ObjectSetInteger(0, EditOrderTime, OBJPROP_STATE, false);
    ObjectSetInteger(0, EditOrderTime, OBJPROP_HIDDEN, true);
    ObjectSetInteger(0, EditOrderTime, OBJPROP_READONLY, true);
    ObjectSetInteger(0, EditOrderTime, OBJPROP_FONTSIZE, NOFontSize);
    ObjectSetString(0, EditOrderTime, OBJPROP_TOOLTIP, "Open Order Time (HH:MM) (Server Time)");
    ObjectSetInteger(0, EditOrderTime, OBJPROP_ALIGN, ALIGN_CENTER);
    ObjectSetString(0, EditOrderTime, OBJPROP_FONT, DetFont);
    ObjectSetString(0, EditOrderTime, OBJPROP_TEXT, "Time");
    ObjectSet(EditOrderTime, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, EditOrderTime, OBJPROP_COLOR, clrBlack);
    ObjectSetInteger(0, EditOrderTime, OBJPROP_BGCOLOR, clrLightCyan);
    ObjectSetInteger(0, EditOrderTime, OBJPROP_BORDER_COLOR, clrBlack);

    ObjectCreate(0, EditOrderType, OBJ_EDIT, 0, 0, 0);
    ObjectSet(EditOrderType, OBJPROP_XDISTANCE, EditXoff + (DetGLabelX + 2) * 3 + 2);
    ObjectSet(EditOrderType, OBJPROP_YDISTANCE, (EditYoff + 2) + (DetButtonY + 2) + 10);
    ObjectSetInteger(0, EditOrderType, OBJPROP_XSIZE, DetGLabelX);
    ObjectSetInteger(0, EditOrderType, OBJPROP_YSIZE, DetGLabelY);
    ObjectSetInteger(0, EditOrderType, OBJPROP_BORDER_TYPE, BORDER_FLAT);
    ObjectSetInteger(0, EditOrderType, OBJPROP_STATE, false);
    ObjectSetInteger(0, EditOrderType, OBJPROP_HIDDEN, true);
    ObjectSetInteger(0, EditOrderType, OBJPROP_READONLY, true);
    ObjectSetInteger(0, EditOrderType, OBJPROP_FONTSIZE, NOFontSize);
    ObjectSetString(0, EditOrderType, OBJPROP_TOOLTIP, "Order Type");
    ObjectSetInteger(0, EditOrderType, OBJPROP_ALIGN, ALIGN_CENTER);
    ObjectSetString(0, EditOrderType, OBJPROP_FONT, DetFont);
    ObjectSetString(0, EditOrderType, OBJPROP_TEXT, "Type");
    ObjectSet(EditOrderType, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, EditOrderType, OBJPROP_COLOR, clrBlack);
    ObjectSetInteger(0, EditOrderType, OBJPROP_BGCOLOR, clrLightCyan);
    ObjectSetInteger(0, EditOrderType, OBJPROP_BORDER_COLOR, clrBlack);

    ObjectCreate(0, EditOrderSize, OBJ_EDIT, 0, 0, 0);
    ObjectSet(EditOrderSize, OBJPROP_XDISTANCE, EditXoff + (DetGLabelX + 2) * 4 + 2);
    ObjectSet(EditOrderSize, OBJPROP_YDISTANCE, (EditYoff + 2) + (DetButtonY + 2) + 10);
    ObjectSetInteger(0, EditOrderSize, OBJPROP_XSIZE, DetGLabelX);
    ObjectSetInteger(0, EditOrderSize, OBJPROP_YSIZE, DetGLabelY);
    ObjectSetInteger(0, EditOrderSize, OBJPROP_BORDER_TYPE, BORDER_FLAT);
    ObjectSetInteger(0, EditOrderSize, OBJPROP_STATE, false);
    ObjectSetInteger(0, EditOrderSize, OBJPROP_HIDDEN, true);
    ObjectSetInteger(0, EditOrderSize, OBJPROP_READONLY, true);
    ObjectSetInteger(0, EditOrderSize, OBJPROP_FONTSIZE, NOFontSize);
    ObjectSetString(0, EditOrderSize, OBJPROP_TOOLTIP, "Order Size");
    ObjectSetInteger(0, EditOrderSize, OBJPROP_ALIGN, ALIGN_CENTER);
    ObjectSetString(0, EditOrderSize, OBJPROP_FONT, DetFont);
    ObjectSetString(0, EditOrderSize, OBJPROP_TEXT, "Size");
    ObjectSet(EditOrderSize, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, EditOrderSize, OBJPROP_COLOR, clrBlack);
    ObjectSetInteger(0, EditOrderSize, OBJPROP_BGCOLOR, clrLightCyan);
    ObjectSetInteger(0, EditOrderSize, OBJPROP_BORDER_COLOR, clrBlack);

    ObjectCreate(0, EditOrderSymbol, OBJ_EDIT, 0, 0, 0);
    ObjectSet(EditOrderSymbol, OBJPROP_XDISTANCE, EditXoff + (DetGLabelX + 2) * 5 + 2);
    ObjectSet(EditOrderSymbol, OBJPROP_YDISTANCE, (EditYoff + 2) + (DetButtonY + 2) + 10);
    ObjectSetInteger(0, EditOrderSymbol, OBJPROP_XSIZE, DetGLabelX);
    ObjectSetInteger(0, EditOrderSymbol, OBJPROP_YSIZE, DetGLabelY);
    ObjectSetInteger(0, EditOrderSymbol, OBJPROP_BORDER_TYPE, BORDER_FLAT);
    ObjectSetInteger(0, EditOrderSymbol, OBJPROP_STATE, false);
    ObjectSetInteger(0, EditOrderSymbol, OBJPROP_HIDDEN, true);
    ObjectSetInteger(0, EditOrderSymbol, OBJPROP_READONLY, true);
    ObjectSetInteger(0, EditOrderSymbol, OBJPROP_FONTSIZE, NOFontSize);
    ObjectSetString(0, EditOrderSymbol, OBJPROP_TOOLTIP, "Order Symbol");
    ObjectSetInteger(0, EditOrderSymbol, OBJPROP_ALIGN, ALIGN_CENTER);
    ObjectSetString(0, EditOrderSymbol, OBJPROP_FONT, DetFont);
    ObjectSetString(0, EditOrderSymbol, OBJPROP_TEXT, "Symbol");
    ObjectSet(EditOrderSymbol, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, EditOrderSymbol, OBJPROP_COLOR, clrBlack);
    ObjectSetInteger(0, EditOrderSymbol, OBJPROP_BGCOLOR, clrLightCyan);
    ObjectSetInteger(0, EditOrderSymbol, OBJPROP_BORDER_COLOR, clrBlack);

    ObjectCreate(0, EditOrderPrice, OBJ_EDIT, 0, 0, 0);
    ObjectSet(EditOrderPrice, OBJPROP_XDISTANCE, EditXoff + (DetGLabelX + 2) * 6 + 2);
    ObjectSet(EditOrderPrice, OBJPROP_YDISTANCE, (EditYoff + 2) + (DetButtonY + 2) + 10);
    ObjectSetInteger(0, EditOrderPrice, OBJPROP_XSIZE, DetGLabelX);
    ObjectSetInteger(0, EditOrderPrice, OBJPROP_YSIZE, DetGLabelY);
    ObjectSetInteger(0, EditOrderPrice, OBJPROP_BORDER_TYPE, BORDER_FLAT);
    ObjectSetInteger(0, EditOrderPrice, OBJPROP_STATE, false);
    ObjectSetInteger(0, EditOrderPrice, OBJPROP_HIDDEN, true);
    ObjectSetInteger(0, EditOrderPrice, OBJPROP_READONLY, true);
    ObjectSetInteger(0, EditOrderPrice, OBJPROP_FONTSIZE, NOFontSize);
    ObjectSetString(0, EditOrderPrice, OBJPROP_TOOLTIP, "Order Open Price");
    ObjectSetInteger(0, EditOrderPrice, OBJPROP_ALIGN, ALIGN_CENTER);
    ObjectSetString(0, EditOrderPrice, OBJPROP_FONT, DetFont);
    ObjectSetString(0, EditOrderPrice, OBJPROP_TEXT, "OP");
    ObjectSet(EditOrderPrice, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, EditOrderPrice, OBJPROP_COLOR, clrBlack);
    ObjectSetInteger(0, EditOrderPrice, OBJPROP_BGCOLOR, clrLightCyan);
    ObjectSetInteger(0, EditOrderPrice, OBJPROP_BORDER_COLOR, clrBlack);

    ObjectCreate(0, EditOrderSL, OBJ_EDIT, 0, 0, 0);
    ObjectSet(EditOrderSL, OBJPROP_XDISTANCE, EditXoff + (DetGLabelX + 2) * 7 + 2);
    ObjectSet(EditOrderSL, OBJPROP_YDISTANCE, (EditYoff + 2) + (DetButtonY + 2) + 10);
    ObjectSetInteger(0, EditOrderSL, OBJPROP_XSIZE, DetGLabelX);
    ObjectSetInteger(0, EditOrderSL, OBJPROP_YSIZE, DetGLabelY);
    ObjectSetInteger(0, EditOrderSL, OBJPROP_BORDER_TYPE, BORDER_FLAT);
    ObjectSetInteger(0, EditOrderSL, OBJPROP_STATE, false);
    ObjectSetInteger(0, EditOrderSL, OBJPROP_HIDDEN, true);
    ObjectSetInteger(0, EditOrderSL, OBJPROP_READONLY, true);
    ObjectSetInteger(0, EditOrderSL, OBJPROP_FONTSIZE, NOFontSize);
    ObjectSetString(0, EditOrderSL, OBJPROP_TOOLTIP, "Order Stop Loss Price");
    ObjectSetInteger(0, EditOrderSL, OBJPROP_ALIGN, ALIGN_CENTER);
    ObjectSetString(0, EditOrderSL, OBJPROP_FONT, DetFont);
    ObjectSetString(0, EditOrderSL, OBJPROP_TEXT, "SL");
    ObjectSet(EditOrderSL, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, EditOrderSL, OBJPROP_COLOR, clrBlack);
    ObjectSetInteger(0, EditOrderSL, OBJPROP_BGCOLOR, clrLightCyan);
    ObjectSetInteger(0, EditOrderSL, OBJPROP_BORDER_COLOR, clrBlack);

    ObjectCreate(0, EditOrderTP, OBJ_EDIT, 0, 0, 0);
    ObjectSet(EditOrderTP, OBJPROP_XDISTANCE, EditXoff + (DetGLabelX + 2) * 8 + 2);
    ObjectSet(EditOrderTP, OBJPROP_YDISTANCE, (EditYoff + 2) + (DetButtonY + 2) + 10);
    ObjectSetInteger(0, EditOrderTP, OBJPROP_XSIZE, DetGLabelX);
    ObjectSetInteger(0, EditOrderTP, OBJPROP_YSIZE, DetGLabelY);
    ObjectSetInteger(0, EditOrderTP, OBJPROP_BORDER_TYPE, BORDER_FLAT);
    ObjectSetInteger(0, EditOrderTP, OBJPROP_STATE, false);
    ObjectSetInteger(0, EditOrderTP, OBJPROP_HIDDEN, true);
    ObjectSetInteger(0, EditOrderTP, OBJPROP_READONLY, true);
    ObjectSetInteger(0, EditOrderTP, OBJPROP_FONTSIZE, NOFontSize);
    ObjectSetString(0, EditOrderTP, OBJPROP_TOOLTIP, "Order Take Profit Price");
    ObjectSetInteger(0, EditOrderTP, OBJPROP_ALIGN, ALIGN_CENTER);
    ObjectSetString(0, EditOrderTP, OBJPROP_FONT, DetFont);
    ObjectSetString(0, EditOrderTP, OBJPROP_TEXT, "TP");
    ObjectSet(EditOrderTP, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, EditOrderTP, OBJPROP_COLOR, clrBlack);
    ObjectSetInteger(0, EditOrderTP, OBJPROP_BGCOLOR, clrLightCyan);
    ObjectSetInteger(0, EditOrderTP, OBJPROP_BORDER_COLOR, clrBlack);

    ObjectCreate(0, EditOrderProfit, OBJ_EDIT, 0, 0, 0);
    ObjectSet(EditOrderProfit, OBJPROP_XDISTANCE, EditXoff + (DetGLabelX + 2) * 9 + 2);
    ObjectSet(EditOrderProfit, OBJPROP_YDISTANCE, (EditYoff + 2) + (DetButtonY + 2) + 10);
    ObjectSetInteger(0, EditOrderProfit, OBJPROP_XSIZE, DetGLabelX);
    ObjectSetInteger(0, EditOrderProfit, OBJPROP_YSIZE, DetGLabelY);
    ObjectSetInteger(0, EditOrderProfit, OBJPROP_BORDER_TYPE, BORDER_FLAT);
    ObjectSetInteger(0, EditOrderProfit, OBJPROP_STATE, false);
    ObjectSetInteger(0, EditOrderProfit, OBJPROP_HIDDEN, true);
    ObjectSetInteger(0, EditOrderProfit, OBJPROP_READONLY, true);
    ObjectSetInteger(0, EditOrderProfit, OBJPROP_FONTSIZE, NOFontSize);
    ObjectSetString(0, EditOrderProfit, OBJPROP_TOOLTIP, "Order Current Profit/Loss");
    ObjectSetInteger(0, EditOrderProfit, OBJPROP_ALIGN, ALIGN_CENTER);
    ObjectSetString(0, EditOrderProfit, OBJPROP_FONT, DetFont);
    ObjectSetString(0, EditOrderProfit, OBJPROP_TEXT, "Profit");
    ObjectSet(EditOrderProfit, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, EditOrderProfit, OBJPROP_COLOR, clrBlack);
    ObjectSetInteger(0, EditOrderProfit, OBJPROP_BGCOLOR, clrLightCyan);
    ObjectSetInteger(0, EditOrderProfit, OBJPROP_BORDER_COLOR, clrBlack);

    ObjectCreate(0, EditOrderMagic, OBJ_EDIT, 0, 0, 0);
    ObjectSet(EditOrderMagic, OBJPROP_XDISTANCE, EditXoff + (DetGLabelX + 2) * 10 + 2);
    ObjectSet(EditOrderMagic, OBJPROP_YDISTANCE, (EditYoff + 2) + (DetButtonY + 2) + 10);
    ObjectSetInteger(0, EditOrderMagic, OBJPROP_XSIZE, DetGLabelX);
    ObjectSetInteger(0, EditOrderMagic, OBJPROP_YSIZE, DetGLabelY);
    ObjectSetInteger(0, EditOrderMagic, OBJPROP_BORDER_TYPE, BORDER_FLAT);
    ObjectSetInteger(0, EditOrderMagic, OBJPROP_STATE, false);
    ObjectSetInteger(0, EditOrderMagic, OBJPROP_HIDDEN, true);
    ObjectSetInteger(0, EditOrderMagic, OBJPROP_READONLY, true);
    ObjectSetInteger(0, EditOrderMagic, OBJPROP_FONTSIZE, NOFontSize);
    ObjectSetString(0, EditOrderMagic, OBJPROP_TOOLTIP, "Order Magic Number");
    ObjectSetInteger(0, EditOrderMagic, OBJPROP_ALIGN, ALIGN_CENTER);
    ObjectSetString(0, EditOrderMagic, OBJPROP_FONT, DetFont);
    ObjectSetString(0, EditOrderMagic, OBJPROP_TEXT, "Magic");
    ObjectSet(EditOrderMagic, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, EditOrderMagic, OBJPROP_COLOR, clrBlack);
    ObjectSetInteger(0, EditOrderMagic, OBJPROP_BGCOLOR, clrLightCyan);
    ObjectSetInteger(0, EditOrderMagic, OBJPROP_BORDER_COLOR, clrBlack);

    ObjectCreate(0, EditOrderComment, OBJ_EDIT, 0, 0, 0);
    ObjectSet(EditOrderComment, OBJPROP_XDISTANCE, EditXoff + (DetGLabelX + 2) * 11 + 2);
    ObjectSet(EditOrderComment, OBJPROP_YDISTANCE, (EditYoff + 2) + (DetButtonY + 2) + 10);
    ObjectSetInteger(0, EditOrderComment, OBJPROP_XSIZE, DetCmntLabelX);
    ObjectSetInteger(0, EditOrderComment, OBJPROP_YSIZE, DetGLabelY);
    ObjectSetInteger(0, EditOrderComment, OBJPROP_BORDER_TYPE, BORDER_FLAT);
    ObjectSetInteger(0, EditOrderComment, OBJPROP_STATE, false);
    ObjectSetInteger(0, EditOrderComment, OBJPROP_HIDDEN, true);
    ObjectSetInteger(0, EditOrderComment, OBJPROP_READONLY, true);
    ObjectSetInteger(0, EditOrderComment, OBJPROP_FONTSIZE, NOFontSize);
    ObjectSetString(0, EditOrderComment, OBJPROP_TOOLTIP, "Order Comment");
    ObjectSetInteger(0, EditOrderComment, OBJPROP_ALIGN, ALIGN_CENTER);
    ObjectSetString(0, EditOrderComment, OBJPROP_FONT, DetFont);
    ObjectSetString(0, EditOrderComment, OBJPROP_TEXT, "Comment");
    ObjectSet(EditOrderComment, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, EditOrderComment, OBJPROP_COLOR, clrBlack);
    ObjectSetInteger(0, EditOrderComment, OBJPROP_BGCOLOR, clrLightCyan);
    ObjectSetInteger(0, EditOrderComment, OBJPROP_BORDER_COLOR, clrBlack);

    int OrderNumber = Order;
    if (!OrderSelect(OrderNumber, SELECT_BY_TICKET)) Print("Error selecting the order");
    string TextTicket = IntegerToString(OrderTicket());
    string TextMagic = IntegerToString(OrderMagicNumber());
    string TextDate = TimeToStr(OrderOpenTime(), TIME_DATE);
    string TextTime = TimeToStr(OrderOpenTime(), TIME_MINUTES);
    string TextSymbol = OrderSymbol();
    string TextType = "";
    if (OrderType() == OP_BUY) TextType = "BUY";
    else if (OrderType() == OP_SELL) TextType = "SELL";
    else if (OrderType() == OP_BUYLIMIT) TextType = "BUY LIMIT";
    else if (OrderType() == OP_SELLLIMIT) TextType = "SELL LIMIT";
    else if (OrderType() == OP_BUYSTOP) TextType = "BUY STOP";
    else if (OrderType() == OP_SELLSTOP) TextType = "SELL STOP";
    string TextSize = DoubleToStr(OrderLots(), 2);
    int eDigits = (int)MarketInfo(TextSymbol, MODE_DIGITS);
    string TextTP = DoubleToStr(OrderTakeProfit(), eDigits);
    string TextSL = DoubleToStr(OrderStopLoss(), eDigits);
    string TextProfit = DoubleToStr(OrderProfit(), 2);
    string TextPrice = DoubleToStr(OrderOpenPrice(), eDigits);
    string TextCmnt = OrderComment();
    CurrOpenPrice = 0;
    CurrSLPrice = 0;
    CurrTPPrice = 0;
    CurrLotSize = 0;
    if (OrderSymbol() == Symbol())
    {
        if (StringFind(TextType, "SELL") >= 0) CurrLinesSide = LINE_ORDER_SELL;
        if (StringFind(TextType, "BUY") >= 0) CurrLinesSide = LINE_ORDER_BUY;
        CurrOpenPrice = (double)TextPrice;
        CurrSLPrice = (double)TextSL;
        CurrTPPrice = (double)TextTP;
        CurrLotSize = (double)TextSize;
        CurrLinesType = LINE_ORDER_LIMIT; //This is just so I can force UpdateLinesLabel to use the CurrOpenPrice for calculation
        UpdateLineByPrice(LineNameOpen);
        UpdateLineByPrice(LineNameSL);
        UpdateLineByPrice(LineNameTP);
    }
    int j = 1;
    ObjectCreate(0, EditOrderNumberI, OBJ_EDIT, 0, 0, 0);
    ObjectSet(EditOrderNumberI, OBJPROP_XDISTANCE, EditXoff + 2);
    ObjectSet(EditOrderNumberI, OBJPROP_YDISTANCE, EditYoff + DetButtonY + (DetGLabelY + 5) * j + 20);
    ObjectSetInteger(0, EditOrderNumberI, OBJPROP_XSIZE, DetGLabelX);
    ObjectSetInteger(0, EditOrderNumberI, OBJPROP_YSIZE, DetGLabelY);
    ObjectSetInteger(0, EditOrderNumberI, OBJPROP_BORDER_TYPE, BORDER_FLAT);
    ObjectSetInteger(0, EditOrderNumberI, OBJPROP_STATE, false);
    ObjectSetInteger(0, EditOrderNumberI, OBJPROP_HIDDEN, true);
    ObjectSetInteger(0, EditOrderNumberI, OBJPROP_READONLY, true);
    ObjectSetInteger(0, EditOrderNumberI, OBJPROP_FONTSIZE, NOFontSize);
    ObjectSetString(0, EditOrderNumberI, OBJPROP_TOOLTIP, "Order Number");
    ObjectSetInteger(0, EditOrderNumberI, OBJPROP_ALIGN, ALIGN_CENTER);
    ObjectSetString(0, EditOrderNumberI, OBJPROP_FONT, DetFont);
    ObjectSetString(0, EditOrderNumberI, OBJPROP_TEXT, TextTicket);
    ObjectSet(EditOrderNumberI, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, EditOrderNumberI, OBJPROP_COLOR, clrBlack);

    ObjectCreate(0, EditOrderDateI, OBJ_EDIT, 0, 0, 0);
    ObjectSet(EditOrderDateI, OBJPROP_XDISTANCE, EditXoff + (DetGLabelX + 4));
    ObjectSet(EditOrderDateI, OBJPROP_YDISTANCE, EditYoff + DetButtonY + (DetGLabelY + 5) * j + 20);
    ObjectSetInteger(0, EditOrderDateI, OBJPROP_XSIZE, DetGLabelX);
    ObjectSetInteger(0, EditOrderDateI, OBJPROP_YSIZE, DetGLabelY);
    ObjectSetInteger(0, EditOrderDateI, OBJPROP_BORDER_TYPE, BORDER_FLAT);
    ObjectSetInteger(0, EditOrderDateI, OBJPROP_STATE, false);
    ObjectSetInteger(0, EditOrderDateI, OBJPROP_HIDDEN, true);
    ObjectSetInteger(0, EditOrderDateI, OBJPROP_READONLY, true);
    ObjectSetInteger(0, EditOrderDateI, OBJPROP_FONTSIZE, NOFontSize);
    ObjectSetString(0, EditOrderDateI, OBJPROP_TOOLTIP, "Order Date (YYYY/MM/DD)");
    ObjectSetInteger(0, EditOrderDateI, OBJPROP_ALIGN, ALIGN_CENTER);
    ObjectSetString(0, EditOrderDateI, OBJPROP_FONT, DetFont);
    ObjectSetString(0, EditOrderDateI, OBJPROP_TEXT, TextDate);
    ObjectSet(EditOrderDateI, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, EditOrderDateI, OBJPROP_COLOR, clrBlack);

    ObjectCreate(0, EditOrderTimeI, OBJ_EDIT, 0, 0, 0);
    ObjectSet(EditOrderTimeI, OBJPROP_XDISTANCE, EditXoff + (DetGLabelX + 2) * 2 + 2);
    ObjectSet(EditOrderTimeI, OBJPROP_YDISTANCE, EditYoff + DetButtonY + (DetGLabelY + 5) * j + 20);
    ObjectSetInteger(0, EditOrderTimeI, OBJPROP_XSIZE, DetGLabelX);
    ObjectSetInteger(0, EditOrderTimeI, OBJPROP_YSIZE, DetGLabelY);
    ObjectSetInteger(0, EditOrderTimeI, OBJPROP_BORDER_TYPE, BORDER_FLAT);
    ObjectSetInteger(0, EditOrderTimeI, OBJPROP_STATE, false);
    ObjectSetInteger(0, EditOrderTimeI, OBJPROP_HIDDEN, true);
    ObjectSetInteger(0, EditOrderTimeI, OBJPROP_READONLY, true);
    ObjectSetInteger(0, EditOrderTimeI, OBJPROP_FONTSIZE, NOFontSize);
    ObjectSetString(0, EditOrderTimeI, OBJPROP_TOOLTIP, "Order Time (HH:MM)");
    ObjectSetInteger(0, EditOrderTimeI, OBJPROP_ALIGN, ALIGN_CENTER);
    ObjectSetString(0, EditOrderTimeI, OBJPROP_FONT, DetFont);
    ObjectSetString(0, EditOrderTimeI, OBJPROP_TEXT, TextTime);
    ObjectSet(EditOrderTimeI, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, EditOrderTimeI, OBJPROP_COLOR, clrBlack);

    ObjectCreate(0, EditOrderTypeI, OBJ_EDIT, 0, 0, 0);
    ObjectSet(EditOrderTypeI, OBJPROP_XDISTANCE, EditXoff + (DetGLabelX + 2) * 3 + 2);
    ObjectSet(EditOrderTypeI, OBJPROP_YDISTANCE, EditYoff + DetButtonY + (DetGLabelY + 5) * j + 20);
    ObjectSetInteger(0, EditOrderTypeI, OBJPROP_XSIZE, DetGLabelX);
    ObjectSetInteger(0, EditOrderTypeI, OBJPROP_YSIZE, DetGLabelY);
    ObjectSetInteger(0, EditOrderTypeI, OBJPROP_BORDER_TYPE, BORDER_FLAT);
    ObjectSetInteger(0, EditOrderTypeI, OBJPROP_STATE, false);
    ObjectSetInteger(0, EditOrderTypeI, OBJPROP_HIDDEN, true);
    ObjectSetInteger(0, EditOrderTypeI, OBJPROP_READONLY, true);
    ObjectSetInteger(0, EditOrderTypeI, OBJPROP_FONTSIZE, NOFontSize);
    ObjectSetString(0, EditOrderTypeI, OBJPROP_TOOLTIP, "Order Type");
    ObjectSetInteger(0, EditOrderTypeI, OBJPROP_ALIGN, ALIGN_CENTER);
    ObjectSetString(0, EditOrderTypeI, OBJPROP_FONT, DetFont);
    ObjectSetString(0, EditOrderTypeI, OBJPROP_TEXT, TextType);
    ObjectSet(EditOrderTypeI, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, EditOrderTypeI, OBJPROP_COLOR, clrBlack);

    ObjectCreate(0, EditOrderSizeI, OBJ_EDIT, 0, 0, 0);
    ObjectSet(EditOrderSizeI, OBJPROP_XDISTANCE, EditXoff + (DetGLabelX + 2) * 4 + 2);
    ObjectSet(EditOrderSizeI, OBJPROP_YDISTANCE, EditYoff + DetButtonY + (DetGLabelY + 5) * j + 20);
    ObjectSetInteger(0, EditOrderSizeI, OBJPROP_XSIZE, DetGLabelX);
    ObjectSetInteger(0, EditOrderSizeI, OBJPROP_YSIZE, DetGLabelY);
    ObjectSetInteger(0, EditOrderSizeI, OBJPROP_BORDER_TYPE, BORDER_FLAT);
    ObjectSetInteger(0, EditOrderSizeI, OBJPROP_STATE, false);
    ObjectSetInteger(0, EditOrderSizeI, OBJPROP_HIDDEN, true);
    ObjectSetInteger(0, EditOrderSizeI, OBJPROP_READONLY, true);
    ObjectSetInteger(0, EditOrderSizeI, OBJPROP_FONTSIZE, NOFontSize);
    ObjectSetString(0, EditOrderSizeI, OBJPROP_TOOLTIP, "Order Size");
    ObjectSetInteger(0, EditOrderSizeI, OBJPROP_ALIGN, ALIGN_CENTER);
    ObjectSetString(0, EditOrderSizeI, OBJPROP_FONT, DetFont);
    ObjectSetString(0, EditOrderSizeI, OBJPROP_TEXT, TextSize);
    ObjectSet(EditOrderSizeI, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, EditOrderSizeI, OBJPROP_COLOR, clrBlack);

    ObjectCreate(0, EditOrderSymbolI, OBJ_EDIT, 0, 0, 0);
    ObjectSet(EditOrderSymbolI, OBJPROP_XDISTANCE, EditXoff + (DetGLabelX + 2) * 5 + 2);
    ObjectSet(EditOrderSymbolI, OBJPROP_YDISTANCE, EditYoff + DetButtonY + (DetGLabelY + 5) * j + 20);
    ObjectSetInteger(0, EditOrderSymbolI, OBJPROP_XSIZE, DetGLabelX);
    ObjectSetInteger(0, EditOrderSymbolI, OBJPROP_YSIZE, DetGLabelY);
    ObjectSetInteger(0, EditOrderSymbolI, OBJPROP_BORDER_TYPE, BORDER_FLAT);
    ObjectSetInteger(0, EditOrderSymbolI, OBJPROP_STATE, false);
    ObjectSetInteger(0, EditOrderSymbolI, OBJPROP_HIDDEN, true);
    ObjectSetInteger(0, EditOrderSymbolI, OBJPROP_READONLY, true);
    ObjectSetInteger(0, EditOrderSymbolI, OBJPROP_FONTSIZE, NOFontSize);
    ObjectSetString(0, EditOrderSymbolI, OBJPROP_TOOLTIP, "Order Symbol");
    ObjectSetInteger(0, EditOrderSymbolI, OBJPROP_ALIGN, ALIGN_CENTER);
    ObjectSetString(0, EditOrderSymbolI, OBJPROP_FONT, DetFont);
    ObjectSetString(0, EditOrderSymbolI, OBJPROP_TEXT, TextSymbol);
    ObjectSet(EditOrderSymbolI, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, EditOrderSymbolI, OBJPROP_COLOR, clrBlack);

    ObjectCreate(0, EditOrderPriceI, OBJ_EDIT, 0, 0, 0);
    ObjectSet(EditOrderPriceI, OBJPROP_XDISTANCE, EditXoff + (DetGLabelX + 2) * 6 + 2);
    ObjectSet(EditOrderPriceI, OBJPROP_YDISTANCE, EditYoff + DetButtonY + (DetGLabelY + 5) * j + 20);
    ObjectSetInteger(0, EditOrderPriceI, OBJPROP_XSIZE, DetGLabelX);
    ObjectSetInteger(0, EditOrderPriceI, OBJPROP_YSIZE, DetGLabelY);
    ObjectSetInteger(0, EditOrderPriceI, OBJPROP_BORDER_TYPE, BORDER_FLAT);
    ObjectSetInteger(0, EditOrderPriceI, OBJPROP_STATE, false);
    ObjectSetInteger(0, EditOrderPriceI, OBJPROP_HIDDEN, true);
    ObjectSetInteger(0, EditOrderPriceI, OBJPROP_READONLY, true);
    ObjectSetInteger(0, EditOrderPriceI, OBJPROP_FONTSIZE, NOFontSize);
    ObjectSetString(0, EditOrderPriceI, OBJPROP_TOOLTIP, "Order Open Price");
    ObjectSetInteger(0, EditOrderPriceI, OBJPROP_ALIGN, ALIGN_CENTER);
    ObjectSetString(0, EditOrderPriceI, OBJPROP_FONT, DetFont);
    ObjectSetString(0, EditOrderPriceI, OBJPROP_TEXT, TextPrice);
    ObjectSet(EditOrderPriceI, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, EditOrderPriceI, OBJPROP_COLOR, clrBlack);

    ObjectCreate(0, EditOrderSLI, OBJ_EDIT, 0, 0, 0);
    ObjectSet(EditOrderSLI, OBJPROP_XDISTANCE, EditXoff + (DetGLabelX + 2) * 7 + 2);
    ObjectSet(EditOrderSLI, OBJPROP_YDISTANCE, EditYoff + DetButtonY + (DetGLabelY + 5) * j + 20);
    ObjectSetInteger(0, EditOrderSLI, OBJPROP_XSIZE, DetGLabelX);
    ObjectSetInteger(0, EditOrderSLI, OBJPROP_YSIZE, DetGLabelY);
    ObjectSetInteger(0, EditOrderSLI, OBJPROP_BORDER_TYPE, BORDER_FLAT);
    ObjectSetInteger(0, EditOrderSLI, OBJPROP_STATE, false);
    ObjectSetInteger(0, EditOrderSLI, OBJPROP_HIDDEN, true);
    ObjectSetInteger(0, EditOrderSLI, OBJPROP_READONLY, false);
    ObjectSetInteger(0, EditOrderSLI, OBJPROP_FONTSIZE, NOFontSize);
    ObjectSetString(0, EditOrderSLI, OBJPROP_TOOLTIP, "Order Stop Loss Price - Click to Change");
    ObjectSetInteger(0, EditOrderSLI, OBJPROP_ALIGN, ALIGN_CENTER);
    ObjectSetString(0, EditOrderSLI, OBJPROP_FONT, DetFont);
    ObjectSetString(0, EditOrderSLI, OBJPROP_TEXT, TextSL);
    ObjectSet(EditOrderSLI, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, EditOrderSLI, OBJPROP_COLOR, clrBlack);

    ObjectCreate(0, EditOrderTPI, OBJ_EDIT, 0, 0, 0);
    ObjectSet(EditOrderTPI, OBJPROP_XDISTANCE, EditXoff + (DetGLabelX + 2) * 8 + 2);
    ObjectSet(EditOrderTPI, OBJPROP_YDISTANCE, EditYoff + DetButtonY + (DetGLabelY + 5) * j + 20);
    ObjectSetInteger(0, EditOrderTPI, OBJPROP_XSIZE, DetGLabelX);
    ObjectSetInteger(0, EditOrderTPI, OBJPROP_YSIZE, DetGLabelY);
    ObjectSetInteger(0, EditOrderTPI, OBJPROP_BORDER_TYPE, BORDER_FLAT);
    ObjectSetInteger(0, EditOrderTPI, OBJPROP_STATE, false);
    ObjectSetInteger(0, EditOrderTPI, OBJPROP_HIDDEN, true);
    ObjectSetInteger(0, EditOrderTPI, OBJPROP_READONLY, false);
    ObjectSetInteger(0, EditOrderTPI, OBJPROP_FONTSIZE, NOFontSize);
    ObjectSetString(0, EditOrderTPI, OBJPROP_TOOLTIP, "Order Take Profit Price - Click to Change");
    ObjectSetInteger(0, EditOrderTPI, OBJPROP_ALIGN, ALIGN_CENTER);
    ObjectSetString(0, EditOrderTPI, OBJPROP_FONT, DetFont);
    ObjectSetString(0, EditOrderTPI, OBJPROP_TEXT, TextTP);
    ObjectSet(EditOrderTPI, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, EditOrderTPI, OBJPROP_COLOR, clrBlack);

    ObjectCreate(0, EditOrderProfitI, OBJ_EDIT, 0, 0, 0);
    ObjectSet(EditOrderProfitI, OBJPROP_XDISTANCE, EditXoff + (DetGLabelX + 2) * 9 + 2);
    ObjectSet(EditOrderProfitI, OBJPROP_YDISTANCE, EditYoff + DetButtonY + (DetGLabelY + 5) * j + 20);
    ObjectSetInteger(0, EditOrderProfitI, OBJPROP_XSIZE, DetGLabelX);
    ObjectSetInteger(0, EditOrderProfitI, OBJPROP_YSIZE, DetGLabelY);
    ObjectSetInteger(0, EditOrderProfitI, OBJPROP_BORDER_TYPE, BORDER_FLAT);
    ObjectSetInteger(0, EditOrderProfitI, OBJPROP_STATE, false);
    ObjectSetInteger(0, EditOrderProfitI, OBJPROP_HIDDEN, true);
    ObjectSetInteger(0, EditOrderProfitI, OBJPROP_READONLY, true);
    ObjectSetInteger(0, EditOrderProfitI, OBJPROP_FONTSIZE, NOFontSize);
    ObjectSetString(0, EditOrderProfitI, OBJPROP_TOOLTIP, "Order Current Profit/Loss");
    ObjectSetInteger(0, EditOrderProfitI, OBJPROP_ALIGN, ALIGN_CENTER);
    ObjectSetString(0, EditOrderProfitI, OBJPROP_FONT, DetFont);
    ObjectSetString(0, EditOrderProfitI, OBJPROP_TEXT, TextProfit);
    ObjectSet(EditOrderProfitI, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, EditOrderProfitI, OBJPROP_COLOR, clrBlack);

    ObjectCreate(0, EditOrderMagicI, OBJ_EDIT, 0, 0, 0);
    ObjectSet(EditOrderMagicI, OBJPROP_XDISTANCE, EditXoff + (DetGLabelX + 2) * 10 + 2);
    ObjectSet(EditOrderMagicI, OBJPROP_YDISTANCE, EditYoff + DetButtonY + (DetGLabelY + 5) * j + 20);
    ObjectSetInteger(0, EditOrderMagicI, OBJPROP_XSIZE, DetGLabelX);
    ObjectSetInteger(0, EditOrderMagicI, OBJPROP_YSIZE, DetGLabelY);
    ObjectSetInteger(0, EditOrderMagicI, OBJPROP_BORDER_TYPE, BORDER_FLAT);
    ObjectSetInteger(0, EditOrderMagicI, OBJPROP_STATE, false);
    ObjectSetInteger(0, EditOrderMagicI, OBJPROP_HIDDEN, true);
    ObjectSetInteger(0, EditOrderMagicI, OBJPROP_READONLY, true);
    ObjectSetInteger(0, EditOrderMagicI, OBJPROP_FONTSIZE, NOFontSize);
    ObjectSetString(0, EditOrderMagicI, OBJPROP_TOOLTIP, "Order Magic Number");
    ObjectSetInteger(0, EditOrderMagicI, OBJPROP_ALIGN, ALIGN_CENTER);
    ObjectSetString(0, EditOrderMagicI, OBJPROP_FONT, DetFont);
    ObjectSetString(0, EditOrderMagicI, OBJPROP_TEXT, TextMagic);
    ObjectSet(EditOrderMagicI, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, EditOrderMagicI, OBJPROP_COLOR, clrBlack);

    ObjectCreate(0, EditOrderCommentI, OBJ_EDIT, 0, 0, 0);
    ObjectSet(EditOrderCommentI, OBJPROP_XDISTANCE, EditXoff + (DetGLabelX + 2) * 11 + 2);
    ObjectSet(EditOrderCommentI, OBJPROP_YDISTANCE, EditYoff + DetButtonY + (DetGLabelY + 5) * j + 20);
    ObjectSetInteger(0, EditOrderCommentI, OBJPROP_XSIZE, DetCmntLabelX);
    ObjectSetInteger(0, EditOrderCommentI, OBJPROP_YSIZE, DetGLabelY);
    ObjectSetInteger(0, EditOrderCommentI, OBJPROP_BORDER_TYPE, BORDER_FLAT);
    ObjectSetInteger(0, EditOrderCommentI, OBJPROP_STATE, false);
    ObjectSetInteger(0, EditOrderCommentI, OBJPROP_HIDDEN, true);
    ObjectSetInteger(0, EditOrderCommentI, OBJPROP_READONLY, true);
    ObjectSetInteger(0, EditOrderCommentI, OBJPROP_FONTSIZE, NOFontSize);
    ObjectSetString(0, EditOrderCommentI, OBJPROP_TOOLTIP, "Order Comment");
    ObjectSetInteger(0, EditOrderCommentI, OBJPROP_ALIGN, ALIGN_CENTER);
    ObjectSetString(0, EditOrderCommentI, OBJPROP_FONT, DetFont);
    ObjectSetString(0, EditOrderCommentI, OBJPROP_TEXT, TextCmnt);
    ObjectSet(EditOrderCommentI, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, EditOrderCommentI, OBJPROP_COLOR, clrBlack);
}

void UpdateEditProfit(int Order)
{
    if (!OrderSelect(Order, SELECT_BY_TICKET))
    {
        int LastError = GetLastError();
        Print("Error selecting order #" + IntegerToString(Order) + ": " + IntegerToString(LastError) + " - " + GetLastErrorText(LastError));
        return;
    }
    string TextProfit = DoubleToStr(OrderProfit(), 2);
    ObjectSetString(0, EditOrderProfitI, OBJPROP_TEXT, TextProfit);
    return;
}

void UpdateOrder(int Order)
{
    int LastError = 0;
    if (!OrderSelect(Order, SELECT_BY_TICKET))
    {
        LastError = GetLastError();
        Print("Error selecting order #" + IntegerToString(Order) + ": " + IntegerToString(LastError) + " - " + GetLastErrorText(LastError));
        return;
    }
    int Type = OrderType();
    double OpenPrice = OrderOpenPrice();
    double SLPrice = StringToDouble(ObjectGetString(0, EditOrderSLI, OBJPROP_TEXT));
    double TPPrice = StringToDouble(ObjectGetString(0, EditOrderTPI, OBJPROP_TEXT));
    double Points = MarketInfo(OrderSymbol(), MODE_POINT);
    double Spread = MarketInfo(OrderSymbol(), MODE_SPREAD);
    double StopLevel = MarketInfo(OrderSymbol(), MODE_STOPLEVEL) * Points;
    bool res = false;
    if (Type == OP_BUY)
    {
        OpenPrice = MarketInfo(OrderSymbol(), MODE_BID);
    }
    else if (Type == OP_SELL)
    {
        OpenPrice = MarketInfo(OrderSymbol(), MODE_ASK);
    }
    if ((Type == OP_BUY) || (Type == OP_BUYLIMIT) || (Type == OP_BUYSTOP))
    {
        if ((SLPrice > 0) && (SLPrice >= OpenPrice - StopLevel))
        {
            MessageBox("Stop-loss must be below open price (for pending orders) and current price (for market orders) minus stop level.");
            return;
        }
        if ((TPPrice > 0) && (TPPrice <= OpenPrice + StopLevel))
        {
            MessageBox("Take-profit must be above open price (for pending orders) and current price (for market orders) plus stop level.");
            return;
        }
    }
    if ((Type == OP_SELL) || (Type == OP_SELLLIMIT) || (Type == OP_SELLSTOP))
    {
        if ((SLPrice > 0) && (SLPrice <= OpenPrice + StopLevel))
        {
            MessageBox("Stop-loss must be above open price (for pending orders) and current price (for market orders) plus stop level.");
            return;
        }
        if ((TPPrice > 0) && (TPPrice >= OpenPrice - StopLevel))
        {
            MessageBox("Take profit must be below open price (for pending orders) and current price (for market orders) minus stop level.");
            return;
        }
    }
    if ((SLPrice < 0) || (TPPrice < 0))
    {
        MessageBox("Stop-loss and take-profit cannot be negative.");
        return;
    }
    if ((SLPrice == OrderStopLoss()) && (TPPrice == OrderTakeProfit())) return;
    res = OrderModify(OrderTicket(), OrderOpenPrice(), SLPrice, TPPrice, 0, clrNONE);
    LastError = GetLastError();
    if (res)
    {
        MessageBox("Order " + IntegerToString(OrderTicket()) + " successfully modified.");
        ShowEdit(OrderTicket());
        return;
    }
    else
    {
        MessageBox("Order " + IntegerToString(OrderTicket()) + " failed to update - " + IntegerToString(LastError) + " - " + GetLastErrorText(LastError));
        ShowEdit(OrderTicket());
        return;
    }
    return;
}

void CloseOrder(int Order)
{
    int LastError = 0;
    if (!OrderSelect(Order, SELECT_BY_TICKET))
    {
        LastError = GetLastError();
        Print("Error selecting order #" + IntegerToString(Order) + ": " + IntegerToString(LastError) + " - " + GetLastErrorText(LastError));
        return;
    }
    double OpenPrice = 0;
    bool res = false;
    if (OrderType() == OP_BUY)
    {
        OpenPrice = OrderOpenPrice();
        res = OrderClose(OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_BID), Slippage, OpenBuyColor);
        LastError = GetLastError();
    }
    else if (OrderType() == OP_SELL)
    {
        OpenPrice = OrderOpenPrice();
        res = OrderClose(OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_ASK), Slippage, OpenSellColor);
        LastError = GetLastError();
    }
    else if ((OrderType() == OP_BUYLIMIT) || (OrderType() == OP_BUYSTOP))
    {
        res = OrderDelete(OrderTicket(), OpenBuyColor);
        LastError = GetLastError();
    }
    else if ((OrderType() == OP_SELLLIMIT) || (OrderType() == OP_SELLSTOP))
    {
        res = OrderDelete(OrderTicket(), OpenSellColor);
        LastError = GetLastError();
    }
    if (res)
    {
        if (ShowMsg) MessageBox("Order " + IntegerToString(OrderTicket()) + " closed/deleted.");
        ShowDetails();
    }
    else
    {
        MessageBox("Error closing/deleting order " + IntegerToString(OrderTicket()) + " - " + IntegerToString(LastError) + " - " + GetLastErrorText(LastError));
    }
}


void ExitEdit()
{
    ObjectsDeleteAll(0, IndicatorName + "-E-");
    DeleteNewOrderLine(LINE_ALL);
    EditOpen = false;
}

string SettingsBase = IndicatorName + "-S-Base";
string SettingsSave = IndicatorName + "-S-Save";
string SettingsClose = IndicatorName + "-S-Close";
string SettingsTakeScreenshot = IndicatorName + "-S-Screenshot";
string SettingsTakeScreenshotE = IndicatorName + "-S-ScreenshotE";
string SettingsLotSize = IndicatorName + "-S-LotSize";
string SettingsLotSizeE = IndicatorName + "-S-LotSizeE";
string SettingsLotStep = IndicatorName + "-S-LotStep";
string SettingsLotStepE = IndicatorName + "-S-LotStepE";
string SettingsRiskPerc = IndicatorName + "-S-RiskPerc";
string SettingsRiskPercE = IndicatorName + "-S-RiskPercE";
string SettingsRiskBase = IndicatorName + "-S-RiskBase";
string SettingsRiskBaseE = IndicatorName + "-S-RiskBaseE";
string SettingsOrdersPerPage = IndicatorName + "-S-OrderPerPage";
string SettingsOrdersPerPageE = IndicatorName + "-S-OrderPerPageE";
int SetButtonY = SetGLabelY;
void ShowSettings()
{
    SetButtonY = SetGLabelY;
    int SetXoff = Xoff;
    int SetYoff = Yoff + PanelMovY + 2 * 4;
    int SetX = SetButtonX * 2 + 6;
    int SetY = (SetButtonY + 2) * 7 + 2;
    int j = 1;
    string TextTakeScreenshot = "";
    string TextLotSize = "";
    string TextLotStep = "";
    string TextRiskPerc = "";
    string TextRiskBase = "";
    string TextOPP = IntegerToString(OrdersPerPage);
    if (TakeScreenshot) TextTakeScreenshot = "ON";
    else TextTakeScreenshot = "OFF";
    TextLotStep = DoubleToString(LotStep, 2);
    TextLotSize = DoubleToString(LotSize, 2);
    TextRiskPerc = DoubleToString(RiskPerc, 2);
    if (RiskBase == Equity) TextRiskBase = "EQUITY";
    else if (RiskBase == Balance) TextRiskBase = "BALANCE";
    else if (RiskBase == FreeMargin) TextRiskBase = "FREE MARGIN";

    ObjectCreate(0, SettingsBase, OBJ_RECTANGLE_LABEL, 0, 0, 0);
    ObjectSet(SettingsBase, OBJPROP_XDISTANCE, SetXoff);
    ObjectSet(SettingsBase, OBJPROP_YDISTANCE, SetYoff);
    ObjectSetInteger(0, SettingsBase, OBJPROP_XSIZE, SetX);
    ObjectSetInteger(0, SettingsBase, OBJPROP_YSIZE, SetY);
    ObjectSetInteger(0, SettingsBase, OBJPROP_BGCOLOR, clrWhite);
    ObjectSetInteger(0, SettingsBase, OBJPROP_BORDER_TYPE, BORDER_FLAT);
    ObjectSetInteger(0, SettingsBase, OBJPROP_STATE, false);
    ObjectSetInteger(0, SettingsBase, OBJPROP_HIDDEN, true);
    ObjectSetInteger(0, SettingsBase, OBJPROP_FONTSIZE, NOFontSize);
    ObjectSet(SettingsBase, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, SettingsBase, OBJPROP_COLOR, clrBlack);

    ObjectCreate(0, SettingsSave, OBJ_EDIT, 0, 0, 0);
    ObjectSet(SettingsSave, OBJPROP_XDISTANCE, SetXoff + 2);
    ObjectSet(SettingsSave, OBJPROP_YDISTANCE, SetYoff + 2);
    ObjectSetInteger(0, SettingsSave, OBJPROP_XSIZE, SetButtonX);
    ObjectSetInteger(0, SettingsSave, OBJPROP_YSIZE, SetButtonY);
    ObjectSetInteger(0, SettingsSave, OBJPROP_BORDER_TYPE, BORDER_FLAT);
    ObjectSetInteger(0, SettingsSave, OBJPROP_STATE, false);
    ObjectSetInteger(0, SettingsSave, OBJPROP_HIDDEN, true);
    ObjectSetInteger(0, SettingsSave, OBJPROP_READONLY, true);
    ObjectSetInteger(0, SettingsSave, OBJPROP_FONTSIZE, NOFontSize);
    ObjectSetString(0, SettingsSave, OBJPROP_TOOLTIP, "Save Changes");
    ObjectSetInteger(0, SettingsSave, OBJPROP_ALIGN, ALIGN_CENTER);
    ObjectSetString(0, SettingsSave, OBJPROP_FONT, NOFont);
    ObjectSetString(0, SettingsSave, OBJPROP_TEXT, "Save");
    ObjectSet(SettingsSave, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, SettingsSave, OBJPROP_COLOR, clrBlack);
    ObjectSetInteger(0, SettingsSave, OBJPROP_BGCOLOR, clrPaleGreen);
    ObjectSetInteger(0, SettingsSave, OBJPROP_BORDER_COLOR, clrBlack);

    ObjectCreate(0, SettingsClose, OBJ_EDIT, 0, 0, 0);
    ObjectSet(SettingsClose, OBJPROP_XDISTANCE, SetXoff + (SetButtonX + 2) * 1 + 2);
    ObjectSet(SettingsClose, OBJPROP_YDISTANCE, SetYoff + 2);
    ObjectSetInteger(0, SettingsClose, OBJPROP_XSIZE, SetButtonX);
    ObjectSetInteger(0, SettingsClose, OBJPROP_YSIZE, SetButtonY);
    ObjectSetInteger(0, SettingsClose, OBJPROP_BORDER_TYPE, BORDER_FLAT);
    ObjectSetInteger(0, SettingsClose, OBJPROP_STATE, false);
    ObjectSetInteger(0, SettingsClose, OBJPROP_HIDDEN, true);
    ObjectSetInteger(0, SettingsClose, OBJPROP_READONLY, true);
    ObjectSetInteger(0, SettingsClose, OBJPROP_FONTSIZE, NOFontSize);
    ObjectSetString(0, SettingsClose, OBJPROP_TOOLTIP, "Close Settings Panel");
    ObjectSetInteger(0, SettingsClose, OBJPROP_ALIGN, ALIGN_CENTER);
    ObjectSetString(0, SettingsClose, OBJPROP_FONT, NOFont);
    ObjectSetString(0, SettingsClose, OBJPROP_TEXT, "X");
    ObjectSet(SettingsClose, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, SettingsClose, OBJPROP_COLOR, clrBlack);
    ObjectSetInteger(0, SettingsClose, OBJPROP_BGCOLOR, clrCrimson);
    ObjectSetInteger(0, SettingsClose, OBJPROP_BORDER_COLOR, clrBlack);

    ObjectCreate(0, SettingsTakeScreenshot, OBJ_EDIT, 0, 0, 0);
    ObjectSet(SettingsTakeScreenshot, OBJPROP_XDISTANCE, SetXoff + 2);
    ObjectSet(SettingsTakeScreenshot, OBJPROP_YDISTANCE, SetYoff + 2 + (SetButtonY + 2) * j);
    ObjectSetInteger(0, SettingsTakeScreenshot, OBJPROP_XSIZE, SetGLabelX);
    ObjectSetInteger(0, SettingsTakeScreenshot, OBJPROP_YSIZE, SetGLabelY);
    ObjectSetInteger(0, SettingsTakeScreenshot, OBJPROP_BORDER_TYPE, BORDER_FLAT);
    ObjectSetInteger(0, SettingsTakeScreenshot, OBJPROP_STATE, false);
    ObjectSetInteger(0, SettingsTakeScreenshot, OBJPROP_HIDDEN, true);
    ObjectSetInteger(0, SettingsTakeScreenshot, OBJPROP_READONLY, true);
    ObjectSetInteger(0, SettingsTakeScreenshot, OBJPROP_FONTSIZE, NOFontSize);
    ObjectSetString(0, SettingsTakeScreenshot, OBJPROP_TOOLTIP, "Take Screenshot when placing an order");
    ObjectSetInteger(0, SettingsTakeScreenshot, OBJPROP_ALIGN, ALIGN_LEFT);
    ObjectSetString(0, SettingsTakeScreenshot, OBJPROP_FONT, NOFont);
    ObjectSetString(0, SettingsTakeScreenshot, OBJPROP_TEXT, "Take Screnshot");
    ObjectSet(SettingsTakeScreenshot, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, SettingsTakeScreenshot, OBJPROP_COLOR, clrBlack);

    ObjectCreate(0, SettingsTakeScreenshotE, OBJ_EDIT, 0, 0, 0);
    ObjectSet(SettingsTakeScreenshotE, OBJPROP_XDISTANCE, SetXoff + 2 + SetGLabelX + 2);
    ObjectSet(SettingsTakeScreenshotE, OBJPROP_YDISTANCE, SetYoff + 2 + (SetButtonY + 2) * j);
    ObjectSetInteger(0, SettingsTakeScreenshotE, OBJPROP_XSIZE, SetGLabelEX);
    ObjectSetInteger(0, SettingsTakeScreenshotE, OBJPROP_YSIZE, SetButtonY);
    ObjectSetInteger(0, SettingsTakeScreenshotE, OBJPROP_BORDER_TYPE, BORDER_FLAT);
    ObjectSetInteger(0, SettingsTakeScreenshotE, OBJPROP_STATE, false);
    ObjectSetInteger(0, SettingsTakeScreenshotE, OBJPROP_HIDDEN, true);
    ObjectSetInteger(0, SettingsTakeScreenshotE, OBJPROP_READONLY, true);
    ObjectSetInteger(0, SettingsTakeScreenshotE, OBJPROP_FONTSIZE, NOFontSize);
    ObjectSetString(0, SettingsTakeScreenshotE, OBJPROP_TOOLTIP, "Take Screenshot when placing an order - Click to change");
    ObjectSetInteger(0, SettingsTakeScreenshotE, OBJPROP_ALIGN, ALIGN_CENTER);
    ObjectSetString(0, SettingsTakeScreenshotE, OBJPROP_FONT, NOFont);
    ObjectSetString(0, SettingsTakeScreenshotE, OBJPROP_TEXT, TextTakeScreenshot);
    ObjectSet(SettingsTakeScreenshotE, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, SettingsTakeScreenshotE, OBJPROP_COLOR, clrBlack);
    j++;

    ObjectCreate(0, SettingsLotSize, OBJ_EDIT, 0, 0, 0);
    ObjectSet(SettingsLotSize, OBJPROP_XDISTANCE, SetXoff + 2);
    ObjectSet(SettingsLotSize, OBJPROP_YDISTANCE, SetYoff + 2 + (SetButtonY + 2) * j);
    ObjectSetInteger(0, SettingsLotSize, OBJPROP_XSIZE, SetGLabelX);
    ObjectSetInteger(0, SettingsLotSize, OBJPROP_YSIZE, SetGLabelY);
    ObjectSetInteger(0, SettingsLotSize, OBJPROP_BORDER_TYPE, BORDER_FLAT);
    ObjectSetInteger(0, SettingsLotSize, OBJPROP_STATE, false);
    ObjectSetInteger(0, SettingsLotSize, OBJPROP_HIDDEN, true);
    ObjectSetInteger(0, SettingsLotSize, OBJPROP_READONLY, true);
    ObjectSetInteger(0, SettingsLotSize, OBJPROP_FONTSIZE, NOFontSize);
    ObjectSetString(0, SettingsLotSize, OBJPROP_TOOLTIP, "Default Lot Size");
    ObjectSetInteger(0, SettingsLotSize, OBJPROP_ALIGN, ALIGN_LEFT);
    ObjectSetString(0, SettingsLotSize, OBJPROP_FONT, NOFont);
    ObjectSetString(0, SettingsLotSize, OBJPROP_TEXT, "Lot Size");
    ObjectSet(SettingsLotSize, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, SettingsLotSize, OBJPROP_COLOR, clrBlack);

    ObjectCreate(0, SettingsLotSizeE, OBJ_EDIT, 0, 0, 0);
    ObjectSet(SettingsLotSizeE, OBJPROP_XDISTANCE, SetXoff + 2 + SetGLabelX + 2);
    ObjectSet(SettingsLotSizeE, OBJPROP_YDISTANCE, SetYoff + 2 + (SetButtonY + 2) * j);
    ObjectSetInteger(0, SettingsLotSizeE, OBJPROP_XSIZE, SetGLabelEX);
    ObjectSetInteger(0, SettingsLotSizeE, OBJPROP_YSIZE, SetButtonY);
    ObjectSetInteger(0, SettingsLotSizeE, OBJPROP_BORDER_TYPE, BORDER_FLAT);
    ObjectSetInteger(0, SettingsLotSizeE, OBJPROP_STATE, false);
    ObjectSetInteger(0, SettingsLotSizeE, OBJPROP_HIDDEN, true);
    ObjectSetInteger(0, SettingsLotSizeE, OBJPROP_READONLY, false);
    ObjectSetInteger(0, SettingsLotSizeE, OBJPROP_FONTSIZE, NOFontSize);
    ObjectSetString(0, SettingsLotSizeE, OBJPROP_TOOLTIP, "Default Lot Size - Click to change");
    ObjectSetInteger(0, SettingsLotSizeE, OBJPROP_ALIGN, ALIGN_CENTER);
    ObjectSetString(0, SettingsLotSizeE, OBJPROP_FONT, NOFont);
    ObjectSetString(0, SettingsLotSizeE, OBJPROP_TEXT, TextLotSize);
    ObjectSet(SettingsLotSizeE, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, SettingsLotSizeE, OBJPROP_COLOR, clrBlack);
    j++;

    ObjectCreate(0, SettingsLotStep, OBJ_EDIT, 0, 0, 0);
    ObjectSet(SettingsLotStep, OBJPROP_XDISTANCE, SetXoff + 2);
    ObjectSet(SettingsLotStep, OBJPROP_YDISTANCE, SetYoff + 2 + (SetButtonY + 2) * j);
    ObjectSetInteger(0, SettingsLotStep, OBJPROP_XSIZE, SetGLabelX);
    ObjectSetInteger(0, SettingsLotStep, OBJPROP_YSIZE, SetGLabelY);
    ObjectSetInteger(0, SettingsLotStep, OBJPROP_BORDER_TYPE, BORDER_FLAT);
    ObjectSetInteger(0, SettingsLotStep, OBJPROP_STATE, false);
    ObjectSetInteger(0, SettingsLotStep, OBJPROP_HIDDEN, true);
    ObjectSetInteger(0, SettingsLotStep, OBJPROP_READONLY, true);
    ObjectSetInteger(0, SettingsLotStep, OBJPROP_FONTSIZE, NOFontSize);
    ObjectSetString(0, SettingsLotStep, OBJPROP_TOOLTIP, "Lot Step when using + and - ");
    ObjectSetInteger(0, SettingsLotStep, OBJPROP_ALIGN, ALIGN_LEFT);
    ObjectSetString(0, SettingsLotStep, OBJPROP_FONT, NOFont);
    ObjectSetString(0, SettingsLotStep, OBJPROP_TEXT, "Lot Step");
    ObjectSet(SettingsLotStep, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, SettingsLotStep, OBJPROP_COLOR, clrBlack);

    ObjectCreate(0, SettingsLotStepE, OBJ_EDIT, 0, 0, 0);
    ObjectSet(SettingsLotStepE, OBJPROP_XDISTANCE, SetXoff + 2 + SetGLabelX + 2);
    ObjectSet(SettingsLotStepE, OBJPROP_YDISTANCE, SetYoff + 2 + (SetButtonY + 2) * j);
    ObjectSetInteger(0, SettingsLotStepE, OBJPROP_XSIZE, SetGLabelEX);
    ObjectSetInteger(0, SettingsLotStepE, OBJPROP_YSIZE, SetButtonY);
    ObjectSetInteger(0, SettingsLotStepE, OBJPROP_BORDER_TYPE, BORDER_FLAT);
    ObjectSetInteger(0, SettingsLotStepE, OBJPROP_STATE, false);
    ObjectSetInteger(0, SettingsLotStepE, OBJPROP_HIDDEN, true);
    ObjectSetInteger(0, SettingsLotStepE, OBJPROP_READONLY, false);
    ObjectSetInteger(0, SettingsLotStepE, OBJPROP_FONTSIZE, NOFontSize);
    ObjectSetString(0, SettingsLotStepE, OBJPROP_TOOLTIP, "Lot step when using + and - Click to change");
    ObjectSetInteger(0, SettingsLotStepE, OBJPROP_ALIGN, ALIGN_CENTER);
    ObjectSetString(0, SettingsLotStepE, OBJPROP_FONT, NOFont);
    ObjectSetString(0, SettingsLotStepE, OBJPROP_TEXT, TextLotStep);
    ObjectSet(SettingsLotStepE, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, SettingsLotStepE, OBJPROP_COLOR, clrBlack);
    j++;

    ObjectCreate(0, SettingsRiskPerc, OBJ_EDIT, 0, 0, 0);
    ObjectSet(SettingsRiskPerc, OBJPROP_XDISTANCE, SetXoff + 2);
    ObjectSet(SettingsRiskPerc, OBJPROP_YDISTANCE, SetYoff + 2 + (SetButtonY + 2) * j);
    ObjectSetInteger(0, SettingsRiskPerc, OBJPROP_XSIZE, SetGLabelX);
    ObjectSetInteger(0, SettingsRiskPerc, OBJPROP_YSIZE, SetGLabelY);
    ObjectSetInteger(0, SettingsRiskPerc, OBJPROP_BORDER_TYPE, BORDER_FLAT);
    ObjectSetInteger(0, SettingsRiskPerc, OBJPROP_STATE, false);
    ObjectSetInteger(0, SettingsRiskPerc, OBJPROP_HIDDEN, true);
    ObjectSetInteger(0, SettingsRiskPerc, OBJPROP_READONLY, true);
    ObjectSetInteger(0, SettingsRiskPerc, OBJPROP_FONTSIZE, NOFontSize);
    ObjectSetString(0, SettingsRiskPerc, OBJPROP_TOOLTIP, "Percentage of risk per trade");
    ObjectSetInteger(0, SettingsRiskPerc, OBJPROP_ALIGN, ALIGN_LEFT);
    ObjectSetString(0, SettingsRiskPerc, OBJPROP_FONT, NOFont);
    ObjectSetString(0, SettingsRiskPerc, OBJPROP_TEXT, "Risk Percentage");
    ObjectSet(SettingsRiskPerc, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, SettingsRiskPerc, OBJPROP_COLOR, clrBlack);

    ObjectCreate(0, SettingsRiskPercE, OBJ_EDIT, 0, 0, 0);
    ObjectSet(SettingsRiskPercE, OBJPROP_XDISTANCE, SetXoff + 2 + SetGLabelX + 2);
    ObjectSet(SettingsRiskPercE, OBJPROP_YDISTANCE, SetYoff + 2 + (SetButtonY + 2) * j);
    ObjectSetInteger(0, SettingsRiskPercE, OBJPROP_XSIZE, SetGLabelEX);
    ObjectSetInteger(0, SettingsRiskPercE, OBJPROP_YSIZE, SetButtonY);
    ObjectSetInteger(0, SettingsRiskPercE, OBJPROP_BORDER_TYPE, BORDER_FLAT);
    ObjectSetInteger(0, SettingsRiskPercE, OBJPROP_STATE, false);
    ObjectSetInteger(0, SettingsRiskPercE, OBJPROP_HIDDEN, true);
    ObjectSetInteger(0, SettingsRiskPercE, OBJPROP_READONLY, false);
    ObjectSetInteger(0, SettingsRiskPercE, OBJPROP_FONTSIZE, NOFontSize);
    ObjectSetString(0, SettingsRiskPercE, OBJPROP_TOOLTIP, "Percentage of risk per trade - Click to change");
    ObjectSetInteger(0, SettingsRiskPercE, OBJPROP_ALIGN, ALIGN_CENTER);
    ObjectSetString(0, SettingsRiskPercE, OBJPROP_FONT, NOFont);
    ObjectSetString(0, SettingsRiskPercE, OBJPROP_TEXT, TextRiskPerc);
    ObjectSet(SettingsRiskPercE, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, SettingsRiskPercE, OBJPROP_COLOR, clrBlack);
    j++;

    ObjectCreate(0, SettingsRiskBase, OBJ_EDIT, 0, 0, 0);
    ObjectSet(SettingsRiskBase, OBJPROP_XDISTANCE, SetXoff + 2);
    ObjectSet(SettingsRiskBase, OBJPROP_YDISTANCE, SetYoff + 2 + (SetButtonY + 2) * j);
    ObjectSetInteger(0, SettingsRiskBase, OBJPROP_XSIZE, SetGLabelX);
    ObjectSetInteger(0, SettingsRiskBase, OBJPROP_YSIZE, SetGLabelY);
    ObjectSetInteger(0, SettingsRiskBase, OBJPROP_BORDER_TYPE, BORDER_FLAT);
    ObjectSetInteger(0, SettingsRiskBase, OBJPROP_STATE, false);
    ObjectSetInteger(0, SettingsRiskBase, OBJPROP_HIDDEN, true);
    ObjectSetInteger(0, SettingsRiskBase, OBJPROP_READONLY, true);
    ObjectSetInteger(0, SettingsRiskBase, OBJPROP_FONTSIZE, NOFontSize);
    ObjectSetString(0, SettingsRiskBase, OBJPROP_TOOLTIP, "Calculate the risk percentage using one of the following");
    ObjectSetInteger(0, SettingsRiskBase, OBJPROP_ALIGN, ALIGN_LEFT);
    ObjectSetString(0, SettingsRiskBase, OBJPROP_FONT, NOFont);
    ObjectSetString(0, SettingsRiskBase, OBJPROP_TEXT, "Risk Base");
    ObjectSet(SettingsRiskBase, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, SettingsRiskBase, OBJPROP_COLOR, clrBlack);

    ObjectCreate(0, SettingsRiskBaseE, OBJ_EDIT, 0, 0, 0);
    ObjectSet(SettingsRiskBaseE, OBJPROP_XDISTANCE, SetXoff + 2 + SetGLabelX + 2);
    ObjectSet(SettingsRiskBaseE, OBJPROP_YDISTANCE, SetYoff + 2 + (SetButtonY + 2) * j);
    ObjectSetInteger(0, SettingsRiskBaseE, OBJPROP_XSIZE, SetGLabelEX);
    ObjectSetInteger(0, SettingsRiskBaseE, OBJPROP_YSIZE, SetButtonY);
    ObjectSetInteger(0, SettingsRiskBaseE, OBJPROP_BORDER_TYPE, BORDER_FLAT);
    ObjectSetInteger(0, SettingsRiskBaseE, OBJPROP_STATE, false);
    ObjectSetInteger(0, SettingsRiskBaseE, OBJPROP_HIDDEN, true);
    ObjectSetInteger(0, SettingsRiskBaseE, OBJPROP_READONLY, true);
    ObjectSetInteger(0, SettingsRiskBaseE, OBJPROP_FONTSIZE, NOFontSize);
    ObjectSetString(0, SettingsRiskBaseE, OBJPROP_TOOLTIP, "Base to calculate the risk - Click to change");
    ObjectSetInteger(0, SettingsRiskBaseE, OBJPROP_ALIGN, ALIGN_CENTER);
    ObjectSetString(0, SettingsRiskBaseE, OBJPROP_FONT, NOFont);
    ObjectSetString(0, SettingsRiskBaseE, OBJPROP_TEXT, TextRiskBase);
    ObjectSet(SettingsRiskBaseE, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, SettingsRiskBaseE, OBJPROP_COLOR, clrBlack);
    j++;

    ObjectCreate(0, SettingsOrdersPerPage, OBJ_EDIT, 0, 0, 0);
    ObjectSet(SettingsOrdersPerPage, OBJPROP_XDISTANCE, SetXoff + 2);
    ObjectSet(SettingsOrdersPerPage, OBJPROP_YDISTANCE, SetYoff + 2 + (SetButtonY + 2) * j);
    ObjectSetInteger(0, SettingsOrdersPerPage, OBJPROP_XSIZE, SetGLabelX);
    ObjectSetInteger(0, SettingsOrdersPerPage, OBJPROP_YSIZE, SetGLabelY);
    ObjectSetInteger(0, SettingsOrdersPerPage, OBJPROP_BORDER_TYPE, BORDER_FLAT);
    ObjectSetInteger(0, SettingsOrdersPerPage, OBJPROP_STATE, false);
    ObjectSetInteger(0, SettingsOrdersPerPage, OBJPROP_HIDDEN, true);
    ObjectSetInteger(0, SettingsOrdersPerPage, OBJPROP_READONLY, true);
    ObjectSetInteger(0, SettingsOrdersPerPage, OBJPROP_FONTSIZE, NOFontSize);
    ObjectSetString(0, SettingsOrdersPerPage, OBJPROP_TOOLTIP, "Orders Per Page");
    ObjectSetInteger(0, SettingsOrdersPerPage, OBJPROP_ALIGN, ALIGN_LEFT);
    ObjectSetString(0, SettingsOrdersPerPage, OBJPROP_FONT, DetFont);
    ObjectSetString(0, SettingsOrdersPerPage, OBJPROP_TEXT, "Orders Per Page");
    ObjectSet(SettingsOrdersPerPage, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, SettingsOrdersPerPage, OBJPROP_COLOR, clrBlack);

    ObjectCreate(0, SettingsOrdersPerPageE, OBJ_EDIT, 0, 0, 0);
    ObjectSet(SettingsOrdersPerPageE, OBJPROP_XDISTANCE, SetXoff + 2 + SetGLabelX + 2);
    ObjectSet(SettingsOrdersPerPageE, OBJPROP_YDISTANCE, SetYoff + 2 + (SetButtonY + 2) * j);
    ObjectSetInteger(0, SettingsOrdersPerPageE, OBJPROP_XSIZE, SetGLabelEX);
    ObjectSetInteger(0, SettingsOrdersPerPageE, OBJPROP_YSIZE, SetButtonY);
    ObjectSetInteger(0, SettingsOrdersPerPageE, OBJPROP_BORDER_TYPE, BORDER_FLAT);
    ObjectSetInteger(0, SettingsOrdersPerPageE, OBJPROP_STATE, false);
    ObjectSetInteger(0, SettingsOrdersPerPageE, OBJPROP_HIDDEN, true);
    ObjectSetInteger(0, SettingsOrdersPerPageE, OBJPROP_READONLY, false);
    ObjectSetInteger(0, SettingsOrdersPerPageE, OBJPROP_FONTSIZE, NOFontSize);
    ObjectSetString(0, SettingsOrdersPerPageE, OBJPROP_TOOLTIP, "Click to Change (Value 1 to 20)");
    ObjectSetInteger(0, SettingsOrdersPerPageE, OBJPROP_ALIGN, ALIGN_CENTER);
    ObjectSetString(0, SettingsOrdersPerPageE, OBJPROP_FONT, DetFont);
    ObjectSetString(0, SettingsOrdersPerPageE, OBJPROP_TEXT, TextOPP);
    ObjectSet(SettingsOrdersPerPageE, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, SettingsOrdersPerPageE, OBJPROP_COLOR, clrBlack);
    j++;
}

void ChangeTakeScreenshot()
{
    string Tmp = ObjectGetString(0, SettingsTakeScreenshotE, OBJPROP_TEXT);
    if (Tmp == "ON")
    {
        ObjectSetString(0, SettingsTakeScreenshotE, OBJPROP_TEXT, "OFF");
        return;
    }
    if (Tmp == "OFF")
    {
        ObjectSetString(0, SettingsTakeScreenshotE, OBJPROP_TEXT, "ON");
        return;
    }
}

void ChangeRiskBase()
{
    string Tmp = ObjectGetString(0, SettingsRiskBaseE, OBJPROP_TEXT);
    if (Tmp == "EQUITY")
    {
        ObjectSetString(0, SettingsRiskBaseE, OBJPROP_TEXT, "BALANCE");
        return;
    }
    if (Tmp == "BALANCE")
    {
        ObjectSetString(0, SettingsRiskBaseE, OBJPROP_TEXT, "FREE MARGIN");
        return;
    }
    if (Tmp == "FREE MARGIN")
    {
        ObjectSetString(0, SettingsRiskBaseE, OBJPROP_TEXT, "EQUITY");
        return;
    }
}

void SaveSettingsChanges()
{
    string SettingsTakeScreenshotTmp = ObjectGetString(0, SettingsTakeScreenshotE, OBJPROP_TEXT);
    double SettingsLotSizeTmp = StringToDouble(ObjectGetString(0, SettingsLotSizeE, OBJPROP_TEXT));
    double SettingsLotStepTmp = StringToDouble(ObjectGetString(0, SettingsLotStepE, OBJPROP_TEXT));
    double SettingsRiskPercTmp = StringToDouble(ObjectGetString(0, SettingsRiskPercE, OBJPROP_TEXT));
    string SettingsRiskBaseTmp = ObjectGetString(0, SettingsRiskBaseE, OBJPROP_TEXT);
    int SettingsOrdersPerPageTmp = (int)StringToInteger(ObjectGetString(0, SettingsOrdersPerPageE, OBJPROP_TEXT));
    if ((SettingsOrdersPerPageTmp >= 1) && (SettingsOrdersPerPageTmp <= 20)) OrdersPerPage = SettingsOrdersPerPageTmp;
    else
    {
        OrdersPerPage = DefaultOrdersPerPage;
    }
    if (SettingsTakeScreenshotTmp == "ON") TakeScreenshot = true;
    else TakeScreenshot = false;
    if ((SettingsRiskPercTmp > 0) && (SettingsRiskPercTmp <= 100)) RiskPerc = SettingsRiskPercTmp;
    else
    {
        MessageBox("Risk % not valid - must be between 0 and 100. Setting to default.");
        RiskPerc = DefaultRiskPerc;
    }
    if ((SettingsLotSizeTmp >= MarketInfo(Symbol(), MODE_MINLOT)) && (SettingsLotSizeTmp <= MarketInfo(Symbol(), MODE_MAXLOT)))
    {
        LotSize = SettingsLotSizeTmp;
        LotSize = MathRound(LotSize / MarketInfo(Symbol(), MODE_LOTSTEP)) * MarketInfo(Symbol(), MODE_LOTSTEP);
    }
    else
    {
        MessageBox("Lot Size must be between " + DoubleToString(MarketInfo(Symbol(), MODE_MINLOT), 2) + " and " + DoubleToString(MarketInfo(Symbol(), MODE_MAXLOT), 2));
        LotSize = DefaultLotStep;
        LotSize = MathRound(LotSize / MarketInfo(Symbol(), MODE_LOTSTEP)) * MarketInfo(Symbol(), MODE_LOTSTEP);
    }
    if ((SettingsLotStepTmp >= MarketInfo(Symbol(), MODE_LOTSTEP)) && (SettingsLotStepTmp <= MarketInfo(Symbol(), MODE_MAXLOT)))
    {
        LotStep = SettingsLotStepTmp;
        LotStep = MathRound(LotStep / MarketInfo(Symbol(), MODE_LOTSTEP)) * MarketInfo(Symbol(), MODE_LOTSTEP);
    }
    else
    {
        MessageBox("Lot Step must be between " + DoubleToString(MarketInfo(Symbol(), MODE_LOTSTEP), 2) + " and " + DoubleToString(MarketInfo(Symbol(), MODE_MAXLOT), 2));
        LotStep = DefaultLotStep;
        LotStep = MathRound(LotStep / MarketInfo(Symbol(), MODE_LOTSTEP)) * MarketInfo(Symbol(), MODE_LOTSTEP);
    }
    if (StringFind(SettingsRiskBaseTmp, "EQUITY") >= 0) RiskBase = Equity;
    else if (StringFind(SettingsRiskBaseTmp, "BALANCE") >= 0) RiskBase = Balance;
    else if (StringFind(SettingsRiskBaseTmp, "MARGIN") >= 0) RiskBase = FreeMargin;
    ShowSettings();
}

void CloseSettings()
{
    ObjectsDeleteAll(0, IndicatorName + "-S-");
}

void UpdateSpread()
{
    if (NewOrderPanelIsOpen)
    {
        string TextSpread = "CURRENT SPREAD IS " + IntegerToString((int)MarketInfo(Symbol(), MODE_SPREAD)) + " POINTS";
        ObjectSetString(0, NewOrderSpread, OBJPROP_TEXT, TextSpread);
    }
}

void UpdateRecommendedSize()
{
    if (NewOrderPanelIsOpen)
    {
        string TextRecSize = "";
        if (RecommendedSize() > 0) TextRecSize = "RECOMMENDED SIZE (LOTS) : " + DoubleToStr(RecommendedSize(), 2);
        else TextRecSize = "RECOMMENDED SIZE (LOTS) : N/A";
        ObjectSetString(0, NewOrderRecommendedSize, OBJPROP_TEXT, TextRecSize);
    }
}

double RecommendedSize()
{
    double StopLoss = 0;
    double Base = 0;
    double Lots = 0;
    double TickValue = MarketInfo(Symbol(), MODE_TICKVALUE);
    if (RiskBase == Equity) Base = AccountEquity();
    else if (RiskBase == Balance) Base = AccountBalance();
    else if (RiskBase == FreeMargin) Base = AccountFreeMargin();
    double Points = MarketInfo(Symbol(), MODE_POINT);
    if (CurrSLPtsOrPrice == ByPts) StopLoss = CurrSLPts;
    else if (CurrSLPtsOrPrice == ByPrice)
    {
        double OpenPrice = 0;
        double SLPrice = CurrSLPrice;
        if (CurrMarketPending == Pending)
        {
            OpenPrice = CurrOpenPrice;
            if (SLPrice > 0) StopLoss = MathAbs(MathRound((OpenPrice - SLPrice) / Points));

        }
        else if (CurrMarketPending == Market)
        {
            if ((SLPrice > MarketInfo(Symbol(), MODE_ASK)) && (SLPrice > MarketInfo(Symbol(), MODE_BID))) OpenPrice = MarketInfo(Symbol(), MODE_BID);
            if ((SLPrice < MarketInfo(Symbol(), MODE_ASK)) && (SLPrice < MarketInfo(Symbol(), MODE_BID))) OpenPrice = MarketInfo(Symbol(), MODE_ASK);
            if (SLPrice > 0) StopLoss = MathAbs(MathRound((OpenPrice - SLPrice) / Points));
        }
        if (CurrSLPtsOrPrice == ByPts) StopLoss = StringToDouble(ObjectGetString(0, NewOrderSLPtsE, OBJPROP_TEXT));
    }
    if ((StopLoss >= MarketInfo(Symbol(), MODE_STOPLEVEL)) && (StopLoss > 0)) Lots = (Base * RiskPerc / 100) / (StopLoss * TickValue);
    if (Lots > MaxLotSize) Lots = MaxLotSize;
    return Lots;
}

void CleanChart()
{
    ObjectsDeleteAll(0, IndicatorName);
}
//+------------------------------------------------------------------+