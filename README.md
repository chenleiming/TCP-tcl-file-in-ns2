# TCP-tcl-file-in-ns2 

#1、cubic-dv-fattree-k4.tcl 仿真TCP cubic，dv是ns2中的一种路由算法，可实现最短路径。文件中拓扑为k=4的fattree拓扑结构，16个主机既是数据发送端也是数据接收端，同时模拟16条一对一的TCP流，并记录cwnd和部分queue。变量ecn为1 时可实现ECN机制。

#2、dctcp-dv-fattree-k4.tcl 仿真DCTCP。
