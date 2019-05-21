#create simulator
set ns [new Simulator]

#tracing simulator results
set tl4 [open l4.tr w]
$ns trace-all $tl4

#tracing NAM results
set nl4 [open l4.nam w]
$ns namtrace-all $nl4

#create 6 nodes
set n0 [$ns node]
set n1 [$ns node]

#connecting nodes
$ns duplex-link $n0 $n1 10Mb 22ms DropTail

#orientation
$ns duplex-link-op $n0 $n1 orient right

#create tcp agent
set tcp0 [new Agent/TCP]
$ns attach-agent $n0 $tcp0

#create tcp receiver
set tcp1 [new Agent/TCPSink]
$ns attach-agent $n1 $tcp1

#connect tcp agents
$ns connect $tcp0 $tcp1

#create ftp objects
set ftp [new Application/FTP]

#attach ftp with agent tcp0
$ftp attach-agent $tcp0

#to set packet size
$tcp0 set packetsize_ 1500

#schedule events for ftp
$ns at 0.2 "$ftp start"
$ns at 4.0 "$ftp stop"

#procedure finish
proc finish {} {
 global ns tl4 nl4
 $ns flush-trace
 close $tl4
 close $nl4
 exec nam l4.nam &
 exit 0
}

#schedule execution at procedure
$ns at 4.5 "finish"

#to run
$ns run

#awk script(awk -f l4awk.awk lr.tr)
BEGIN{
	ps=0;
	pr=0;
}

{
 if($3==0 && $1=="+" && $5=="tcp")
 {
  ps+=$6;
 }
 
 if($4==1 && $1=="r" && $5=="tcp")
 {
  pr+=$6;
 }
}

END{
	printf("Packets send: %fMb\n", (ps/1000000));
	printf("Packets received: %fMb\n", (pr/1000000));
}

#awk script for xgraph(awk -f l4awkforxgraph.awk lr.tr)
BEGIN{
	c=0;
	t=0;
}

{
 if($1=="r" && $4==1 $5=="tcp")
 {
  c+=$6;
  t=$2;
  printf("\n%f\t%f\n", t,(c/1000000));
 }
}

END{
}
