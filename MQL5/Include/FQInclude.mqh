//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2020, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, FQ Trade "
#property link "https://www.youtube.com/channel/UCiGuEnXVW_7KcKk6hY8NyRw"
#property description "Questo include è il mio tentativo di rendere la programmazione in MQL5 più semplice e rapida"
#property  strict

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CInfo
  {
protected:
   int               BarsCount;
   datetime          variabile_memorizzatrice;
   int               chiusure_parziali;
   string            contatore_parziale_sell;
   string            contatore_parziale_buy;
   int               Parziale_sell;
   int               Parziale_buy;

public:
                     CInfo(void)
     {
      this.BarsCount=0;
      this.variabile_memorizzatrice=0;
      this.chiusure_parziali=0;
      this.contatore_parziale_sell="";
      this.contatore_parziale_buy="";
      this.Parziale_sell=0;
      this.Parziale_buy=0;
     };
                    ~CInfo(void) {};

   bool              NewCandle();
   bool              PositionsMagicSymbol(int magic, string symbol);
   int               TicketLastClosingDeal(string Mercato, int Magico);

  };

//Funzione che ritorna true se c'è un nuova candla sul grafico
bool CInfo::NewCandle()
  {
// Se il numero di barre è maggiore alla variabile Barscount(all'inzio vale 0)
   if(Bars(Symbol(),PERIOD_CURRENT) > BarsCount)
     {
      // Allora BarsCount è uguale al numero di barre
      BarsCount = Bars(Symbol(),PERIOD_CURRENT);
      // Ritorni True
      return true;
     }
// Altrimenti ritorni falso
   else
      return false;
  }

// Questa funzione ritorna true se ci sono ordini aperti dal nostro EA
bool CInfo::PositionsMagicSymbol(int magic, string symbol)
  {
   for(int i = 0 ; i < PositionsTotal() ; i++)
     {
      // Selezioniamo la posizione
      if(!PositionSelect(Symbol()))
         Print("C'è un errore nella selezione della posizione: " + IntegerToString(GetLastError()));

      //In delle variabili printiamo i valori della posizione selezionata che ci servono
      long position_magic = PositionGetInteger(POSITION_MAGIC);
      string position_symbol = PositionGetString(POSITION_SYMBOL);

      // Se la posizione ha il simbolo e il magic uguali a quelli immessi come input ritorna true
      if(symbol == position_symbol && position_magic ==magic)

         // Ci sono posizione attualmente aperte nel simbolo scelto e del magic scelto
         return(true);
     }

   return(false);

  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//Ci ritorna il ticket dell'ultimo DEAL di chiusura
int CInfo::TicketLastClosingDeal(string Mercato, int Magico)
  {

//Facciamo le variabili contatore che ritornano dopo il ciclo
   datetime contatore_orario = 0;
   int contatore_ticket =0;

//--- Richiedi la History completa di ordini e deals
   HistorySelect(0,TimeCurrent());

// A total impostiamo la quantità di deals della history
   uint total=HistoryDealsTotal();

//Uno ad uno cicliamo questi deal per coglierne le proprietà
   for(uint i=0; i<total; i++)
     {
      //Impostiamo alla variabile ticket il ticket del deal preso dalla history
      ulong ticket =HistoryDealGetTicket(i);

      //Se è maggiore di zero assegnamo alle variabili le proprietà del deal selezionato
      if(ticket > 0)
        {
         //Prendiamo le proprietà del deal selezionato
         datetime time  =(datetime)HistoryDealGetInteger(ticket,DEAL_TIME);
         string symbol=HistoryDealGetString(ticket,DEAL_SYMBOL);
         long entry =HistoryDealGetInteger(ticket,DEAL_ENTRY);
         long magic=HistoryDealGetInteger(ticket,DEAL_MAGIC);

         if(entry == DEAL_ENTRY_OUT && symbol== Mercato  && magic == Magico)
           {
            //Se il time del deal è minore al time del deal selezionato allora vuol dire che c'è un nuovo DEAL
            if(contatore_orario < time)
              {
               //Immagazziniamo il suo time e il suo ticket così possiamo ritornarlo alla fine se vogliamo
               contatore_orario = time;
               contatore_ticket = (int)ticket;
              }
           }
        }

     }

//Ci ritorna il ticket dell'ultimo DEAL di chiusura
   return contatore_ticket;
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
