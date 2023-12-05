//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2020, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+

#include <Trade/Trade.mqh>
#include <Trade/PositionInfo.mqh>

input int Magic_Number = 231;
input double Lotti=0.1;
input int StopLoss= 30;
input int TakeProfit=60;
input int Chosen_Time = 3; //Tempo in minuti dopo news
input string scelgo_io = "EUR";

double pips,BarsCount;

//Facciamo un oggetto della classe trade duh
CTrade OB_Trade;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
//Questa funzione calcola quanto vale un pip in base al mercato dove sta l'ea
   Calcolo_pips();
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {

  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {
   if(Bars(Symbol(),PERIOD_CURRENT) > BarsCount)
     {

      News();

      BarsCount = Bars(Symbol(),PERIOD_CURRENT);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void News()
  {
//Dichiara un array di tipo struttura MqlCalendarValue
   MqlCalendarValue values[];

//Facciamo delle variabili datetime per stabilire da quando a quando vogliamo prendere le news
   datetime startTime = iTime(_Symbol, PERIOD_D1, 0);
   datetime endTime = startTime + PeriodSeconds(PERIOD_D1);

//Utilizziamo questa funzione per riempire l'array di tipo structure creato poco fa
   CalendarValueHistory(values, startTime, endTime, NULL, NULL);

//Con questo ciclo for ciclicamo ogni elemento dell'array struttura appena creato
   for(int i = 0; i < ArraySize(values); i++)
     {

      //Facciamo una variabile di tipo struttura MqlCalendarEvent
      MqlCalendarEvent event;
      //Tramite la funzione CalendareventById dentro l'array values riempiamo la voce event_id della struttura MqlCalendarValue con la variabile struttura event
      CalendarEventById(values[i].event_id, event);

      //Creaiamo una variabile di tipo struttura MqlCalendarCountry
      MqlCalendarCountry country;
      //Tramite la funzione CalendarCountryById riempiamo la voce country_id della struttura MqlCalendarEvent con la variabile struttura country
      CalendarCountryById(event.country_id, country);

      Print(values[i].GetActualValue());
      //Tramite questo if facciamo una serie di controlli di queste struttue create e combinate fra loro
      //La news è appena uscita o sono passati Tot minuti da essa
      //Mi ritorni true solo se la notizia ha una valore numerico reale dell'Attuale ovvero è uscita e non c'è il "nan"

      if(
         country.currency == scelgo_io &&                                            //Currency è uguale alla stringa che scelgo io negli input
         event.importance >=2 &&                                                     //L'importanza dell'evento è maggiore o uguale a 2 (moderato = 2 High = 3)
         TimeCurrent() < values[i].time + Chosen_Time * PeriodSeconds(PERIOD_M1) &&  //Tempo attuale < alla data della news + i minuti scelti negli input
         TimeCurrent() >= values[i].time &&                                          //Tempo attuale >= alla data della news
         event.type == CALENDAR_TYPE_INDICATOR &&                                    //Il tipo di evento è il tipo INDICATORE
         MathIsValidNumber(values[i].GetActualValue())                               //Il valore attuale è un numero valido ovvero non è nan
      )
        {
         if(values[i].GetActualValue()>values[i].GetForecastValue())
           {
            F_AproBuy();
           }

         if(values[i].GetActualValue()<values[i].GetForecastValue())
           {

            F_AproSell();
           }

         // Printami nel terminale "Experts" i dati relativi alla news
         Print("Il nome dell'evento/news è " + event.name + " La currency invece è "+ country.currency +
               " Attuale " + (string)values[i].GetActualValue() +
               " Forecast " + (string)values[i].GetForecastValue() +
               " Precedente " + (string)values[i].GetPreviousValue()
              );
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
// Funzione che apre posizione sell
void F_AproSell()
  {
   double Bid=SymbolInfoDouble(Symbol(),SYMBOL_BID);

   OB_Trade.SetExpertMagicNumber(Magic_Number);
   OB_Trade.Buy(Lotti,Symbol(),Bid,StopLoss*pips,TakeProfit*pips,"Inviato Baby Buy");

  };

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
// Funzione che apre posizione buy
void F_AproBuy()
  {
   double Ask=SymbolInfoDouble(Symbol(),SYMBOL_ASK);

   OB_Trade.SetExpertMagicNumber(Magic_Number);
   OB_Trade.Sell(Lotti,Symbol(),Ask,StopLoss*pips,TakeProfit*pips,"Inviato Baby Sell");

  };


// Ci invia una notifica su telegram quando c'è un evento



//Funzione che ci ritorna quanto vale un pip o ci ritorna i punti perchè non siamo sul forex
//Questa funzione è da corregere perchè altrimenti su mercati con 2 digits o meno ritorna un valore di un pip errato
double Calcolo_pips()
  {
// If there are 3 or fewer digits (JPY, for example), then return 0.01, which is the pip value.
   if(Digits() <= 3)
     {
      pips=0.01;
     }
// If there are 4 or more digits, then return 0.0001, which is the pip value.
   else
      if(Digits() >= 4)
        {
         pips=0.0001;
        }
      // In all other cases, pips = Point
      else
         pips = Point();

   return pips;
  }
//+------------------------------------------------------------------+
