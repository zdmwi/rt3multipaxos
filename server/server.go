package main

import (
	"flag"
	"sync"

	"github.com/ailidani/paxi"
	"github.com/ailidani/paxi/log"
	"zidanewright.me/rt3multipaxos/paxos"
)

var algorithm = flag.String("algorithm", "paxos", "Distributed algorithm")
var id = flag.String("id", "", "ID in format of Zone.Node.")
var simulation = flag.Bool("sim", false, "simulation mode")

var master = flag.String("master", "", "Master address.")

func replica(id paxi.ID) {
	if *master != "" {
		paxi.ConnectToMaster(*master, false, id)
	}

	log.Infof("node %v starting...", id)

	switch *algorithm {

	case "paxos":
		paxos.NewReplica(id).Run()

	default:
		panic("Unknown algorithm")
	}
}

func main() {
	paxi.Init()

	if *simulation {
		var wg sync.WaitGroup
		wg.Add(1)
		paxi.Simulation()
		for id := range paxi.GetConfig().Addrs {
			n := id
			go replica(n)
		}
		wg.Wait()
	} else {
		replica(paxi.ID(*id))
	}
}