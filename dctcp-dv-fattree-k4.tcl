
# read the command line arguments
set k 4 ;#k is for fat-tree
set KK 20 ;#KK is ECN ssthreshhold

set stoptime 1

set cwndInterval 0.001
 
set ns [new Simulator]

$ns rtproto DV
Agent/rtProto/DV set advertInterval  1000000

#Simulator set nix-routing 1
#$ns set-nix-routing

set enableNAM 1
set enableALL 1 

# set up tracing

if { $enableALL != 0 } {
   set tracefd  [open tcp-all.tr w]
   $ns trace-all $tracefd
}

if { $enableNAM != 0} {
  set namtrace [open out.nam w]   
  $ns namtrace-all $namtrace
}


set bw_ 1Gb
set pktsize 1460
set propagation_ 0.05ms
set qLimit 400  ;  #packets
Node set multiPath_ 1
set switchAlg RED
set sourceAlg DC-TCP-Sack

$ns color 0 Red
$ns color 1 Yellow
$ns color 2 Black
$ns color 3 Green
$ns color 4 Blue

set DCTCP_g_ 0.0625
set ackRatio 1 


Agent/TCP set ecn_ 1  ;#default 0
Agent/TCP set old_ecn_ 1
Agent/TCP set packetSize_ $pktsize
Agent/TCP/FullTcp set segsize_ $pktsize
Agent/TCP set window_ 20000
Agent/TCP set slow_start_restart_ false
Agent/TCP set tcpTick_ 0.01
Agent/TCP set minrto_ 0.2 ; # minRTO = 200ms
Agent/TCP set windowOption_ 0
Agent/TCPSink set ecn_syn_ true

if {[string compare $sourceAlg "DC-TCP-Sack"] == 0} {
    Agent/TCP set dctcp_ true    ;  #default false
    Agent/TCP set dctcp_g_ $DCTCP_g_;  #default dctcp_g_ 0.0625
}

Agent/TCP/FullTcp set segsperack_ $ackRatio; # ACK frequency
Agent/TCP/FullTcp set spa_thresh_ 3000;
Agent/TCP/FullTcp set interval_ 0.04 ; #delayed ACK interval = 40ms
Agent/TCP/FullTcp set ecn_syn_ true

Queue set limit_ 500

Queue/RED set bytes_ false
Queue/RED set queue_in_bytes_ false
Queue/RED set mean_pktsize_ $pktsize
Queue/RED set setbit_ true
Queue/RED set gentle_ false
Queue/RED set q_weight_ 1.0
Queue/RED set mark_p_ 1.0
Queue/RED set thresh_ [expr $KK]
Queue/RED set maxthresh_ [expr $KK]
			 
DelayLink set avoidReordering_ true

#cwndfile
for {set p 0} {$p < $k} {incr p} {
  for {set s 0} {$s < $k/2} {incr s} {
     for {set i 0} {$i < $k/2} {incr i} {
	set cwndfile($p,$s,$i) [open cwnd-($p,$s,$i).tr w]	
    }
  }
}

 
# loop variables: p: pod, s: switch, i: host
# generating hosts
for {set p 0} {$p < $k} {incr p} {
  for {set s 0} {$s < $k/2} {incr s} {
    for {set i 0} {$i < $k/2} {incr i} {
 
            set h($p,$s,$i) [$ns node]
}
} 
}
# generating edge switches (es)  level 1
for {set p 0} {$p < $k} {incr p} {
  for {set s 0} {$s < [expr $k/2]} {incr s} {
 
     set es($p,$s) [$ns node]
	 $es($p,$s) color green
     #$es($p,$s) qthreshold $high $low
 
}
}
# generating aggregation switches (as)  level 2
for {set p 0} {$p < $k} {incr p} {
  for {set s 0} {$s < $k/2} {incr s} {
 
        set as($p,$s) [$ns node]
		$as($p,$s) color red
        #$as($p,$s) qthreshold $high $low
} 
}
# generating core switches (cs)  level 3
for {set p 0} {$p < $k/2} {incr p} {
  for {set s 0} {$s < $k/2} {incr s} {
 
           set cs($p,$s) [$ns node]
		   $cs($p,$s) color blue
 
}
}
 

