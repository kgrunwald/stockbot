package main

import (
	"github.com/alpacahq/alpaca-trade-api-go/common"
	"github.com/kgrunwald/goweb/di"
	"github.com/kgrunwald/goweb/ilog"
	"github.com/kgrunwald/stockbot/server/brokerage"
)

func main() {
	di.GetContainer().Invoke(func(b brokerage.Brokerage, log ilog.Logger) {
		log.WithFields("apiKey", common.Credentials().ID, "secret", common.Credentials().Secret).Info("Alpaca creds")
		amt, err:= b.GetPreviousValue("TQQQ")
		if err != nil {
			log.WithFields("err", err.Error()).Info("error")
			return 
		}
		
		log.WithFields("amt", amt).Info("bars")
	})
}