package brokerage

import (
	"github.com/kgrunwald/goweb/di"
	"github.com/shopspring/decimal"
)

type Brokerage interface {
	GetAccountBalance() (decimal.Decimal, error)
	GetPreviousValue(symbol string) (float32, error) 
}

func init() {
	c := di.GetContainer()
	c.Register(newAlpacaApi)
}