# generating links between hosts and es
for {set p 0} {$p < $k} {incr p} {
  for {set s 0} {$s < $k/2} {incr s} {
   for {set i 0} {$i < $k/2} {incr i} {
 
        $ns duplex-link $h($p,$s,$i) $es($p,$s) $bw_ $propagation_ $switchAlg
        $ns queue-limit $h($p,$s,$i) $es($p,$s) $qLimit
        $ns queue-limit $es($p,$s) $h($p,$s,$i) $qLimit
 
} 
}
}
# generating links between es and as
for {set p 0} {$p < $k} {incr p} {
  for {set s 0} {$s < $k/2} {incr s} {
   for {set i 0} {$i < $k/2} {incr i} {
 
        $ns duplex-link $es($p,$i) $as($p,$s) $bw_ $propagation_ $switchAlg
        $ns queue-limit $es($p,$i) $as($p,$s) $qLimit
        $ns queue-limit $as($p,$s) $es($p,$i) $qLimit
 
}
}
}
# generating links between as and cs
for {set p 0} {$p < $k} {incr p} {
  for {set s 0} {$s < $k/2} {incr s} {
    for {set c 0} {$c < $k/2} {incr c} {
 
        $ns duplex-link $as($p,$s) $cs($s,$c) $bw_ $propagation_ $switchAlg
        $ns queue-limit $as($p,$s) $cs($s,$c) $qLimit
        $ns queue-limit $cs($s,$c) $as($p,$s) $qLimit
}
}
}
 
 
# generating traffic
set fidnumber 0  ;#tcp id start from 0
for {set p 0} {$p < $k} {incr p } {
  for {set s 0} {$s < $k/2} {incr s} {
     for {set i 0} {$i < $k/2} {incr i} {
 
           if {[string compare $sourceAlg "Reno"] == 0 || [string compare $sourceAlg "DC-TCP-Reno"] == 0} {
	     set tcp($p,$s,$i) [new Agent/TCP/Reno]
	     set sink($p,$s,$i) [new Agent/TCPSink]
        }
       if {[string compare $sourceAlg "Sack"] == 0 || [string compare $sourceAlg "DC-TCP-Sack"] == 0} { 
         set tcp($p,$s,$i) [new Agent/TCP/FullTcp/Sack]
	     set sink($p,$s,$i) [new Agent/TCP/FullTcp/Sack]
	     $sink($p,$s,$i) listen
        }
			#set tcp($p,$s,$i) [new Agent/TCP/Linux]
			#$ns at 0 "$tcp($p,$s,$i) select_ca $flow_tcp"
			$tcp($p,$s,$i) set fid_ $fidnumber
			incr fidnumber
            $tcp($p,$s,$i) set packetSize_ $pktsize
            #set sink($p,$s,$i) [new Agent/TCPSink/Sack1]
            $ns attach-agent $h($p,$s,$i) $tcp($p,$s,$i)
            set q [ expr {($p+1) % $k } ]
            $ns attach-agent $h($q,$s,$i) $sink($p,$s,$i)
            $ns connect $tcp($p,$s,$i) $sink($p,$s,$i)
           # set ftp($p,$s,$i)  [new Application/Traffic/Pareto]
			 set ftp($p,$s,$i)  [new Application/FTP]
            $ftp($p,$s,$i) attach-agent $tcp($p,$s,$i)
			$ftp($p,$s,$i) set type_ FTP 
            $ftp($p,$s,$i) set packetSize_ $pktsize
            $ftp($p,$s,$i) set shape_ 1.5
 
           
	    $ns at 0.6 "$ftp($p,$s,$i) start"
            $ns at $stoptime "$ftp($p,$s,$i) stop"         
}     
}
} 

proc recordCwnd {} {

        global ns  tcp cwndfile cwndInterval k
        #Get an instance of the simulator
        set ns [Simulator instance]
        #Set the time after which the procedure should be called again    
        
        #Get the current time
        set now [$ns now]
        
        #Get the cwnd of tcp
	for {set p 0} {$p < $k} {incr p} {
      for {set s 0} {$s < $k/2} {incr s} {
        for {set i 0} {$i < $k/2} {incr i} {
		
        set cwnd($p,$s,$i) [$tcp($p,$s,$i) set cwnd_]
        puts $cwndfile($p,$s,$i) "$now $cwnd($p,$s,$i)"
		}
		}
		}
		                
        #Re-schedule the procedure
        $ns at [expr $now+$cwndInterval] "recordCwnd"
}

#record queue
set qfile1 [open queue1.tr w]
set qmon1 [$ns monitor-queue $cs(0,0) $as(0,0) $qfile1 0.001]
[$ns link $cs(0,0) $as(0,0)] queue-sample-timeout

set qfile2 [open queue2.tr w]
set qmon2 [$ns monitor-queue $cs(0,1) $as(0,0) $qfile2 0.001]
[$ns link $cs(0,1) $as(0,0)] queue-sample-timeout

set qfile3 [open queue3.tr w]
set qmon3 [$ns monitor-queue $cs(1,0) $as(0,1) $qfile3 0.001]
[$ns link $cs(1,0) $as(0,1)] queue-sample-timeout

set qfile4 [open queue4.tr w]
set qmon4 [$ns monitor-queue $cs(1,1) $as(0,1) $qfile4 0.001]
[$ns link $cs(1,1) $as(0,1)] queue-sample-timeout
 
proc stop {} {
 
    global ns enableNAM namtrace
       if {$enableNAM != 0} {
	    close $namtrace
	    exec nam out.nam &
		} 
    exit 0
}
 
$ns at 0.0001 "recordCwnd" 
$ns at $stoptime "stop"
$ns at $stoptime "puts \"NS EXITING...\" ; $ns halt"

 
puts "Starting Simulation..."
$ns run
